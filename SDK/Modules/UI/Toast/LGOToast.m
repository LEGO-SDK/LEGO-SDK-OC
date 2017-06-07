//
//  LGOToast.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/6/7.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOToast.h"
#import "LGOCore.h"

@interface LGOToastRequest : LGORequest

@property (nonatomic, copy) NSString *opt;
@property (nonatomic, copy) NSString *style;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger timeout;

- (UIView *)toastView;

@end

@implementation LGOToastRequest

- (UIView *)toastView {
    UIView *container = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    container.userInteractionEnabled = YES;
    UIView *maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    maskView.backgroundColor = [UIColor clearColor];
    [container addSubview:maskView];
    UIView *toast = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120.0, 120.0)];
    toast.center = CGPointMake(container.bounds.size.width / 2.0, container.bounds.size.height / 2.0);
    toast.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    toast.layer.cornerRadius = 6.0;
    [container addSubview:toast];
    if ([self.style isEqualToString:@"success"]) {
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:@"iVBORw0KGgoAAAANSUhEUgAAAGIAAABGCAMAAAAARrEcAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAIcUExURUdwTP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9ONOj4AAACzdFJOUwABAgP7BPz6Bf79+R6wKuy/E+8kmajOPOkYMo9A9uDUKw/T8wgWiIaOf5Bwl6toY3ygVRpgtFx1T3nfCwox7vHnxhfIM8316IkSuNa7RObj2t7M3YJ9eHt0bqdklGxvvIVM+FEjVj2cByBiZ4QJR8NyWCaA9JEMaQbRLL2KokPcN9dNEOLtW0ZfUzrkm5VQy5+jS0lIPvc4DaHHHzUvIjAZNi4cphvqncopOeUoHdiqr2oRGMZ4wQAABBZJREFUWMO1mGVbG0EQgOdydzkBAqUUp7RYvaVASwsVCjUoUHd3d3d3d3d3mT/Y2YvthijZy4dwecjtm5n3Znd2Adx66QCN4wFU1wBggnkX8aZ7DMWEzNuoaXjHrRA8Hrh2HQ3L8uJndwiUmwYbDUQkxgeXRK9B1JC9DKx0RfTOEezn+wnZb+WL1mFrPnqtACG3WL5oFUoLSXSAMOM1BSVd9Ch0RDuEwgHSCTTeiaBoIsz2uUCYkBUUzQh9ZROoovcdRc32EzJwrnQCVfSpi0ENRJj/UzaBRB9GjvArUzaBKrokJJoIs1plE0w4NAbtgGiKpeKNZAJVtG8WalaIkN8umUCiL+dSckKEeX0kE0j0sLBounj2hKmRW9EHw6KJMGWg5BhMON+Jth0m5FTJjYFEHzsbnFj9hAlyCR4Fzh0Ia7AM7NDlEmiwPZxoS8MOUy7BBCWPE00xZCmyCe3H0WtzMUgmkOji05xoIvQDqQQSPW56WANbiOISPKaauujxyBM0HB2vffVAqhGS6M2IXj6GuAQVinYMANWTCqFoNyeazeLD4xEUgDGYvT75QBQVpjZxotn0EZdAIw/BMsSZkOTkpSqwcR2ngcUwNC7BhFInl7i6nt2djOhart6cGEoSbFSqm9gNtoEtu5LY0tAEcTLUKgUINf4nJvbrTyBoeq9NmCwT6qfwotG2cFAiwt9Q0PQ3i1ZEJW5PfOYCL5oRhiQiwMzwokve+hewByb2CjpW40UjhbMwIQGqOoX53rsqZrJI9H4UCKRkESiJC6oqh7uNkrWsOXqyTDjSj69o53pJMgQdmtvCuWLJKi9mbUuUXW5bqCcOEoZF+WZUxsAv/IRmYMbyHqVOogtmCKIZYSWbcJObcfpU8CmmyzxdFEKir4iiGWFksgTGqC7n76fnfpqPnxcppEFCRTuEUUnNBiHGx/k8g5I1uS6cLBO2jBAq2sE1pEJggzyfK+SBrocGnl4SvSFfFM0Il1IjsMH6douPvIU5maDqHt0DmwpF0YywN1UCY3xtERiUrOy1zr+2W6JoRrgKeqoExng3SRyKPgz2tU7MixBNn6xbvSEwxtRckUEjeydZaNkRBO1eb5sZEx5PFxkW+/maoIG+oD3ofbtkwsOyiKTYXjEEIjzqSmf7oEOXFsHASEJZaXotnwn37XgMAysL0t0C6TAOYzOo6L+lv8kyoU5cFARC7gsZ2zgVxsZgUC1OlLJRpKZ+W1SGgZ9eStqKUnswMgrDwG55R2TEWNqDYeD3HxK307TiNzoNDE/oL/cAixiLue26Q3gl++BEgQXc9GfgHOkHWIxRE+pdifBeOsFpIgcHzowNrChygeAwVjgMA8urXSE4jBvUFWTIP8AS+rOnlKdp/1wjOIySyt9pH2D9B0gXLwUiIj7lAAAAAElFTkSuQmCC" options:kNilOptions]]];
        iconView.frame = CGRectMake(0, 0, 49, 35);
        iconView.center = CGPointMake(toast.bounds.size.width / 2.0, toast.bounds.size.height / 2.0 - 14.0);
        [toast addSubview:iconView];
    }
    else if ([self.style isEqualToString:@"error"]) {
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:@"iVBORw0KGgoAAAANSUhEUgAAAFoAAABaCAMAAAAPdrEwAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAKaUExURUdwTP////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7+/v39/QAAAPz8/EtLS0hISEZGRkpKSklJSZOTk5qams7OzkVFRfn5+fb29ouLi/r6+szMzN7e3tnZ2TQ0NEBAQEdHR+jo6Hd3dyIiIj4+PkRERObm5vX19ff398XFxa+vr/Pz84iIiPLy8tLS0o+Pj/j4+J6enrGxse7u7oGBgTo6OtbW1hwcHAEBAScnJwUFBZSUlOvr68nJyTU1NcTExOPj4y4uLuXl5aGhob29vefn51lZWSgoKEJCQri4uF5eXgwMDGNjYxkZGampqbOzs7CwsM/Pz3h4eD8/PyMjI+np6XBwcBcXF1BQUGlpaW9vbwQEBBYWFk9PTwMDAx8fHxUVFWhoaB4eHhQUFK6urq2trZ2XQNwAAACBdFJOUwAB+/n8AgT+/QP67/jeBXELEzfkKPJMd/B6w/PQxJXLXtX1PMYdoZzjr1esMTI2bJHpClQSlDXHVdtyyD6M2g8atGsX4dnUGRSIYuqbLvYcECUGq92K3KA5wEInzlwfsyG8OB660krPU0mAqSKSI1gpxZOl0W2kuLd5NH3up6btfnt1G/sAAAZJSURBVFjDrZn1QxtLEMc3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" options:kNilOptions]]];
        iconView.frame = CGRectMake(0, 0, 45, 45);
        iconView.center = CGPointMake(toast.bounds.size.width / 2.0, toast.bounds.size.height / 2.0 - 14.0);
        [toast addSubview:iconView];
    }
    else if ([self.style isEqualToString:@"loading"]) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicatorView startAnimating];
        indicatorView.center = CGPointMake(toast.bounds.size.width / 2.0, toast.bounds.size.height / 2.0 - 10.0);
        [toast addSubview:indicatorView];
    }
    if (self.title != nil) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, 120.0, 30.0)];
        label.textColor = [UIColor colorWithWhite:1.0 alpha:0.85];
        label.font = [UIFont boldSystemFontOfSize:16.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = self.title;
        [toast addSubview:label];
    }
    return container;
}

