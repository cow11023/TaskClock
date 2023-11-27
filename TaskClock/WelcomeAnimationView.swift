//
//  WelcomeAnimationView.swift
//  TaskClock
//
//  Created by 张逸然 on 2023/11/10.
//

// WelcomeAnimationView.swift
import SwiftUI

struct WelcomeAnimationView: View {
    let completionHandler: () -> Void
    let app_name = "任务时钟"
    let versin = "版本号"
    let author = "作者"
    let name = "cow11023"
    
    
    
    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(x: -1)

            VStack(alignment: .trailing, spacing: 10) {
                GeometryReader { geo in
                    HStack {
                        Spacer()
                        Text("\(app_name) \n Apps \n \(versin) \n v2.1.0")
                            .multilineTextAlignment(.trailing)
                            .bold()
                            .foregroundColor(Color("Cow11023Gray"))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: geo.size.width - 50, height: 3)
                                    .foregroundColor(.white)
                                    .offset(x: -20, y: geo.frame(in: .local).midY)
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)

                Text("\(author) \n \(name)")
                    .multilineTextAlignment(.trailing)
                    .bold()
                    .foregroundColor(Color("Cow11023Gray").opacity(0.6))
            }
        }
        .ignoresSafeArea()
    }
}


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
        ContentView()
    }
}
