//
//  HomeScreen.swift
//  ProTasker
//
//  Created by ARTEM on 23.05.2023.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

struct HomeScreen: View {
    //MARK: - Variables for showing screen
    @State var showNewProject = false
    @State var userName = "Friend"
    @State private var cancellable: AnyCancellable?
    
    //MARK: - Environmental firebase managers
    @EnvironmentObject var firestoreManger: FirestoreManager
    @ObservedObject var projectManager: ProjectManager
    
    
    var body: some View {
        NavigationStack{
            VStack{
                if !projectManager.projectList.isEmpty{
                    ScrollView {
                        LazyVStack {
                            ForEach(projectManager.projectList.indices, id: \.self) { proj_index in
                                let proj = projectManager.projectList[proj_index]
                                NavigationLink(
                                    destination: ProjectScreen(projectManager: projectManager, proj_index: proj_index)
                                                    .environmentObject(firestoreManger)
                                ) {
                                        projectRow(imageUrl: proj.image,
                                                   projectName: proj.name,
                                                   projectAuthor: proj.createdBy)
                                    }
                            }
                        }
                    }
                }
                else{
                    VStack{
                        Text("No projects exist")
                            .font(.custom("Apple SD Gothic Neo", size: 20))
                            .foregroundColor(.gray)
                    }
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddMainScreen(), label: {
                        Image(systemName: "equal.square.fill")
                            .font(.system(size: 35))
                    })
                }
                
                ToolbarItem(placement: .navigationBarLeading){
                    Text("Hello, \(firestoreManger.username)")
                        .font(.custom("Apple SD Gothic Neo", size: 25))
                        .bold(true)
                        .padding(.top, 15)
                }
                ToolbarItem(placement: .bottomBar) {
                            Spacer()
                }
                ToolbarItem(placement: .bottomBar){
                    Button(action: {
                        showNewProject.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                    })
                    .padding(.trailing, 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showNewProject){
                            NewProjectScreen()
                                .presentationDetents([.fraction(0.95)])
                                .environmentObject(projectManager)
                                .environmentObject(firestoreManger)
                        }
        }
        .onAppear(){
            self.firestoreManger.getUserdata()
            self.projectManager.getProjectdata()
        }
    }
    @ViewBuilder
    func projectRow(imageUrl: String, projectName: String, projectAuthor: String) -> some View{
        HStack{
            AsyncImage(url: URL(string: imageUrl)){ image in
                image.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 4)
            VStack{
                HStack{
                    Text(projectName)
                        .font(.custom("Apple SD Gothic Neo", size: 23))
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                }
                HStack{
                    Text("Created By \(projectAuthor)")
                        .font(.custom("Apple SD Gothic Neo", size: 20))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            Spacer()
        }
        .padding(15)
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
       HomeScreen(projectManager: ProjectManager())
    }
}
