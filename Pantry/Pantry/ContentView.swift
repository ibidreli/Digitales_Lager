//
//  ContentView.swift
//  Digitales_Lager
//
//  Created by Elias Pulver on 23.09.21.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class AppViewModel: ObservableObject {
    
    private let database = Database.database().reference()
    
    
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    init() {
        authStateHandle = auth.addStateDidChangeListener({ _, user in self.signedIn = user != nil})
    }
    
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
    
    
    func signUp(email: String, household: String, password: String) {
        auth.createUser(withEmail: email, password: password) { [weak self]                            result, error in
            guard result != nil, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
        let new_email = email
        let new_email_corrected = new_email.replacingOccurrences(of: ".", with: ",")
        
        database.child("users").child(new_email_corrected).setValue(household)
        
        let reference_of_data = database.child("group").child(household).child("members")
        
        database.child("group").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(household) {
                let new_database = Database.database().reference()
                print("the room exists")
                new_database.child("group").child(household).child("members").child("number_of_users").getData(completion: {error, snapshot in guard error == nil else {
                        print(error!.localizedDescription)
                        return;
                    }
                    
                    var number_of_users:Int = snapshot.value! as! Int
                    number_of_users = number_of_users + 1
                    print("number", number_of_users)
                    reference_of_data.child("number_of_users").setValue(number_of_users)
                    reference_of_data.child("user" + String(number_of_users)).setValue(email)
                    
                });
            }
            else {
                reference_of_data.child("number_of_users").setValue(1)
                reference_of_data.child("user1").setValue(email)
            }
        })
    }
    
    
    func resetEmail(resetEmail: String) {
        Auth.auth().sendPasswordReset(withEmail: resetEmail)
    }
        
        
    func signOut(){
        try? auth.signOut()
        print("signOut")
    }
    
    
    func deleteAccount(){
        auth.currentUser?.delete()
        print("deleteAccount")
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
                            Text("Scannen")
                        }
                    AboutView()
                        .tabItem {
                            Image(systemName: "info.circle")
                            Text("Profil")
                        }
                }.accentColor(Color("ButtonColor"))
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
    @State var error = ""
    
    
    @EnvironmentObject var viewModel: AppViewModel
    
    
    var body: some View {
        VStack {
                Text("Wilkommen bei Pantry")
                .font(.system(size: 30).bold())
            
                Text("Dein digitales Lebensmittellager")
            
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                VStack{
                    TextField("Email Adresse", text: $email)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        
                    SecureField("Passwort", text: $password)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    
                    Text(self.error)
                        .foregroundColor(.red)
                        .padding()
                    
                    Button(action: {
                        guard !email.isEmpty else {
                            self.error = "Bitte geben sie eine Email Adresse ein!"
                            return
                        }
                        
                        guard !password.isEmpty else {
                            self.error = "Bitte geben sie ein Passwort ein!"
                            return
                        }
                        viewModel.signIn(email: email, password: password)
                        
                    }, label: {
                        Text("Anmelden")
                            .foregroundColor(Color.white)
                            .frame(width: 230, height: 50)
                            .background(Color("ButtonColor"))
                            .cornerRadius(8)
                    } )
                    
                    NavigationLink("Registrieren", destination: SignUpView())
                        .padding()
                        .foregroundColor(Color.white)
                        .frame(width: 230, height: 50)
                        .background(Color.gray)
                        .cornerRadius(8)
                    
                    NavigationLink("Passwort Zurücksetzen", destination: PasswordResetView())
                        .foregroundColor(Color.white)
                        .frame(width: 230, height: 50)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
            }
        }
}


struct SignUpView: View {
    @State var email = ""
    @State var password = ""
    @State var household = ""
    @State var error = ""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        
            VStack {
                Text("Registrieren")
                .font(.system(size: 30).bold())
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                VStack{
                    TextField("Email Adresse", text: $email)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    
                    TextField("Haushalt", text: $household)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        
                    SecureField("Passwort", text: $password)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    
                    Text(self.error)
                        .foregroundColor(.red)
                        .padding()
                    
                    Button(action: {
                        guard !email.isEmpty else {
                            self.error = "Bitte geben sie eine Email Adresse ein!"
                            return
                        }
                        guard !household.isEmpty else {
                            self.error = "Bitte geben sie ein Haushalt Name ein!"
                            return
                        }
                        guard !password.isEmpty else {
                            self.error = "Bitte geben sie ein Passwort ein!"
                            return
                        }
                        viewModel.signUp(email: email, household: household, password: password)
                        
                    }, label: {
                        Text("Registrieren")
                            .foregroundColor(Color.white)
                            .frame(width: 200, height: 50)
                            .background(Color("ButtonColor"))
                            .cornerRadius(8)
                    } )
                }
                .padding()
                
                Spacer()
            }
            

        }
}

struct PasswordResetView: View {
    @State var resetEmail = ""
    @State var error = ""
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        
            VStack {

                Text("Passwort zurücksetzen")
                .font(.system(size: 30).bold())
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                VStack{
                    TextField("Email Adresse", text: $resetEmail)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        
                    Text(self.error)
                        .foregroundColor(.red)
                        .padding()
                    
                    Button(action: {
                        
                        guard !resetEmail.isEmpty else {
                            self.error = "Bitte geben sie eine Email Adresse ein!"
                            return
                        }
                        viewModel.resetEmail(resetEmail: resetEmail)
                        
                    }, label: {
                        Text("Passwort zurücksetzten")
                            .foregroundColor(Color.white)
                            .frame(width: 230, height: 50)
                            .background(Color("ButtonColor"))
                            .cornerRadius(8)
                    } )
                }
                .padding()
                Spacer()
                    
            }
        }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

