//
//  ServerContentDownloadVC.m
//  JPPBook
//
//  Created by okano on 11/09/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerContentDownloadVC.h"


@implementation ServerContentDownloadVC
@synthesize targetUuid;
@synthesize targetUrl;
@synthesize progressLabel, myProgressLabel, downloadedContentLengthLabel, expectedContentLengthLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		downloaderLock = [[NSLock alloc] init];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil
			   bundle:(NSBundle *)nibBundleOrNil
			targetUrl:(NSURL *)url
		   targetUuid:(NSString *)uuid
{
	LOG_CURRENT_METHOD;
	LOG_CURRENT_LINE;
	NSLog(@"url=%@(class %@)", [url description], [url class]);
	
	targetUrl = url;
	targetUuid = [NSString stringWithString:uuid];
	LOG_CURRENT_LINE;
	NSLog(@"targetUrl class=%@", [targetUrl class]);
	NSLog(@"targetUrl=%@", [targetUrl description]);
	NSLog(@"targetUuid=%@", targetUuid);
	
	//NSLog(@"cid=%d, url=%@", cid, [url description]);
	
	LOG_CURRENT_LINE;
	return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

#pragma mark -
- (void)doDownload
{
	NSString* cidStr = [NSString stringWithFormat:@"%d", targetCid];
	NSString* contentFilename = [ContentFileUtility getContentBodyFilename:cidStr];
	NSLog(@"contentFilename=%@", contentFilename);
	NSFileManager* fMgr = [NSFileManager defaultManager];
	
	//Check if file already downloaded.
	if([fMgr fileExistsAtPath:contentFilename] == NO)
	{
		//File not exist. then Download it.
		//NSLog(@"Download start. contentId=%@", contentId);
		
		//Create directory if not exists.
		NSFileManager* fMgr = [NSFileManager defaultManager];
		BOOL isDir;
		NSError* err = nil;
		NSString* contentDownloadDirectory = [ContentFileUtility getContentDownloadDirectory];
		if ( !([fMgr fileExistsAtPath:contentDownloadDirectory isDirectory:&isDir] && isDir))
		{
			[fMgr createDirectoryAtPath:contentDownloadDirectory withIntermediateDirectories:TRUE attributes:nil error:&err];
			if (err)
			{
				NSLog(@"content download directory cannot create. path=%@, err=%@", contentDownloadDirectory, [err localizedDescription]);
				return;
			}
		}
		
		//Prepare GUI and counter.
		downloadedContentLength = 0;
		//myProgressBar.progress = 0;
		//progressLabel.text = NSLocalizedString(@"Downloading...", nil);
		
		
		//Generate Downloader.(and start download automatically.)
		NSURLRequest* req = [NSURLRequest requestWithURL:targetUrl];
		NSLog(@"targetUrl=%@", [targetUrl description]);
		NSLog(@"contentDownloadDirectory=%@", contentDownloadDirectory);
		downloader = [[URLDownload alloc] initWithRequest:req
												directory:contentDownloadDirectory
					  							 delegate:self];
	}
}

/*
//  ダウンロード開始
- (IBAction) download:(id)sender {
	//[urlField resignFirstResponder];
	NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlField text]]];
	
	// ここでダウンロード開始
	downloader = [[URLDownload alloc] initWithRequest:req directory:tmpPath delegate:self];
}
*/

#pragma mark - URLDownloadDelegate implements
// ダウンロード完了
- (void)downloadDidFinish:(URLDownload *)download {
	LOG_CURRENT_METHOD;
	NSLog(@"%@", download.filePath);
	[self releaseDownloader];
	
	NSError* error = nil;

	//Get new ContentId.
	Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
	ContentId newContentId = [appDelegate.contentListDS nextContentId];
	NSString* newContentIdStr = [NSString stringWithFormat:@"%d", newContentId];
	NSLog(@"new ContentId=%d", newContentId);
	
	
	//Only copy if simple PDF file.
	NSLog(@"pathExtension=%@", [download.filePath pathExtension]);
	if ([[download.filePath pathExtension] caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
		NSString* toPathFull = [[[[ContentFileUtility getContentBodyDirectory]
										   stringByAppendingPathComponent:newContentIdStr]
										  stringByAppendingPathComponent:newContentIdStr]
										 stringByAppendingPathExtension:@"pdf"];
		[[NSFileManager defaultManager] moveItemAtPath:download.filePath
															  toPath:toPathFull		
															   error:&error];
		if (error != nil) {
			NSLog(@"fail to move downloaded file. fromPath=%@, toPath=%@, result=%@, %@",
				  download.filePath, toPathFull, [error localizedDescription], [error localizedFailureReason]);
		}
	} else {
		//Extract.
	
		//Make directory for extract.
		[FileUtility removeFile:[ContentFileUtility	getContentExtractDirectory]];
		[FileUtility makeDir:[ContentFileUtility getContentExtractDirectory]];
		
		//Rename file if "*.cbz".
		if ([[download.filePath pathExtension] caseInsensitiveCompare:@"cbz"] == NSOrderedSame) {
			NSString* newFilePath = [[download.filePath stringByDeletingPathExtension]
									 stringByAppendingPathExtension:@"zip"];
			[[NSFileManager defaultManager] moveItemAtPath:download.filePath
													toPath:newFilePath
													 error:&error];
			if (error != nil) {
				NSLog(@"file rename failed. fromPath=%@, toPath=%@, result=%@, %@",
				download.filePath, newFilePath, [error localizedDescription], [error localizedFailureReason]);
			}
		}

		
		//Extract file.
		BOOL extractResult;
		NSString* f = [[download.filePath stringByDeletingPathExtension]
					   stringByAppendingPathExtension:@"zip"];
		extractResult = [self unzipFile:f ToDirectory:[ContentFileUtility getContentExtractDirectory]];
		if (extractResult == FALSE) {
			NSLog(@"extract error.");
		}
		
		
		//Move downloaded file to ContentBodyDirectory.
		/*
		NSString* newFilename = [NSString stringWithFormat:@"%d.%@", newContentId, @"pdf"];
		NSString* bodyDirectory = [ContentFileUtility getContentBodyDirectory];
		NSString* toFilenameFull = [bodyDirectory stringByAppendingPathComponent:newFilename] ;
		NSLog(@"toFilenameFull=%@", toFilenameFull);
		
		[FileUtility makeDir:[ContentFileUtility getContentBodyDirectory]];
		BOOL result = [[NSFileManager defaultManager] moveItemAtPath:download.filePath
															  toPath:toFilenameFull
															   error:&error];
		if (result == NO) {
			LOG_CURRENT_LINE;
			NSLog(@"fail to move downloaded file. fromPath=%@, toPath=%@, result=%@, %@",
				  download.filePath, toFilenameFull, [error localizedDescription], [error localizedFailureReason]);
		}
		*/
		
		[FileUtility makeDir:[ContentFileUtility getContentBodyDirectory]];
		NSString* contentDirectoryWithContentId = [[ContentFileUtility getContentBodyDirectory]
												   stringByAppendingPathComponent:newContentIdStr];
		[[NSFileManager defaultManager] moveItemAtPath:[ContentFileUtility getContentExtractDirectory]
												toPath:contentDirectoryWithContentId 
												 error:&error];
	}
	
	
	//Add downloaded metadata to (inner)ContentListDS.
	NSString* uuid = targetUuid;
	NSLog(@"uuid=%@(%@)", uuid, targetUuid);
	NSMutableDictionary* metaData = [NSMutableDictionary dictionaryWithDictionary:[appDelegate.serverContentListDS getMetadataByUuid:uuid]];
	[metaData setValue:[NSNumber numberWithInteger:newContentId] forKey:CONTENT_CID];	//Set new ContentId.
	NSLog(@"metaData=%@", [metaData description]);
	if (! metaData) {
		NSLog(@"cannot get metadata. UUID=%@", targetUuid);
	}
	[appDelegate.contentListDS addMetadata:metaData];
	[appDelegate.contentListDS saveToPlist];	//save into plist.
	
	//StepUp nextContentId.
	[appDelegate.contentListDS stepupContentIdToUserDefault:newContentId];
	
	
	//Add Download(purchase) history.
	[appDelegate.paymentHistoryDS enableContent:newContentId];
	
	//Copy image cache for Cover.
	//NSString* cacheFilenameFull = [CoverUtility getCoverCacheFilenameFull:uuid];
	NSString* cacheFilenameFull = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"Tmp"]
									  stringByAppendingPathComponent:COVER_CACHE_DIR]
									 stringByAppendingPathComponent:uuid]
									stringByAppendingPathExtension:COVER_FILE_EXTENSION];
	NSString* targetFilenameFull = [[[[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
									   stringByAppendingPathComponent:DETAIL_DIR]
									  stringByAppendingPathComponent:newContentIdStr]
									 stringByAppendingPathComponent:newContentIdStr]
									stringByAppendingPathExtension:COVER_FILE_EXTENSION];
	//targetFilenameFull = [ContentFileUtility getCoverIconDirectory:newContentIdStr];
	[FileUtility makeDir:[targetFilenameFull stringByDeletingLastPathComponent]];
	NSLog(@"cacheFilenameFull=%@", cacheFilenameFull);
	NSLog(@"targetFilenameFull=%@", targetFilenameFull);
	[[NSFileManager defaultManager] moveItemAtPath:cacheFilenameFull
											toPath:targetFilenameFull
											 error:&error];
	if (error != nil) {
		NSLog(@"error with copy image cache for Cover. fromPath=%@, toPath=%@, result=%@, %@",
			  cacheFilenameFull, targetFilenameFull, [error localizedDescription], [error localizedFailureReason]);
	}


	//Open ContentPlayer.
	[appDelegate hideServerContentDetailView];
	[appDelegate showContentPlayerView:newContentId];
	
}

// ダウンロードをキャンセルした際に呼ばれる
- (void)download:(URLDownload *)download didCancelBecauseOf:(NSException *)exception {
	LOG_CURRENT_METHOD;
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:[exception reason] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil] autorelease];
	[alert show];
	[self releaseDownloader];
}

// ダウンロードに失敗した際に呼ばれる
- (void)download:(URLDownload *)download didFailWithError:(NSError *)error {
	LOG_CURRENT_METHOD;
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil] autorelease];
	[alert show];
	[self releaseDownloader];
}

// ダウンロード進行中に呼ばれる
- (void)download:(URLDownload *)download didReceiveDataOfLength:(NSUInteger)length {
	// プログレスバーの表示でもやる
	LOG_CURRENT_METHOD;
	NSLog(@"length=%d", length);
	downloadedContentLength += length;
	downloadedContentLengthLabel.text = [NSString stringWithFormat:@"%10ld", downloadedContentLength];
}



#pragma mark release method.
- (void)releaseDownloader {
	[downloaderLock lock];
	if (downloader != nil) {
		[downloader release];
		downloader = nil;
	}
	//[[NSFileManager defaultManager] clearTmpDirectory];
	[downloaderLock unlock];
}

#pragma mark -

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
