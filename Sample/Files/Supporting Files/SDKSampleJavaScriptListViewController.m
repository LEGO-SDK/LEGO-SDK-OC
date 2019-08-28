//
//  SDKSampleJavaScriptListViewController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SDKSampleJavaScriptItemViewController.h"
#import "SDKSampleJavaScriptListViewController.h"
#import "LGOBaseViewController.h"
#import "LGOPack.h"
#import "LGOPageState.h"
#import "SDKPageStateManager.h"

@implementation SDKSampleJavaScriptListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[LGOPageState sharedInstance] registerPageStateObserver:[SDKPageStateManager shareInstance]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SDKSampleJavaScriptItemViewController *viewController = [[UIStoryboard storyboardWithName:@"SDKSample" bundle:nil]
        instantiateViewControllerWithIdentifier:@"SDKSampleJavaScriptItemViewController"];
    viewController.title = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    viewController.file = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)handleButtonTapped:(UIButton *)sender {
    SDKSampleJavaScriptItemViewController *viewController = [[UIStoryboard storyboardWithName:@"SDKSample" bundle:nil]
        instantiateViewControllerWithIdentifier:@"SDKSampleJavaScriptItemViewController"];
    viewController.title = sender.accessibilityLabel;
    viewController.file = sender.accessibilityLabel;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)handlePackButtonTapped:(UIButton *)sender {
    [LGOPack setPublicKey:[NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                                              pathForResource:@"weui.zip"
                                                              ofType:@"pub"]
                                                    encoding:NSUTF8StringEncoding error:nil]
                forDomain:@"raw.githubusercontent.com"];
    LGOBaseViewController *viewController = [LGOBaseViewController new];
    viewController.title = sender.accessibilityLabel;
    viewController.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://raw.githubusercontent.com/LEGO-SDK/LEGO-SDK-OC/master/Resources/%@.zip?index.html", sender.accessibilityLabel]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
