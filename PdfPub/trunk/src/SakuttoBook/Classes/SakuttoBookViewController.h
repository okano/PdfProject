//
//  SakuttoBookViewController.h
//  SakuttoBook
//
//  Created by okano on 10/12/13.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKBE_MainViewController.h"
#import "ContentPlayerViewController.h"

@interface SakuttoBookViewController : SKBE_MainViewController {
	ContentPlayerViewController* contentPlayerViewController;
}
@property (nonatomic, retain) ContentPlayerViewController* contentPlayerViewController;

- (void)showContentPlayerView;

@end

