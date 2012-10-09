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
			targetCid:(ContentId)cid
{
	LOG_CURRENT_METHOD;
	LOG_CURRENT_LINE;
	NSLog(@"url=%@(class %@)", [url description], [url class]);
	
	targetUrl = url;
	targetUuid = [NSString stringWithString:uuid];
	targetCid = cid;
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
		return;
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
			
			//Set Ignore Backup.
			NSURL* ignoreBackupUrl = [NSURL URLWithString:contentDownloadDirectory];
			[FileUtility addSkipBackupAttributeToItemAtURL:ignoreBackupUrl];
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

#pragma mark -
- (void)askOverwrite
{
	LOG_CURRENT_METHOD;
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Downloaded file was exist"
													 message:@"Do you want to overwrite it?"
													delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"OK",nil]
						  autorelease];
	alert.tag = ALERTVIEW_TAG_CONFIRM_OVERWRITE;
	[alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	LOG_CURRENT_METHOD;
	NSLog(@"action sheet: index=%d", buttonIndex);
    
	if (alertView.tag != ALERTVIEW_TAG_CONFIRM_OVERWRITE) {
		return;
	}
	
	if( buttonIndex == [alertView cancelButtonIndex])	//"Cancel" selected.
    {
        //Close this window.
		[self dismissModalViewControllerAnimated:YES];
		/*
		Pdf2iPadAppDelegate* appDelegate = (Pdf2iPadAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate hideServerContentDetailView];
		[appDelegate showServerContentDetailView:targetUuid];
		*/
	}
    else if(buttonIndex == [alertView firstOtherButtonIndex])	//"OK" Selected.
	{
		//Delete directory for contents.
		NSString* cidStr = [NSString stringWithFormat:@"%d", targetCid];
		NSString* contentFileDirectory = [ContentFileUtility getContentBodyDirectoryWithContentId:cidStr];
		//NSString* contentFilename = [ContentFileUtility getContentBodyFilenamePdf:cidStr];
		//NSLog(@"contentFilename=%@", contentFilename);
		//NSLog(@"contentFileDirectory=%@", contentFileDirectory);
		
		NSFileManager* fMgr = [NSFileManager defaultManager];
		NSError* error = nil;
		[fMgr removeItemAtPath:contentFileDirectory error:&error];
		if (error) {
			LOG_CURRENT_METHOD;
			NSLog(@"content directory delete error. %@", [error localizedDescription]);
			NSLog(@"content directory =%@", contentFileDirectory);
		}
		
		//Delete old metadata.
		SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate.contentListDS removeMetadataWithContentId:targetCid];
		
		//Delete old page cache.
		NSString* topPageCacheFilename = [FileUtility getPageFilenameFull:1 WithContentId:targetCid];
		NSString* pageCacheDir = [topPageCacheFilename stringByDeletingLastPathComponent];
		//NSLog(@"page cache dir = %@", pageCacheDir);
		[fMgr removeItemAtPath:pageCacheDir error:&error];
		if (error) {
			LOG_CURRENT_METHOD;
			NSLog(@"pageCache directory delete error. %@", [error localizedDescription]);
			NSLog(@"pageCache directory =%@", pageCacheDir);
		}
		
		
		//Do(retry) download.
		[self doDownload];
    } else {
		NSLog(@"button tapped. index=%d", buttonIndex);
        //Close this window.
		[self dismissModalViewControllerAnimated:YES];
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
	NSLog(@"downloaded file at %@", download.filePath);
	[self releaseDownloader];
	
	//NSError* error = nil;

	SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];

	
	//Copy metadata from server to local ContentListDS.
	NSLog(@"uuid at server = %@", targetUuid);
	NSMutableDictionary* metaData2 = [NSMutableDictionary dictionaryWithDictionary:[appDelegate.serverContentListDS getMetadataByUuid:targetUuid]];
	if (! metaData2) {
		NSLog(@"cannot get metadata. UUID=%@", targetUuid);
	}
	NSLog(@"metaData2=%@", [metaData2 description]);
	[appDelegate.contentListDS removeMetadataWithUuid:targetUuid];
	[appDelegate.contentListDS addMetadata:metaData2];
	[appDelegate.contentListDS saveToPlist];
	
	//Get ContentId from metadata in server.
	ContentId newContentId = [[metaData2 objectForKey:CONTENT_CID] intValue];
	NSString* newContentIdStr = [NSString stringWithFormat:@"%d", newContentId];
	//NSLog(@"new ContentId=%d", newContentId);
	
	
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
	
	
	//Add Download(purchase) history. -> do it by PaymentConductor.
	//[appDelegate.paymentHistoryDS enableContent:newContentId];
	
	
	
	//Copy image cache for Cover.
	UIImage* thumbnailImage = [CoverUtility coverImageWithUuid:targetUuid];
	NSString* toFilename = [CoverUtility getCoverLocalFilenameFull:[newContentIdStr intValue]];
	NSLog(@"toFilename=%@", toFilename);
	[FileUtility makeDir:[toFilename stringByDeletingLastPathComponent]];
	//Set Ignore Backup.
	NSURL* ignoreBackupUrl = [NSURL URLWithString:[toFilename stringByDeletingLastPathComponent]];
	[FileUtility addSkipBackupAttributeToItemAtURL:ignoreBackupUrl];

	NSData *data = UIImageJPEGRepresentation(thumbnailImage, 1.0f);
	if ( ! [data writeToFile:toFilename atomically:YES])
	{
		NSLog(@"thumbnail file copy error");
	}
	
	//Set Ignore Backup.
	NSURL* ignoreBackupUrl2 = [NSURL URLWithString:toFilename];
	[FileUtility addSkipBackupAttributeToItemAtURL:ignoreBackupUrl2];

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
	
	//Set Ignore Backup.
	NSURL* ignoreBackupUrl = [NSURL URLWithString:dirStr];
	[FileUtility addSkipBackupAttributeToItemAtURL:ignoreBackupUrl];
	
	//Copy file.
	NSString* fromPathFullFormatted = [NSString stringWithCString:[[NSFileManager defaultManager] fileSystemRepresentationWithPath:filePath] encoding:NSUTF8StringEncoding];
	
	NSString* toPathFull = [[dirStr stringByAppendingPathComponent:contentIdStr]
								   stringByAppendingPathExtension:@"pdf"];
	NSString* toPathFullFormatted = [NSString stringWithCString:[[NSFileManager defaultManager] fileSystemRepresentationWithPath:toPathFull] encoding:NSUTF8StringEncoding];
	[[NSFileManager defaultManager] moveItemAtPath:fromPathFullFormatted
											toPath:toPathFullFormatted
											 error:&error];
	if (error != nil) {
		NSLog(@"fail to move downloaded file. fromPath=%@, toPath=%@, result=%@, %@",
			  filePath, toPathFull, [error localizedDescription], [error localizedFailureReason]);
		NSLog(@"fromPathFullFormatted=%@", fromPathFullFormatted);
		NSLog(@"toPathFullFormatted=%@", toPathFullFormatted);
	}
	
	//Set Ignore Backup.
	NSURL* ignoreBackupUrl2 = [NSURL URLWithString:toPathFullFormatted];
	[FileUtility addSkipBackupAttributeToItemAtURL:ignoreBackupUrl2];
}

