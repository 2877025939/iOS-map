//
//  ViewController.swift
//  systemmap(Swift)
//
//  Created by anan on 2017/8/1.
//  Copyright © 2017年 Plan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class ViewControlvar: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate
{
   
    var latitude :Double = 0.0
    var longitude :Double = 0.0
    var myLatitude :Double = 0.0
    var myLongitude :Double = 0.0

    var locationManager :CLLocationManager?
    var mapView :MKMapView!
    var geoC :CLGeocoder?
    var str :String!
    var directions :MKDirections?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "规划", style: .plain, target: self, action:#selector(click))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "导航", style: .plain, target: self, action:#selector(leftClick))
        
        createMap()
        
        createLocation()
    
        createGeoC1()
    }
    
    func createMap() -> Void {
     
        mapView = MKMapView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView?.mapType = MKMapType.standard
        mapView?.showsScale = true
        mapView?.showsCompass = true
        mapView?.showsUserLocation = true
        mapView?.delegate = self
        self.view.addSubview(mapView!)
        
    }
    
    func createLocation() -> Void {
        
        if CLLocationManager.locationServicesEnabled() {
            print("可以定位")
            
            locationManager = CLLocationManager.init()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.distanceFilter = 50
            
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager?.requestWhenInUseAuthorization()
            }
            locationManager?.startUpdatingLocation()
        }else{
            
            print("打开定位权限")
        }
    }
    
    
    func createGeoC1() -> Void {
        geoC = CLGeocoder.init()
        
        test()
    }
    
    //MARK: - CLLocationManagerDelegate
    
    //定位成功
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("定位成功");
        
        //定位：
        let currLocation = locations.last
        
        //CLLocation *currLocation  =[locations lastObject];
        
    
        //重置定位
        var theCoordinate = CLLocationCoordinate2D()
        
        //latitude纬度
        theCoordinate.latitude = (currLocation?.coordinate.latitude)!;
        //longitude经度
        theCoordinate.longitude = (currLocation?.coordinate.longitude)!;
        
        myLatitude  = (currLocation?.coordinate.latitude)!;
        myLongitude = (currLocation?.coordinate.longitude)!;
        
        //定义显示的范围span范围
        var theSpan = MKCoordinateSpan()
        
        theSpan.latitudeDelta = 0.01;
        theSpan.longitudeDelta = 0.01;
        
        //定义显示的区域 region区域范围
       var theRegion =  MKCoordinateRegion()
        theRegion.center = theCoordinate
        theRegion.span = theSpan
        
        //设置地图显示
        mapView.region = theRegion
        //[self.mapView setRegion:theRegion];
    }
    
    //定位失败
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失败!详见：\(error)");
        
    }
    
    //方向更新
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
    }
    
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
       
        return true
    }
    
    
    //MARK:  地图代理方法
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        userLocation.title = "现在位置"
        
        var theCoordinate = CLLocationCoordinate2D()
        
        //latitude纬度
        theCoordinate.latitude = userLocation.coordinate.latitude;
        //longitude经度
        theCoordinate.longitude = userLocation.coordinate.longitude;
        
        mapView.setCenter(theCoordinate, animated: true)
        
        
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 判断大头针位置是否在原点,如果是则不加大头针
        if annotation is MKUserLocation  {
            
            return nil
        }
        
        let inden = "pappap"
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: inden)
        
        if pin == nil {
            pin = MKAnnotationView.init(annotation: annotation, reuseIdentifier: inden)
            pin?.annotation = annotation
//            pin?.canShowCallout = true
//            pin?.isDraggable = true
            
        }
       
        pin?.image = UIImage(named: "map")
        let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 25))
        imageView.image = UIImage(named: "map1")
        //pin?.leftCalloutAccessoryView = imageView;
        pin?.detailCalloutAccessoryView = imageView
        return pin
        
    }
    
    
    
    func test() -> Void {
        
        geoC?.geocodeAddressString("张江药谷大厦", completionHandler: { (pls: [CLPlacemark]?, error: Error?)  in
            
            if error == nil {
                print("地理编码成功")
                guard pls != nil else {return}
                
                let firstPL = pls?.first
               // self.addressTV.text = firstPL?.name
               self.latitude = (firstPL?.location?.coordinate.latitude)!
               self.longitude = (firstPL?.location?.coordinate.longitude)!
                
                //计算两个坐标之间的位置
               let location1 = CLLocation.init(latitude: self.latitude, longitude: self.longitude)
               let location2 = CLLocation.init(latitude: self.myLatitude, longitude: self.myLongitude)
                
               let distance  = location1.distance(from: location2)
                
               self.str = String(format: "%", arguments: [distance/1000])
                
                
               
               self.addAnnoWithPT(pt: (firstPL?.location?.coordinate)!)
                
                
                
                
            }else {
                print("错误")
            }
        })
    }
    
    func addAnnoWithPT(pt:CLLocationCoordinate2D) -> Void {
        
        
        //创建一个大头针对象
        let objectAnnotation = MKPointAnnotation()
        
        //设置大头针的显示位置
        objectAnnotation.coordinate = CLLocation(latitude: pt.latitude,
                                                 longitude: pt.longitude).coordinate
        //设置点击大头针之后显示的标题
        objectAnnotation.title = self.str
        //设置点击大头针之后显示的描述
        objectAnnotation.subtitle = "张江药谷大厦"
       
        
        //添加大头针
        self.mapView.addAnnotation(objectAnnotation)
        
//        let anno = myAnnotation.init()
//
//        anno.coordinate = pt
//        anno.title = self.str!
//        anno.subtitle = "张江药谷大厦"
//        
//        self.mapView.addAnnotation(anno as! MKAnnotation)
    }
    
    func click() -> Void {
        
    }

    
    func leftClick() -> Void {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

