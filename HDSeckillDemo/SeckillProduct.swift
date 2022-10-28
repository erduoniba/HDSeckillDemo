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
        var remoteImage: Data?
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
    
    public static func disposeNotifiMessage(userInfo: [AnyHashable: Any]) {
        if let aps = userInfo["aps"] as? [String: Any] {
            if let content = aps["content-state"] as? [String: Any], let alert = aps["alert"] as? [String: Any] {
                if let productId = alert["productId"] as? String, let seckillFinished = content["seckillFinished"] as? Bool {
                    let activityId = SeckillDatamanager.getSeckillActivityId(productId: productId)
                    for activity in Activity<SeckillProductAttributes>.activities where activityId == activity.id {
                        let updateAtt = SeckillProductAttributes.ContentState(seckillFinished: seckillFinished)
                        Task {
                            await activity.update(using: updateAtt)
                        }
                    }
                }
            }
        }
    }
}

struct SeckillDatamanager {
    // 保留商品的预约状态，key是商品id，value是activity的id
    static let seckillProductIds = "com.harry.toolbardemo.seckillProductIds"
    
    static func checkIsSeckill(productId: String) -> Bool {
        if let ids = UserDefaults.standard.value(forKey: SeckillDatamanager.seckillProductIds) as? [String: String] {
            // 本地缓存包含该商品ID，并且系统的Activity依旧存在
            if ids.keys.contains(productId) {
                for activity in Activity<SeckillProductAttributes>.activities where activity.id == ids[productId] {
                    return true
                }
            }
        }
        return false
    }
    
    static func saveSeckillState(productId: String, activityId: String) {
        var ids = [String: String]()
        if let tempIds = UserDefaults.standard.value(forKey: SeckillDatamanager.seckillProductIds) as? [String: String] {
            ids = tempIds
        }
        ids[productId] = activityId
        UserDefaults.standard.set(ids, forKey: SeckillDatamanager.seckillProductIds)
    }
    
    static func getSeckillActivityId(productId: String) -> String? {
        if let ids = UserDefaults.standard.value(forKey: SeckillDatamanager.seckillProductIds) as? [String: String] {
            return ids[productId]
        }
        return nil
    }
    
    static func removeSeckillActivityId(productId: String) {
        if var ids = UserDefaults.standard.value(forKey: SeckillDatamanager.seckillProductIds) as? [String: String] {
            ids.removeValue(forKey: productId)
            UserDefaults.standard.set(ids, forKey: SeckillDatamanager.seckillProductIds)
        }
    }
}
