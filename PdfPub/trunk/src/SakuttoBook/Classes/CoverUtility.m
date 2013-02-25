//
//  CoverUtility.m
//  JPPBook
//
//  Created by okano on 11/09/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoverUtility.h"


@implementation CoverUtility

+ (UIImage*)coverImageWithContentId:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	if (cid == InvalidContentId) {
		LOG_CURRENT_METHOD;
		NSLog(@"Invalid ContentId");
		return nil;
	} else if (cid == UndefinedContentId) {
		LOG_CURRENT_METHOD;
		NSLog(@"Undefined ContentId.");
		return nil;
	}
	
	NSString* targetFilenameFull = [self getCoverLocalFilenameFull:cid];
	//(1)get from cache folder.
	targetFilenameFull = [self getCoverCacheFilenameFullWithContentId:cid];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:targetFilenameFull]) {
		UIImage* image = [UIImage imageWithContentsOfFile:targetFilenameFull];
		return image;
	}
	
	//(1b)get from local folder... not use.
	//			NSString* coverFilenameInLocal = [tmpContentListDS getCoverLocalFilenameFull:targetCid];

	
	//(2)download from url.
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url = [appDelegate.serverContentListDS coverUrlByContentId:cid];
	if (url != nil)
	{
		NSData* data = [NSData dataWithContentsOfURL:url];
		if (data != nil) {
			//save to local folder.
			targetFilenameFull = [CoverUtility getCoverCacheFilenameFullWithContentId:cid];
			[FileUtility makeDir:[targetFilenameFull stringByDeletingLastPathComponent]];
			
			//Conver image format.
			if ([[[[url description] pathExtension] lowercaseString] compare:[COVER_FILE_EXTENSION lowercaseString]] == NSOrderedSame)
			{
				[data writeToFile:targetFilenameFull atomically:YES];
				
			} else {
				UIImage* tmpImg = [[UIImage alloc] initWithData:data];
				if ([[COVER_FILE_EXTENSION lowercaseString] compare:@"jpg"] == NSOrderedSame)
				{
					NSData* jpgData = UIImageJPEGRepresentation(tmpImg, 1.0);
					[jpgData writeToFile:targetFilenameFull atomically:YES];
				} else if ([[COVER_FILE_EXTENSION lowercaseString] compare:@"png"] == NSOrderedSame)
				{
					NSData* pngData = UIImagePNGRepresentation(tmpImg);
					[pngData writeToFile:targetFilenameFull atomically:YES];
				}
				
			}
			
			LOG_CURRENT_LINE;
			NSLog(@"cover image saved. filename=%@", targetFilenameFull);
			//Set Ignore Backup.
			[FileUtility addSkipBackupAttributeToItemWithString:targetFilenameFull];
			//Generate image.
			UIImage* img = [[UIImage alloc] initWithData:data];
			return img;
		} else {
			NSLog(@"cover image not found. url=%@", [url description]);
			
			//(Get from thumbnailUrl.)
			NSURL* coverImageUrl = [appDelegate.serverContentListDS thumbnailUrlByContentId:cid atThumbnailIndex:0];
			if (coverImageUrl == nil) {
				NSLog(@"cannot get thumbnailUrl. targetCid=%d", cid);
			}
			
			return nil;
		}
	}
	else {
		//(3)Get from local content icon.
		UIImage* img = [appDelegate.contentListDS contentIconByContentId:cid];
		if (img != nil) {
			LOG_CURRENT_LINE;
			NSLog(@"img with contentIconByContentId. size=%@", NSStringFromCGSize(img.size));
			return img;
		} else {
			//(4)Get from page small file.
			targetFilenameFull = [FileUtility getPageSmallFilenameFull:1 WithContentId:cid];
			if ([fileManager fileExistsAtPath:targetFilenameFull]) {
				UIImage* image = [UIImage imageWithContentsOfFile:targetFilenameFull];
				return image;
			}
			else {
				//(5)Get from thumbnailUrl.
				//coverImageUrl = [tmpContentListDS thumbnailUrlAtIndex:i];

			}
		}
	}
	return nil;
	
}

+ (NSString*)getCoverFilenameFull:(ContentId)cid
{
	return @"";
}


//force download from url.
+ (UIImage*)coverImageWithUuid:(NSString*)uuid
{
	//download.
	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url = [appDelegate.serverContentListDS coverUrlByUuid:uuid];
	NSData* data = [NSData dataWithContentsOfURL:url];
	if (data != nil) {
		//Generate directory for save.
		NSString* targetFilenameFull = [self getCoverCacheFilenameFull:uuid];
		[FileUtility makeDir:[targetFilenameFull stringByDeletingLastPathComponent]];
		//Save to file.
		//NSLog(@"targetFilenameFull=%@", targetFilenameFull);
		[data writeToFile:targetFilenameFull atomically:YES];
		//Set Ignore Backup.
		[FileUtility addSkipBackupAttributeToItemWithString:targetFilenameFull];
		
		//Generate image.
		UIImage* img = [[UIImage alloc] initWithData:data];
		return img;
	} else {
		NSLog(@"thumbnail image not found. url=%@", [url description]);
	}
	return nil;
}

+ (NSString*)getCoverLocalFilenameFull:(ContentId)cid
{
	NSString* filename = [NSString stringWithFormat:@"%@%d", COVER_FILE_PREFIX, cid];
	NSString* targetFilenameFull = [[[[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									   stringByAppendingPathComponent:DETAIL_DIR]
									  stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",cid]]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:COVER_FILE_EXTENSION];
	return targetFilenameFull;
}

+ (NSString*)getCoverCacheFilenameFullWithContentId:(ContentId)cid
{
	NSString* filename = [NSString stringWithFormat:@"%@%d", COVER_FILE_PREFIX, cid];
	NSString* targetFilenameFull = [[[[[NSHomeDirectory() stringByAppendingPathComponent:@"Tmp"]
									   stringByAppendingPathComponent:COVER_CACHE_DIR]
									  stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",cid]]
									 stringByAppendingPathComponent:filename]
									stringByAppendingPathExtension:COVER_FILE_EXTENSION];
	return targetFilenameFull;
}

+ (NSString*)getCoverCacheFilenameFull:(NSString*)uuid
{
	NSString* targetFilenameFull = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"Tmp"]
									   stringByAppendingPathComponent:COVER_CACHE_DIR]
									 stringByAppendingPathComponent:uuid]
									stringByAppendingPathExtension:COVER_FILE_EXTENSION];
	return targetFilenameFull;
}
										
@end
