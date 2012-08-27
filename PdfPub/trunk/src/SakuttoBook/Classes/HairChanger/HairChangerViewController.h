//
//  HairChangerViewController.h
//  SakuttoBook
//
//  Created by  on 12/07/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#define MAX_HAIR  12

@interface HairChangerViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate> {
	//Face view.
	IBOutlet UIImageView* faceImageView;
	//Person view.
	IBOutlet UIImageView* hairImageView;
	IBOutlet UIView* hairContainerView;
	//Button
	IBOutlet UIView* buttonContainerView;
	
	//Image Picker.
	UIPopoverController* popoverController;
	bool isShownImagePicker;
	
	//current scene, pose.
	int currentHairNumber;	//0-start.
	
	//Scale, position for hair.
	CGPoint lastOrigin;	//for UIImageView.
	CGFloat lastScale;
	
	//Gesture Recoginzer.
	UIPinchGestureRecognizer* pinchRecognizer;	//scale big/small with image.
	UIPanGestureRecognizer* panRecognizer;		//move image.
}

//Utility method.
- (NSString*)getHairFilename:(int)hairNumber;
- (NSString*)getSceneFilename:(int)sceneNumber;


//
- (void)hideHairChangerView;
- (IBAction)switchToContentPlayerView;
- (void)switchToHairChangerView;	//switch this view with new image.

//
- (IBAction)saveImageToAlbum;

@end




//
//imagePicker
@interface HairChangerViewController (ImagePicker) <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
- (void)openImagePickerWithType:(NSUInteger)sourceType;
@end
