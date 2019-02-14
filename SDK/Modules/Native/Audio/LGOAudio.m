//
//  LGOAudio.m
//  Sample
//
//  Created by errnull on 2019/1/28.
//  Copyright © 2019 UED Center. All rights reserved.
//

#import "LGOCore.h"
#import "LGOAudio.h"
#import <AudioToolbox/AudioToolbox.h>

typedef NS_OPTIONS(NSUInteger, LGOAudioType){
    LGOAudioTypeVibrate   = 1 << 0,
    LGOAudioTypeFeedBack0 = 1 << 1,
    LGOAudioTypeFeedBack1 = 1 << 2,
    LGOAudioTypeFeedBack2 = 1 << 3,
};


@interface LGOAudioRequest : LGORequest

@property(nonatomic, assign) LGOAudioType audioType;

@end

@implementation LGOAudioRequest

@end

@interface LGOAudioResponse : LGOResponse

@property (nonatomic, copy) NSString *text;

@end

@implementation LGOAudioResponse

@end

@interface LGOAudioOperation : LGORequestable

@property(nonatomic, strong) LGOAudioRequest *request;

@end

@implementation LGOAudioOperation

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    if ((self.request.audioType & LGOAudioTypeVibrate) == LGOAudioTypeVibrate) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *impactFeedBack;
        if ((self.request.audioType & LGOAudioTypeFeedBack0) == LGOAudioTypeFeedBack0) {
            impactFeedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        }
        if ((self.request.audioType & LGOAudioTypeFeedBack1) == LGOAudioTypeFeedBack1) {
            impactFeedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        }
        if ((self.request.audioType & LGOAudioTypeFeedBack2) == LGOAudioTypeFeedBack2) {
            impactFeedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
        }
        [impactFeedBack prepare];
        [impactFeedBack impactOccurred];
    }
    LGOAudioResponse *response = [[LGOAudioResponse alloc] init];
    callbackBlock([response accept:nil]);
}

@end


@implementation LGOAudio

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"Native.Audio" instance:[self new]];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    
    LGOAudioRequest *request = [[LGOAudioRequest alloc] init];
    
    if ([dictionary[@"type"] isEqualToString:@"vibrate"]) {
        request.audioType = LGOAudioTypeVibrate;
    }
    if ([dictionary[@"type"] isEqualToString:@"FeedBack0"]) {
        request.audioType = LGOAudioTypeFeedBack0;
    }
    if ([dictionary[@"type"] isEqualToString:@"FeedBack"] || [dictionary[@"type"] isEqualToString:@"FeedBack1"]) {
        request.audioType = LGOAudioTypeFeedBack1;
    }
    if ([dictionary[@"type"] isEqualToString:@"FeedBack2"]) {
        request.audioType = LGOAudioTypeFeedBack2;
    }
    
    LGOAudioOperation *operation = [[LGOAudioOperation alloc] init];
    operation.request = request;
    return operation;
}

@end
