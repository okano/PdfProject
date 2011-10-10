//
//  ServerContentDownloadVC+Extract.m
//  JPPBook
//
//  Created by okano on 11/10/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerContentDownloadVC.h"


@implementation ServerContentDownloadVC (extract)

#pragma mark -
/**
 *extract zip file.
 */
/*
- (BOOL)ensureExtractContentWithContentId:(NSString*)cId
{
	NSString* tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
	NSString* tmpPathWithContentId = [[NSString stringWithString:tmpPath] stringByAppendingPathComponent:cId];
	NSFileManager* fMgr = [NSFileManager defaultManager];
	BOOL isDir;
	NSError* err;
	
	//Check directory exists, 
	if([fMgr fileExistsAtPath:tmpPathWithContentId isDirectory:&isDir] && isDir)
	{
		//directory exists.
		NSArray* files = [fMgr contentsOfDirectoryAtPath:tmpPathWithContentId error:&err];
		if ([files count] > 0)
		{
			return TRUE;
		}
	}
	
	// Extract .zip file.
	NSString* contentFilename = [ContentFileUtility getContentBodyFilename:cId];
	return [self unzipFileToTmpDirectory:contentFilename contentId:[cId intValue]];
}
*/

/**
 *
 */
//- (BOOL)unzipFileToTmpDirectory:(NSString*)fromFileFullname contentId:(ContentId)cId
- (BOOL)unzipFile:(NSString*)fromFileFullname ToDirectory:(NSString*)toDirectory;
{
	/**
	 *Copy file to TMP directory for extract.
	 */
	NSFileManager* fMgr = [NSFileManager defaultManager];
	NSString* tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
	//NSString* tmpPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"a"];
	NSString* copyToFilename = [tmpPath stringByAppendingPathComponent:[fromFileFullname lastPathComponent]];
	
	NSError* err;
	
	
	//Remove if already exists in tmp directory.
	if ([fMgr fileExistsAtPath:copyToFilename])
	{
		NSLog(@"file remove before copy. to=%@", copyToFilename);
		[fMgr removeItemAtPath:copyToFilename error:&err];
		if(err)
		{
			NSLog(@"error=%@", [err localizedDescription]);
		}
		return FALSE;
	}
	
	
	//Copy file.
	//if ([fMgr copyItemAtPath:fromFileFullname toPath:tmpPath error:&err])
	if (([fMgr copyItemAtPath:fromFileFullname toPath:copyToFilename error:&err]) == FALSE)
	{
		NSLog(@"file copy error. from=%@, to=%@", fromFileFullname, tmpPath);
		NSLog(@"file copy error. copyToFilename=%@", copyToFilename);
		if(err)
		{
			NSLog(@"error=%@", [err localizedDescription]);
		}
		return FALSE;
	}
	
	NSString* originalFilename = [fromFileFullname lastPathComponent];
	NSString* newFileFullname = [tmpPath stringByAppendingPathComponent:originalFilename];
#if IS_DEBUG
	NSLog(@"new file fullname = %@", newFileFullname);
#endif
	
	/**
	 *Generate object for unzip.
	 */
	//HetimaUnZipContainer *unzipContainer = [[HetimaUnZipContainer alloc] initWithZipFile:filePath];
	HetimaUnZipContainer *unzipContainer = [[HetimaUnZipContainer alloc] initWithZipFile:newFileFullname];
	[unzipContainer setListOnlyRealFile:YES];
	
	/**
	 *Extract.
	 */
	if ([[unzipContainer contents] count] == 0) {
		NSString *err = NSLocalizedString(@"No zip file is found.", nil);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"no file found." message:err delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[alert show];
		[alert release];
		return FALSE;
	} else {
		NSString* contentIdStr = [NSString stringWithFormat:@"%d", cId];
		/**
		 *Create Directory to extract if not exists.
		 */
		NSString* pathToExtract = [ContentFileUtility getContentTmpDirectoryWithContentId:contentIdStr];
		NSFileManager* fMgr = [NSFileManager defaultManager];
		NSError* error = nil;
		BOOL isDir;
		if ( ! ([fMgr fileExistsAtPath:pathToExtract isDirectory:&isDir] && isDir))
		{
			if ( ! ([fMgr createDirectoryAtPath:pathToExtract 
					withIntermediateDirectories:YES
									 attributes:nil
										  error:&error]))
			{
				NSLog(@"directory create error. path=%@", pathToExtract);
			}
			//else
			//{
			//	NSLog(@"directory create success. path=%@", pathToExtract);
			//}
		}
#if IS_DEBUG
		else
		{
			NSLog(@"directory already exists. path=%@", pathToExtract);
		}
#endif
		
		/*
		 *
		 */
		HetimaUnZipItem *item;
		NSEnumerator *contentsEnum = [[unzipContainer contents] objectEnumerator];
		//
		expectedUmcompressedContentSize = 0;
		contentsEnum = [[unzipContainer contents] objectEnumerator];
		for (item in contentsEnum) {
			expectedUmcompressedContentSize += [item uncompressedSize];
#if IS_DEBUG
			NSLog(@"zip path:%@\t%d", [item path], [item uncompressedSize]);
#endif
		}
		//
		NSUInteger totalFileNum = [[unzipContainer contents] count];
		NSUInteger i = 0;
		contentsEnum = [[unzipContainer contents] objectEnumerator];
		for (item in contentsEnum) {
			/*
			 NSString *path = [[NSFileManager defaultManager] suggestFilePath:[APPLICATION_TMP_DIR
			 stringByAppendingPathComponent:[item path]]];
			 */
			//
			NSString* extractToFilename = [pathToExtract
										   stringByAppendingPathComponent:[item path]];
			
			//Create directory if extract file with directory.
			NSArray *listItems = [[item path] componentsSeparatedByString:@"/"];
			if ([listItems count] >= 2)
			{
#if IS_DEBUG
				NSLog(@"file with directory. expect filename = %@", [item path]);
#endif				
				
				NSString* directoryToCreate;
				//directoryToCreate = [extractToFilename substringToIndex:lastSlash];
				directoryToCreate = [extractToFilename stringByStandardizingPath];
				directoryToCreate = [extractToFilename stringByDeletingLastPathComponent];
				
				if (([fMgr createDirectoryAtPath:directoryToCreate
					 withIntermediateDirectories:YES
									  attributes:nil
										   error:&err]
					 ) == FALSE)
				{
					NSLog(@"create directory fail. target=%@", extractToFilename);
				}
				//else
				//{
				//	NSLog(@"create directory success. target=%@", extractToFilename);
				//}
				
			}
			
			//Extract.
			BOOL result = [item extractTo:extractToFilename delegate:self];
			if (!result) {
				NSString *err = [NSString stringWithFormat:NSLocalizedString(@"Failed to extract %@.", nil), [item path]];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:err delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
				[alert show];
				[alert release];
				return FALSE;
			}
			
			i = i + 1;
#if IS_DEBUG
			NSLog(@"extact %d / %d = %4.3f x", i, totalFileNum, (float)((float)i / (float)totalFileNum));
#endif
			myProgressBar.progress = (float)((float)i / (float)totalFileNum);
			myProgressLabel.text = [NSString stringWithFormat:@" extract %4.3f,%%", myProgressBar.progress * 100];
			myProgressLabel.hidden = YES;
			downloadedContentLengthLabel.hidden = YES;
			expectedContentLengthLabel.hidden = YES;
			[myProgressLabel setNeedsDisplay];
			[myProgressLabel performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
			[self.view setNeedsDisplay];
			[self.view performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
		}
	}
	
	[unzipContainer release];
	//[pool release];
	
	return TRUE;
}

#pragma mark HetimaUnZipItemDelegate
///////////////////////////////////////////////////////////////////////////////////////
// HetimaUnZipItemDelegate
- (void)item:(HetimaUnZipItem *)item didExtractDataOfLength:(NSUInteger)length {
	myProgressBar.progress = myProgressBar.progress + ((long double)length / (long double)expectedUmcompressedContentSize) * 0.5f;
	//NSLog(@"Extracting %f", progressBar.progress);
}


@end
