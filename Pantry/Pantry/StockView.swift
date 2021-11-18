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
    let productGroup: String
}


struct StockView: View {
    private let database = Database.database().reference()
    @State var listProducts = [Products]()
    @State var produkt = ""


    var body: some View {
        VStack{
            Text(self.produkt)
        
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
            
        
    
        
    }
    private func delete(with indexSet: IndexSet) {
        
        indexSet.forEach({
            index in listProducts
            print("index::", index)
            print(listProducts)
            let productName = listProducts[index].productGroup
            let ref = database.database.reference().child("group/Elis House/products/" + productName)
            print(ref)
            ref.child("picture_path").removeValue()
            ref.child("product_name").removeValue()
        indexSet.forEach({index in listProducts.remove(at: index)})
            
        })
        
        
    }
    
   
    
    func getData(){
        let ref = database.child("group").child("Elis House").child("products")
        ref.child("number_of_products").getData(completion: {error, snapshot in guard
            error == nil else {
            print("error getting the numbers")
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
                                print("list" , listProducts)
                            }
                            
                            
                        }
                    
                    });
                    
                }
            }
            else {
                print("error")
            }
            
        });
    }
}

struct StockView_Previews: PreviewProvider {
    static var previews: some View {
        StockView()
    }
}
