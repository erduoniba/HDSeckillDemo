//
//  SeckillProduct.swift
//  HDSeckillDemo
//
//  Created by denglibing on 2022/10/11.
//

import Foundation
import ActivityKit

struct SeckillProductAttributes: ActivityAttributes {
    typealias SeckillProductState = ContentState
    public struct ContentState: Codable, Hashable {
        var seckillFinished: Bool
    }
    
    let productId: String
    let name: String
    let price: String
    let image: String
    let countDown: Double
    let isSeckill: Bool
    
    init(productId: String, name: String,  price: String, image: String, countDown: Double, isSeckill: Bool = false) {
        self.productId = productId
        self.name = name
        self.price = price
        self.image = image
        self.countDown = countDown
        self.isSeckill = isSeckill
    }
}

// 解析灵动岛的传递数据，做相应的事件，这里通过通知给主工程的控制器执行相应任务
struct ActivityBrigde {
    @discardableResult
    public static func activityAction(url: URL) -> Bool {
        let host = url.host
        guard host != nil else { return false }
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        guard let queryItems = queryItems else { return false }
        var productId : String?
        var name : String?
        for item in queryItems {
            // 获取商品id和名称
            if item.name == "productId" {
                productId = item.value
            }
            else if item.name == "name" {
                name = item.value
            }
        }
        guard let productId = productId else { return false }
        debugPrint("立即抢购[\(name ?? "")] \(productId)")
        
        let info = [
            "productId": productId,
            "name": name ?? ""
        ]
        NotificationCenter.default.post(name: Notification.Name("liveActivityNotif"), object: nil, userInfo: info)
        
        return true
    }
}
