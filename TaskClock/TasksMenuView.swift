//
//  TasksMenuView.swift
//  TaskClock
//
//  Created by 张逸然 on 2023/11/15.
//

import SwiftUI
import CloudKit
import Combine

// 定义任务列表的数据结构
class Task: ObservableObject, Identifiable{
    @Published var tasks: [Task] = []
    @Published var  id: String
     @Published var name: String {
        didSet {
            // 检查并限制中文字符数量
            limitChineseCharacterCount()
        }
    }
    @Published var isActivated: Bool // 任务是否启用
    // PassthroughSubject
       var objectWillChange = PassthroughSubject<Void, Never>()
    // 初始化方法
    init(id: String, name: String, isActivated: Int) {
        self.id = id
        self.name = name
        self.isActivated = isActivated == 1  // Convert Int to Bool
    }
    // 添加 Identifiable 协议需要的 id 属性
        var taskId: String { id }
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
// 在 Task 类中添加一个计算属性，该属性返回对应于 CKRecord 的实例
extension Task {
    var record: CKRecord {
        let record = CKRecord(recordType: "Task")

        record["id"] = self.id as CKRecordValue
        record["name"] = self.name as CKRecordValue
        record["isActivated"] = self.isActivated as CKRecordValue
//        record["createtime"] = self.createtime as any CKRecordValue as CKRecordValue
//        record["updatetime"] = self.updatetime as any CKRecordValue as CKRecordValue

        return record
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
    @State private var isDataLoaded = false
    @State private var newTaskName: String = ""
    @State private var isShowingErrorAlert = false
    @State private var refreshView = false

//    init() {
//        loadTasks()
//    }

    var body: some View {
        ZStack {
            Image("BG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(x: -1)
                .ignoresSafeArea(.keyboard)

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
                    }                }
                VStack {
                       ForEach(tasks) { task in
                           Text("任务名称: \(task.name)\n")
                               .font(.title)
                               .multilineTextAlignment(.center) // 设置文本居中
                               .lineLimit(nil) // 允许文本多行显示
                               .background(Color.red) // 设置每个任务的背景颜色
                               .bold()
                       }
                   }
                .frame(width: 380, height: 300) // 设置列表的宽度和高度
                .background(Color.yellow) // 设置HStack的背景色
                .onAppear {
                    if !isDataLoaded {
                        loadTasks()
                        print("视图出现。任务数量：\(tasks.count)")
                    }
                }
            }
            .alert(isPresented: $isShowingErrorAlert) {
                Alert(title: Text("超过20个中文字符，请重新输入"))
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    private func addTask() {

        let chineseCharacterCount = newTaskName.countChineseCharacters()
        if chineseCharacterCount > 20 {
            isShowingErrorAlert = true
        } else {
            let newTask = Task(
                id: UUID().uuidString,
                name: newTaskName,
                isActivated: 1
            )

            tasks.append(newTask)
            newTaskName = ""

            // 将新任务数据同步到 CloudKit 中
            print("新任务详情：ID - \(newTask.id)，名称 - \(newTask.name)，是否激活 - \(newTask.isActivated)")
            TaskToCloudKit(task: newTask)
           
            
            // 刷新视图
            refreshView.toggle()
        }
    }
    private func TaskToCloudKit(task: Task) {
        // 创建新的 Task 对象
        let newTask = Task(
            id: UUID().uuidString,
            name: task.name,
            isActivated: 1
        )

        let container = CKContainer(identifier: "iCloud.TaskClock")
        let db = container.privateCloudDatabase
        let taskRecord = newTask.record

        db.save(taskRecord) { (record, dberror) in
            if let error = dberror {
                print("保存任务到 CloudKit 出错: \(error.localizedDescription)")
            } else if let record = record {
                let savedTask = Task(
                    id: record.recordID.recordName,
                    name: record["name"] as? String ?? "",
                    isActivated: record["isActivated"] as? Int ?? 0
                )

                OperationQueue.main.addOperation {
                    self.tasks.append(savedTask)
                }
                print("CKRecord已保存: \(record.debugDescription)")
                print("任务保存到 CloudKit 成功 \(self.tasks)")
            }
        }
    }

    private func loadTasks() {
        let container = CKContainer(identifier: "iCloud.TaskClock")
        let db = container.privateCloudDatabase
        let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))

        db.fetch(withQuery: query) { (result: Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>) in
            switch result {
            case .success(let matchResults):
                var tasks: [Task] = []

                for (recordID, recordResult) in matchResults.0 {
                    switch recordResult {
                    case .success(let record):
                        print("Record ID: \(recordID.recordName)")
                        print("Record Data: \(record)")

                        let task = Task(
                            id: record.recordID.recordName,
                            name: record["name"] as? String ?? "",
                            isActivated: record["isActivated"] as? Int ?? 0
                        )
                        tasks.append(task)

                    case .failure(let error):
                        print("获取记录失败: \(error.localizedDescription)")
                    }
                }
                DispatchQueue.main.async {
                    self.tasks = tasks
                    print("匹配的结果: \(tasks)")
                    print("在 DispatchQueue 中的任务: \(self.tasks)")

                }
                
            case .failure(let error):
                print("查询任务时出错: \(error.localizedDescription)")
            }
        }
        isDataLoaded = true
    }





}


struct TasksMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TasksMenuView()
    }
}

