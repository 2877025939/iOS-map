//
//  ViewController.m
//  系统高德地图
//
//  Created by anan on 2017/7/4.
//  Copyright © 2017年 Plan. All rights reserved.
//

#import "ViewController.h"
#import "Header.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "myAnnotation.h"

#define moreiOS8  ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0)

@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate>{
   
    double _latitude;
    double _longitude;
    double _myLatitude;
    double _myLongitude;
}

/** 定位 */
@property (nonatomic,strong) CLLocationManager *locationManager;
/** 地图 */
@property (nonatomic,strong) MKMapView * mapView;
/** 地理编码 */
@property (nonatomic, strong) CLGeocoder *geoC;

/** 目标位置标题 */
@property (nonatomic,copy) NSString *str;

/** 发送请求给服务器 */
@property (nonatomic,strong) MKDirections *directions;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"规划" style:UIBarButtonItemStylePlain target:self action:@selector(click)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"导航" style:UIBarButtonItemStylePlain target:self action:@selector(leftClick)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self createMap];
    
    [self createLocation];
    
    [self createGeoC1];
   
}

-(void)createMap{
    
    self.mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mapView.mapType =  MKMapTypeStandard;
    //显示指南针
    self.mapView.showsCompass = YES;
    //显示比例尺
    self.mapView.showsScale = YES;
    //显示用户所在的位置
    self.mapView.showsUserLocation = YES;
    
    
    self.mapView.delegate =self;
    
    [self.view addSubview:self.mapView];

    //一些属性 可以自己看一下啊
//    显示感兴趣的东西
//    self.mapView.showsPointsOfInterest = YES;
//    //定义显示的范围span范围
//    MKCoordinateSpan theSpan;
//    theSpan.latitudeDelta =0.01;
//    theSpan.longitudeDelta =0.01;
//    //定义显示的区域 region区域范围
//    MKCoordinateRegion theRegion;
//    // theRegion.center = theCoordinate;
//    theRegion.span=theSpan;
//    //显示交通状况
//    self.mapView.showsTraffic = YES;
//    //显示建筑物
//    self.mapView.showsBuildings = YES;
}

-(void)createLocation{
    
    if ( [CLLocationManager  locationServicesEnabled]) {
        NSLog(@"可以定位");
        
        self.locationManager = [[CLLocationManager alloc]init];
        
        self.locationManager.delegate = self;
        //设置定位精度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置距离
        self.locationManager.distanceFilter = 50;
        //申请定位许可，iOS8以后特有
        if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        
        //开始定位
        [self.locationManager startUpdatingLocation];
        
    }else{
        
        NSLog(@"请打开定位权限");
    }
}

-(void)createGeoC1{
    
    self.geoC = [[CLGeocoder alloc] init];
    
    //获取目标位置
    [self test];
}

//添加大头针
-(void)addAnnoWithPT:(CLLocationCoordinate2D)pt{
    
    myAnnotation *anno = [[myAnnotation alloc] init];
    anno.coordinate = pt;
    anno.title = self.str;
    anno.subtitle = @"张江药谷大厦";
    [self.mapView addAnnotation:anno];
    
}

#pragma mark - 定位代理方法
//locationManager:didUpdateLocations:（调用很频繁）
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    //定位：
    CLLocation *currLocation  =[locations lastObject];
    NSLog(@"定位方法: %@ ",currLocation.description);
    //重置定位
    CLLocationCoordinate2D theCoordinate;
    
    //latitude纬度
    theCoordinate.latitude = currLocation.coordinate.latitude;
    //longitude经度
    theCoordinate.longitude = currLocation.coordinate.longitude;
    
    _myLatitude  = currLocation.coordinate.latitude;
    _myLongitude = currLocation.coordinate.longitude;
    
    //定义显示的范围span范围
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta =0.01;
    theSpan.longitudeDelta =0.01;
    
    //定义显示的区域 region区域范围
    MKCoordinateRegion theRegion;
    theRegion.center = theCoordinate;
    theRegion.span = theSpan;
    
    //设置地图显示
    [self.mapView setRegion:theRegion];
    
    
    
//    CLLocationCoordinate2D theCoordinate1;
//    //latitude纬度
//    theCoordinate1.latitude = 31.193806;
//    //longitude经度
//    theCoordinate1.longitude = 121.606917;
//    
//    
//    CLLocationCoordinate2D theCoordinate2;
//    
//    //latitude纬度
//    theCoordinate2.latitude = 31.191285;
//    //longitude经度
//    theCoordinate2.longitude = 121.607031;
//
//    //添加大头针
//    [self addAnnoWithPT:theCoordinate1];
//    
//    [self addAnnoWithPT:theCoordinate2];
    
}

