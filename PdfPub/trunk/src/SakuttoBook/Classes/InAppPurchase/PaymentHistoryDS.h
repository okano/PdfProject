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

@interface PaymentHistoryDS : NSObject /* <SKProductsRequestDelegate, SKPaymentTransactionObserver> */ {
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
//
- (BOOL)isEnabledContent:(ContentId)cid;
- (void)enableContent:(ContentId)cid;
- (void)enableContentWithProductId:(NSString*)productId;
//- (void)disableContent:(ContentId)cid;

- (void)buyContent:(NSString*)productId;

@end
#define PURCHASE_HISTORY_ARRAY	@"Purchase_History_Array"
#define PURCHASE_CONTENT_ID		@"Purchase_ContentId"
#define PURCHASE_DAYTIME		@"Purchase_DayTime"	/* time when call method. */
