//
//  LGOViewControllerGlobalValues.h
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/5.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIViewController* (^LGOViewControllerInitializeBlock) (NSDictionary* args);

@interface LGOViewControllerGlobalValues : NSObject

+ (NSDictionary*)LGOViewControllerMapping;

@end


@interface UIViewController (LGO)

- (void) lgo_dismiss;

@end