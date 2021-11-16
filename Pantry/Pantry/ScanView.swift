//
//  ScanView.swift
//  Digitales_Lager
//
//  Created by Elias Pulver on 11.10.21.
//
import CodeScanner
import Firebase
import SwiftUI
import FirebaseDatabase
import FirebaseStorage
import SDWebImageSwiftUI

struct ScanView: View {
    private let database = Database.database().reference()
    
    @State var email = ""
    @State private var isShowingScanner = false
    @State var text = ""
    
    @State var result = ""
    @State var produkt = ""
    @State var groupName = ""
    @State private var imageURL = URL(string: "")
    
    var body: some View {
        
        VStack {
            WebImage(url: imageURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250)
            
            Text(produkt)
                .padding()
                .font(.system(size: 20))
        
            Button(action: {
                self.isShowingScanner = true
                
            }, label: {
                Text("Scan")
                    .foregroundColor(Color.white)
                    .frame(width: 200, height: 50)
                    .background(Color("ButtonColor"))
                    .cornerRadius(8)
            })
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.ean13, .ean8], completion: self.handleScan)
            }
        }
    }
    
    
    func searchAfterNumber(){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        if let user = user {
                email = user.email!
        }
        print("email: " + self.email)
        let new_email = self.email
        let new_email_corrected = new_email.replacingOccurrences(of: ".", with: ",")
        
        ref.child("users").child(new_email_corrected).getData(completion: {error, snapshot in guard error == nil else {
            print(error!.localizedDescription)
            return;
            }
            let groupName = snapshot.value as? String ?? "Unknow";
            self.groupName = groupName
            print("groupname", self.groupName)
        });
        
        
        let questionPostsRef = ref.child("gtin")
        let query = questionPostsRef.queryOrdered(byChild: "Gtin_A").queryEqual(toValue: self.text)
        print("text" + self.text)
        print(type(of: self.text))
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                let dict = childSnap.value as! [String: Any]
                let cat = dict["Produkt"] as! String
                let picture = dict["Picture-Name"] as! String
                
                let storageRef = Storage.storage().reference(withPath: picture + ".png")
                
                storageRef.downloadURL { (url, error) in
                    if error != nil {
                        print((error?.localizedDescription)!)
                        return
                    }
                    
                        self.imageURL = url!
                }
                
                database.child("group").child(self.groupName).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.hasChild("products") {
                        let new_database = Database.database().reference()
                        new_database.child("group").child(self.groupName).child("products").child("number_of_products").getData(completion: {error, snapshot in guard error == nil else {
                                print(error!.localizedDescription)
                                return;
                            }
                            var number_of_products:Int = snapshot.value! as! Int
                            number_of_products = number_of_products + 1
                            print("number", number_of_products)
                            database.child("group").child(self.groupName).child("products").child("number_of_products").setValue(number_of_products)
                            let reference_of_data = database.child("group").child(self.groupName).child("products").child("product" + String(number_of_products))
                            
                            reference_of_data.child("product_name").setValue(cat)
                            reference_of_data.child("picture_path").setValue(picture + ".png")
                        });
                    }
                    else {
                        database.child("group").child(self.groupName).child("products").child("number_of_products").setValue(1)
                        let reference_of_data = database.child("group").child(self.groupName).child("products").child("product1")
                        reference_of_data.child("product_name").setValue(cat)
                        
                        reference_of_data.child("picture_path").setValue(picture + ".png")
                    }
                })
                self.produkt = cat
            }
        })
    }
    
    
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        
        self.isShowingScanner = false
        
        switch result {
            case .success(let code):
                self.text = code
                searchAfterNumber()
                
            
                        
            case .failure(let error):
                print("Scanning failed")
                
                self.isShowingScanner = true
            
        }
        
    }
}


struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        StockView()
    }
}


