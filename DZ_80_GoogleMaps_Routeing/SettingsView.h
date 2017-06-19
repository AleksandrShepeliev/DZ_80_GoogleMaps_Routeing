//
//  SettingsView.h
//  DZ_80_GoogleMaps_Routeing
//
//  Created by macbook pro on 14.06.17.
//  Copyright © 2017 Shepeliev Aleksandr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SettingsView : UIView

@property (weak, nonatomic) IBOutlet UITextField *ibStartPointField;
@property (weak, nonatomic) IBOutlet UITextField *ibFinishPointField;
@property (weak, nonatomic) IBOutlet UITableView *ibStartTableView;
@property (weak, nonatomic) IBOutlet UITableView *ibFinishTableView;
@property (weak, nonatomic) IBOutlet UIButton *ibMyLOcationButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ibTableViewHeightConstraint;
@property (nonatomic, strong) void (^RouteButtonBlock)(SettingsView *view);
@property (nonatomic, strong) void (^ChangeButtonBlock)(SettingsView *view);
@property (nonatomic, strong) void (^MyLocationButtonBlock)();


@end
