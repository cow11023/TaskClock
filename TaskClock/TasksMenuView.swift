//
//  TasksMenuView.swift
//  TaskClock
//
//  Created by 张逸然 on 2023/11/15.
//

import SwiftUI
import CloudKit

// 定义任务列表的数据结构
struct Task: Identifiable {
    var id: String
    var name: String {
        didSet {
            // 检查并限制中文字符数量
            limitChineseCharacterCount()
        }
    }
    var isActivated: Bool // 任务是否启用
    var createtime: TimeZone
    var updatetime: TimeZone

    // 检查中文字符数量是否超过20的私有方法
    private func limitChineseCharacterCount() {
        let chineseCharacterCount = name.countChineseCharacters()
        if chineseCharacterCount > 20 {
            // 如果超过限制，显示错误提示
            showErrorAlert()
        }
    }

    // 显示错误提示的私有方法
    private func showErrorAlert() {
        // 显示错误提示
        // 这里可以使用一个状态变量来控制 Alert 的显示
        // 例如，@State private var isShowingErrorAlert = false
        // 然后在这里设置 isShowingErrorAlert = true
        // 在视图中使用 .alert(isPresented: $isShowingErrorAlert) { ... } 来显示 Alert
        print("超过20个中文字符，请重新输入")
    }
}

// 扩展 String 类型以计算中文字符数量
extension String {
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

// 扩展 UnicodeScalar 类型以判断字符是否为中文
extension UnicodeScalar {
    var isChinese: Bool {
        return (0x4E00 <= value && value <= 0x9FFF)
    }
}

struct TasksMenuView: View {
    
    @State private var tasks: [Task] = []
    @State private var newTaskName: String = ""
    @State private var isShowingErrorAlert = false

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
                VStack(alignment: .leading, spacing: 10) {
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

                        // 列表显示任务
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

                    // Spacer() 添加垂直空间
                    Spacer()

                    // Spacer() 添加额外的垂直空间，这里可以调整高度
                    Spacer().frame(height: 120)

                    // 添加用于创建任务的按钮和文本字段
                    HStack {
                        TextField("新任务", text: $newTaskName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        Button(action: {
                            // 点击按钮时调用添加任务的逻辑
                            addTask()
                        }) {
                            Text("添加任务")
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.yellow))
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                }
            }
            .alert(isPresented: $isShowingErrorAlert) {
                Alert(title: Text("超过20个中文字符，请重新输入"))
            }
        }
    }

    private func addTask() {
        let chineseCharacterCount = newTaskName.countChineseCharacters()
        if chineseCharacterCount > 20 {
            isShowingErrorAlert = true
        } else {
            let newTask = Task(
                id: UUID().uuidString,
                name: newTaskName,
                isActivated: false,
                createtime: TimeZone.current,
                updatetime: TimeZone.current
            )

            tasks.append(newTask)
            newTaskName = ""

            // 将新任务数据同步到 CloudKit 中
            TaskToCloudKit(task: newTask)
        }
    }

    private func TaskToCloudKit(task: Task) {
        let container = CKContainer(identifier: "iCloud.TaskClock")
        let db = container.privateCloudDatabase

        // 创建 CKRecord 对象
        let record = CKRecord(recordType: "Task")
        record["id"] = task.id
        record["name"] = task.name
        record["isActivated"] = task.isActivated
        if let createtimeData = try? NSKeyedArchiver.archivedData(withRootObject: task.createtime, requiringSecureCoding: false) {
            record["createtime"] = createtimeData as CKRecordValue
        }
        if let updatetimeData = try? NSKeyedArchiver.archivedData(withRootObject: task.updatetime, requiringSecureCoding: false) {
            record["updatetime"] = updatetimeData as CKRecordValue
        }

        // 将 CKRecord 保存到 CloudKit 数据库
        db.save(record) { (record, error) in
            if let error = error {
                print("保存任务到 CloudKit 出错: \(error.localizedDescription)")
            } else {
                print("任务保存到 CloudKit 成功")
            }
        }
    }


    private func loadTasks() {
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
                            id: record["id"] as? String ?? "",
                            name: record["name"] as? String ?? "",
                            isActivated: record["isActivated"] as? Bool ?? false,
                            createtime: record["createtime"] as? TimeZone ?? TimeZone.current,
                            updatetime: record["updatetime"] as? TimeZone ?? TimeZone.current
                        )
                    }
                }
                print("开始打印数据", self.tasks)
            }
        }
    }
}


struct TasksMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TasksMenuView()
    }
}

