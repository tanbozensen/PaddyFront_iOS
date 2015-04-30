//
//  FirstViewController.swift
//  PaddyFront
//
//  Created by K.Mochizuki on 2015/04/29.
//  Copyright (c) 2015年 K.Mochizuki. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController , GMSMapViewDelegate {

    var gmaps : GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let lat: CLLocationDegrees = 36.3162
        let lon: CLLocationDegrees = 137.8652
        let zoom: Float = 4.8
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(lat,longitude: lon,zoom: zoom);
        gmaps = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        gmaps.camera = camera
        self.view.addSubview(gmaps)
        
        for ( var i = 0, n = 10 ; i < n ; i++ ) {
            var marker: GMSMarker = GMSMarker ()
            marker.position = CLLocationCoordinate2DMake(34.689197, 135.502321)
            marker.snippet = "Hello World"
            if ( i == 0) {
                marker.icon = UIImage(named: "nae50.png")
            }
            else {
                marker.icon = UIImage(named: "ine50.png")
            }
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = gmaps;
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

