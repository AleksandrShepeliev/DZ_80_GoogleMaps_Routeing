//
//  Fetcher.m
//  DZ_80_GoogleMaps_Routeing
//
//  Created by macbook pro on 16.06.17.
//  Copyright © 2017 Shepeliev Aleksandr. All rights reserved.
//

#import "Fetcher.h"
#import <AFNetworking.h>

static NSString *kBaseURLGeocode = @"https://maps.googleapis.com/maps/api/geocode/json";
static NSString *kApiKey = @"AIzaSyC8-q4JUDRPCdHsRAoDnKWi9o0QG4fhU5w";

@interface Fetcher () {
    
}

@end

@implementation Fetcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fullAddreses = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)sharedInstans {
    static Fetcher *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [Fetcher new];
    });
    return manager;
}


- (void)getHelpForGeocodeAddress:(NSString *)address {
    
    NSArray *addressComponents = [address componentsSeparatedByString:@", "];
    
    NSString *formatedAddress = [addressComponents componentsJoinedByString:@"+"];

    NSDictionary *params = @{@"address":formatedAddress, @"key":kApiKey};
    
    [[AFHTTPSessionManager manager] GET:kBaseURLGeocode parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            [self directionCallbacWithResponceObject:responseObject error:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"_________%@", error);
        }
    }];
}

- (void)buildARouteFromPoint:(NSString *)startAddressPoint toPoint:(NSString *)finishAddressPoint {
    
}

- (NSString *)getPointCoordinateForAddress:(NSString *)address {
    NSString *result;
    return result;
}

#pragma mark - Responce

- (void)directionCallbacWithResponceObject:(id)responceObgect error:(NSError *)error {
    
    if (responceObgect) {
        
        // получим варианты адресов
        NSArray *array = [responceObgect objectForKey:@"results"];
        if (array.count > 0) {
            for (NSDictionary *dict in array) {
                
                if ([dict valueForKey:@"formatted_address"]) {
                    [self.fullAddreses removeAllObjects];
                    NSString *fullAddress = [dict valueForKey:@"formatted_address"];
                    [self.fullAddreses addObject:fullAddress];
                }
            }

        } else {
            
        }
    } else if (error) {
        
    }
}


@end
