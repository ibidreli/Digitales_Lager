//
//  StockView.swift
//  Digitales_Lager
//
//  Created by Elias Pulver on 11.10.21.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage
import SDWebImageSwiftUI
import FirebaseAuth




struct Products: Identifiable {
    let id: Int
    
    let name: String
    let picture: URL
    let productGroup: String
}


struct StockView: View {
    private let database = Database.database().reference()
    @State var listProducts = [Products]()
    @State var produkt = ""
    @State var email = ""
    @State var groupName = ""
    
    


    var body: some View {
        VStack{
            Text("Dein Lager").font(.system(size: 30).bold()).frame(alignment: .topLeading).foregroundColor(Color("ButtonColor"))
                
            VStack{
                Text(self.produkt)
            
                List {
                    ForEach(listProducts) {
                        product in
                        HStack {
                            Text(product.name)
                            
                            Spacer()
                                                
                            WebImage(url: product.picture)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                        }
                    }.onDelete(perform: delete)

                    }.onAppear {
                        getData()
                    }
                    

            }
            
        }
    }
    
    
    private func delete(with indexSet: IndexSet) {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        if let user = user {
                email = user.email!
        }
        let new_email = self.email
        let new_email_corrected = new_email.replacingOccurrences(of: ".", with: ",")
        
        print("new email", new_email_corrected)
        
        ref.child("users").child(new_email_corrected).getData(completion: {error, snapshot in guard error == nil else {
            print(error!.localizedDescription)
            return;
            }
            let groupName = snapshot.value as? String ?? "Unknow";
            self.groupName = groupName
            print(groupName)
            indexSet.forEach({
                index in listProducts
                let productName = listProducts[index].productGroup
                let ref = database.database.reference().child("group/").child(groupName).child("/products/" + productName)
                ref.child("picture_path").removeValue()
                ref.child("product_name").removeValue()
            indexSet.forEach({index in listProducts.remove(at: index)})
            })
            
        });
        
    
    }
    
    
    func getData(){
        listProducts.removeAll()
        var ref1: DatabaseReference!
        ref1 = Database.database().reference()
        
        let user = Auth.auth().currentUser
        if let user = user {
                email = user.email!
        }
        let new_email = self.email
        let new_email_corrected = new_email.replacingOccurrences(of: ".", with: ",")
        
        ref1.child("users").child(new_email_corrected).getData(completion: {error, snapshot in guard error == nil else {
            print(error!.localizedDescription)
            return;
            }
            let groupName = snapshot.value as? String ?? "Unknow";
            self.groupName = groupName
            
            let ref = database.child("group").child(groupName).child("products")
            ref.child("number_of_products").getData(completion: {error, snapshot in guard
                error == nil else {
                return;
            }
                let json = snapshot.value as? NSInteger
                if json != nil{
                    
                    
                    var number_of_products :Int = json!
                    for number_of_product in 1...number_of_products {
                        ref.child("product" + String(number_of_product)).getData(completion: {error, second_snapshot in guard
                            error == nil else {
                            print("error getting data of specific product")
                            return;
                        }
                            if let dictionary = second_snapshot.value as? NSDictionary {
                                let picturePath = dictionary["picture_path"] as? String
                                let productName = dictionary["product_name"] as? String
                                
                                
                                let storageRef = Storage.storage().reference(withPath: picturePath!)
                                
                                storageRef.downloadURL { (url, error) in
                                    if error != nil {
                                        print((error?.localizedDescription)!)
                                        return
                                    }
                                    

                                    if !listProducts.contains(where: {product in product.productGroup == "product" + String(number_of_product)}) {
                                        listProducts.append(Products(id: number_of_product, name: productName!, picture: url!, productGroup: "product" + String(number_of_product)))
                                    }
                                }
                            }
                        });
                    }
                }
                else {
                    print("error")
                }
                
            });
        });
        
    }
}

struct StockView_Previews: PreviewProvider {
    static var previews: some View {
        StockView()
    }
}
