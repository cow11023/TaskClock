//
//  ClockView.swift
//  TaskClock
//
//  Created by 张逸然 on 2023/11/12.
//
import SwiftUI

struct ClockView: View {
    @State private var currentDate = Date()
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd EEEE HH:mm:ss"
        formatter.locale = Locale(identifier: "zh_CN") // 设置为中文本地化
        return formatter
    }
    
    private var formattedDate: String {
        return dateFormatter.string(from: currentDate)
    }
    
    var body: some View {
        VStack {
            Text(formattedDate)
                .font(.custom("CuteFont", size: 22))
                .fontWeight(.bold)
                .padding()
            
            Spacer()
        }
        .onAppear {
            updateCurrentDate()
        }
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            updateCurrentDate()
        }
    }
    
    private func updateCurrentDate() {
        currentDate = Date()
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView()
    }
}