@end

@interface LGOToastOperation : LGORequestable

@property (nonatomic, strong) LGOToastRequest *request;

@end

@implementation LGOToastOperation

static UIWindow *window;
static NSTimer *timer;

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([self.request.opt isEqualToString:@"hide"]) {
            [timer invalidate];
            [self hide];
        }
        else {
            if (window == nil) {
                window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            }
            [[window subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [window addSubview:[self.request toastView]];
            window.hidden = NO;
            [timer invalidate];
            window.alpha = 0.0;
            [UIView animateWithDuration:0.15 animations:^{
                window.alpha = 1.0;
            }];
            if ([self.request.style isEqualToString:@"success"] || [self.request.style isEqualToString:@"error"]) {
                timer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                         target:self
                                                       selector:@selector(hide)
                                                       userInfo:nil
                                                        repeats:NO];
            }
            else {
                timer = [NSTimer scheduledTimerWithTimeInterval:self.request.timeout
                                                         target:self
                                                       selector:@selector(hide)
                                                       userInfo:nil
                                                        repeats:NO];
            }
        }
    }];
}

- (void)hide {
    window.alpha = 1.0;
    [UIView animateWithDuration:0.15 animations:^{
        window.alpha = 0.0;
    } completion:^(BOOL finished) {
        window.hidden = YES;
    }];
}

@end

@implementation LGOToast

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"UI.Toast" instance:[self new]];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOToastRequest *request = [LGOToastRequest new];
    request.context = context;
    request.opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"";
    request.style = [dictionary[@"style"] isKindOfClass:[NSString class]] ? dictionary[@"style"] : @"";
    request.title = [dictionary[@"title"] isKindOfClass:[NSString class]] ? dictionary[@"title"] : @"";
    request.timeout = [dictionary[@"timeout"] isKindOfClass:[NSNumber class]] ? MIN(10, [dictionary[@"timeout"] integerValue]) : 0;
    LGOToastOperation *operation = [LGOToastOperation new];
    operation.request = request;
    return operation;
}

@end
