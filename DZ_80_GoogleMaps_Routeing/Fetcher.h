//
//  Fetcher.h
//  DZ_80_GoogleMaps_Routeing
//
//  Created by macbook pro on 16.06.17.
//  Copyright © 2017 Shepeliev Aleksandr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fetcher : NSObject

@property (nonatomic, strong) NSMutableArray *fullAddreses;

+ (instancetype)sharedInstans;

- (void)getHelpForGeocodeAddress:(NSString *)address;
- (void)buildARouteFromPoint:(NSString *)startAddressPoint toPoint:(NSString *)finishAddressPoint;

@end
