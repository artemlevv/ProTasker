//
//  MyCardsScreen.swift
//  ProTasker
//
//  Created by ARTEM on 08.06.2023.
//

import SwiftUI
import Firebase

struct MyCardsScreen: View {
    @ObservedObject var projectManager: ProjectManager
    @EnvironmentObject var firestoreManger: FirestoreManager
    @Environment(\.colorScheme) var colorScheme
    let useUid = Auth.auth().currentUser?.uid
    
    @State var cards: [Card] = []
    @State var delete: Bool = false

    var body: some View {
        NavigationStack{
            VStack{
                if !projectManager.projectList.isEmpty{
                    ScrollView {
                        LazyVStack {
                            ForEach(projectManager.projectList.indices, id: \.self) {
                                proj_index in
                                ForEach(projectManager.projectList[proj_index].taskList.indices, id: \.self){
                                    list_index in
                                    ForEach(projectManager.projectList[proj_index].taskList[list_index].cards.indices, id: \.self){
                                        card_index in
                                        if projectManager.projectList[proj_index].taskList[list_index].cards[card_index].assignedTo.contains(self.useUid ?? ""){
                                            NavigationLink(
                                                destination: CardDetailScreen(projectManager: projectManager, proj_index: proj_index, taskIndex: list_index, cardIndex: card_index, cards: $cards, deleteCard: $delete)
                                                    .environmentObject(firestoreManger)
                                            ) {
                                                let projName = projectManager.projectList[proj_index].name
                                                let cardName = projectManager.projectList[proj_index].taskList[list_index].cards[card_index].name
                                                VStack{
                                                    TaskView(projectManager: projectManager, proj_index: proj_index, taskIndex: list_index, cardIndex: card_index)
                                                        .environmentObject(firestoreManger)
                                                    HStack{
                                                        Text("\(cardName) is from project \(projName)")
                                                            .foregroundColor(.gray)
                                                        Spacer()
                                                    }
                                                    .padding(.top, 8)
                                                    .padding(.bottom, 8)
                                                }
                                                .padding(8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else{
                    VStack{
                        Text("No cards exist")
                            .font(.custom("Apple SD Gothic Neo", size: 20))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .background(colorScheme == .dark ? Color.clear: Color.backListTask)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
        .toolbar{
            ToolbarItem(placement: .principal) {
                
                Text("My Cards")
                    .font(.custom("Apple SD Gothic Neo", size: 21))
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .onAppear(){
            for pro_index in 0..<projectManager.projectList.count{
                for list_index in 0..<projectManager.projectList[pro_index].taskList.count{
                    for card_index in 0..<projectManager.projectList[pro_index].taskList[list_index].cards.count{
                        if projectManager.projectList[pro_index].taskList[list_index].cards[card_index].assignedTo.contains(self.useUid ?? ""){
                            self.cards.append(projectManager.projectList[pro_index].taskList[list_index].cards[card_index])
                        }
                    }
                }
            }
        }
    }
}

struct MyCardsScreen_Previews: PreviewProvider {
    static var previews: some View {
        MyCardsScreen(projectManager: ProjectManager())
    }
}
