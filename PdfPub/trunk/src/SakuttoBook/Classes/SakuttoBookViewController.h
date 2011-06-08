//
//  SakuttoBookViewController.h
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentPlayerViewController.h"
#import "CosmeLessonViewController.h"

@interface SakuttoBookViewController : UIViewController {
	ContentPlayerViewController* contentPlayerViewController;
	CosmeLessonViewController* cosmeLessonVC;
}
@property (nonatomic, retain) ContentPlayerViewController* contentPlayerViewController;

//Methods for switch ContentView/CosmeLessonView.
- (void)showContentPlayerView;
- (void)hideContentPlayerView;
- (IBAction)showCosmeLessonView;
- (void)hideCosmeLessonView;

@end

