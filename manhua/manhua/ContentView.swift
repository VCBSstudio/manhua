//
//  ContentView.swift
//  manhua
//
//  Created by helinyu on 2024/12/12.
//


import SwiftUI


struct ContentView: View {
    
    let colors: [Color] = [
        Color.randomColor(),
        Color.randomColor(),
        Color.randomColor()
    ]
    
    var body: some View {
        CarouselView(colors: colors) // 替换为自己的图片名称
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
