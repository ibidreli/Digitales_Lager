//
//  ScanView.swift
//  Digitales_Lager
//
//  Created by Elias Pulver on 11.10.21.
//
import CodeScanner
import SwiftUI

struct ScanView: View {
    @State private var isShowingScanner = false
    @State var text = ""
    
    var body: some View {
        
        VStack {
            Text(text)
                .padding()
                .font(.system(size: 40))
        
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
        print(self.text)
        
    }
    
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        
        switch result {
        case .success(let code):
            self.text = code
                    
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


