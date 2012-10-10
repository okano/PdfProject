//
//  PaymentConductor.h
//  SakuttoBook
//
//  Created by okano on 11/06/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "Utility.h"
#import "ProtocolDefine.h"
#import "InAppPurchaseDefine.h"
#import "ProductIdList.h"
#import "PaymentHistoryDS.h"
//
#import "VerificationController.h"

@interface PaymentConductor : NSObject
<SKProductsRequestDelegate,SKPaymentTransactionObserver> {
	UIViewController <VCWithInAppPurchaseProtocol> * parentVC;
	PaymentHistoryDS* paymentHistoryDS;
	NSMutableDictionary* productInfomationCache;
	BOOL withContinuePayment;
	NSString* productIdToBuy;
}
@property (nonatomic, retain) UIViewController* parentVC;
@property (nonatomic, retain) PaymentHistoryDS* paymentHistoryDS;
@property (nonatomic, retain) NSMutableDictionary* productInfomationCache;

//Get product infomation from Store.
//- (void)getProductInfomation:(ContentId)cid;
- (void)getProductInfomation:(NSString*)productId withContinueBuy:(BOOL)buyFlag;

- (void)buyContent:(NSString*)productId;

//Restore completed(purchased) transaction.
- (void)myRestoreCompletedTransactions;

//call from SKPaymentTransactionObserver related methods.
- (void)completeTransaction:(SKPaymentTransaction*)transaction;
- (void)restoreTransaction:(SKPaymentTransaction*)transaction;
- (void)failedTransaction:(SKPaymentTransaction*)transaction;

@end
