import SwiftUI

struct ContentView: View {
    @State private var isTasksMenuPresented = false
    @State private var isScheduleMenuPresented = false
    
    

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                Image("cat")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                ClockView()
                    .padding()

                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer()

                        // 任务列表按钮
                        Button(action: {
                            isTasksMenuPresented.toggle()
                        }) {
                            Text("任务列表")
                                .customButtonStyle()
                        }
                        .sheet(isPresented: $isTasksMenuPresented) {
                            // 在这里放置任务列表的子菜单视图
                            TasksMenuView()
                        }

                        // 日程事件按钮
                        Button(action: {
                            isScheduleMenuPresented.toggle()
                        }) {
                            Text("日程事件")
                                .customButtonStyle()
                        }
                        .sheet(isPresented: $isScheduleMenuPresented) {
                            // 在这里放置日程事件的子菜单视图
                            ScheduleMenuView()
                        }
                    }
                    .padding(.bottom, 10) // 任务列表和日程事件按钮的间隔
                    .padding(.leading, 10) // 左边距

                    Spacer()

                    VStack(alignment: .trailing, spacing: 26) {
                        Spacer() // 添加垂直间隔

                        // 退出按钮
                        Button(action: {
                            //退出逻辑
                            exit(0)
                            
                        }) {
                            Text("退出APP")
                                .customButtonStyle()
                        }

                        // 关于作者按钮
                        Button(action: {
                            // 处理关于作者逻辑
                        }) {
                            Text("关于作者")
                                .customButtonStyle()
                        }
                    }
                    .padding(.trailing, 30) // 右边距
                }
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
        ContentView()
    }
}

