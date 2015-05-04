//
//  FirstViewController.swift
//  PaddyFront
//
//  Created by K.Mochizuki on 2015/04/29.
//  Copyright (c) 2015年 K.Mochizuki. All rights reserved.
//

import UIKit
import Foundation

class FirstViewController: UIViewController , GMSMapViewDelegate {

    var gmaps : GMSMapView!
    
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
        
        // Buttonを作成する.
        let myButton: UIButton = UIButton(frame: CGRectMake(0, 0, 80, 50))
        myButton.layer.position = CGPointMake(self.view.frame.width/2, self.view.frame.height-100)
        myButton.layer.masksToBounds = true
        myButton.layer.cornerRadius = 20.0
        myButton.setTitle("更新", forState: .Normal)
        myButton.backgroundColor = UIColor.redColor()
        myButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        myButton.addTarget(self, action: "touchUpdateButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myButton)
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
            // フェーズ
            jsonbuf = json[i]["phase"]
            let phase = "\(jsonbuf)"
            
            // マーカー設定
            let marker: GMSMarker = GMSMarker ()
            marker.snippet = daneDate
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
