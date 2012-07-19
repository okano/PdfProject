//
//  HairChangerViewController.h
//  SakuttoBook
//
//  Created by  on 12/07/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#define MAX_POSE  9
#define MAX_SCENE 8

@interface HairChangerViewController : UIViewController <UIScrollViewDelegate> {
	//Scene view.
	IBOutlet UIImageView* sceneImageView;
	//Person view.
	IBOutlet UIImageView* personImageView;
	IBOutlet UIView* personContainerView;
	//Button
	IBOutlet UIView* buttonContainerView;
	
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
