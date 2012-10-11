//
//  ViewController.m
//  uuid-test-ios5
//
//  Created by okano on 12/10/10.
//  Copyright (c) 2012年 okano. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//Source code from VerificationController.m (for check un-secure server)
//@see: http://developer.apple.com/library/ios/#releasenotes/StoreKit/IAP_ReceiptValidation/_index.html
- (IBAction)uuidForIos5:(id)sender
{
	NSLog(@"ver=%d", __IPHONE_OS_VERSION_MAX_ALLOWED);
	
	
	// Pre iOS 6
	NSString *localIdentifier           = [UIDevice currentDevice].uniqueIdentifier;
	NSLog(@"localIdentifier=%@", localIdentifier);
}
- (IBAction)uuidForIos6:(id)sender
{
	if ([[UIDevice currentDevice] respondsToSelector:NSSelectorFromString(@"identifierForVendor")]) // iOS 6?
    {

#if IS_IOS6_AWARE
		// iOS 6 (or later)
		NSString *localIdentifier                   = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
		NSLog(@"localIdentifier=%@", localIdentifier);
#else
		NSLog(@"IS_IOS6_AWARE not define.");
#endif
		NSLog(@"(for iOS6)");
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
