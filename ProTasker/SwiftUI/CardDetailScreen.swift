//
//  CardDetailScreen.swift
//  ProTasker
//
//  Created by ARTEM on 05.06.2023.
//

import SwiftUI

struct CardDetailScreen: View {
    @ObservedObject var projectManager: ProjectManager
    @EnvironmentObject var firestoreManger: FirestoreManager
    @State var proj_index: Int
    @State var taskIndex: Int
    @State var cardIndex: Int
    
    @State var cardName: String = ""
    
    @State private var selectedColor = Color.white

    let colors: [Color] = [.white, .green, .blue, .red]
    
    //MARK: - Timer for updating firebase
    @State var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var showListUsers = false
    
    //MARK: - Alert bools
    @State var showChangeCardError = false
    @State var successUpdate = false
    var body: some View {
        VStack{
            HStack{
                Text("Card Name")
                    .font(.custom("Apple SD Gothic Neo", size: 18))
                    .bold()
                Spacer()
            }
            .padding(.leading, 20)
            
            TextField("Enter cardName", text: $cardName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            VStack{
                HStack{
                    Text("Added Users")
                        .font(.custom("Apple SD Gothic Neo", size: 18))
                        .bold()
                        .padding(.leading, 25)
                    
                    Spacer()
                    Button(action: {
                        showListUsers.toggle()
                    }, label: {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                    })
                    .padding(.trailing, 25)
                }
                HStack{
                        ScrollView(.horizontal){
                            LazyHStack{
                                ForEach(projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].assignedTo, id: \.self) { user_id in
                                    var us =  firestoreManger.userList.filter({$0.id == user_id})
                                    AsyncImage(url: URL(string: us[0].image)){ image in
                                        image.image?
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    }
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 4)
                                        .padding(.trailing, 12)
                                        .padding(.leading, 3)
                                }
                            }
                        }
                }
                .frame(height: 100)
                .padding(.leading, 20)
                
            }
            VStack{
                HStack{
                    Text("Select Color")
                        .font(.custom("Apple SD Gothic Neo", size: 18))
                        .bold()
                        .padding(.leading, 25)
                    Spacer()
                    Capsule()
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(.gray, lineWidth: 1.5)
                        )
                        .foregroundColor(selectedColor)
                        .frame(width: 90, height: 40)
                        .padding(.trailing, 25)
                }
                ScrollView(.horizontal){
                    HStack{
                        ForEach(colors, id: \.self){ color in
                            Circle()
                                .foregroundColor(color)
                                .frame(width: 45, height: 45)
                                .opacity(color == selectedColor ? 0.5 : 1.0)
                                .scaleEffect(color == selectedColor ? 1.1 : 1.0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(.gray, lineWidth: 1.5)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                            
                        }
                    }
                    .frame(height: 70)
                    .padding(.leading, 8)
                }
                .frame(height: 70)
                .padding(.leading, 20)
            }
            HStack{
                Button(action: {
                    if !cardName.isEmpty{
                        projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].name = cardName
                        let ch_color = selectedColor.toHex() as? String ?? ""
                        print(ch_color)
                        self.projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].color = ch_color
                        self.projectManager.updateProject(project: projectManager.projectList[proj_index])
                        successUpdate.toggle()
                    }
                    else{
                        showChangeCardError.toggle()
                    }
                }) {
                    Text("Update")
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                        .padding()
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .alert(isPresented: $showChangeCardError){
                Alert(
                    title: Text("Empty name"),
                    message: Text("Please fill the card name"),
                    dismissButton: .default(Text("Ok"))
                )
            }
            .alert(isPresented: $successUpdate){
                Alert(
                    title: Text("Succes Update"),
                    message: Text("Card data has been successfully updated"),
                    dismissButton: .default(Text("Ok"))
                )
            }
            Spacer()
            
        }
        .padding(.top, 20)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
        .onAppear(){
            self.cardName = self.projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].name
            self.selectedColor = Color.init(hex: self.projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].color) ?? Color.white
        }
        .onReceive(timer) { input in
            self.projectManager.updateProject(project: projectManager.projectList[proj_index])
            firestoreManger.getAllUsersdata()
        }
        .sheet(isPresented: $showListUsers){
            VStack{
                Text("Select users")
                    .padding(.top, 30)
                    .font(.custom("Apple SD Gothic Neo", size: 21))
                    .bold()
            List {
                ForEach(projectManager.projectList[proj_index].asignedTo, id: \.self) { user_id in
                    var us =  firestoreManger.userList.filter({$0.id == user_id})
                    MultipleSelectionRow(user: us[0], isSelected:
                                            self.projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].assignedTo.contains(user_id)){
                        if self.projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].assignedTo.contains(user_id) {
                            self.projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].assignedTo.removeAll(where: { $0 == user_id })
                            self.projectManager.updateProject(project: projectManager.projectList[proj_index])
                        }
                        else {
                            self.projectManager.projectList[proj_index].taskList[taskIndex].cards[cardIndex].assignedTo.append(user_id)
                            self.projectManager.updateProject(project: projectManager.projectList[proj_index])
                        }
                    }
                                            .environmentObject(firestoreManger)
                        }
                    }
                Spacer()
                    }
            }
    }
}

struct CardDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailScreen(projectManager: ProjectManager(), proj_index: 0, taskIndex: 0, cardIndex: 0)
    }
}


struct MultipleSelectionRow: View {
    
    var user: User
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                peopleRow(imageUrl: user.image, personName: user.name, personEmail: user.email)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.title2)
                }
            }
        }
    }
    
    @ViewBuilder
    func peopleRow(imageUrl: String, personName: String, personEmail: String) -> some View{
        HStack{
            AsyncImage(url: URL(string: imageUrl)){ image in
                image.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 4)
            VStack{
                HStack{
                    Text(personName)
                        .font(.custom("Apple SD Gothic Neo", size: 16))
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                }
                HStack{
                    Text("\(personEmail)")
                        .font(.custom("Apple SD Gothic Neo", size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            Spacer()
        }
        .padding(15)
    }
}



extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
