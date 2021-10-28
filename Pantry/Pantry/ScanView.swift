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
    @State private var isShowingScanner = false
    @State var text = ""
    @State var produkt = ""
    @State private var imageURL = URL(string: "")
    
    
    var body: some View {
        
        VStack {
            WebImage(url: imageURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text(text)
                .padding()
                .font(.system(size: 20))
            
            Text(produkt)
                .padding()
                .font(.system(size: 20))
        
            Button(action: {
                self.isShowingScanner = true
                
                
            }, label: {
                Text("Scan")
                    .foregroundColor(Color.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(8)
            } )
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.ean13, .ean8], completion: self.handleScan)
            
            }
            
            Button(action: {
                searchAfterNumber()
                
                
            }, label: {
                Text("Search")
                    .padding()
                    .foregroundColor(Color.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(8)
            } )
            
            
        }
    }
    
    func searchAfterNumber(){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        
        let questionPostsRef = ref.child("gtin")
        let query = questionPostsRef.queryOrdered(byChild: "Gtin_A").queryEqual(toValue: self.text)
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            for child in snapshot.children {
                let childSnap = child as! DataSnapshot
                let dict = childSnap.value as! [String: Any]
                let cat = dict["Produkt"] as! String
                let picture = dict["Picture-Name"] as! String
                
                
                self.produkt = cat
            }
        })
        let storageRef = Storage.storage().reference(withPath: "screen1.png")
        
        storageRef.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                
                return
            }
            
                self.imageURL = url!
        }
        
        
    }
    
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        
        switch result {
        case .success(let code):
            self.text = code
            searchAfterNumber()
                    
        case .failure(let error):
            print("Scanning failed")
            
        }
    }
}


struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        StockView()
    }
}


