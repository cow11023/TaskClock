//
//  WelcomeView.swift
//  TaskClock
//
//  Created by 张逸然 on 2023/11/10.
//

// WelcomeView.swift
import SwiftUI

class WelcomeViewModel: ObservableObject {
    @Published var isWelcomeAnimationCompleted = false

    init() {
        // 在初始化时手动触发动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(Animation.easeInOut(duration: 2.5)) {
                // 模拟动画完成
                self.isWelcomeAnimationCompleted = true
            }
        }
    }
}

struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()

    var body: some View {
        if viewModel.isWelcomeAnimationCompleted {
            // 欢迎动画完成后，切换到主界面
            NavigationLink(destination: ContentView()) {
                EmptyView()
            }
        } else {
            // 欢迎动画
            WelcomeAnimationView(completionHandler: {
                // 欢迎动画完成时设置标志
                viewModel.isWelcomeAnimationCompleted = true
            })
        }
    }
}
