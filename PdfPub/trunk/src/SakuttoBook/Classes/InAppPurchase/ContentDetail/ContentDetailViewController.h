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

@interface ContentDetailViewController : UIViewController <VCWithInAppPurchaseProtocol> {
	SakuttoBookAppDelegate* appDelegate;
	ContentId targetCid;
	NSString* targetProductId;
	
	//UserInterface.
    IBOutlet UIImageView* thumbnailImageView;
	UIImage* image;
	IBOutlet UILabel* titleLabel;
	IBOutlet UILabel* authorLabel;
	IBOutlet UITextView* descriptionTextView;
	IBOutlet UIButton* buyButton;
}
@property (nonatomic, retain) UIImageView* thumbnailImageView;
@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UILabel* authorLabel;
@property (nonatomic, retain) UITextView* descriptionTextView;
@property (nonatomic, retain) UIButton* buyButton;

- (void)setLabelsWithContentId:(ContentId)cid;
- (IBAction)showContentList:(id)sender;
- (IBAction)buyContent:(id)sender;

//called from SKProductsRequestDelegate related methods.
- (void)productsRequest:(SKProductsRequest *)request
	 didReceiveResponse:(SKProductsResponse *)responseParameters;
//called from SKPaymentTransactionObserver related methods.
- (void)completeTransaction:(SKPaymentTransaction*)transaction;

@end
