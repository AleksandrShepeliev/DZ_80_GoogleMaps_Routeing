//
//  ViewController.m
//  DZ_80_GoogleMaps_Routeing
//
//  Created by macbook pro on 14.06.17.
//  Copyright © 2017 Shepeliev Aleksandr. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SettingsView.h"
#import "Fetcher.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>

typedef void(^BuildARouteBlock)(SettingsView *view);
typedef void(^CangePointsCoordinateBlock)(SettingsView *view);
typedef void(^MyLocationBlock)();

static CGRect kSettingsViewShowFrame;
static CGRect kSettingsViewHideFrame;
static NSString *kBaseURLGeocode = @"https://maps.googleapis.com/maps/api/geocode/json";
static NSString *kBaseRouteURL =  @"https://maps.googleapis.com/maps/api/directions/json";
static NSString *kApiKey = @"AIzaSyC8-q4JUDRPCdHsRAoDnKWi9o0QG4fhU5w";

@interface ViewController () <GMSMapViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    NSMutableArray<GMSPolyline *> *polylinesArray;
    NSMutableArray *dataSources;
   __block CGFloat tempLatitude;
   __block CGFloat tempLongitude;
    //__weak SettingsView *settingsView;
}

@property (nonatomic, weak) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) SettingsView *settingsView;
@property (nonatomic, strong) NSString *startPoint;
@property (nonatomic, strong) NSString *finishPoint;
@property (nonatomic, strong) GMSMarker *startMarker;
@property (nonatomic, strong) GMSMarker *finishMarker;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Построение маршрута";
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;

    polylinesArray = [NSMutableArray array];

    dataSources = [NSMutableArray array];
    
    _settingsView = [[NSBundle mainBundle] loadNibNamed:@"SettingsView" owner:nil options:nil].firstObject;
    kSettingsViewShowFrame = CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), 200);
    kSettingsViewHideFrame = CGRectMake(0, -200, CGRectGetWidth(self.view.bounds), 200);
    _settingsView.frame = kSettingsViewHideFrame;
    _settingsView.ibTableViewHeightConstraint.constant = 0;
    _settingsView.RouteButtonBlock = [self initBuildARouteBlock];
    _settingsView.ChangeButtonBlock = [self initCangePointsCoordinateBlock];
    _settingsView.MyLocationButtonBlock = [self initMyLocationBlock];
    
    [self.view addSubview:_settingsView];
    
    _settingsView.ibStartPointField.delegate = self;
    _settingsView.ibFinishPointField.delegate = self;
    
    _settingsView.ibStartTableView.delegate = self;
    _settingsView.ibStartTableView.dataSource = self;
    
    _settingsView.ibFinishTableView.delegate = self;
    _settingsView.ibFinishTableView.dataSource = self;
    
    [self showSettingsView];
    
    _startMarker = [GMSMarker new];
    _startMarker.icon = [UIImage imageNamed:@"start_pin"];
    _startMarker.map = self.mapView;
    
    _finishMarker = [GMSMarker new];
    _finishMarker.icon = [UIImage imageNamed:@"finish_pin"];
    _finishMarker.map = self.mapView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeText:) name:UITextFieldTextDidChangeNotification object:nil];

}

- (BuildARouteBlock)initBuildARouteBlock {
    
    __weak ViewController *weakSelf = self;
    BuildARouteBlock buildARoute = ^(SettingsView *view) {
        [weakSelf hideSettingsView];
        [SVProgressHUD showWithStatus:@""];
        for (GMSPolyline *polyline in polylinesArray) {
            polyline.map = nil;
        }
        [polylinesArray removeAllObjects];
        [weakSelf buildARoute];
    };
    
    return buildARoute;
}

- (CangePointsCoordinateBlock)initCangePointsCoordinateBlock {
    //__weak ViewController *weakSelf = self;
    CangePointsCoordinateBlock changeCoordinate = ^(SettingsView *view) {
        
        NSString *startPoint = _startPoint;
        _startPoint = _finishPoint;
        self.finishPoint = startPoint;
    };
    
    return changeCoordinate;
}

