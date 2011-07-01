//
//  CosmeLessonViewController+MarkerPen.m
//  CosmeLesson01
//
//  Created by okano on 11/06/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CosmeLessonViewController.h"


@implementation CosmeLessonViewController (ImagePicker)

- (void)openImagePickerFromBarButtonItem:(UIBarButtonItem*)button
{
	
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];  
	picker.delegate = self;  
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		//iPad('On iPad, UIImagePickerController must be presented via UIPopoverController')
		UIPopoverController* popoverController =[[UIPopoverController alloc] initWithContentViewController:picker];
		popoverController.delegate = self;

		//[popoverController setPopoverContentSize:CGSizeMake(160,160) animated:YES];
		[popoverController presentPopoverFromBarButtonItem:button
								  permittedArrowDirections:UIPopoverArrowDirectionAny
												  animated:YES];
	} else {
		//iPhone
		[self presentModalViewController:picker animated:YES];  
	}
	
	[picker release];
}

- (void) imagePickerController:(UIImagePickerController*)picker  
		 didFinishPickingImage:(UIImage *)selectedImage
				   editingInfo:(NSDictionary*)editingInfo {  
    // Get selected image.
	LOG_CURRENT_METHOD;
	[self setupImage:selectedImage];
	
	[picker dismissModalViewControllerAnimated:YES];  
	LOG_CURRENT_METHOD;
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker {  
    //Treat "cancel".
	LOG_CURRENT_METHOD;
	
	[picker dismissModalViewControllerAnimated:YES];  
}

//- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{}
//- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{}

@end
