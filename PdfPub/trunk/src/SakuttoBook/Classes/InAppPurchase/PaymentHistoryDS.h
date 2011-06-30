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
#import "InAppPurchaseUtility.h"

@interface PaymentHistoryDS : NSObject /* <SKProductsRequestDelegate, SKPaymentTransactionObserver> */ {
    NSMutableArray* paymentHistory;
	//
	id productsRequestDelegate;
}
@property (nonatomic, retain) NSMutableArray* paymentHistory;
@property (nonatomic, retain) id productsRequestDelegate;

//Save/Load with UserDefault.
- (void)savePaymentHistory;
- (void)loadPaymentHistory;
//
- (BOOL)isEnabledContent:(ContentId)cid;
- (void)enableContent:(ContentId)cid;
- (void)enableContentWithProductId:(NSString*)productId;
- (void)enableContentWithProductId:(NSString*)productId WithDict:(NSDictionary*)dict;
//- (void)disableContent:(ContentId)cid;
- (void)recordHistoryOnceWithProductId:(NSString*)productId;

- (void)buyContent:(NSString*)productId;

//Misc.
- (NSUInteger)count;
- (NSString*)descriptionAtIndex:(NSUInteger)index;
@end

#define PURCHASE_HISTORY_ARRAY	@"Purchase_History_Array"
#define PURCHASE_CONTENT_ID		@"Purchase_ContentId"
#define PURCHASE_DAYTIME		@"Purchase_DayTime"	/* time when call method. */
#define PURCHASE_PRODUCT_ID		@"Purchase_ProductId"

