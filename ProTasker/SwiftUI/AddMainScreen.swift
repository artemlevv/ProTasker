//
//  AddMainScreen.swift
//  ProTasker
//
//  Created by ARTEM on 26.05.2023.
//

import SwiftUI
import Firebase

struct AddMainScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var showProfileScreen = false
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    @ObservedObject var projectManager: ProjectManager
    
    
    var body: some View {
        NavigationStack{
            VStack{
                HStack {
                    AsyncImage(url: URL(string: firestoreManager.userPhoto)){ image in
                        image.image?
                            .resizable()
                            .scaledToFill()
                    }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 4)
                    Spacer()
                }
                .padding(.leading, 50)
                .padding(.top, 50)
                .padding(.bottom, 30)
                .background(.blue)
                HStack{
                    NavigationLink(destination: MyProfileScreen(projectManager: projectManager).environmentObject(firestoreManager), label: {
                        HStack{
                            Image(systemName: "person.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.blue)
                            Text("My profile")
                                .font(.custom("Apple SD Gothic Neo", size: 25))
                                .padding(.top, 15)
                                .padding(.leading, 14)
                                .foregroundColor(.blue)
                        }
                    })
                    Spacer()
                }
                .padding(.leading, 50)
                .padding(.top, 20)
                HStack{
                    NavigationLink(destination: MyCardsScreen(projectManager: projectManager).environmentObject(firestoreManager)
                        , label: {
                        HStack{
                            Image(systemName: "menucard.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.blue)
                            Text("My cards")
                                .font(.custom("Apple SD Gothic Neo", size: 25))
                                .padding(.top, 12)
                                .padding(.leading, 17)
                                .foregroundColor(.blue)
                        }
                    })
                    Spacer()
                }
                .padding(.leading, 50)
                HStack{
                    Button(action: {
                        withAnimation{
                            do {
                                try Auth.auth().signOut()
                            }
                            catch let signOutError as NSError {
                                print ("Error signing out: %@", signOutError)
                            }
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let initial = storyboard.instantiateViewController(identifier: "welcome_story")
                            UIApplication.shared.keyWindow?.rootViewController = initial
                        }
                        
                    }, label: {
                        HStack{
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                                .font(.system(size: 35))
                            Text("Sign out")
                                .font(.custom("Apple SD Gothic Neo", size: 25))
                                .padding(.top, 12)
                                .padding(.leading, 8)
                        }
                    })
                    Spacer()
                }
                .padding(.leading, 50)
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: CustomBackButton())
        }
    }
}

struct AddMainScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        AddMainScreen(projectManager: ProjectManager())
    }
}


struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            withAnimation{
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            Image(systemName: "arrow.left")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}
