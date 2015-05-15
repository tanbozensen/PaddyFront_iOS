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
    
    // 現在地マーカー
    var currentMarker: GMSMarker = GMSMarker ()
    
    // マップ切り替えボタン
    let mapChangeButton: UIButton = UIButton(frame: CGRectMake(0, 0, 80, 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // タブボタンカラー設定
        let colorKey = UIColor(red: 0/255, green: 137/255, blue: 80/255, alpha: 1.0)
        UITabBar.appearance().tintColor = colorKey
        
        // GoogleMap 初期設定
        let lat: CLLocationDegrees = 36.3162
        let lon: CLLocationDegrees = 137.8652
        let zoom: Float = 4.8
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(lat,longitude: lon,zoom: zoom);
        gmaps = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        gmaps.camera = camera
        gmaps.mapType = kGMSTypeNormal;
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
        updateButton.layer.position = CGPointMake(self.view.frame.width/6, 50)
        updateButton.layer.masksToBounds = true
        updateButton.layer.cornerRadius = 20.0
        updateButton.setTitle("更新", forState: .Normal)
        updateButton.backgroundColor = UIColor.whiteColor()
        updateButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        updateButton.addTarget(self, action: "touchUpdateButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(updateButton)

        // 現在位置表示 Buttonを作成する.
        let positionButton: UIButton = UIButton(frame: CGRectMake(0, 0, 80, 50))
        positionButton.layer.position = CGPointMake(self.view.frame.width/6 * 3, 50)
        positionButton.layer.masksToBounds = true
        positionButton.layer.cornerRadius = 20.0
        positionButton.setTitle("現在位置", forState: .Normal)
        positionButton.backgroundColor = UIColor.whiteColor()
        positionButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        positionButton.addTarget(self, action: "touchPositionButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(positionButton)
        
        // map切り替え Buttonを作成する.
        mapChangeButton.layer.position = CGPointMake(self.view.frame.width/6 * 5, 50)
        mapChangeButton.layer.masksToBounds = true
        mapChangeButton.layer.cornerRadius = 20.0
        mapChangeButton.setTitle("衛生写真", forState: .Normal)
        mapChangeButton.backgroundColor = UIColor.whiteColor()
        mapChangeButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        mapChangeButton.addTarget(self, action: "touchMapChangeButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(mapChangeButton)
    
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
            var riceTypeStr: String = ""
            var j = 0
            for ( j = 1 ; j < riceTypeTbl.count ; j++ ) {   // 選択なし飛ばす
                if ( riceType == riceTypeTbl[j][0] ){
                    riceTypeStr = riceTypeTbl[j][1]
                }
            }
            // 耕作面積
            var areaUnderTillage = ""
            if ( json[i]["area_under_tillage"].isError ) {
            }
            else {
                jsonbuf = json[i]["area_under_tillage"]
                areaUnderTillage = "\(jsonbuf)"
            }
            // フェーズ
            jsonbuf = json[i]["phase"]
            let phase = "\(jsonbuf)"
            
            // マーカー設定
            var snippetStr = daneDate
            if ( riceTypeStr != "") {
                snippetStr += "\n" + "品種 : " + riceTypeStr
            }
            if ( areaUnderTillage != "") {
                snippetStr += "\n" + "耕作面積 : " + areaUnderTillage + "ha"
            }
            let marker: GMSMarker = GMSMarker ()
            marker.snippet = snippetStr
            if ( phase == "0") {
                marker.icon = UIImage(named: "nae40.png")
            }
            else{
                marker.icon = UIImage(named: "tawara30.png")
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
        
        // 現在地マーカー設定
        currentMarker.map = nil
        currentMarker.snippet = "現在地"
        currentMarker.appearAnimation = kGMSMarkerAnimationPop;
        currentMarker.position = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
        // マーカーをマップへ表示
        currentMarker.map = gmaps;
        
        // GPSの使用を停止する．停止しない限りGPSは実行され，指定間隔で更新され続ける．
        lm.stopUpdatingLocation()
        
        
    }
    
    /** 位置情報取得失敗時 */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // なんか表示する
    }
    
    func touchMapChangeButton(sender: UIButton) {
        if ( mapChangeButton.titleLabel?.text == "衛生写真" ) {
            mapChangeButton.setTitle("地図", forState: .Normal)
            gmaps.mapType = kGMSTypeHybrid
        }
        else {
            mapChangeButton.setTitle("衛生写真", forState: .Normal)
            gmaps.mapType = kGMSTypeNormal
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}
