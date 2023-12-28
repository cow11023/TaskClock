// 改变iCloudKit中任务状态
private func updateTaskActivationStatus(id: String, isActivated: Bool) {
    print("尝试更新任务状态，任务ID：\(id)，是否启用：\(isActivated)")
    
    // 只允许存在一个已启用的任务
    if isActivated {
        self.deactivateAllOtherTasks(except: id)
    }
    
    // 创建 DispatchGroup 以确保异步任务同步执行
    let dispatchGroup = DispatchGroup()
    // 进入 DispatchGroup，标记异步任务的开始
    dispatchGroup.enter()
    let container = CKContainer(identifier: "iCloud.TaskClock")
    let db = container.privateCloudDatabase
    let recordID = CKRecord.ID(recordName: id)
    
    // 异步操作：从 CloudKit 中获取记录
    
    db.fetch(withRecordID: recordID) { (record, error) in
        // defer 语句确保在离开作用域时离开 DispatchGroup
        defer {
            dispatchGroup.leave()
        }
        
        if let error = error {
            print("获取记录时出错: \(error.localizedDescription)")
            return
        }
        
        if let record = record {
            // 无论任务当前状态如何，都切换 isActivated 的值
            let newValue = isActivated ? 1 : 0
            record["isActivated"] = newValue as CKRecordValue
            // 异步操作：保存记录
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
                        // 在主线程中更新任务状态
                        if let index = self.tasks.firstIndex(where: { $0.id == id }) {
                            self.tasks[index].isActivated = (newValue != 0)
                            DispatchQueue.main.async {
                                self.tasks[index].isActivated.toggle()
                                print("保存到 CloudKit 前的任务状态：\(self.tasks[index].isActivated)")
                                // 保存到 CloudKit 后的记录
                                print("保存到 CloudKit 后的记录：\(savedRecord)")
                                self.refreshView.toggle()
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
        // 所有异步任务完成后的回调
        print("所有异步任务完成")
        // 保存记录完成后加载任务
        self.refreshView.toggle()
    }
}