- (void)handleDownloadedCbz:(NSString*)filePath contentIdStr:(NSString*)contentIdStr;
{
	//Rename filename from "*.cbz" to "*.zip".
	NSError* error = nil;
	NSString* fromPathFullFormatted = [NSString stringWithCString:[[NSFileManager defaultManager] fileSystemRepresentationWithPath:filePath] encoding:NSUTF8StringEncoding];
	NSString* newFilePath = [[fromPathFullFormatted stringByDeletingPathExtension]
							 stringByAppendingPathExtension:@"zip"];
	//Delete old destination.
	[[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&error];
	//Rename
	[[NSFileManager defaultManager] moveItemAtPath:fromPathFullFormatted
											toPath:newFilePath
											 error:&error];
	if (error != nil) {
		if ([FileUtility existsFile:newFilePath] == YES) {
			NSLog(@"file rename failed. but file exists at %@", newFilePath);
		} else {
			NSLog(@"file rename failed. fromPath=%@, toPath=%@, result=%@, %@",
				  filePath, newFilePath, [error localizedDescription], [error localizedFailureReason]);
			NSLog(@"fromPathFullFormatted=%@", fromPathFullFormatted);
			NSLog(@"file exist check with filePath=%d", [FileUtility existsFile:filePath]);
			NSLog(@"file exist check with newFilePath=%d", [FileUtility existsFile:newFilePath]);
			NSLog(@"TRUE=%d, FALSE=%d", TRUE, FALSE);
			
			if (error.code == 516) {
				NSLog(@"code NSFileWriteFileExistsError = 516, Write error returned when NSFileManager class’s copy, move, and link methods report errors when the destination file already exists.");
			}
		}
	}
	
	//Set Ignore Backup.
	NSURL* ignoreBackupUrl = [NSURL URLWithString:newFilePath];
	[FileUtility addSkipBackupAttributeToItemAtURL:ignoreBackupUrl];
	
	//Extract file.
	[self handleDownloadedZip:newFilePath contentIdStr:contentIdStr];
}

- (void)handleDownloadedZip:(NSString*)filePath contentIdStr:(NSString*)contentIdStr;
{
	//Extract.
	NSError* error = nil;
	
	//Clear directory for extract.
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
	NSString* contentBodyDirectory = [ContentFileUtility getContentBodyDirectory];
	[FileUtility makeDir:contentBodyDirectory];
	NSString* contentDirectoryWithContentId = [[ContentFileUtility getContentBodyDirectory]
											   stringByAppendingPathComponent:contentIdStr];
	[[NSFileManager defaultManager] moveItemAtPath:[ContentFileUtility getContentExtractDirectory]
											toPath:contentDirectoryWithContentId 
											 error:&error];
	
	//Set Ignore Backup with contentBodyDirectory.
	NSURL* ignoreBackupUrl = [NSURL URLWithString:contentBodyDirectory];
	[FileUtility addSkipBackupAttributeToItemAtURL:ignoreBackupUrl];
	
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
	
	//Check pdf file included in zip file.
	if([[NSFileManager defaultManager] fileExistsAtPath:fromPath] == NO)
	{
		NSLog(@"pdf file cannot found in archive file. expect filename=%@", fromPath);
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Downloaded file error"
														 message:@"PDF file does not found in archive file."
														delegate:self
											   cancelButtonTitle:nil
											   otherButtonTitles:@"OK",nil]
							  autorelease];
		alert.tag = ALERTVIEW_TAG_PDF_NOT_FOUND;
		[alert show];
		
		//Delete content from contentList.
		SakuttoBookAppDelegate* appDelegate = (SakuttoBookAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate.contentListDS removeMetadataWithContentId:[cidStr intValue]];
		
		return;
	} else {
		NSLog(@"copy-from pdf file found. filename=%@", fromPath);
	}
	
	//Rename.
	[[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error];
	if (error != nil) {
		NSLog(@"cannot rename pdf file. from=%@, to=%@", fromPath, toPath);
	}
	
	//Set Ignore Backup.
	NSURL* ignoreBackupUrl = [NSURL URLWithString:toPath];
	[FileUtility addSkipBackupAttributeToItemAtURL:ignoreBackupUrl];
}