//定位失败

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    
    NSLog(@"定位失败error%@",error);
}

//方向的更新
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading{
    
}

//用于判断是否显示方向的校对,用于判断是否显示方向的校对,返回yes的时候，将会校对正确之后才会停止
//或者dismissheadingcalibrationdisplay方法解除。
-(BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
    
    return  YES;
}


#pragma mark -   地图代理方法有
//一个位置更改默认只会调用一次，不断监测用户的当前位置
//每次调用，都会把用户的最新位置（userLocation参数）传进来
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{

    userLocation.title = @"现在位置";
    
    
    CLLocationCoordinate2D theCoordinate;
    //latitude纬度
    theCoordinate.latitude = userLocation.coordinate.latitude;
    //longitude经度
    theCoordinate.longitude= userLocation.coordinate.longitude;
    [self.mapView setCenterCoordinate:theCoordinate animated:YES];
    NSLog(@"用户定位: %f %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    
}

//地图的显示区域即将发生改变的时候调用
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
}

//地图的显示区域已经发生改变的时候调用
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
}


//设置大头针
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    
    // 判断大头针位置是否在原点,如果是则不加大头针
    if([annotation isKindOfClass:[mapView.userLocation class]]){
        return nil;
    }
    
    static NSString *inden = @"pappao";
    MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:inden];
    if (pin == nil) {
        pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:inden];
    }
    
    pin.annotation = annotation;
    // 设置是否弹出标注
    pin.canShowCallout = YES;
    pin.image = [UIImage imageNamed:@"map"];
    pin.draggable = YES;
    
    //弹出视图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 25)];
    imageView.image = [UIImage imageNamed:@"map1"];
    pin.leftCalloutAccessoryView = imageView;
    
    return pin;
    
}

#pragma mark - 地理编码
-(void)test{
    
    //根据位置名称转换经纬度
    [self.geoC geocodeAddressString:@"凯信国际广场" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        /**
         *  CLPlacemark
         location : 位置对象
         addressDictionary : 地址字典
         name : 地址全称
         */
        if(error == nil){
            NSLog(@"%@", placemarks);
            [placemarks enumerateObjectsUsingBlock:^(CLPlacemark * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSLog(@"目标位置: %@ %f %f", obj.name, obj.location.coordinate.latitude,obj.location.coordinate.longitude);
                CLLocationCoordinate2D coordinate;
                //latitude纬度
                coordinate.latitude = obj.location.coordinate.latitude;
                //longitude经度
                coordinate.longitude= obj.location.coordinate.longitude;
                
                _latitude  = obj.location.coordinate.latitude;
                _longitude = obj.location.coordinate.longitude;
                
                //计算两个坐标之间的位置
                CLLocation *location1 = [[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude];
                CLLocation *location2 = [[CLLocation alloc] initWithLatitude:_myLatitude longitude:_myLongitude];
                
                float distance = [location1 distanceFromLocation:location2];
                
                NSLog(@"distance %f",distance);
                
                self.str = [NSString stringWithFormat:@"距离:%.3fkm",distance/1000];
                
                //添加大头针
                [self addAnnoWithPT:coordinate];
                
                
            }];
        }else{
            NSLog(@"cuowu--%@", error.localizedDescription);
        }
        
    }];

}

#pragma mark - 反地理编码
-(void)testLatitude:(CLLocationDegrees)latitude
          longitude:(CLLocationDegrees)longitude{
    

    //地理反编码根据经纬度，获取位置信息
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    [self.geoC reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(error == nil)
        {
            NSLog(@"%@", placemarks);
            
            [placemarks enumerateObjectsUsingBlock:^(CLPlacemark * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"%@\n ", obj.name);
               
            }];
        }else
        {
            NSLog(@"cuowu");
        }
        
    }];

}


#pragma mark - 触摸手势
//-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

//    // 1. 获取当前触摸点
//    CGPoint point = [[touches anyObject] locationInView:self.mapView];
//
//    // 2. 转换成经纬度
//    CLLocationCoordinate2D pt = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
//
//    // 3. 添加大头针
//    [self addAnnoWithPT:pt];

//}

//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    // 移除大头针(模型)
//    NSArray *annos = self.mapView.annotations;
//    [self.mapView removeAnnotations:annos];
//}



