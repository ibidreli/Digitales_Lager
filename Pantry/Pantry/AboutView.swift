//
//  AboutView.swift
//  Digitales_Lager
//
//  Created by Elias Pulver on 11.10.21.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase

class AboutViewModel: ObservableObject {
    
    let auth = Auth.auth()
    
    @Published var signedIn = true
    
    func signOut(){
        try? auth.signOut()
        
        self.signedIn = false
        print("SignOut2")
    }
    
    func deleteAccount(){
        auth.currentUser?.delete()
        
        self.signedIn = false
        print("DeleteAccount2")
    }
}

struct AboutView: View {
    @State var actGroupName = ""
    @State var email = "Elias"
    let instanceContentView = AppViewModel()
    var body: some View {
        VStack {
            Text(self.actGroupName).font(.system(size: 30).bold()).frame(alignment: .topLeading).foregroundColor(Color("ButtonColor"))
                .padding(.bottom,140)
                .onAppear {
                    getData()
                }
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            NavigationLink("Haushalt wechseln", destination: HouseholdChangeView())
                .padding()
                .foregroundColor(Color.white)
                .frame(width: 230, height: 50)
                .background(Color("ButtonColor"))
                .cornerRadius(8)
            
            Button(action: {instanceContentView.signOut()}, label: {
                Text("Abmelden")
                    .padding()
                    .foregroundColor(Color.white)
                    .frame(width: 230, height: 50)
                    .background(Color("ButtonColor"))
                    .cornerRadius(8)
            })
        
            
            Button(action: {instanceContentView.deleteAccount()}, label: {
                Text("Konto löschen")
                    .padding()
                    .foregroundColor(Color.white)
                    .frame(width: 230, height: 50)
                    .background(Color("ButtonColor"))
                    .cornerRadius(8)
            })
        }
    }
    func getData() {
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
            self.actGroupName = groupName
        });
    }
}




struct HouseholdChangeView: View {
    @State var household = ""
    @State var error = ""
    @State var email = ""
    @State var groupName = ""

    var body: some View {
        VStack {
            
            
            Text("Haushalt wechseln")
            .font(.system(size: 30).bold())
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            VStack {
                TextField("Haushalt", text: $household)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                
                Text(self.error)
                    .foregroundColor(.red)
                    .padding()
                
                Button(action: {
                    guard !household.isEmpty else {
                        self.error = "Bitte geben sie einen Haushalt ein!"
                        return
                    }

                    ChangeHousehold(household: household)
                    
                }, label: {
                    Text("Haushalt wechseln")
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
    func ChangeHousehold(household :String){
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
            
            Database.database().reference().child("users").child(new_email_corrected).setValue(household)
            
            let database = Database.database().reference()
            
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
            self.error = "Haushalt gewechselt!"
            
        });
    }
}






struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
