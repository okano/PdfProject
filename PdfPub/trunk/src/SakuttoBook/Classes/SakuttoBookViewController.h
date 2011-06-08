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

- (void)showContentPlayerView;
//
- (IBAction)showCosmeLesson;
- (void)closeCosmeLessonView;

@end

