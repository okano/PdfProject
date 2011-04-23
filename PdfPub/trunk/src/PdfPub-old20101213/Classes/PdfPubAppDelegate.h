//
//  PdfPubAppDelegate.h
//  PdfPub
//
//  Created by okano on 10/11/18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PdfPubViewController;

@interface PdfPubAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PdfPubViewController *viewController;
	//
	int currentPageNum;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PdfPubViewController *viewController;
//
@property int currentPageNum;

@end

