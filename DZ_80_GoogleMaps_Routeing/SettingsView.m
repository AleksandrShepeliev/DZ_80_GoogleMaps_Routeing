//
//  SettingsView.m
//  DZ_80_GoogleMaps_Routeing
//
//  Created by macbook pro on 14.06.17.
//  Copyright © 2017 Shepeliev Aleksandr. All rights reserved.
//

#import "SettingsView.h"

@interface SettingsView ()  {
    
   
}

@end

@implementation SettingsView

- (UITextField *)ibStartPointField {
    _ibStartPointField.clearButtonMode = UITextFieldViewModeWhileEditing;
    return _ibStartPointField;
}

- (UITextField *)ibFinishPointField {
    _ibFinishPointField.clearButtonMode = UITextFieldViewModeWhileEditing;
    return _ibFinishPointField;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

#pragma mark - Actions

- (IBAction)buildARouteButtonClicked:(UIButton *)sender {
    
    if ([self.ibStartPointField isEditing]) {
        [self.ibStartPointField resignFirstResponder];
    } else {
        [self.ibFinishPointField resignFirstResponder];
    }
    
    _RouteButtonBlock(self);
}

- (IBAction)myLocationButtonClicked:(UIButton *)sender {
    [self.ibStartPointField setText:@"Ваше текущее местоположение"];
    self.ibTableViewHeightConstraint.constant = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:_ibStartPointField userInfo:@{@"info":@"Do not send request!"}];
    
    _MyLocationButtonBlock();
    NSLog(@"myLocationButtonClicked");
}

- (IBAction)changeRolesButttonClicked:(id)sender {
    
    NSString *startText = _ibStartPointField.text;
    self.ibStartPointField.text = _ibFinishPointField.text;
    self.ibFinishPointField.text = startText;
    
    _ChangeButtonBlock(self);
    NSLog(@"changeRolesButttonClicked");
}

@end
