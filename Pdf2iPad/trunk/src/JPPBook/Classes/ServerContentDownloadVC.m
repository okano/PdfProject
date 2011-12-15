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
	NSString* contentFilename = [ContentFileUtility getContentBodyFilenamePdf:cidStr];
	NSLog(@"contentFilename=%@", contentFilename);
	NSFileManager* fMgr = [NSFileManager defaultManager];
	
	
	//Ask with OverWrite to exist file.
	if ([fMgr fileExistsAtPath:contentFilename] == YES) {
		[self askOverwrite];
	}
	
	
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

- (void)askOverwrite
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Downloaded file error"
													 message:@"pdf file cannot found in archive file."
													delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"OK",nil]
						  autorelease];
	[alert show];
}

#pragma mark - UIActionSheetDelegate Protocol.
- (void)actionSheet:(UIActionSheet *)sheet didDismissWithButtonIndex:(NSInteger)index
{
	//NSLog(@"action sheet: index=%d", index);
    if( index == [sheet cancelButtonIndex])
    {
        //Close this window.
		Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate hideServerContentDetailView];
		[appDelegate showServerContentDetailView:targetUuid];
    }
	else if( index == [sheet destructiveButtonIndex] )
    {
        // Do Nothing
    }
    else if(index == 0)
	{
		//Delete directory for contents.
		NSString* cidStr = [NSString stringWithFormat:@"%d", targetCid];
		//NSString* contentFilename = [ContentFileUtility getContentBodyFilenamePdf:cidStr];
		//NSLog(@"contentFilename=%@", contentFilename);
		NSString* contentFileDirectory = [ContentFileUtility getContentBodyDirectoryWithContentId:cidStr];
		NSLog(@"contentFileDirectory=%@", contentFileDirectory);
		NSFileManager* fMgr = [NSFileManager defaultManager];
		
		NSError* error = nil;
		[fMgr removeItemAtPath:contentFileDirectory error:&error];
		if (error) {
			NSLog(@"error. %@", [error localizedDescription]);
		}

		//Do(retry) download.
		[self doDownload];
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
	if ([[download.filePath pathExtension] caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
		[self handleDownloadedPdf:download.filePath contentIdStr:newContentIdStr];
	} else if ([[download.filePath pathExtension] caseInsensitiveCompare:@"cbz"] == NSOrderedSame) {
		[self handleDownloadedCbz:download.filePath contentIdStr:newContentIdStr];
	} else if ([[download.filePath pathExtension] caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
		[self handleDownloadedZip:download.filePath contentIdStr:newContentIdStr];
	} else {
		NSLog(@"Illigal file extensions. filename=%@, ext=%@", download.filePath, [download.filePath pathExtension]);
	}
	
	/*
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
	*/
	
	//Copy metadata from server to local ContentListDS.
	NSString* serverUuid = targetUuid;
	NSLog(@"uuid at server = %@", targetUuid);
	NSMutableDictionary* metaData2 = [NSMutableDictionary dictionaryWithDictionary:[appDelegate.serverContentListDS getMetadataByUuid:serverUuid]];
	if (! metaData2) {
		NSLog(@"cannot get metadata. UUID=%@", targetUuid);
	}
	NSLog(@"metaData2=%@", [metaData2 description]);
	[appDelegate.contentListDS addMetadata:metaData2];
	[appDelegate.contentListDS saveToPlist];
	
	
	
	//Add Download(purchase) history. -> do it by PaymentConductor.
	//[appDelegate.paymentHistoryDS enableContent:newContentId];
	
	
	
	//Copy image cache for Cover.
	//NSString* cacheFilenameFull = [CoverUtility getCoverCacheFilenameFull:uuid];
	NSString* cacheFilenameFull = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"Tmp"]
									  stringByAppendingPathComponent:COVER_CACHE_DIR]
									 stringByAppendingPathComponent:targetUuid]
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

