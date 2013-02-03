//
//  ContentDetailView.h
//  SakuttoBook
//
//  Created by okano on 11/06/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppPurchaseDefine.h"
#import "ProductIdList.h"
#import "SakuttoBookAppDelegate.h"
#import "ServerContentDownloadVC.h"
#import "CoverUtility.h"

@interface ServerContentDetailVC : UIViewController <VCWithInAppPurchaseProtocol> {
	SakuttoBookAppDelegate* appDelegate;
	ContentId targetCid;
	NSString* targetProductId;
	NSString* taregetUuid;
	NSURL* targetUrl;
	
	//UserInterface.
	IBOutlet UIScrollView* scrollView;
    IBOutlet UIImageView* thumbnailImageView;
	IBOutlet UIScrollView* thumbnailScrollView;
	UIImage* image;
	IBOutlet UILabel* titleLabel;
	IBOutlet UILabel* authorLabel;
	IBOutlet UITextView* descriptionTextView;
	IBOutlet UILabel* priceLabel;
	//
	IBOutlet UIButton* buyButton;
	IBOutlet UIButton* reDownloadButton;
	//For debug.
	IBOutlet UIButton* downloadWithoutPurchaseButton;
}
@property (nonatomic, retain) NSString* targetUuid;
@property (nonatomic, retain) NSURL* targetUrl;
@property (nonatomic, retain) UIImageView* thumbnailImageView;
@property (nonatomic, retain) UIScrollView* thumbnailScrollView;
@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UILabel* authorLabel;
@property (nonatomic, retain) UITextView* descriptionTextView;
@property (nonatomic, retain) UILabel* priceLabel;

@property (nonatomic, retain) UIButton* buyButton;
@property (nonatomic, retain) UIButton* reDownloadButton;

//- (void)setLabelsWithContentId:(ContentId)cid;
- (void)setLabelsWithUuid:(NSString*)uuid;
- (void)enableBuyButton;
- (void)disableBuyButton;
- (void)hideBuyButton;
- (void)enableReDownloadButton;
- (void)disableReDownloadButton;
- (void)hideReDownloadButton;

//Close this view.
- (IBAction)showServerContentList:(id)sender;
//Buy and Download.
- (IBAction)pushedBuyButton:(id)sender;
- (IBAction)downloadContent:(id)sender;

//For debug.
- (IBAction)downloadWithoutPurchase:(id)sender;
- (void)showDownloadWithoutPurchase;
- (void)hideDownloadWithoutPurchase;
#define DEBUG_FREE_PURCHASE 0	/* 1:download without purchase. */

//called from SKProductsRequestDelegate related methods.
//- (void)productsRequest:(SKProductsRequest *)request
//	 didReceiveResponse:(SKProductsResponse *)responseParameters;
//called from SKPaymentTransactionObserver related methods.
//- (void)completeTransaction:(SKPaymentTransaction*)transaction;

@end
