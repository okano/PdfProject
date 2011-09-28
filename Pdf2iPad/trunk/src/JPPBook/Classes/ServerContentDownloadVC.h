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
#import "ContentUrlUtility.h"

@interface ServerContentDownloadVC : UIViewController <URLDownloadDeleagte> {
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
	long long expectedUmcompressedContentSize;
}
//targetCid is typedef UInteger. non @property.
@property (nonatomic, retain) NSString* targetUuid;
@property (nonatomic, retain) NSURL* targetUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil
			   bundle:(NSBundle *)nibBundleOrNil
			targetUrl:(NSURL*)url
		   targetUuid:(NSString*)uuid;
- (void)doDownload;
- (void)releaseDownloader;


@end
