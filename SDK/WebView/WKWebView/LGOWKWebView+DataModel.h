//
//  LGOWKWebView+DataModel.h
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWKWebView.h"

@interface LGOWKWebView (DataModel)

- (void)updateDataModel:(NSString*)dataKey dataValue:(id)dataValue;

- (void)notifyDataModelDidChanged:(NSString*)dataKey dataValue:(id)dataValue;

@end
