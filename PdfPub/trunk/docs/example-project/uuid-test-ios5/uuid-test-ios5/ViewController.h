//
//  ViewController.h
//  uuid-test-ios5
//
//  Created by okano on 12/10/10.
//  Copyright (c) 2012年 okano. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_IOS6_AWARE (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1)

@interface ViewController : UIViewController

- (IBAction)uuidForIos5:(id)sender;
- (IBAction)uuidForIos6:(id)sender;
@end