#pragma mark  提供两个点，路径规划
-(void)moveWith:(MKMapItem *)source toDestination:(MKMapItem *)destination{
    
    //创建请求体
    // 创建请求体 (起点与终点)
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = source;
    request.destination = destination;
    
    self.directions = [[MKDirections alloc]initWithRequest:request];
    
    // 计算路线规划信息 (向服务器发请求)
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        
        //获取到所有路线
        NSArray <MKRoute *> *routesArray = response.routes;
        //取出最后一条路线
        MKRoute *rute = routesArray.lastObject;
        
        //路线中的每一步
        NSArray <MKRouteStep *>*stepsArray = rute.steps;
        
        //遍历
        for (MKRouteStep *step in stepsArray) {
            
            [self.mapView addOverlay:step.polyline];
        }
        
    }];
    
}

// 返回指定的遮盖模型所对应的遮盖视图, renderer-渲染
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    // 判断类型
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        // 针对线段, 系统有提供好的遮盖视图
        MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        
        // 配置，遮盖线的颜色
        render.lineWidth = 5;
        render.strokeColor = [UIColor lightGrayColor];
        //[UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1.0];
        
        return render;
    }
    // 返回nil, 是没有默认效果
    return nil;
}


#pragma mark - 跳转第三方地图导航
-(void)leftClick{
    
    
    if (moreiOS8) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"导航到设备" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        //自带地图
        [alert addAction:[UIAlertAction actionWithTitle:@"自带地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSLog(@"alertController -- 自带地图");
            
            //使用自带地图导航
            MKMapItem *currentLocation =[MKMapItem mapItemForCurrentLocation];
            
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(_latitude, _longitude) addressDictionary:nil]];
            
            [MKMapItem openMapsWithItems:@[currentLocation,toLocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                                                                       MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
            
            
        }]];
        
        //判断是否安装了高德地图，如果安装了高德地图，则使用高德地图导航
        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
            
            [alert addAction:[UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSLog(@"alertController -- 高德地图");
                NSString *urlsting =[[NSString stringWithFormat:@"iosamap://navi?sourceApplication= &backScheme= &lat=%f&lon=%f&dev=0&style=2",_latitude,_longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[UIApplication  sharedApplication]openURL:[NSURL URLWithString:urlsting]];
                
            }]];
        }
        
        //判断是否安装了百度地图，如果安装了百度地图，则使用百度地图导航
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
            [alert addAction:[UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSLog(@"alertController -- 百度地图");
                NSString *urlsting =[[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",_latitude,_longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting]];
                
            }]];
        }
        
        //添加取消选项
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            [alert dismissViewControllerAnimated:YES completion:nil];
            
        }]];
        
        //显示alertController
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    else {  //系统版本低于8.0，则使用UIActionSheet
        
        UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"导航到设备" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"自带地图", nil];
        
        //如果安装高德地图，则添加高德地图选项
        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
            
            [actionsheet addButtonWithTitle:@"高德地图"];
            
        }
        
        //如果安装百度地图，则添加百度地图选项
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
            
            
            [actionsheet addButtonWithTitle:@"百度地图"];
        }
        
        [actionsheet showInView:self.view];
        
    }
}

#pragma mark - 开始规划路线
-(void)click{
    NSLog(@"开始规划路线");
    
    //    地理反编码根据经纬度，获取位置信息 这个误差较大
    //    CLLocation *loc  = [[CLLocation alloc] initWithLatitude:_myLatitude longitude:_myLongitude];
    //    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude];
    //
    //    [self.geoC reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
    //
    //       MKMapItem *intrItem = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithPlacemark:[placemarks lastObject]]];
    //
    //        // 让地图跳转到起点所在的区域
    //        MKCoordinateRegion region = MKCoordinateRegionMake(intrItem.placemark.location.coordinate, MKCoordinateSpanMake(0.02, 0.02));
    //
    //        [self.mapView setRegion:region];
    //
    //
    //        [self.geoC reverseGeocodeLocation:loc1 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
    //
    //            MKMapItem *destItem = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithPlacemark:[placemarks lastObject]]];
    //
    //            //调用下面方法发送请求
    //            [self moveWith:intrItem toDestination:destItem];
    //
    //        }];
    //
    //    }];
    
    
    //根据位置名称转换经纬度
    [self.geoC geocodeAddressString:@"凯信国际广场" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        MKMapItem *source = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithPlacemark:[placemarks lastObject]]];
        
        MKCoordinateRegion region = MKCoordinateRegionMake(source.placemark.location.coordinate, MKCoordinateSpanMake(0.02, 0.02));
        
        [self.mapView setRegion:region];
        
        [self.geoC geocodeAddressString:@"上海市浦东新区张江药谷大厦" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            MKMapItem *destination = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithPlacemark:[placemarks lastObject]]];
            
            //调用下面方法发送请求
            [self moveWith:source toDestination:destination];
            
        }];
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
