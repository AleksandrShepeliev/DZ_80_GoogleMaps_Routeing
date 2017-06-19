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

typedef void(^BuildARouteBlock)(SettingsView *view);

@interface ViewController () <GMSMapViewDelegate, UITextFieldDelegate> {
    
    NSMutableArray<GMSPolyline *> *polylinesArray;
    //__weak SettingsView *settingsView;
}

@property (nonatomic, weak) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) SettingsView *settingsView;
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
    _settingsView = [[NSBundle mainBundle] loadNibNamed:@"SettingsView" owner:nil options:nil].firstObject;
    _settingsView.frame = CGRectMake(0, -200, CGRectGetWidth(self.view.bounds), 200);
    
//    __weak ViewController *weakSelf = self;
//    buildARoute = ^(SettingsView *view) {
//        
//        [weakSelf hideSettingsView];
//    };
    
    _settingsView.RouteButtonBlock = [self initBuildARouteBlock];
    [self.view addSubview:_settingsView];
    
    _settingsView.ibStartPointField.delegate = self;
    _settingsView.ibFinishPointField.delegate = self;
    
    [self showSettingsView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeText:) name:UITextFieldTextDidChangeNotification object:nil];

}

- (BuildARouteBlock)initBuildARouteBlock {
    
    __weak ViewController *weakSelf = self;
    BuildARouteBlock buildARoute = ^(SettingsView *view) {
        [weakSelf hideSettingsView];
    };
    
    return buildARoute;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Auxiliary methods

- (void)showSettingsView {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _settingsView.frame = CGRectMake(0, 44, CGRectGetWidth(_settingsView.frame), CGRectGetHeight(_settingsView.frame));
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideSettingsView {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _settingsView.frame = CGRectMake(0,- CGRectGetHeight(_settingsView.frame) -44, CGRectGetWidth(_settingsView.frame), CGRectGetHeight(_settingsView.frame));
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Actions

- (IBAction)settingsButtonClecked:(UIBarButtonItem *)sender {
    [self showSettingsView];
    
}

#pragma mark - UITextFieldDelegate

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

#pragma mark - Notifications 

- (void)didChangeText:(NSNotification *)notification {
    
    if ( [notification.object isEqual:_settingsView.ibStartPointField]) {
        
        if (_settingsView.ibStartPointField.text.length != 0) {
            _settingsView.ibMyLOcationButton.enabled = NO;
        } else {
            _settingsView.ibMyLOcationButton.enabled = YES;
        }
    }
}
@end
