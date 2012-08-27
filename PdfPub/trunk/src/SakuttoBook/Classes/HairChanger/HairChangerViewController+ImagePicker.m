//
//  HairChangerViewController+MarkerPen.m
//  HairChanger01
//
//  Created by okano on 11/06/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HairChangerViewController.h"


@implementation HairChangerViewController (ImagePicker)

- (void)openImagePickerWithType:(NSUInteger)sourceType
{
    [self dismissModalViewControllerAnimated:YES];
	
	if (isShownImagePicker == YES) {
		return;
	}
	
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];  
	picker.delegate = self;  
	picker.sourceType = sourceType;		//UIImagePickerControllerSourceTypePhotoLibrary;
	
	//iPhone
	[self presentModalViewController:picker animated:YES];  
	
	//Set flag.(ignore multi open with ImagePicker.)
	isShownImagePicker = YES;
	
	[picker release];
}

- (void) imagePickerController:(UIImagePickerController*)picker  
		 didFinishPickingImage:(UIImage *)selectedImage
				   editingInfo:(NSDictionary*)editingInfo {  
    // Setup with selected image.
	testImageView.image = selectedImage;	
	
	//Close picker view.
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		//iPad
		[popoverController dismissPopoverAnimated:YES];
	} else {
		//iPhone
		[picker dismissModalViewControllerAnimated:YES];  
	}
	
	//Set flag.(ignore multi open with ImagePicker.)
	isShownImagePicker = NO;
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker {  
    //Treat "cancel".
	//LOG_CURRENT_METHOD;
	
	[picker dismissModalViewControllerAnimated:YES];  
	//Set flag.(ignore multi open with ImagePicker.)
	isShownImagePicker = NO;
}

//- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	//Set flag.(ignore multi open with ImagePicker.)
	isShownImagePicker = NO;
}

@end
