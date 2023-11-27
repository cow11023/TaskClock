//
//  TasksMenuView.swift
//  TaskClock
//
//  Created by 张逸然 on 2023/11/15.
//

import SwiftUI

//定义任务列表的数据结构
struct Task: Identifiable {
    var id: Int64
    var name: String
    var SceduleID: Int64
}

struct TasksMenuView: View {
    var body: some View {
        // 在这里放置 TasksMenuView 的内容
        Text("This is TasksMenuView")
    }
}
