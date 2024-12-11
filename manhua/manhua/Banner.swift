//
//  Banner.swift
//  manhua
//
//  Created by helinyu on 2024/12/12.
//

import SwiftUI

extension Color {
    static func randomColor() -> Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(red: red, green: green, blue: blue)
    }
}

//struct CustomPageIndicator: View {
//    let numberOfPages: Int // 总页数
//    let currentIndex: Int // 当前索引
//
//    var body: some View {
//        HStack(spacing: 8) {
//            ForEach(0..<numberOfPages, id: \.self) { index in
//                Circle()
//                    .fill(index == currentIndex ? Color.blue : Color.gray)
//                    .frame(width: 10, height: 10)
//                    .animation(.easeInOut, value: currentIndex) // 平滑过渡动画
//            }
//        }
//    }
//}

//struct CustomPageIndicator: View {
//    let numberOfPages: Int
//    let currentIndex: Int
//
//    var body: some View {
//        ProgressView(value: Double(currentIndex + 1), total: Double(numberOfPages))
//            .progressViewStyle(LinearProgressViewStyle(tint: Color.blue)) // 自定义进度条样式
//            .frame(height: 4)
//            .padding(.horizontal)
//    }
//}

// 可能还有长图
//struct CustomPageIndicator: View {
//    let numberOfPages: Int
//    let currentIndex: Int
//
//    var body: some View {
//        HStack(spacing: 8) {
//            ForEach(0..<numberOfPages, id: \.self) { index in
//                GeometryReader { geometry in
//                    Circle()
//                        .fill(index == currentIndex ? Color.blue : Color.gray)
//                        .frame(width: index == currentIndex ? 12 : 8, height: index == currentIndex ? 12 : 8)
//                        .scaleEffect(index == currentIndex ? 1.2 : 1.0) // 动态缩放效果
//                        .animation(.spring(), value: currentIndex)
//                }
//                .frame(width: 12, height: 12) // 限制 GeometryReader 的大小
//            }
//        }
//    }
//}

struct CustomPageIndicator: View {
    let numberOfPages: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                if index == currentIndex {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue) // 选中的索引颜色
                        .frame(width: 20, height: 8) // 长条的大小
                        .animation(.easeInOut, value: currentIndex)
                } else {
                    Circle()
                        .fill(Color.gray) // 未选中的索引颜色
                        .frame(width: 8, height: 8) // 圆点的大小
                }
            }
        }
    }
}

struct CarouselView: View {
    
    @State var currentIndex = 0 // 当前索引
    let autoScrollInterval: TimeInterval = 3.0 // 自动滚动时间间隔
    @State private var isAnimating = false // 动画是否正在执行
    @State private var isTouching = false // 是否正在触摸屏幕
    @State private var timer: Timer? // 用于保存定时器引用
    var originColors:[Color]
    @State private var colors: [Color] // 改为动态状态
    
    init(colors: [Color]) {
        
        self.originColors = colors
        self.colors = colors + colors + colors
        self.currentIndex = colors.count
        print("lt -- colors :\(self.colors) currenetIndex:\(self.currentIndex)")
    }
    
    func repeatColors(colors: [Color]) -> [Color] {
        print("lt -- repeatColors执行，颜色数组扩展三倍")
        return colors + colors + colors
    }
    
    //     可以展示的范围内
    // 在这个范围内才是合法的， 中间段 + 左右两边
    //    1 2 3 1 2 3 1 2 3
    func checkCurrentIndex(destIndex: Int) -> Int {
        // 这个都是在合法范围内
        if destIndex / self.originColors.count == 1 || destIndex == self.originColors.count - 1 || destIndex == self.originColors.count * 2{
            return destIndex
        }
        else {
            //             纠正索引
            return self.originColors.count + destIndex / self.originColors.count
        }
    }
    
    // 有 3段，我们只是在中间段滑动
    func isAtScrollCurrentIndex(destIndex: Int) -> Bool {
        return destIndex / self.originColors.count == 1
    }
    
    func checkScrollCurrentIndex(destIndex: Int) -> Int {
        return destIndex % self.originColors.count + self.originColors.count
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ForEach(0 ..< colors.count, id: \.self) { index in
                    Image("")
                        .tag(index)
                        .frame(width: UIScreen.main.bounds.size.width, height: 200, alignment: .center)
                        .background(colors[index%(self.originColors.count)])
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                self.currentIndex = self.checkCurrentIndex(destIndex: self.currentIndex)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    startAutoScroll()
                }
            }
            .onDisappear {
                stopAutoScroll()
            }
            .onChange(of: currentIndex) { newValue in
//                print("lt -- currentindex; \(currentIndex)")
//                print("lt -- 灭有在范围内的index \(self.currentIndex)")
                if !isTouching && !isAnimating {
                    isAnimating = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isAnimating = false
//                        print("动画执行完成，当前索引是 \(newValue)")
                        
                        // 不再滑动范围内，需要纠正到滑动的范围内
                        if !self.isAtScrollCurrentIndex(destIndex: self.currentIndex) {
                            stopAutoScroll()
                            self.currentIndex = self.checkScrollCurrentIndex(destIndex: self.currentIndex)
                            self.startAutoScroll()
//                            print("lt -- 重新启动")
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        // 手指开始触摸时，暂停自动滚动
                        isTouching = true
                        stopAutoScroll()
                    }
                    .onEnded { _ in
                        // 手指停止触摸时，恢复自动滚动
                        isTouching = false
                        startAutoScroll()
                    }
            )
        }
        .frame(height: 250) // 轮播图的高度
        // 自定义分页指示器
        CustomPageIndicator(numberOfPages: self.originColors.count, currentIndex: currentIndex % self.originColors.count)
                       .padding(.top, 10)
    }
    
    // 启动自动滚动
    private func startAutoScroll() {
        // 如果定时器已经存在，则不再启动新的定时器
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
                withAnimation {
                    self.currentIndex = self.checkCurrentIndex(destIndex: self.currentIndex + 1)
                }
            }
        }
    }
    
    // 停止自动滚动
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}
