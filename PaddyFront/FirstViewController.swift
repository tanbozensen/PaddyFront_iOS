//
//  FirstViewController.swift
//  PaddyFront
//
//  Created by K.Mochizuki on 2015/04/29.
//  Copyright (c) 2015年 K.Mochizuki. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MapKit

class FirstViewController: UIViewController , GMSMapViewDelegate , CLLocationManagerDelegate {

    var gmaps : GMSMapView!

    // 現在地の位置情報の取得にはCLLocationManagerを使用
    var lm: CLLocationManager! = nil
    // 取得した緯度を保持するインスタンス
    var latitude: CLLocationDegrees!
    // 取得した経度を保持するインスタンス
    var longitude: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // GoogleMap 初期設定
        let lat: CLLocationDegrees = 36.3162
        let lon: CLLocationDegrees = 137.8652
        let zoom: Float = 4.8
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(lat,longitude: lon,zoom: zoom);
        gmaps = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        gmaps.camera = camera
        gmaps.mapType = kGMSTypeHybrid;
        self.view.addSubview(gmaps)
        
        // GPS初期化
        lm = CLLocationManager()
        lm.delegate = self
        //位置情報取得の可否。バックグラウンドで実行中の場合にもアプリが位置情報を利用することを許可する
        lm.requestAlwaysAuthorization()
        //位置情報の精度
        lm.desiredAccuracy = kCLLocationAccuracyBest
        //位置情報取得間隔(m)
        lm.distanceFilter = 20
        
        // 更新 Buttonを作成する.
        let updateButton: UIButton = UIButton(frame: CGRectMake(0, 0, 80, 50))
        updateButton.layer.position = CGPointMake(self.view.frame.width/3, self.view.frame.height-100)
        updateButton.layer.masksToBounds = true
        updateButton.layer.cornerRadius = 20.0
        updateButton.setTitle("更新", forState: .Normal)
        updateButton.backgroundColor = UIColor.redColor()
        updateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        updateButton.addTarget(self, action: "touchUpdateButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(updateButton)

        // 現在位置表示 Buttonを作成する.
        let positionButton: UIButton = UIButton(frame: CGRectMake(0, 0, 80, 50))
        positionButton.layer.position = CGPointMake(self.view.frame.width/3 * 2, self.view.frame.height-100)
        positionButton.layer.masksToBounds = true
        positionButton.layer.cornerRadius = 20.0
        positionButton.setTitle("現在位置", forState: .Normal)
        positionButton.backgroundColor = UIColor.redColor()
        positionButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        positionButton.addTarget(self, action: "touchPositionButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(positionButton)
    }
    
    func touchUpdateButton(sender: UIButton) {
        // 田んぼ情報取得
        let json = JSON(url:"http://tanbozensen.herokuapp.com/api/tanbos?year=2015")
        
        // 要素の取り出し
        for ( var i = 0 ;; i++ ) {
            if ( json[i].isError ) {    // エラーとなるまで取得
                break
            }
            // 緯度・経度
            var jsonbuf = json[i]["latitude"]
            let latStr = "\(jsonbuf)"
            jsonbuf = json[i]["longitude"]
            let lonStr = "\(jsonbuf)"
            let markerLat: CLLocationDegrees = NSString(string: latStr).doubleValue
            let markerLon: CLLocationDegrees = NSString(string: lonStr).doubleValue
            // 日時
            jsonbuf = json[i]["done_date"]
            let daneDate = "\(jsonbuf)"
            // 品種
            jsonbuf = json[i]["rice_type"]
            let riceType = "\(jsonbuf)"
            var riceTypeStr: String = "選択なし"
            
            var j = 0
            for ( j = 0 ; j < riceTypeTbl.count ; j++ ) {
                if ( riceType == riceTypeTbl[j][0] ){
                    riceTypeStr = riceTypeTbl[j][1]
                }
            }
                let ooo = riceTypeTbl.count
            // フェーズ
            jsonbuf = json[i]["phase"]
            let phase = "\(jsonbuf)"
            
            // マーカー設定
            let marker: GMSMarker = GMSMarker ()
            marker.snippet = daneDate + " : " + riceTypeStr
            if ( phase == "0") {
                marker.icon = UIImage(named: "nae35.png")
            }
            else{
                marker.icon = UIImage(named: "ine35.png")
            }
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.position = CLLocationCoordinate2DMake(markerLat, markerLon)
            
            // マーカーをマップへ表示
            marker.map = gmaps;
        }

    }
    
    func touchPositionButton(sender: UIButton) {
        //現在地取得
        lm.startUpdatingLocation()
    }
    
    /** 位置情報取得成功時 */
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        /* 現在位置 */
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:newLocation.coordinate.latitude,longitude:newLocation.coordinate.longitude)
        gmaps.animateToLocation( CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude) )
        /* ズーム */
        gmaps.animateToZoom(16);
        // GPSの使用を停止する．停止しない限りGPSは実行され，指定間隔で更新され続ける．
        lm.stopUpdatingLocation()
    }
    
    /** 位置情報取得失敗時 */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // なんか表示する
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
