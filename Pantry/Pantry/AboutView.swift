//
//  AboutView.swift
//  Digitales_Lager
//
//  Created by Elias Pulver on 11.10.21.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

class AboutViewModel: ObservableObject {
    
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    func signOut(){
        try? auth.signOut()
        
        self.signedIn = false
    }
    
    func deleteAccount(){
        auth.currentUser?.delete()
        
        self.signedIn = false
    }
}

struct AboutView: View {
    let instanceContentView = AppViewModel()
    var body: some View {
        VStack {
            Text("About Views")
            
            Button(action: {instanceContentView.signOut()}, label: {
                Text("Sign Out")
                    .padding()
                    .foregroundColor(Color.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(8)
            })
        
            
            Button(action: {instanceContentView.deleteAccount()}, label: {
                Text("Delete Account")
                    .padding()
                    .foregroundColor(Color.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(8)
            })
            
            
            
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
