//
//  ProjectManager.swift
//  ProTasker
//
//  Created by ARTEM on 04.06.2023.
//

import Foundation
import Firebase
import FirebaseFirestore

class ProjectManager: ObservableObject{
    @Published var projectList: [Project] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init(){
        getProjectdata()
    }
    func getProjectdata(){
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        
        db.collection("projects").addSnapshotListener { (querySnapshot, error) in
              guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
              }

              self.projectList = documents.compactMap { queryDocumentSnapshot -> Project? in
                let id = queryDocumentSnapshot.documentID
                let data = queryDocumentSnapshot.data()
                let assignedTo: [String] = data["assignedTo"] as? [String] ?? []
                var taskList: [TaskT] = []
                  
                if assignedTo.contains(userUid){
                      let createdBy = data["createdBy"] as? String ?? ""
                      let documentID = data["documentID"] as? String ?? ""
                      let image = data["image"] as? String ?? ""
                      let name = data["name"] as? String ?? ""
                    
                    if let taskListData = data["taskList"] as? [[String: Any]] {
                        taskList = taskListData.compactMap { taskData -> TaskT? in
                            let cardsData = taskData["cards"] as? [[String: Any]] ?? []
                            let createdBy = taskData["createdBy"] as? String ?? ""
                            let title = taskData["title"] as? String ?? ""
                            
                            let cards = cardsData.compactMap { cardData -> Card? in
                                let assignedTo = cardData["assignedTo"] as? [String] ?? []
                                let createdBy = cardData["createdBy"] as? String ?? ""
                                let name = cardData["name"] as? String ?? ""
                                let color = cardData["color"] as? String ?? ""
                                
                                return Card(assignedTo: assignedTo,color: color, createdBy: createdBy, name: name)
                            }
                            
                            return TaskT(cards: cards, createdBy: createdBy, title: title)
                        }
                    }
                    return Project(id: id, asignedTo: assignedTo, createdBy: createdBy, image: image, name: name, taskList: taskList)
                }
                return nil
            }
        }
    }
    
    func addProject(image_url: String, nameProject: String, user_name: String){
        guard let userUid = Auth.auth().currentUser?.uid else {return}
     
        let assigning: [String] = [userUid]
        let project = Project(id: "", asignedTo: assigning, createdBy: user_name, image: image_url, name: nameProject, taskList: [])
        
            let projectData: [String: Any] = [
                "assignedTo": project.asignedTo,
                "createdBy": project.createdBy,
                "image": project.image,
                "name": project.name,
                "taskList": project.taskList.map { task in
                    return [
                        "cards": task.cards.map { card in
                            return [
                                "assignedTo": card.assignedTo,
                                "color": card.color,
                                "createdBy": card.createdBy,
                                "name": card.name
                            ]
                        },
                        "createdBy": task.createdBy,
                        "title": task.title
                    ]
                }
            ]
            
        db.collection("projects").addDocument(data: projectData) { error in
                if let error = error {
                    print("Error adding project: \(error.localizedDescription)")
                } else {
                    print("Project added successfully")
            }
        }
    }
    func updateProject(project: Project) {
            
            let projectData: [String: Any] = [
                "assignedTo": project.asignedTo,
                "createdBy": project.createdBy,
                "image": project.image,
                "name": project.name,
                "taskList": project.taskList.map { task in
                    return [
                        "cards": task.cards.map { card in
                            print("CARD COLOR: \(card.color)")
                            return [
                                "assignedTo": card.assignedTo,
                                "color": card.color,
                                "createdBy": card.createdBy,
                                "name": card.name
                            ]
                        },
                        "createdBy": task.createdBy,
                        "title": task.title
                    ]
                }
            ]
            
        db.collection("projects").document(project.id).updateData(projectData){ error in//setData(projectData) { error in
                if let error = error {
                    print("Error updating project: \(error.localizedDescription)")
                } else {
                    print("Project updated successfully")
                }
            }
        /*db.collection("projects").document(project.id).addSnapshotListener{ (querySnapshot, error) in
            querySnapshot?.data().set
            
        }*/
        }
}


struct Project: Hashable{
    var id: String
    var asignedTo: [String]
    var createdBy: String
    var image: String
    var name: String
    var taskList: [TaskT]
    
}

struct TaskT: Hashable{
    var cards: [Card]
    var createdBy: String
    var title: String
}

struct Card: Hashable {
    var assignedTo: [String]
    var color: String
    var createdBy: String
    var name: String
}
