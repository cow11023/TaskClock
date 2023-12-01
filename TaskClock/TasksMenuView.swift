//
//  TasksMenuView.swift
//  TaskClock
//
//  Created by 张逸然 on 2023/11/15.
//

import SwiftUI
import CloudKit

//定义任务列表的数据结构
struct Task: Identifiable {
    var id: String
    var name: String {
        didSet {
            // 检查并限制中文字符数量
            limitChineseCharacterCount()
        }
    }
    var SceduleID: Int64
    var isActivated: Bool //任务是否启用
    var createtime: TimeZone
    var updatetime: TimeZone

    private func limitChineseCharacterCount() {
        let chineseCharacterCount = name.countChineseCharacters()
        if chineseCharacterCount > 20 {
            // 如果超过限制，显示错误提示
            showErrorAlert()
        }
    }

    private func showErrorAlert() {
        // 显示错误提示
        // 这里可以使用一个状态变量来控制 Alert 的显示
        // 例如，@State private var isShowingErrorAlert = false
        // 然后在这里设置 isShowingErrorAlert = true
        // 在视图中使用 .alert(isPresented: $isShowingErrorAlert) { ... } 来显示 Alert
        print("超过20个中文字符，请重新输入")
    }
}

extension String {
    // 计算中文字符数量的扩展
    func countChineseCharacters() -> Int {
        var count = 0
        for scalar in String(self).unicodeScalars {
            if scalar.isChinese {
                count += 1
            }
        }
        return count
    }
}

extension UnicodeScalar {
    // 判断字符是否是中文的扩展
    var isChinese: Bool {
        //return ("一" <= self && self <= "龥")
        return (0x4E00 <= value && value <= 0x9FFF)
    }
}


struct TasksMenuView: View {
    @State private var tasks: [Task] = []
    
    init() {
        loadTasks()
    }

    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(x: -1)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) { // 将 alignment 设置为 .leading
                    GeometryReader { geo in
                        HStack {
                            Text("任务列表")
                                .font(.title2)
                                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.yellow.opacity(1.5)))
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)

                        List(tasks) { task in
                            Text(task.name)
                                .foregroundColor(.black)
                        }
                        .listRowBackground(Color.orange)
                        .onAppear {
                            loadTasks()
                        }
                    }
                    .padding()
                }
            }
        }
    }



    private func loadTasks() {
        // 使用 CloudKit 查询任务列表数据
        let container = CKContainer(identifier: "iCloud.TaskClock")
        let db = container.privateCloudDatabase
        let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))
        db.perform(query, inZoneWith: nil) { (records, queryError) in
            if let error = queryError {
                print("查询任务时出错: \(error.localizedDescription)")
            } else if let records = records {
                DispatchQueue.main.async {
                    self.tasks = records.map { record in
                        Task(
                            id: record.recordID.recordName,
                            name: record["name"] as? String ?? "",
                            SceduleID: record["scheduleID"] as? Int64 ?? 0,
                            isActivated: record["isActivated"] as? Bool ?? false,
                            createtime: record["createtime"] as? TimeZone ?? TimeZone.current,
                            updatetime: record["updatetime"] as? TimeZone ?? TimeZone.current
                        )
                    }
                }
                print("开始打印数据",self.tasks)
            }
        }
    }
}

struct TasksMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TasksMenuView()
    }
}

