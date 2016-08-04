//
//  LGOModules.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOModules.h"
#import "LGOCheck.h"
#import "LGOCall.h"
#import "LGOFileManager.h"
#import "LGOHTTPRequest.h"
#import "LGOPasteboard.h"
#import "LGOUserDefaults.h"
#import "LGOCanOpenURL.h"
#import "LGOOpenURL.h"
#import "LGONotification.h"
#import "LGODevice.h"

@implementation LGOModules

- (instancetype)init
{
    self = [super init];
    if (self) {
        _items = [@{
                    @"Native.Check": [LGOCheck new],
                    @"Native.Call": [LGOCall new],
                    @"Native.FileManager": [LGOFileManager new],
                    @"Native.HTTPRequest": [LGOHTTPRequest new],
                    @"Native.Pasteboard": [LGOPasteboard new],
                    @"Native.UserDefaults": [LGOUserDefaults new],
                    @"Native.CanOpenURL": [LGOCanOpenURL new],
                    @"Native.OpenURL": [LGOOpenURL new],
                    @"Native.Notification": [LGONotification new],
                    @"Native.Device": [LGODevice new]
                   } mutableCopy];
    }
    return self;
}

- (void)addModuleWithName:(NSString *)name instance:(LGOModule *)instance {
    [_items setObject:instance forKey:name];
}

- (LGOModule *)moduleWithName:(NSString *)name {
    return _items[name];
}

- (NSArray<NSString *> *)allModules {
    return [_items allKeys];
}

@end
