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
#import "InAppPurchaseDefine.h"
#import "InAppPurchaseUtility.h"
#import "PaymentHistoryDS.h"

@interface PaymentConductor : NSObject
<SKProductsRequestDelegate,SKPaymentTransactionObserver> {
	id productsRequestDelegate;
	PaymentHistoryDS* paymentHistoryDS;
}
@property (nonatomic, retain) id productsRequestDelegate;
@property (nonatomic, retain) PaymentHistoryDS* paymentHistoryDS;


//Get product infomation from Store.
- (void)getProductInfomation:(ContentId)cid;

//call from SKPaymentTransactionObserver related methods.
- (void)completeTransaction:(SKPaymentTransaction*)transaction;
- (void)restoreTransaction:(SKPaymentTransaction*)transaction;
- (void)failedTransaction:(SKPaymentTransaction*)transaction;

@end
