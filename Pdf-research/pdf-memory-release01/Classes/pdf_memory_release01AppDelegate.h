//
//  pdf_memory_release01AppDelegate.h
//  pdf-memory-release01
//
//  Created by okano on 11/02/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class pdf_memory_release01ViewController;

@interface pdf_memory_release01AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    pdf_memory_release01ViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet pdf_memory_release01ViewController *viewController;

@end

