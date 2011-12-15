//
//  ContentDetailView.h
//  SakuttoBook
//
//  Created by okano on 11/06/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppPurchaseDefine.h"
#import "InAppPurchaseUtility.h"
#import "Pdf2iPadAppDelegate.h"
#import "ServerContentDownloadVC.h"
#import "CoverUtility.h"

@interface ServerContentDetailVC : UIViewController <VCWithInAppPurchaseProtocol> {
	Pdf2iPadAppDelegate* appDelegate;
	ContentId targetCid;
	NSString* targetProductId;
	NSString* taregetUuid;
	NSURL* targetUrl;
	
	//UserInterface.
    IBOutlet UIImageView* thumbnailImageView;
	UIImage* image;
	IBOutlet UILabel* titleLabel;
	IBOutlet UILabel* authorLabel;
	IBOutlet UITextView* descriptionTextView;
	IBOutlet UILabel* priceLabel;
	//
	IBOutlet UIButton* buyButton;
	IBOutlet UIButton* reDownloadButton;
}
@property (nonatomic, retain) NSString* targetUuid;
@property (nonatomic, retain) NSURL* targetUrl;
@property (nonatomic, retain) UIImageView* thumbnailImageView;
@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UILabel* authorLabel;
@property (nonatomic, retain) UITextView* descriptionTextView;
@property (nonatomic, retain) UILabel* priceLabel;

@property (nonatomic, retain) UIButton* buyButton;
@property (nonatomic, retain) UIButton* reDownloadButton;

//- (void)setLabelsWithContentId:(ContentId)cid;
- (void)setLabelsWithUuid:(NSString*)uuid;
- (IBAction)showServerContentList:(id)sender;
- (IBAction)buyContent:(id)sender;
- (IBAction)downloadContent:(id)sender;

//called from SKProductsRequestDelegate related methods.
//- (void)productsRequest:(SKProductsRequest *)request
//	 didReceiveResponse:(SKProductsResponse *)responseParameters;
//called from SKPaymentTransactionObserver related methods.
//- (void)completeTransaction:(SKPaymentTransaction*)transaction;

@end