- (void)handleDownloadedPdf:(NSString*)filePath contentIdStr:(NSString*)contentIdStr;
{
	//Only copy if simple PDF file.
	NSError* error = nil;

	//Make directory for extract.
	NSString* dirStr = [ContentFileUtility getContentBodyPdfDirectoryWithContentId:contentIdStr];
	[FileUtility makeDir:dirStr];	
	
	//Copy file.
	NSString* toPathFull = [[dirStr stringByAppendingPathComponent:contentIdStr]
								   stringByAppendingPathExtension:@"pdf"];
	[[NSFileManager defaultManager] moveItemAtPath:filePath
											toPath:toPathFull		
											 error:&error];
	if (error != nil) {
		NSLog(@"fail to move downloaded file. fromPath=%@, toPath=%@, result=%@, %@",
			  filePath, toPathFull, [error localizedDescription], [error localizedFailureReason]);
	}
}

- (void)handleDownloadedCbz:(NSString*)filePath contentIdStr:(NSString*)contentIdStr;
{
	//Rename filename from "*.cbz" to "*.zip".
	NSError* error = nil;
	NSString* newFilePath = [[filePath stringByDeletingPathExtension]
							 stringByAppendingPathExtension:@"zip"];
	[[NSFileManager defaultManager] moveItemAtPath:filePath
											toPath:newFilePath
											 error:&error];
	if (error != nil) {
		NSLog(@"file rename failed. fromPath=%@, toPath=%@, result=%@, %@",
			  filePath, newFilePath, [error localizedDescription], [error localizedFailureReason]);
	}
	
	//Extract file.
	[self handleDownloadedZip:newFilePath contentIdStr:contentIdStr];
}

- (void)handleDownloadedZip:(NSString*)filePath contentIdStr:(NSString*)contentIdStr;
{
	//Extract.
	NSError* error = nil;
	
	//Make directory for extract.
	[FileUtility removeFile:[ContentFileUtility	getContentExtractDirectory]];
	[FileUtility makeDir:[ContentFileUtility getContentExtractDirectory]];
	
	//Extract file.
	BOOL extractResult;
	NSString* f = [[filePath stringByDeletingPathExtension]
				   stringByAppendingPathExtension:@"zip"];
	extractResult = [self unzipFile:f ToDirectory:[ContentFileUtility getContentExtractDirectory]];
	if (extractResult == FALSE) {
		NSLog(@"extract error.");
	}
	
	//Move downloaded file to ContentBodyDirectory.
	[FileUtility makeDir:[ContentFileUtility getContentBodyDirectory]];
	NSString* contentDirectoryWithContentId = [[ContentFileUtility getContentBodyDirectory]
											   stringByAppendingPathComponent:contentIdStr];
	[[NSFileManager defaultManager] moveItemAtPath:[ContentFileUtility getContentExtractDirectory]
											toPath:contentDirectoryWithContentId 
											 error:&error];
	
	//Rename pdf file with "{cid}.pdf"
	[self renamePdfWithCid:contentIdStr];
}

- (void)renamePdfWithCid:(NSString*)cidStr
{
	LOG_CURRENT_METHOD;
	
	//Parse pdfDefine for get pdf filename.
	NSString* pdfFilename = [FileUtility getPdfFilename:[cidStr intValue]];

	//Generate new pdfFilename.
	NSString* newPdfFilename = [NSString stringWithFormat:@"%@.pdf", cidStr];
	
	//Prepare for copy.
	NSString* dirStr = [ContentFileUtility getContentBodyPdfDirectoryWithContentId:cidStr];
	NSString* fromPath = [dirStr stringByAppendingPathComponent:pdfFilename];
	NSString* toPath = [dirStr stringByAppendingPathComponent:newPdfFilename];
	NSError* error = nil;
	
	//Check file exists.
	if([[NSFileManager defaultManager] fileExistsAtPath:fromPath] == NO)
	{
		NSLog(@"pdf file cannot found in archive file. expect filename=%@", fromPath);
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Downloaded file error"
														 message:@"pdf file cannot found in archive file."
														delegate:self
											   cancelButtonTitle:nil
											   otherButtonTitles:@"OK",nil]
							  autorelease];
		[alert show];
	} else {
		NSLog(@"pdf file exist. filename=%@", fromPath);
	}
	
	//Rename.
	[[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error];
	if (error != nil) {
		NSLog(@"cannot rename pdf file. from=%@, to=%@", fromPath, toPath);
	}
}


#pragma mark -
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
