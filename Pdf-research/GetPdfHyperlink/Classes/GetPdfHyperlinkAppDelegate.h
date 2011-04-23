//
//  GetPdfHyperlinkAppDelegate.h
//  GetPdfHyperlink
//
//  Created by okano on 10/12/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GetPdfHyperlinkViewController;

@interface GetPdfHyperlinkAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GetPdfHyperlinkViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GetPdfHyperlinkViewController *viewController;

@end

