//
//  PopoverImageViewController.m
//  Pdf2iPad
//
//  Created by okano on 11/02/07.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import "PopoverImageViewController.h"

@implementation PopoverImageViewController

#pragma mark -
#pragma mark handle rotate.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//All orientation is OK.(default is only UIInterfaceOrientationPortrait)
    return YES;
}


@end
