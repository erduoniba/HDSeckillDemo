//
//  ViewController.swift
//  HDSeckillDemo
//
//  Created by denglibing on 2022/10/11.
//

import UIKit
import ActivityKit

class ViewController: UIViewController {
    private var products = [SeckillProductAttributes]()
    
    @IBOutlet weak var seckillButton0: UIButton!
    @IBOutlet weak var seckillButton1: UIButton!
    @IBOutlet weak var seckillButton2: UIButton!
    
    @IBOutlet weak var logTextView: UITextView!
    
    private var remoteImageData: Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchRemoteImage(urlString: "https://mmbiz.qlogo.cn/mmbiz_png/dTZZ7XS8ibTphnEzzVjvTuja1WQeGsCPpe0C8ibEwsTNz1ewCWNjECGfzwXRP224lVk3WgNRqe8Gt24e868Yewibg/0?wx_fmt=png")
        
        initProducts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(liveActivityNotif(notif:)), name: Notification.Name("liveActivityNotif"), object: nil)
    }
    
    private func initProducts() {
        let carId = "2022101101"
        let carIsSeckill = SeckillDatamanager.checkIsSeckill(productId: carId)
        let bicycleId = "2022101102"
        let bicycleIsSeckill = SeckillDatamanager.checkIsSeckill(productId: bicycleId)
        let basketballId = "2022101103"
        let basketballIsSeckill = SeckillDatamanager.checkIsSeckill(productId: basketballId)
        let car = SeckillProductAttributes(productId:carId, name: "Model Y", price: "29.8万", image: "car.side.air.circulate", countDown: 60, isSeckill: carIsSeckill)
        let bicycle = SeckillProductAttributes(productId:bicycleId, name: "永久自行车", price: "1200", image: "bicycle", countDown: 120, isSeckill: bicycleIsSeckill)
        let basketball = SeckillProductAttributes(productId:basketballId, name: "斯伯丁篮球", price: "340", image: "basketball", countDown: 150, isSeckill: basketballIsSeckill)
        products.append(car)
        products.append(bicycle)
        products.append(basketball)
        
        
        // 判断本地缓存和系统ActiviKit的任务数据来显示当前列表
        if carIsSeckill {
            seckillButton0.setTitle("已预约", for: .normal)
        }
        if bicycleIsSeckill {
            seckillButton1.setTitle("已预约", for: .normal)
        }
        if basketballIsSeckill {
            seckillButton2.setTitle("已预约", for: .normal)
        }
    }
    
    
    
    @IBAction func seckillAction(_ sender: UIButton) {
        if sender.tag >= products.count {
            return
        }
        
        if !ActivityAuthorizationInfo().areActivitiesEnabled {
            logToTextView(log: "不支持灵动岛")
            return
        }
        
        let product = products[sender.tag]
        // 判断系统的activities是否还执行该商品的任务，只有是在执行中的，才进行取消操作
        if sender.titleLabel?.text == "已预约" {
            if let activityId = SeckillDatamanager.getSeckillActivityId(productId: product.productId) {
                for activity in Activity<SeckillProductAttributes>.activities where activity.id == activityId {
                    logToTextView(log: "取消预约购买\(product.name)")
                    Task {
                        await activity.end(dismissalPolicy:.immediate)
                    }
                    sender.setTitle("预约抢购", for: .normal)
                }
            }
            return
        }
        
        logToTextView(log: "开始预约购买\(product.name)")
        do {
            // 初始化状态，ContentState是可变的对象
            let initState = SeckillProductAttributes.ContentState(seckillFinished: false, remoteImage: self.remoteImageData)
            // 初始化状态，这里是不变的数据
            let activity = try Activity.request(attributes: product, contentState: initState, pushType: .token)
            logToTextView(log: "activityId: \(activity.id)")
            sender.setTitle("已预约", for: .normal)
            // 将商品id和活动id关联起来，方便查询及取消操作
            SeckillDatamanager.saveSeckillState(productId: product.productId, activityId: activity.id)
        } catch {
            
        }
    }
    
}

extension ViewController {
    @objc private func liveActivityNotif(notif: Notification) {
        if let userInfo = notif.userInfo {
            if let productId = userInfo["productId"] as? String, let name = userInfo["name"] as? String {
                logToTextView(log: "立即抢购[\(name)] \(productId) \n")
            }
        }
    }
    
    private func logToTextView(log: String) {
        debugPrint(log);
        logTextView.text.append("\(log) \n")
        logTextView.scrollRectToVisible(CGRect(x: 0, y: logTextView.contentSize.height - 10, width: logTextView.contentSize.width, height: 10), animated: true)
    }
    
    func fetchRemoteImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url){ (data, response, error) in
            if let imageData = data {
                self.remoteImageData = imageData
            }
        }.resume()
    }
}
