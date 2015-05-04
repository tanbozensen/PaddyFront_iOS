//
//  SecondViewController.swift
//  PaddyFront
//
//  Created by K.Mochizuki on 2015/04/29.
//  Copyright (c) 2015年 K.Mochizuki. All rights reserved.
//

import UIKit
import CoreLocation

class SecondViewController: UIViewController , CLLocationManagerDelegate , UIPickerViewDelegate , NSURLSessionDelegate,NSURLSessionDataDelegate {
    
    // 現在地の位置情報の取得にはCLLocationManagerを使用
    var lm: CLLocationManager! = nil
    // 取得した緯度を保持するインスタンス
    var latitude: CLLocationDegrees!
    // 取得した経度を保持するインスタンス
    var longitude: CLLocationDegrees!
    
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var locationResult: UILabel!
    
    @IBOutlet weak var requestTextView: UITextView!
    @IBOutlet weak var replyTextView: UITextView!

    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var riceTypePicker: UIPickerView!
    let array = ["選択なし","コシヒカリ", "ヒノヒカリ", "ひとめぼれ", "あきたこまち", "キヌヒカリ" , "はえぬき" , "きらら３９７" , "つがるロマン" , "ななつぼし" , "ササニシキ" , "その他" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // riceTypePicker 設定
        // Delegateを設定する.
        riceTypePicker.delegate = self
        // Viewに追加する.
        self.view.addSubview(riceTypePicker)
        
        // 位置情報取得関連 設定
        // フィールドの初期化
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        
        lonLabel.text = "\(longitude)"
        latLabel.text = "\(latitude)"
        locationResult.text = ""
        
        lm = CLLocationManager()
        lm.delegate = self
        //位置情報取得の可否。バックグラウンドで実行中の場合にもアプリが位置情報を利用することを許可する
        lm.requestAlwaysAuthorization()
        //位置情報の精度
        lm.desiredAccuracy = kCLLocationAccuracyBest
        //位置情報取得間隔(m)
        lm.distanceFilter = 300
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func TouchNowBtn(sender: AnyObject) {
        //現在地取得
        lm.startUpdatingLocation()
    }
    
    /** 位置情報取得成功時 */
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        longitude = newLocation.coordinate.longitude
        latitude = newLocation.coordinate.latitude
        
        self.latLabel.text = "\(latitude)"
        self.lonLabel.text = "\(longitude)"
        self.locationResult.text = "成功"
        
        // GPSの使用を停止する．停止しない限りGPSは実行され，指定間隔で更新され続ける．
        lm.stopUpdatingLocation()
    }
    
    /** 位置情報取得失敗時 */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        self.latLabel.text = "-"
        self.lonLabel.text = "-"
        self.locationResult.text = "失敗"
    }
    
    // for delegate
    func numberOfComponentsInPickerView(riceTypePicker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(riceTypePicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }
    
    func pickerView(riceTypePicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return array[row]
    }
    
    @IBAction func TouchSendBtn(sender: AnyObject) {
        // リクエストデータ生成
        var requestStr:NSString
        var RiceType = riceTypePicker.selectedRowInComponent(0)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // ロケールの設定
        dateFormatter.dateFormat = "yyyy-MM-dd" // 日付フォーマットの設定
        let date = dateFormatter.stringFromDate(datePicker.date)
  
        requestStr = "{ \"latitude\": "
                    + "\(latitude)"
                    + ", \"longitude\": "
                    + "\(longitude)"
                    + ", \"phase\": "
                    + "0"
                    + ", \"rice_type\": "
                    + "\(RiceType)"
                    + ", \"done_date\": \""
                    + "\(date)"
                    + "\" }"

        requestTextView.text = "\(requestStr)"

        // POST
        // 通信用のConfigを生成.
        let myConfig:NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundTask")
        // Sessionを生成.
        var mySession:NSURLSession = NSURLSession(configuration: myConfig, delegate: self, delegateQueue: nil)
        // 通信先のURLを生成.
        let myUrl:NSURL = NSURL(string: "http://tanbozensen.herokuapp.com/api/tanbos/")!
        // POST用のリクエストを生成.
        let myRequest:NSMutableURLRequest = NSMutableURLRequest(URL: myUrl)
        // POSTのメソッドを指定.
        myRequest.HTTPMethod = "POST"
        // Httpヘッダのcontenttypeはapplication/jsonに
        myRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // リクエストにセット.
        let myData:NSData = requestStr.dataUsingEncoding(NSUTF8StringEncoding)!
        myRequest.HTTPBody = myData
        // タスクの生成.
        let myTask:NSURLSessionDataTask = mySession.dataTaskWithRequest(myRequest)
        // タスクの実行.
        myTask.resume()
    }
    
    
    /*
    通信が終了したときに呼び出されるデリゲート.
    */
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        // 帰ってきたデータを文字列に変換.
        var myData:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        
        // バックグラウンドだとUIの処理が出来ないので、メインスレッドでUIの処理を行わせる.
        dispatch_async(dispatch_get_main_queue(), {
            self.replyTextView.text = "\(myData)"
        })
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        println("URLSessionDidFinishEventsForBackgroundURLSession")
        // バックグラウンドからフォアグラウンドの復帰時に呼び出されるデリゲート.
    }
    
}

