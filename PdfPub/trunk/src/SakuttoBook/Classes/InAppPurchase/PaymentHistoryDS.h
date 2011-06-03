//
//  PaymentHistory.h
//  PurchaseTest04
//
//  Created by okano on 11/05/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "Define.h"
#import "InAppPurchaseDefine.h"

@interface PaymentHistoryDS : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSMutableArray* paymentHistory;
	//
	id productsRequestDelegate;
}
@property (nonatomic, retain) NSMutableArray* paymentHistory;
@property (nonatomic, retain) id productsRequestDelegate;

- (void)savePaymentHistory;
- (void)loadPaymentHistory;
//Get id from file.
- (NSString*)getProductIdentifier:(ContentId)cid;
//Get product infomation from Store.
- (void)getProductInfomation:(ContentId)cid;
//
- (BOOL)isEnabledContent:(ContentId)cid;
- (void)enableContent:(ContentId)cid;
- (void)enableContentWithProductId:(NSString*)productId;
//- (void)disableContent:(ContentId)cid;

//SKPaymentTransactionObserver related methods.
- (void)completeTransaction:(SKPaymentTransaction*)transaction;
- (void)restoreTransaction:(SKPaymentTransaction*)transaction;
- (void)failedTransaction:(SKPaymentTransaction*)transaction;

- (void)buyContent:(NSString*)productId;
- (void)showImagePlayer:(ContentId)cid;

@end
