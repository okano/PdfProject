//
//  HairChangerViewController.h
//  SakuttoBook
//
//  Created by  on 12/07/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#define MAX_POSE  6
#define MAX_SCENE 11

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
	
	//current scene, pose.
	int currentScene;	//0-start.
	int currentPose;	//0-start.
	
	//Scale, position for hair.
	CGPoint lastOrigin;	//for UIImageView.
	CGFloat lastScale;
}

//Setup View.
- (void)reScalePersonImageView;
//Utility method.
- (NSString*)getHairFilename:(int)hairNumber;
- (NSString*)getSceneFilename:(int)sceneNumber;


//
- (void)hideHairChangerView;
- (IBAction)switchToContentPlayerView;
- (void)switchToHairChangerView;	//switch this view with new image.


@end




//
//imagePicker
@interface HairChangerViewController (ImagePicker) <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
- (void)openImagePickerFromBarButtonItem:(UIBarButtonItem*)button;
@end
