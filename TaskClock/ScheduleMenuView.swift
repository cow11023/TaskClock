//
//  ScheduleMenuView.swift
//  TaskClock
//
//  Created by 张逸然 on 2023/11/14.
//

// ScheduleMenuView.swift
import SwiftUI
import CloudKit
import Combine

// 与Task关联的数据结构
struct TaskAssociation {
    var taskId: String
    var isActivated: Bool
}

// 定义日程事件的数据结构
class Schedule: ObservableObject, Identifiable {
    @Published var id: String
    @Published var eventName: String
    @Published var startTime: Date
    @Published var endTime: Date
    @Published var taskAssociation: TaskAssociation?

    // 初始化方法
    init(id: String, eventName: String, startTime: Date, endTime: Date, taskAssociation: TaskAssociation? = nil) {
        self.id = id
        self.eventName = eventName
        self.startTime = startTime
        self.endTime = endTime
        self.taskAssociation = taskAssociation
    }
}




struct ScheduleMenuView: View {
    var body: some View {
        // 在这里放置 ScheduleMenuView 的内容
        Text("This is ScheduleMenuView")
    }
}

// 可以在这里放置 ScheduleMenuView 相关的其他代码
