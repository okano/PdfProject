//
//  HairChangerViewController.h
//  SakuttoBook
//
//  Created by  on 12/07/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#define MAX_HAIR  6
#define MAX_SCENE 11

@interface HairChangerViewController : UIViewController <UIScrollViewDelegate> {
	//Scene view.
	IBOutlet UIImageView* sceneImageView;
	//Person view.
	IBOutlet UIImageView* hairImageView;
	IBOutlet UIView* hairContainerView;
	//Button
	IBOutlet UIView* buttonContainerView;
	
	//Image Picker.
	UIPopoverController* popoverController;
	bool isShownImagePicker;
	
	//current scene, pose.
	int currentScene;	//0-start.
	int currentHairNumber;	//0-start.
	
	//Scale, position for hair.
	CGPoint lastOrigin;	//for UIImageView.
	CGFloat lastScale;
	
	//Gesture Recoginzer.
	UIPinchGestureRecognizer* pinchRecognizer;	//scale big/small with image.
	UIPanGestureRecognizer* panRecognizer;		//move image.
}

//Setup View.
- (void)reScalePersonImageView;
- (void)setupBackImage:(UIImage*)newImage;
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
- (void)openImagePickerFromBarButtonItem;
@end
