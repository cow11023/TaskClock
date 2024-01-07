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
import SwiftUI
import CloudKit

// 与任务关联的数据结构
struct TaskAssociation {
    var taskId: String
    var isActivated: Bool
}

// 定义日程事件的数据结构
class Schedules: ObservableObject, Identifiable {
    @Published var id: String
    @Published var name: String
    @Published var startTime: Date
    @Published var endTime: Date
    @Published var taskAssociation: TaskAssociation?

    init(id: String, name: String, startTime: Date, endTime: Date, taskAssociation: TaskAssociation? = nil) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.taskAssociation = taskAssociation
    }

    var record: CKRecord {
        let record = CKRecord(recordType: "Schedules")

        record["id"] = self.id as CKRecordValue
        record["name"] = self.name as CKRecordValue
        record["startTime"] = self.startTime as CKRecordValue
        // 注意: 这里需要将 TaskAssociation 转换为 CKRecordValue
        // record["taskAssociation"] = ...

        return record
    }
}

struct ScheduleMenuView: View {
    @State private var schedules: [Schedules] = []
    @State private var newScheduleName: String = ""
    


    var body: some View {
        GeometryReader { geo in
            Image("BG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(x: -1)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    GeometryReader { geo in
                        HStack {
                            Text("日程列表")
                                .font(.title2)
                                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.yellow.opacity(1.5)))
                                .foregroundColor(.black)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                    }
                    .padding()

                    Spacer()
                    Spacer().frame(height: 120)

                    HStack {
                        TextField("新日程", text: $newScheduleName)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal)
                            .background(Color.white)
                            .bold()
                        Button(action: {
                            addSchedule()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                loadSchedules()
                            }
                        }) {
                            Text("添加日程")
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.yellow))
                                .foregroundColor(.black)
                        }
                    }
                }
                VStack {
                    ForEach(schedules) { schedule in
                        HStack {
                            Text("日程名称: \(schedule.name)")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .truncationMode(.tail)
                                .lineLimit(2)
                                .bold()

                            Button(action: {
                                removeSchedule(withID: schedule.id)
                                DispatchQueue.main.async {
                                    loadSchedules()
                                }
                            }) {
                                Text("删除")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(.horizontal, 10)
                                    .background(Color.red)
                                    .cornerRadius(5)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
                .onAppear {
                    loadSchedules()
                }
            }
            .ignoresSafeArea()
        }
    }

    private func addSchedule() {
        // 实现添加新日程的逻辑
    }

    private func removeSchedule(withID id: String) {
        // 实现删除指定ID的日程的逻辑
    }

    private func loadSchedules() {
        // 实现从 CloudKit 中加载日程的逻辑
    }
}

struct ScheduleMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleMenuView()
    }
}

