//
//  CoverUtility.m
//  JPPBook
//
//  Created by okano on 11/09/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoverUtility.h"


@implementation CoverUtility

+ (UIImage*)thumbnailImageWithContentId:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	
	NSString* targetFilenameFull = [FileUtility getThumbnailFilenameFull:1 WithContentId:cid];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:targetFilenameFull]) {
		UIImage* image = [UIImage imageWithContentsOfFile:targetFilenameFull];
		return image;
	}
	else
	{
		//download.
		Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSURL* url = [appDelegate.serverContentListDS thumbnailUrlByContentId:cid];
		NSData* data = [NSData dataWithContentsOfURL:url];
		if (data != nil) {
			//save to local folder.
			[data writeToFile:targetFilenameFull atomically:YES];
			//Generate image.
			UIImage* img = [[UIImage alloc] initWithData:data];
			return img;
		} else {
			NSLog(@"thumbnail image not found. url=%@", [url description]);
		}
		return nil;
	}
}

//force download from url.
+ (UIImage*)thumbnailImageWithUuid:(NSString*)uuid
{
	//download.
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url = [appDelegate.serverContentListDS thumbnailUrlByUuid:uuid];
	NSData* data = [NSData dataWithContentsOfURL:url];
	if (data != nil) {
		//NOT save to local folder.
		//[data writeToFile:targetFilenameFull atomically:YES];
		
		//Generate image.
		UIImage* img = [[UIImage alloc] initWithData:data];
		return img;
	} else {
		NSLog(@"thumbnail image not found. url=%@", [url description]);
	}
	return nil;
}


@end
