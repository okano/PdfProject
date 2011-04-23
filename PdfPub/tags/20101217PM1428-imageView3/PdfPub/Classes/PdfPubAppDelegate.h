//
//  PdfPubAppDelegate.h
//  PdfPub
//
//  Created by okano on 10/12/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PdfPubViewController;

@interface PdfPubAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PdfPubViewController *viewController;
	
	//
	NSMutableArray* tocDefine;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PdfPubViewController *viewController;
//for get value in TocViewController.
@property (nonatomic, retain) NSMutableArray* tocDefine;

@end

