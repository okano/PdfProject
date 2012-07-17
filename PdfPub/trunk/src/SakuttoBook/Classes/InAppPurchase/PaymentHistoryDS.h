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
#import "ProductIdList.h"

#import "ContentListDS.h"	/* only use for get content title. */

@interface PaymentHistoryDS : NSObject /* <SKProductsRequestDelegate, SKPaymentTransactionObserver> */ {
    NSMutableArray* paymentHistory;
	//
	id productsRequestDelegate;
	//
	//ProductIdList* productIdListPointer;
}
@property (nonatomic, retain) NSMutableArray* paymentHistory;
@property (nonatomic, retain) id productsRequestDelegate;
//@property (nonatomic, retain) ProductIdList* productIdListPointer;

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
- (void)recordHistoryOnceWithContentId:(ContentId)contentId ProductId:(NSString*)productId;
- (void)recordHistoryOnceWithContentId:(ContentId)contentId ProductId:(NSString*)productId date:(NSDate*)date;
- (BOOL)isExistSameRecordWithContentId:(ContentId)contentId ProductId:(NSString*)productId date:(NSDate*)date;

//Utility method.
- (NSString*)date2str:(NSDate*)targetDate;
- (NSMutableDictionary*)transcation2StringDict:(SKPaymentTransaction*)transaction;

- (void)buyContent:(NSString*)productId;

//Misc.
- (NSUInteger)count;
- (NSString*)description;
- (NSString*)descriptionAtIndex:(NSUInteger)index;
@end

#define PURCHASE_HISTORY_ARRAY	@"Purchase_History_Array"
#define PURCHASE_CONTENT_ID		@"Purchase_ContentId"
#define PURCHASE_DAYTIME		@"Purchase_DayTime"	/* time when call method. */
#define PURCHASE_PRODUCT_ID		@"Purchase_ProductId"
//
#define PURCHASE_TRANSACTION_DESCRIPTION	@"Purchase_Transaction_Description"
#define PURCHASE_TRANSACTION_DESCRIPTION_TRANSACTION_IDENTIFIER	@"Purchase_Transaction_Description_TransactionIdentifier"
#define PURCHASE_TRANSACTION_DESCRIPTION_TRANSACTION_STATE	@"Purchase_Transaction_Description_TransactionState"
#define PURCHASE_TRANSACTION_DESCRIPTION_TRANSACTION_DATE	@"Purchase_Transaction_Description_TransactionDate"
#define PURCHASE_TRANSACTION_DESCRIPTION_ORIGINAL_TRANSACTION_IDENTIFIER	@"Purchase_Transaction_Description_OriginalTransactionIdentifier"

//
#define TRANSACTION_STATE_STRING_PURCHASING	@"SKPaymentTransactionStatePurchasing"
#define TRANSACTION_STATE_STRING_PURCHASED	@"SKPaymentTransactionStatePurchased"
#define TRANSACTION_STATE_STRING_FAILED		@"SKPaymentTransactionStateFailed"
#define TRANSACTION_STATE_STRING_RESTORED	@"SKPaymentTransactionStateRestored"

