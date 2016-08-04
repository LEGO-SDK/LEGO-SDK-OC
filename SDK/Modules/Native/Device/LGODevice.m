//
//  LGODevice.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/1.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGODevice.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"


#import <CoreTelephony/CTTelephonyNetworkInfo.h>

// - Response

@interface LGODeviceResponse : LGOResponse

@property (nonatomic, retain) NSString *deviceName;
@property (nonatomic, retain) NSString *deviceModel;
@property (nonatomic, retain) NSString *deviceOSName;
@property (nonatomic, retain) NSString *deviceOSVersion;
@property (nonatomic, retain) NSString *deviceIDFV;
@property (nonatomic, retain) NSString *deviceLanguage;
@property (nonatomic, retain) NSNumber *deviceScreenWidth;
@property (nonatomic, retain) NSNumber *deviceScreenHeight;
@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) NSString *appBundleIdentifier;
@property (nonatomic, retain) NSString *appShortVersion;
@property (nonatomic, retain) NSNumber *appBuildNumber;
@property (nonatomic, retain) NSNumber *networkUsingWIFI;
@property (nonatomic, retain) NSNumber *networkCellularType;

@end


@implementation LGODeviceResponse

+ (NSString *)requestBundleStringValueForKey:(NSString *)aKey {
    NSDictionary *dict = [NSBundle mainBundle].infoDictionary;
    if ([dict[aKey] isKindOfClass:[NSString class]]){
        return dict[aKey];
    }
    return @"";
}

+ (NSNumber *)requestBundleIntValueForKey:(NSString *)aKey {
    NSDictionary *dict = [NSBundle mainBundle].infoDictionary;
    if ([dict[aKey] isKindOfClass:[NSNumber class]]){
        return dict[aKey];
    }
    return [[NSNumber alloc] initWithInt:0];
}

- (NSDictionary *)toDictionary {
    self.deviceName = [UIDevice currentDevice].name;
    self.deviceModel = [UIDevice currentDevice].model;
    self.deviceOSName = [UIDevice currentDevice].systemName;
    self.deviceOSVersion = [UIDevice currentDevice].systemVersion;
    self.deviceIDFV = [UIDevice currentDevice].identifierForVendor.UUIDString;
    self.deviceLanguage = [NSLocale currentLocale].localeIdentifier;
    self.deviceScreenWidth = [NSNumber numberWithFloat: [UIScreen mainScreen].bounds.size.width];
    self.deviceScreenHeight = [NSNumber numberWithFloat: [UIScreen mainScreen].bounds.size.height];
    self.appName = [LGODeviceResponse requestBundleStringValueForKey:@"CFBundleName"];
    self.appBundleIdentifier = [LGODeviceResponse requestBundleStringValueForKey:@"CFBundleIdentifier"];
    self.appShortVersion = [LGODeviceResponse requestBundleStringValueForKey:@"CFBundleShortVersionString"];
    self.appBuildNumber = [LGODeviceResponse requestBundleIntValueForKey:@"CFBundleVersion"];
    self.networkUsingWIFI = @true; //@Td
    self.networkCellularType = @3; //@Td
    
    return @{
             @"device": @{
                        @"name": self.deviceName,
                        @"model": self.deviceModel,
                        @"osName": self.deviceOSName,
                        @"osVersion": self.deviceOSVersion,
                        @"IDFV": self.deviceIDFV,
                        @"screenWidth": self.deviceScreenWidth,
                        @"screenHeight": self.deviceScreenHeight
                     },
             @"application": @{
                        @"name": self.appName,
                        @"bundleIdentifier": self.appBundleIdentifier,
                        @"shortVersion": self.appShortVersion,
                        @"buildNumber": self.appBuildNumber
                     },
             @"network": @{
                        @"usingWIFI": self.networkUsingWIFI,
                        @"cellularType": self.networkCellularType,
                     }
//             @"custom": [LGODevice custom]
             };
}

@end


// - Operation
@interface LGODeviceOperation : LGORequestable

@end

@implementation LGODeviceOperation

- (LGOResponse *)requestSynchronize {
    return [LGODeviceResponse new];
}

@end

// - Module
@implementation LGODevice

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    return [LGODeviceOperation new];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    return [LGODeviceOperation new];
}




@end







