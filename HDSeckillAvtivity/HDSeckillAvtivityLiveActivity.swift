//
//  HDSeckillAvtivityLiveActivity.swift
//  HDSeckillAvtivity
//
//  Created by denglibing on 2022/10/11.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HDSeckillAvtivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SeckillProductAttributes.self) { context in
            // 锁屏之后，显示的桌面通知栏位置，这里可以做相对复杂的布局
            VStack {
                Text("Hello").multilineTextAlignment(.center)
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            // 灵动岛的布局代码
            DynamicIsland {
                /*
                 这里是长按灵动岛区域后展开的UI
                 有四个区域限制了布局，分别是左、右、中间（硬件下方）、底部区域
                 这里采取左边为App的Icon、右边为上下布局（商品名称+商品图标）、
                 中间为立即购买按钮，支持点击deeplink传参唤起App、
                 底部为价格和倒计时区域
                 */
                DynamicIslandExpandedRegion(.leading) {
                    Image("zyg100").resizable().frame(width: 32, height: 32)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.name).font(.subheadline).multilineTextAlignment(.center)
                    Spacer(minLength: 8)
                    Image(systemName: context.attributes.image).multilineTextAlignment(.center)
                }
                DynamicIslandExpandedRegion(.center) {
                    // 这里的url一定记得需要中文编码
                    let url = "hdSeckill://seckill?productId=\(context.attributes.productId)&name=\(context.attributes.name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    Link("立即购买", destination: URL(string: url)!).foregroundColor(.red).font(.system(size: 24, weight: .bold))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .center, content: {
                        Spacer(minLength: 8)
                        Text("价格\(context.attributes.price)").font(.subheadline)
                        Spacer(minLength: 8)
                        Text(Date().addingTimeInterval(context.attributes.countDown * 60), style: .timer).font(.system(size: 16, weight: .semibold)).multilineTextAlignment(.center)
                        
                    }).foregroundColor(.green)
                }
            } compactLeading: {
                // 这里是灵动岛未被展开左边的布局，这里用来展示App的Icon
                Image("zyg100").resizable().frame(width: 32, height: 32)
            } compactTrailing: {
                // 这里是灵动岛未被展开右边的布局，这里用来商品的名称
                HStack {
                    Text(context.attributes.name).font(.subheadline)
                }
            } minimal: {
                // 这里是灵动岛有多个任务的情况下，展示优先级高的任务，位置在右边的一个圆圈区域
                // 这用户展示商品的图标
                Image(systemName: context.attributes.image)
            }
            // 点击整个区域，通过deeplink将数据传递给主工程，做相应的业务
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}
