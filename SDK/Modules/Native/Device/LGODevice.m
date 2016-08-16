//
//  LGODevice.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/1.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOBuildFailed.h"
#import "LGOCore.h"
#import "LGODevice.h"
#import "LGODeviceReachability.h"

@interface LGODevice ()

+ (NSDictionary *)custom;

@end

@interface LGODeviceResponse : LGOResponse

@property(nonatomic, strong) NSString *deviceName;
@property(nonatomic, strong) NSString *deviceModel;
@property(nonatomic, strong) NSString *deviceOSName;
@property(nonatomic, strong) NSString *deviceOSVersion;
@property(nonatomic, strong) NSString *deviceIDFV;
@property(nonatomic, strong) NSString *deviceLanguage;
@property(nonatomic, strong) NSNumber *deviceScreenWidth;
@property(nonatomic, strong) NSNumber *deviceScreenHeight;
@property(nonatomic, strong) NSString *appName;
@property(nonatomic, strong) NSString *appBundleIdentifier;
@property(nonatomic, strong) NSString *appShortVersion;
@property(nonatomic, strong) NSNumber *appBuildNumber;
@property(nonatomic, strong) NSNumber *networkUsingWIFI;
@property(nonatomic, strong) NSNumber *networkCellularType;

@end

@implementation LGODeviceResponse

+ (NSString *)requestBundleStringValueForKey:(NSString *)aKey {
    NSDictionary *dict = [NSBundle mainBundle].infoDictionary;
    if ([dict[aKey] isKindOfClass:[NSString class]]) {
        return dict[aKey];
    }
    return @"";
}

+ (NSNumber *)requestBundleIntValueForKey:(NSString *)aKey {
    NSDictionary *dict = [NSBundle mainBundle].infoDictionary;
    if ([dict[aKey] isKindOfClass:[NSNumber class]]) {
        return dict[aKey];
    }
    return [[NSNumber alloc] initWithInt:0];
}

- (NSDictionary *)resData {
    self.deviceName = [UIDevice currentDevice].name;
    self.deviceModel = [UIDevice currentDevice].model;
    self.deviceOSName = [UIDevice currentDevice].systemName;
    self.deviceOSVersion = [UIDevice currentDevice].systemVersion;
    self.deviceIDFV = [UIDevice currentDevice].identifierForVendor.UUIDString;
    self.deviceLanguage = [NSLocale currentLocale].localeIdentifier;
    self.deviceScreenWidth = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.width];
    self.deviceScreenHeight = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.height];
    self.appName = [LGODeviceResponse requestBundleStringValueForKey:@"CFBundleName"];
    self.appBundleIdentifier = [LGODeviceResponse requestBundleStringValueForKey:@"CFBundleIdentifier"];
    self.appShortVersion = [LGODeviceResponse requestBundleStringValueForKey:@"CFBundleShortVersionString"];
    self.appBuildNumber = [LGODeviceResponse requestBundleIntValueForKey:@"CFBundleVersion"];
    self.networkUsingWIFI = [NSNumber numberWithBool:[LGODeviceReachability LGODeviceUsingWifi]];
    self.networkCellularType = [NSNumber numberWithInt:[LGODeviceReachability LGODeviceCellularType]];

    return @{
        @"device" : @{
            @"name" : self.deviceName,
            @"model" : self.deviceModel,
            @"osName" : self.deviceOSName,
            @"osVersion" : self.deviceOSVersion,
            @"IDFV" : self.deviceIDFV,
            @"screenWidth" : self.deviceScreenWidth,
            @"screenHeight" : self.deviceScreenHeight
        },
        @"application" : @{
            @"name" : self.appName,
            @"bundleIdentifier" : self.appBundleIdentifier,
            @"shortVersion" : self.appShortVersion,
            @"buildNumber" : self.appBuildNumber
        },
        @"network" : @{@"usingWIFI" : self.networkUsingWIFI, @"cellularType" : self.networkCellularType},
        @"custom" : [LGODevice custom]
    };
}

@end

@interface LGODeviceOperation : LGORequestable

@end

@implementation LGODeviceOperation

- (LGOResponse *)requestSynchronize {
    return [[LGODeviceResponse new] accept: nil];
}

@end

@implementation LGODevice

static NSDictionary *custom;

+ (NSDictionary *)custom {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      custom = @{};
    });
    return custom;
}

+ (void)configureCustomDictionary:(NSDictionary *)dictionary {
    custom = (dictionary != nil ? dictionary : @{});
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    return [LGODeviceOperation new];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    return [LGODeviceOperation new];
}

- (NSDictionary *)synchronizeResponse:(UIView *)webView {
    return [[[LGODeviceOperation new] requestSynchronize] resData];
}

@end
