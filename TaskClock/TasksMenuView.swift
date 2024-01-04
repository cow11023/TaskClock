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
        self.isActivated = (isActivated == 0) ? false : true

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
    @State private var isShowingAlert = true
    @State private var alertMessage = ""
    
    // SwiftUI 代码，用于定义应用程序中一个视图的结构和行为。
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
                        .frame(height: 100)}
                    .padding()
                    
                    Spacer()
                    Spacer().frame(height: 120)
                    // 显示任务数量的文本
                    Text("任务数量: \(tasks.count)")
                        .foregroundColor(.green)
                        .bold()
                        .padding(.top, 10)
                    
                    HStack {
                        TextField("新任务", text: $newTaskName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button(action: {
                            addTask()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                refreshView.toggle()
                                
                            }
                        }) {
                            Text("添加任务")
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.yellow))
                                .foregroundColor(.black)
                        }
                    }
                }
                VStack {
                    ForEach(tasks) { task in
                        HStack {
                            Text("任务名称: \(task.name)")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .truncationMode(.tail)
                                .lineLimit(2)
                                .background(task.isActivated ? Color.green : Color.red)
                                .bold()
                            
                            Button(action: {
                                task.isActivated.toggle()
                                updateTaskActivationStatus(id: task.id, isActivated: task.isActivated)
                                DispatchQueue.main.async {
                                    loadTasks()
                                    refreshView.toggle()
                                }
                            }) {
                                Text(task.isActivated ? "禁用" : "启用")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(.horizontal, 10)
                                    .background(task.isActivated ? Color.red : Color.green)
                                    .cornerRadius(5)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                removeTask(withID: task.id)
                                DispatchQueue.main.async {
                                    loadTasks()
                                    refreshView.toggle()
                                }
                            }) {
                                Text("删除")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(.horizontal, 10)
                                    .background(Color.red)
                                    .cornerRadius(5)
                            }
                            .buttonStyle(PlainButtonStyle()
                            )
                        }
                    }
                }
                .frame(width: 380, height: 300)
                .background(Color.yellow)
                .onAppear {
                    if !isDataLoaded {
                        loadTasks()
                    }
                }
            }
            
            .alert(isPresented: $isShowingErrorAlert) {
                Alert(title: Text("错误"), message: Text(alertMessage))
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    

    func showError(message: String) {
        DispatchQueue.main.async {
            isShowingErrorAlert = true
            alertMessage = message
            print("显示错误消息：\(message)")
        }
    }



    private func addTask() {
        let chineseCharacterCount = newTaskName.countChineseCharacters()

        if chineseCharacterCount >= 10 {
            showError(message: "超过10个字符，请重新输入")
            //输入框归零
            newTaskName = ""
        } else if tasks.count >= 10 {
            showError(message: "任务数量已达到10个，不能再添加了")
            newTaskName = ""
        } else {
            // 检查任务名称是否已存在
            if tasks.contains(where: { $0.name == newTaskName }) {
                showError(message: "任务已存在")
                newTaskName = ""
            } else {
                let newTask = Task(
                    id: UUID().uuidString,
                    name: newTaskName,
                    isActivated: 0
                )
                
                TaskToCloudKit(task: newTask) {
                    // 此闭包在任务成功保存到 CloudKit 后调用
                    self.tasks.append(newTask)
                    newTaskName = ""
                    refreshView.toggle()
                }
            }
        }
    }


    private func TaskToCloudKit(task: Task, completion: @escaping () -> Void) {
        let container = CKContainer(identifier: "iCloud.TaskClock")
        let db = container.privateCloudDatabase
        let taskRecord = task.record

        db.save(taskRecord) { (record, dberror) in
            if let error = dberror {
                print("保存任务到 CloudKit 出错: \(error.localizedDescription)")
            } else if let record = record {
                OperationQueue.main.addOperation {
                    
                    completion() // 在这里调用完成闭包
                    
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
        refreshView.toggle()
    }

    private func updateTaskActivationStatus(id: String, isActivated: Bool) {
        print("尝试更新任务状态，任务ID：\(id)，是否启用：\(isActivated)")

        if isActivated {
            self.deactivateAllOtherTasks(except: id)
        }

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        let container = CKContainer(identifier: "iCloud.TaskClock")
        let db = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: id)

        db.fetch(withRecordID: recordID) { (record, error) in
            defer {
                dispatchGroup.leave()
            }

            if let error = error {
                print("获取记录时出错: \(error.localizedDescription)")
                return
            }

            if let record = record {
                let newValue = isActivated ? 1 : 0
                record["isActivated"] = newValue as CKRecordValue
                dispatchGroup.enter()
                db.save(record) { (savedRecord, saveError) in
                    defer {
                        dispatchGroup.leave()
                    }

                    if let saveError = saveError {
                        print("保存记录时出错: \(saveError.localizedDescription)")
                    } else {
                        if let savedRecord = savedRecord {
                            print("记录成功更新")
                            if let index = self.tasks.firstIndex(where: { $0.id == id }) {
                                self.tasks[index].isActivated = (newValue != 0)
                                DispatchQueue.main.async {
                                    self.tasks[index].isActivated.toggle()
                                    print("保存到 CloudKit 前的任务状态：\(self.tasks[index].isActivated)")
                                    print("保存到 CloudKit 后的记录：\(savedRecord)")
                                }
                            }
                        } else {
                            print("未能获取保存的记录")
                        }
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("所有异步任务完成")
            self.loadTasks()
        }
    }

    private func deactivateAllOtherTasks(except Id: String) {
        for task in tasks {
            if task.id != Id {
                task.isActivated = false
                updateTaskActivationStatus(id: task.id, isActivated: false)
            }
        }
    }

    private func removeTask(withID id: String) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            showError(message: "任务不存在")
            return
        }
        let taskToDelete = tasks[index]

        if taskToDelete.isActivated {
            showError(message: "已启用的任务不能删除")
            return
        }
        self.updateTaskActivationStatus(id: taskToDelete.id, isActivated: taskToDelete.isActivated)
        
        TaskDelCloudKit(task: taskToDelete, isDelete: true) {
            print("在 showAlert 异步之前")
            DispatchQueue.main.async {
                print("showAlert 内部异步")
                refreshView.toggle()
                
            }
        }
    }

    

    private func TaskDelCloudKit(task: Task,isDelete: Bool,completion: @escaping() -> Void) {
        let container = CKContainer(identifier: "iCloud.TaskClock")
        let db = container.privateCloudDatabase
        if isDelete {
            let recordID = CKRecord.ID(recordName: task.id)
            db.delete(withRecordID: recordID) { (recordID, dbError) in
                if let error = dbError {
                    print("从 CloudKit 删除任务出错: \(error.localizedDescription)")
                } else {
                    print("删除任务成功\(task.id)")
                    DispatchQueue.main.async {
                    completion()
                    print("任务删除成功回调执行完毕")
                    }
                }
            }
        }
    }
}

struct TasksMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TasksMenuView()
    }
}

