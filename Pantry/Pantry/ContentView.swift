//
//  ContentView.swift
//  Digitales_Lager
//
//  Created by Elias Pulver on 23.09.21.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

class AppViewModel: ObservableObject {
    
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password:  password) { [weak self]            result, error in
            guard result != nil, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
            }
            
        }
    }
    
    func signUp(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { [weak self]                            result, error in
            guard result != nil, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        
        }
    
    }
    
    func resetEmail(resetEmail: String) {
        Auth.auth().sendPasswordReset(withEmail: resetEmail)
    }
        
        
    
    func signOut(){
        try? auth.signOut()
        
        self.signedIn = false
        
    }
    
    func deleteAccount(){
        auth.currentUser?.delete()
        
        self.signedIn = false
    }
    
    
}



struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
   
    
    var body: some View {
        NavigationView {
            if viewModel.signedIn {
                TabView {
                    StockView()
                        .tabItem {
                            Image(systemName: "bag")
                            Text("Lager")
                        }
                    ScanView()
                        .tabItem {
                            Image(systemName: "barcode.viewfinder")
                            Text("Scan")
                        }
                    AboutView()
                        .tabItem {
                            Image(systemName: "info.circle")
                            Text("About")
                        }
                }
            }
            else {
                SignInView()
            }
        }
        .onAppear {
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}
  

    
struct SignInView: View {
    @State var email = ""
    @State var password = ""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                VStack{
                    TextField("Email Address", text: $email)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        
                    SecureField("Password", text: $password)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    
                    Button(action: {
                        
                        guard !email.isEmpty, !password.isEmpty else {
                            return
                        }
                        viewModel.signIn(email: email, password: password)
                        
                    }, label: {
                        Text("Sign In")
                            .foregroundColor(Color.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(8)
                    } )
                    
                
                    
                    NavigationLink("Create Account", destination: SignUpView())
                        .padding()
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50)
                        .background(Color.gray)
                        .cornerRadius(8)
                    
                    NavigationLink("Reset Password", destination: PasswordResetView())
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50)
                        .background(Color.gray)
                        .cornerRadius(8)
                    
                    
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Sign In")

        }
}


struct SignUpView: View {
    @State var email = ""
    @State var password = ""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                VStack{
                    TextField("Email Address", text: $email)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        
                    SecureField("Password", text: $password)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    
                    Button(action: {
                        
                        guard !email.isEmpty, !password.isEmpty else {
                            return
                        }
                        viewModel.signUp(email: email, password: password)
                        
                    }, label: {
                        Text("Create Account")
                            .foregroundColor(Color.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(8)
                    } )
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Create Account")

        }
}

struct PasswordResetView: View {
    @State var resetEmail = ""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                VStack{
                    TextField("Email Address", text: $resetEmail)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        
                    
                    Button(action: {
                        
                        guard !resetEmail.isEmpty else {
                            return
                        }
                        viewModel.resetEmail(resetEmail: resetEmail)
                        
                    }, label: {
                        Text("Reset Password")
                            .foregroundColor(Color.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(8)
                    } )
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Reset Password")

        }
}
    
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