- (MyLocationBlock)initMyLocationBlock {
    __weak ViewController *weakSelf = self;
    MyLocationBlock myLocation = ^() {
        weakSelf.startPoint = [NSString stringWithFormat:@"%f,%f", weakSelf.mapView.myLocation.coordinate.latitude, weakSelf.mapView.myLocation.coordinate.longitude];
    };
    return myLocation;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Auxiliary methods

- (void)showSettingsView {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _settingsView.frame = kSettingsViewShowFrame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideSettingsView {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _settingsView.frame = CGRectMake(0,- CGRectGetHeight(_settingsView.frame) -44, CGRectGetWidth(_settingsView.frame), CGRectGetHeight(_settingsView.frame));
    } completion:^(BOOL finished) {
        _settingsView.ibTableViewHeightConstraint.constant = 0;
        _settingsView.frame = kSettingsViewHideFrame;
    }];
}

- (void)showTableView:(UITableView *)tableView {
    CGFloat height = tableView.contentSize.height;
    
    if ([tableView isEqual:_settingsView.ibStartTableView]) {

        _settingsView.ibTableViewHeightConstraint.constant = height;
        _settingsView.frame = CGRectMake(0, 44, self.view.bounds.size.width, 200 + _settingsView.ibTableViewHeightConstraint.constant);
    } else {
        _settingsView.frame = CGRectMake(0, 44, self.view.bounds.size.width, 200 + height);
    }
    
}

#pragma mark - Actions

- (IBAction)settingsButtonClecked:(UIBarButtonItem *)sender {
    [self showSettingsView];
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _settingsView.ibStartPointField) {
        _settingsView.ibMyLOcationButton.enabled = YES;
    }
    textField.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _settingsView.ibTableViewHeightConstraint.constant = 0;
    _settingsView.frame = kSettingsViewShowFrame;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
        return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _settingsView.ibStartPointField) {
        [_settingsView.ibFinishPointField becomeFirstResponder];
        
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    cell.textLabel.text = dataSources[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_settingsView.ibStartPointField.editing) {
        _settingsView.ibStartPointField.text = dataSources[indexPath.row];
        _settingsView.ibTableViewHeightConstraint.constant = 0;
        _settingsView.frame = kSettingsViewShowFrame;
    } else {
        _settingsView.ibFinishPointField.text = dataSources[indexPath.row];
        _settingsView.frame = kSettingsViewShowFrame;
    }
}

#pragma mark - Notifications

- (void)didChangeText:(NSNotification *)notification {
    
    if (!notification.userInfo) {
        
        if ( [notification.object isEqual:_settingsView.ibStartPointField]) {
            
            if (_settingsView.ibStartPointField.text.length != 0) {
                _settingsView.ibMyLOcationButton.enabled = NO;
            } else {
                _settingsView.ibMyLOcationButton.enabled = YES;
            }
            if (_settingsView.ibStartPointField.text.length > 2) {
                
                [self getHelpForGeocodeAddress:_settingsView.ibStartPointField.text];
                [self showTableView:_settingsView.ibStartTableView];
                
            }
        } else if (_settingsView.ibFinishPointField.text.length > 2) {
            
            [self getHelpForGeocodeAddress:_settingsView.ibFinishPointField.text];
            [self showTableView:_settingsView.ibFinishTableView];
        }
    }
}

#pragma mark - Request

- (void)getHelpForGeocodeAddress:(NSString *)address {
    
    NSArray *addressComponents = [address componentsSeparatedByString:@", "];
    
    NSString *formatedAddress = [addressComponents componentsJoinedByString:@"+"];
    
    NSDictionary *params = @{@"address":formatedAddress, @"language":@"ru", @"key":kApiKey};
    
    [[AFHTTPSessionManager manager] GET:kBaseURLGeocode parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            [self directionCallbacWithResponceObject:responseObject error:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"_________%@", error);
            [self directionCallbacWithResponceObject:nil error:error];
        }
    }];
}

