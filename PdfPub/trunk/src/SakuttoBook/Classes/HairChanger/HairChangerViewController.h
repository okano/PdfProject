//
//  HairChangerViewController.h
//  SakuttoBook
//
//  Created by  on 12/07/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"

@interface HairChangerViewController : UIViewController <UIScrollViewDelegate> {
	//Image Picker.
	UIPopoverController* popoverController;
	bool isShownImagePicker;
}

- (IBAction)switchToContentPlayerView;

@end

//
//imagePicker
@interface HairChangerViewController (ImagePicker) <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
- (void)openImagePickerFromBarButtonItem:(UIBarButtonItem*)button;
@end
