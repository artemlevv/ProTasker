//
//  HomeVC.swift
//  ProTasker
//
//  Created by ARTEM on 31.05.2023.
//

import UIKit
import SwiftUI

class HomeVC: UIViewController{
    @StateObject var firestoreManager = FirestoreManager()
    @ObservedObject var projecManager = ProjectManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = UIHostingController(rootView: HomeScreen(projectManager: projecManager).environmentObject(firestoreManager))
        vc.modalPresentationStyle = .fullScreen
        navigationItem.backButtonTitle = ""
        DispatchQueue.main.async { [weak self] in
            self?.present(vc, animated: false, completion: nil)
        }
    }
}