- (void)buildARoute {
    
    NSDictionary *params = @{@"origin":_startPoint, @"destination":_finishPoint, @"language":@"ru", @"key":kApiKey};
    
    // выполняем запрос
    [[AFHTTPSessionManager manager] GET:kBaseRouteURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            
            NSArray *array = [responseObject objectForKey:@"routes"];
            
            if (array.count > 0) {
                
                [SVProgressHUD dismiss];
                
                for (NSDictionary *routData in array) {
                    NSString *points = [routData valueForKeyPath:@"overview_polyline.points"];
                    GMSPath *path = [GMSPath pathFromEncodedPath:points];
                    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                    
                    polyline.map = self.mapView;
                    polyline.strokeWidth = 2;
                    polyline.tappable = YES;
                    [polylinesArray addObject:polyline];
                }
                [self selectPolyline:[polylinesArray firstObject]];
                
                tempLatitude = [[array valueForKeyPath:@"bounds.northeast.lat"][0] floatValue];
                tempLongitude = [[array valueForKeyPath:@"bounds.northeast.lng"][0] floatValue];
                
                CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(tempLatitude, tempLongitude);
                
                tempLatitude = [[array valueForKeyPath:@"bounds.southwest.lat"][0] floatValue];
                tempLongitude = [[array valueForKeyPath:@"bounds.southwest.lng"][0] floatValue];
                CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(tempLatitude, tempLongitude);
                
                GMSCoordinateBounds *screenBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast coordinate:southWest];
                GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:screenBounds withPadding:40];
                [self.mapView animateWithCameraUpdate:cameraUpdate];
                
            } else {
                //polyline.map = nil;
                [SVProgressHUD showWithStatus:@"не удалось построить маршрут"];
                [SVProgressHUD dismissWithDelay:3];
            }
        }
        //
        
        //[self directionCallbacWithResponceObject:responseObject error:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"____________ERROR %@", error);
        }
        //[self directionCallbacWithResponceObject:nil error:error];
    }];

}

#pragma mark - Responce

- (void)directionCallbacWithResponceObject:(id)responceObgect error:(NSError *)error {
    
    if (responceObgect) {
        
        // построим маршрут
        
        //routes

        NSArray *array = [responceObgect objectForKey:@"results"];
        
        if (array.count > 0) {
            for (NSDictionary *dict in array) {
                
                if ([dict valueForKey:@"formatted_address"]) {
                    [dataSources removeAllObjects];
                    NSString *fullAddress = [dict valueForKey:@"formatted_address"];
                    [dataSources addObject:fullAddress];
                    tempLatitude = [[dict valueForKeyPath:@"geometry.location.lat"] floatValue];
                    tempLongitude = [[dict valueForKeyPath:@"geometry.location.lng"] floatValue];
                    NSString *pointCoordinate = [NSString stringWithFormat:@"%f,%f", tempLatitude, tempLongitude];
                    
                    if (_settingsView.ibStartPointField.editing) {
                        
                        self.startPoint = pointCoordinate;
                        self.startMarker.position = CLLocationCoordinate2DMake(tempLatitude, tempLongitude);
                    } else {
                        
                        self.finishPoint = pointCoordinate;
                        self.finishMarker.position = CLLocationCoordinate2DMake(tempLatitude, tempLongitude);
                        self.finishMarker.groundAnchor = CGPointMake(0.8, 1.0);
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (dataSources.count) {
                    
                    [_settingsView.ibStartTableView reloadData];
                    [_settingsView.ibFinishTableView reloadData];
                }
            });
            
        } else {
            
        }
    } else if (error) {
        
    }
}

- (void)selectPolyline:(GMSOverlay *)overlay {
    
    for (GMSPolyline *polyline in polylinesArray) {
        if (polyline == overlay) {
            polyline.strokeColor = [UIColor blueColor];
        } else {
            polyline.strokeColor = [[self randomColor] colorWithAlphaComponent:0.5];
        }
    }
}

- (UIColor *)randomColor {
    
    CGFloat r = (CGFloat)(arc4random() %256) / 255.f;
    CGFloat g = (CGFloat)(arc4random() %256) / 255.f;
    CGFloat b = (CGFloat)(arc4random() %256) / 255.f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
