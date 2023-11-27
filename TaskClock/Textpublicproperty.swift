//
//  Textpublicproperty.swift
//  TaskClock
//
//  Created by 张逸然 on 2023/11/14.
// Textpublicproperty.swift
import SwiftUI


//定义按钮的公共属性
struct CustomButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.orange.opacity(1.5)))
            .foregroundColor(.black)
    }
}

//应用自定义的视图修饰符CustomButtonStyle
extension Text {
    func customButtonStyle() -> some View {
        self.modifier(CustomButtonStyle())
    }
}
