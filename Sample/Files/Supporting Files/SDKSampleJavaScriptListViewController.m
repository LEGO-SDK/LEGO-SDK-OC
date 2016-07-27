//
//  SDKSampleJavaScriptListViewController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SDKSampleJavaScriptListViewController.h"
#import "SDKSampleJavaScriptItemViewController.h"

@implementation SDKSampleJavaScriptListViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SDKSampleJavaScriptItemViewController *viewController = [[UIStoryboard storyboardWithName:@"SDKSample" bundle:nil]
                                                             instantiateViewControllerWithIdentifier:@"SDKSampleJavaScriptItemViewController"];
    viewController.title = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    viewController.file = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)handleButtonTapped:(UIButton *)sender {
    SDKSampleJavaScriptItemViewController *viewController = [[UIStoryboard storyboardWithName:@"SDKSample" bundle:nil] instantiateViewControllerWithIdentifier:@"SDKSampleJavaScriptItemViewController"];
    viewController.title = sender.accessibilityLabel;
    viewController.file = sender.accessibilityLabel;
    [self.navigationController pushViewController:viewController animated:YES];
    
}

@end
