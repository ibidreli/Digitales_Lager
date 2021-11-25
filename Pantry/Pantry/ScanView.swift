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
    @State var isScanning = false
    @State var flag = false
    @State var result = ""
    @State var produkt = ""
    
    @State var groupName = ""
    @State private var imageURL = URL(string: "")
    
    var body: some View {
        
        VStack() {
            Text("Produkte Scannen").font(.system(size: 30).bold()).frame(alignment: .topLeading).foregroundColor(Color("ButtonColor"))
                .padding(.bottom,70)
                
                
            
            WebImage(url: imageURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 320)
                .onAppear {
                    getPicture()
                }
                
                
            
            Text(produkt)
                .padding(.bottom, 100)
                .font(.system(size: 25))
                .frame(height: 30)
                .padding(.top, 60)
                .padding(.bottom, 40)

        
            Button(action: {
                self.isShowingScanner = true
                
            }, label: {
                Text("Produkt Scannen")
                    .foregroundColor(Color.white)
                    .frame(width: 230, height: 50)
                    .background(Color("ButtonColor"))
                    .cornerRadius(8)
                    .padding(.bottom, 40)
            })
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.ean13, .ean8], completion: self.handleScan)
            }
        }
    }
    
    func getPicture(){
        if(self.imageURL == URL(string: "") && self.isScanning == false){
            let storageRef = Storage.storage().reference(withPath: "A_no_product" + ".png")
            
            storageRef.downloadURL { (url, error) in
                if error != nil {
                    print((error?.localizedDescription)!)
                    return
                }
                
                    self.imageURL = url!
            }
        }
    }
    
    
    func searchAfterNumber(){
        self.imageURL = URL(string: "")
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        if let user = user {
                email = user.email!
        }
        let new_email = self.email
        let new_email_corrected = new_email.replacingOccurrences(of: ".", with: ",")
        
        ref.child("users").child(new_email_corrected).getData(completion: {error, snapshot in guard error == nil else {
            print(error!.localizedDescription)
            return;
            }
            let groupName = snapshot.value as? String ?? "Unknow";
            self.groupName = groupName
        });
        
        let Gtin_Array = ["Gtin_A"]
        
        let questionPostsRef = ref.child("gtin")
        self.flag = false
        for item in Gtin_Array{
            if(self.flag == false){
                print(item)
  
                let query1 = questionPostsRef.queryOrdered(byChild: item).queryEqual(toValue: self.text)

                let start = DispatchTime.now()
                query1.observeSingleEvent(of: .value, with: {
                    snapshot in
                    for child in snapshot.children {
                        let end = DispatchTime.now()

                        let childSnap = child as! DataSnapshot
                        let dict = childSnap.value as! [String: Any]
                        let cat = dict["Produkt"] as! String
                        let picture = dict["Picture-Name"] as! String
                        self.flag = true

                        
                        print(cat)
                        if(cat != ""){
                        
                            
                            let storageRef = Storage.storage().reference(withPath: picture + ".png")
                            
                            storageRef.downloadURL { (url, error) in
                                if error != nil {
                                    print((error?.localizedDescription)!)
                                    return
                                }
                                
                                    self.imageURL = url!
                            }
                            
                            let nano_time = end.uptimeNanoseconds - start.uptimeNanoseconds
                            let timeInterval = Double(nano_time) / 1_000_000
                            print(timeInterval)
                            
                            database.child("group").child(self.groupName).observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                if snapshot.hasChild("products") {
                                    let new_database = Database.database().reference()
                                    new_database.child("group").child(self.groupName).child("products").child("number_of_products").getData(completion: {error, snapshot in guard error == nil else {
                                            print(error!.localizedDescription)
                                            return;
                                        }
                                        var number_of_products:Int = snapshot.value! as! Int
                                        number_of_products = number_of_products + 1
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
                    }
                })
            }
        }
        if(self.produkt == "" && self.flag == false){
            let storageRef = Storage.storage().reference(withPath: "A_no_product_found" + ".png")
            
            storageRef.downloadURL { (url, error) in
                if error != nil {
                    print((error?.localizedDescription)!)
                    return
                }
                
                    self.imageURL = url!
            }
        }
    }
    
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.produkt = ""
        self.imageURL = URL(string: "")
        self.isScanning = true
        
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