#pragma mark -
// ダウンロードをキャンセルした際に呼ばれる
- (void)download:(URLDownload *)download didCancelBecauseOf:(NSException *)exception {
	LOG_CURRENT_METHOD;
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"download canceled." message:[exception reason] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil] autorelease];
	alert.tag = ALERTVIEW_TAG_DOWNLOAD_CANCELED;
	[alert show];
	[self releaseDownloader];
}

// ダウンロードに失敗した際に呼ばれる
- (void)download:(URLDownload *)download didFailWithError:(NSError *)error {
	LOG_CURRENT_METHOD;
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"download failed." message:[error localizedDescription] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil] autorelease];
	alert.tag = ALERTVIEW_TAG_DOWNLOAD_FAILED;
	[alert show];
	[self releaseDownloader];
}

// ダウンロード進行中に呼ばれる
- (void)download:(URLDownload *)download didReceiveDataOfLength:(NSUInteger)length {
	// プログレスバーの表示でもやる
	//LOG_CURRENT_METHOD;
	//NSLog(@"length=%d", length);
	downloadedContentLength += length;
	downloadedContentLengthLabel.text = [NSString stringWithFormat:@"%10lld", downloadedContentLength];
}

- (void)download:(URLDownload *)download didReceiveResponse:(NSURLResponse *)response {
	expectedContentLength = [response expectedContentLength];
	expectedContentLengthLabel.text = [NSString stringWithFormat:@"%lld", expectedContentLength];
#if IS_DEBUG
	NSLog(@"expected content length=%d", expectedContentLength);
#endif
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
