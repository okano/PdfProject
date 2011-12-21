//
//  ServerContentDownloadVC.h
//  JPPBook
//
//  Created by okano on 11/09/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pdf2iPadAppDelegate.h"
#import "InAppPurchaseDefine.h"
#import "URLDownload.h"
#import "NSFileManager+Utility.h"
#import "ContentFileUtility.h"
#import "HetimaUnZip.h"

@interface ServerContentDownloadVC : UIViewController <URLDownloadDeleagte, UIAlertViewDelegate, HetimaUnZipItemDelegate> {
	//Downloader
	URLDownload *downloader;
	NSLock *downloaderLock;
	
	//Content ID.
	ContentId targetCid;
	//UUID
	NSString* targetUuid;
	//URL download from.
	NSURL* targetUrl;
	
	//Length
	long long expectedContentLength;
	long long downloadedContentLength;
	long long expectedUncompressedContentSize;
	//UI
	IBOutlet UILabel* progressLabel;
	IBOutlet UIProgressView* myProgressBar;
	IBOutlet UILabel* myProgressLabel;
	IBOutlet UILabel* downloadedContentLengthLabel;
	IBOutlet UILabel* expectedContentLengthLabel;
}
//targetCid is typedef UInteger. non @property.
@property (nonatomic, retain) NSString* targetUuid;
@property (nonatomic, retain) NSURL* targetUrl;
//GUI
@property (nonatomic, retain) UILabel* progressLabel;
@property (nonatomic, retain) UILabel* myProgressLabel;
@property (nonatomic, retain) UILabel* downloadedContentLengthLabel;
@property (nonatomic, retain) UILabel* expectedContentLengthLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil
			   bundle:(NSBundle *)nibBundleOrNil
			targetUrl:(NSURL*)url
		   targetUuid:(NSString*)uuid
			targetCid:(ContentId)cid;
- (void)askOverwrite;
- (void)doDownload;
- (void)releaseDownloader;
//
- (void)handleDownloadedPdf:(NSString*)filePath contentIdStr:(NSString*)contentIdStr;
- (void)handleDownloadedCbz:(NSString*)filePath contentIdStr:(NSString*)contentIdStr;
- (void)handleDownloadedZip:(NSString*)filePath contentIdStr:(NSString*)contentIdStr;
- (void)renamePdfWithCid:(NSString*)cidStr;

@end

// Handle zip.
@interface ServerContentDownloadVC (extract)
- (BOOL)unzipFile:(NSString*)fromFileFullname ToDirectory:(NSString*)toDirectory;

//
- (void)item:(HetimaUnZipItem *)item didExtractDataOfLength:(NSUInteger)length;
@end

#define ALERTVIEW_TAG_PDF_NOT_FOUND		20
#define ALERTVIEW_TAG_CONFIRM_OVERWRITE	35
#define ALERTVIEW_TAG_DOWNLOAD_CANCELED	40
#define ALERTVIEW_TAG_DOWNLOAD_FAILED	41

