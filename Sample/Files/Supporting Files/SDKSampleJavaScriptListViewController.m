//
//  SDKSampleJavaScriptListViewController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SDKSampleJavaScriptItemViewController.h"
#import "SDKSampleJavaScriptListViewController.h"
#import "UIViewController+LGOViewController.h"
#import "LGOPack.h"

@implementation SDKSampleJavaScriptListViewController

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
    UIViewController *viewController = [UIViewController new];
    viewController.title = sender.accessibilityLabel;
    NSURLRequest *request = [NSURLRequest
        requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://raw.githubusercontent.com/LEGO-SDK/LEGO-SDK-OC/master/Resources/%@.zip?sample.html",
                                                                       sender.accessibilityLabel]]];
    [viewController lgo_openWebViewWithRequest:request
                                          args:nil
                           renderFinishedBlock:^{
                             [self.navigationController pushViewController:viewController animated:YES];
                           }];
}

@end
