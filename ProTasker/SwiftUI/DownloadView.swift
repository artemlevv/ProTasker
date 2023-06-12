//
//  Test.swift
//  ProTasker
//
//  Created by ARTEM on 04.06.2023.
//

import SwiftUI

struct DownloadView: View {
    @State private var downloadProgress: Float = 0.0
       
       var body: some View {
           VStack {
               Circle()
                   .trim(from: 0.0, to: CGFloat(downloadProgress))
                   .stroke(Color.blue, lineWidth: 10)
                   .frame(width: 100, height: 100)
                   .rotationEffect(Angle(degrees: -90))
                   .animation(.linear)
               
               Text("\(Int(downloadProgress * 100))%")
                   .font(.headline)
                   .padding(.top, 10)
           }
           .onAppear {
               simulateDownloadProgress()
           }
       }
       
       func simulateDownloadProgress() {
           let totalProgress: Float = 1.0
           let updateInterval: TimeInterval = 0.1
           
           Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
               downloadProgress += 0.1
               
               if downloadProgress >= totalProgress {
                   timer.invalidate()
               }
           }
       }
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadView()
    }
}
