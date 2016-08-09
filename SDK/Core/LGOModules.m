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
#import "LGODataModel.h"
#import "LGODevice.h"
#import "LGOActionSheet.h"
#import "LGOAlertView.h"
#import "LGOBounce.h"
#import "LGOIndicatorView.h"
#import "LGOStatusBar.h"
#import "LGOAppFrame.h"
#import "LGORefresh.h"
#import "LGOImagePreviewer.h"
#import "LGOModalController.h"
#import "LGONavigationItem.h"
#import "LGONavigationController.h"

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
                    @"Native.DataModel": [LGODataModel new],
                    @"Native.Device": [LGODevice new],
                    @"UI.ActionSheet": [LGOActionSheet new],
                    @"UI.AlertView": [LGOAlertView new],
                    @"UI.Bounce": [LGOBounce new],
                    @"UI.IndicatorView": [LGOIndicatorView new],
                    @"UI.StatusBar": [LGOStatusBar new],
                    @"UI.AppFrame": [LGOAppFrame new],
                    @"UI.Refresh": [LGORefresh new],
                    @"UI.ImagePreviewer": [LGOImagePreviewer new],
                    @"UI.ModalController": [LGOModalController new],
                    @"UI.NavigationItem": [LGONavigationItem new],
                    @"UI.NavigationController": [LGONavigationController new]
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
