//
//  ColorSelectorTableViewController.h
//  CosmeLesson01
//
//  Created by okano on 11/06/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import "Utility.h"
@class CosmeLessonViewController;

@interface ColorSelectorTableViewController : UITableViewController {
    CosmeLessonViewController* parentViewController;
}
@property (nonatomic, retain) CosmeLessonViewController* parentViewController;

@end
