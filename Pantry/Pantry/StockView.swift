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



struct Products: Identifiable {
    let id: Int
    
    let name: String
    let picture: URL
}


struct StockView: View {
    private let database = Database.database().reference()
    @State var listProducts = [Products]()

    var body: some View {
        List {
            ForEach(listProducts) {
                product in
                HStack {
                    Text(product.name)
                                        
                    WebImage(url: product.picture)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                }
            }.onDelete(perform: delete)

            }.onAppear {
                getData()
            }
            
        
    
        
    }
    private func delete(with indexSet: IndexSet) {
        indexSet.forEach({index in listProducts.remove(at: index)})
    }
    
    func deleteProduct(at offsets: IndexSet){
        print("deleteRow")
    }
    
    func getData(){
        print("Button clickt")
        let ref = database.child("group").child("Elis House").child("products")
        ref.child("number_of_products").getData(completion: {error, snapshot in guard
            error == nil else {
            print(error!.localizedDescription)
            return;
        }
            let json = snapshot.value as? NSInteger
            var number_of_products :Int = json!
            
            for number_of_product in 1...number_of_products {
                print(number_of_product)
                ref.child("product" + String(number_of_product)).getData(completion: {error, second_snapshot in guard
                    error == nil else {
                    print(error!.localizedDescription)
                    return;
                }
                    if let dictionary = second_snapshot.value as? NSDictionary {
                        let picturePath = dictionary["picture_path"] as? String
                        let productName = dictionary["product_name"] as? String
                        print(picturePath!)
                        print(productName!)
                        
                        let storageRef = Storage.storage().reference(withPath: picturePath!)
                        
                        storageRef.downloadURL { (url, error) in
                            if error != nil {
                                print((error?.localizedDescription)!)
                                return
                            }
                            
                            
                            if !listProducts.contains(where: {product in product.id == number_of_product}) {
                                listProducts.append(Products(id: number_of_product, name: productName!, picture: url!))
                            }
                        }
                        
                        
                    }
                print(listProducts)
                });
                
            }
        });
    }
}

struct StockView_Previews: PreviewProvider {
    static var previews: some View {
        StockView()
    }
}
