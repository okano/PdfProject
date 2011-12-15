//
//  PaymentHistory.m
//  PurchaseTest04
//
//  Created by okano on 11/05/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaymentHistoryDS.h"


@implementation PaymentHistoryDS
@synthesize paymentHistory;
@synthesize productsRequestDelegate;

#pragma mark - initialize.
- (id)init
{
    self = [super init];
    if (self) {
		paymentHistory = [[NSMutableArray alloc] init];
		[self loadPaymentHistory];
    }
    return self;
}

#pragma mark - save/load with file.
- (void)savePaymentHistory
{
	//LOG_CURRENT_METHOD;
	//NSLog(@"all paymentHistory=%@", [paymentHistory description]);
	
	//Store bookmark infomation to UserDefault.
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setObject:paymentHistory forKey:PURCHASE_HISTORY_ARRAY];
	[userDefault synchronize];
}
- (void)loadPaymentHistory
{
	NSDictionary* settings = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	id obj = [settings valueForKey:PURCHASE_HISTORY_ARRAY];
	if (!obj) {		//no payment history exists.
		return;
	}
	if (![obj isKindOfClass:[NSArray class]]) {
		NSLog(@"illigal payment history infomation. class=%@", [obj class]);
		return;
	}
	[self.paymentHistory removeAllObjects];
	[self.paymentHistory addObjectsFromArray:obj];
	return;
}


/*
#pragma mark - SKProductsRequestDelegate methods.
- (void)productsRequest:(SKProductsRequest *)request
	 didReceiveResponse:(SKProductsResponse *)responseParameters
{
	LOG_CURRENT_METHOD;
	if (0 < [responseParameters.invalidProductIdentifiers count]) {
		NSLog(@"invalid product id.");
		for (NSString* tmpProductId in responseParameters.invalidProductIdentifiers){
			NSLog(@"invalid product id = %@", tmpProductId);
		}
	}
	
	for (SKProduct* resultProduct in responseParameters.products) {
		NSLog(@"productIdentifier=%@, localizedTitle=%@, localizedDescription=%@, price=%@, priceLocale=%@", 
			  resultProduct.productIdentifier,
			  resultProduct.localizedTitle,
			  resultProduct.localizedDescription,
			  resultProduct.price,
			  resultProduct.priceLocale
			  );
	}
	
	[productsRequestDelegate productsRequest:request
						  didReceiveResponse:responseParameters];
}

#pragma mark - SKPaymentTransactionObserver Protocol methods.
//Handling Transactions
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	LOG_CURRENT_METHOD;
	for (SKPaymentTransaction* transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased:
				NSLog(@"SKPaymentTransactionStatePurchased");
				[self completeTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				NSLog(@"SKPaymentTransactionStateFailed");
				[self failedTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
				NSLog(@"SKPaymentTransactionStateRestored");
				[self restoreTransaction:transaction];
				break;
			case SKPaymentTransactionStatePurchasing:
				NSLog(@"SKPaymentTransactionStatePurchasing");
				break;
				
			default:
				break;
		}
	};
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions{;}

//Handling Restored Transactions
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{;}
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{;}

#pragma mark - related SKPaymentTransactionObserver methods.
- (void)completeTransaction:(SKPaymentTransaction*)transaction
{
	//Record Transaction.
	NSData* receipt = [transaction transactionReceipt];
	NSMutableDictionary* dict = [NSPropertyListSerialization propertyListWithData:receipt
											  options:NSPropertyListMutableContainersAndLeaves 
											   format:NULL
												error:NULL];
	NSLog(@"dict = %@", [dict description]);
	
	NSLog(@"environment=%@", [dict valueForKey:@"environment"]);
	NSLog(@"pod=%@", [dict valueForKey:@"pod"]);
	NSLog(@"purchase-info=%@", [dict valueForKey:@"purchase-info"]);
	NSLog(@"signature=%@", [dict valueForKey:@"signature"]);
	NSLog(@"signing-status=%@", [dict valueForKey:@"signing-status"]);
	
	//Enable contents.
	NSString* productID = transaction.payment.productIdentifier;
	[self enableContentWithProductId:productID];
	
	//Delete complete transaction in queue.
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
- (void)restoreTransaction:(SKPaymentTransaction*)transaction{;}
- (void)failedTransaction:(SKPaymentTransaction*)transaction{;}
*/


#pragma mark - 
- (BOOL)isEnabledContent:(ContentId)cid
{
	//Check if Free Content.
	NSString* pid = [InAppPurchaseUtility getProductIdentifier:cid];
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d, pid=%@", cid, pid);
	if ([InAppPurchaseUtility isFreeContent:pid] == TRUE)
	{
		return TRUE;
	}
	
	//Find from Payment History.
	for (NSDictionary* tmpDict in paymentHistory) {
		ContentId candidateContentId = [[tmpDict valueForKey:PURCHASE_CONTENT_ID] intValue];
		if (candidateContentId == cid) {
			return TRUE;
		}
	}
	return FALSE;
}
/*
- (void)buyContent:(NSString*)productId
{
	LOG_CURRENT_METHOD;
	NSLog(@"productId=%@", productId);
	//Check enable payment.
	if (! [SKPaymentQueue canMakePayments]) {
		NSLog(@"cannot make payments");
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"cannot make payments."
							  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
		return;
	}
	
	//Process Payment.
	SKPayment* payment = [SKPayment paymentWithProductIdentifier:productId];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}
*/
- (void)enableContent:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	NSString* pid = [InAppPurchaseUtility getProductIdentifier:cid];

	NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:pid forKey:PURCHASE_PRODUCT_ID];
	[tmpDict setValue:[NSNumber numberWithInt:cid] forKey:PURCHASE_CONTENT_ID];
	[tmpDict setValue:[NSDate dateWithTimeIntervalSinceNow:0.0f] forKey:PURCHASE_DAYTIME];
	//NSLog(@"enable content. cid=%d, pid=%@, dict=%@", cid, pid, [tmpDict description]);
	[paymentHistory addObject:tmpDict];
	//NSLog(@"paymentHistory=%@", [paymentHistory description]);
	//
	[self savePaymentHistory];
	;
}
- (void)enableContentWithProductId:(NSString *)productId
{
	//LOG_CURRENT_METHOD;
	NSDictionary* tmpDict = [[NSDictionary alloc] init];
	[self enableContentWithProductId:productId WithDict:tmpDict];
}
- (void)enableContentWithProductId:(NSString*)productId WithDict:(NSDictionary*)dict
{
	//LOG_CURRENT_METHOD;
	ContentId cid = [InAppPurchaseUtility getContentIdentifier:productId];
	
	NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
	[tmpDict setValue:productId forKey:PURCHASE_PRODUCT_ID];
	[tmpDict setValue:[NSNumber numberWithInt:cid] forKey:PURCHASE_CONTENT_ID];
	[tmpDict setValue:[NSDate dateWithTimeIntervalSinceNow:0.0f] forKey:PURCHASE_DAYTIME];
	//NSLog(@"enable content. cid=%d, pid=%@, dict=%@", cid, productId, [tmpDict description]);
	[paymentHistory addObject:tmpDict];
	//
	[self savePaymentHistory];
}
//- (void)disableContent:(ContentId)cid{;}

- (void)recordHistoryOnceWithProductId:(NSString*)productId
{
	LOG_CURRENT_METHOD;
	
	//Check if already recorded, do nothing.
	for (NSDictionary* candidateDict in paymentHistory){
		NSString* candidateProductId = [candidateDict valueForKey:PURCHASE_PRODUCT_ID];
		if ([productId compare:candidateProductId] == NSOrderedSame) {
			return;
		}
	}
	
	//Record it.
	ContentId cid = [InAppPurchaseUtility	getContentIdentifier:productId];
	NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:productId forKey:PURCHASE_PRODUCT_ID];
	[tmpDict setValue:[NSNumber numberWithInt:cid] forKey:PURCHASE_CONTENT_ID];
	[tmpDict setValue:[NSDate dateWithTimeIntervalSinceNow:0.0f] forKey:PURCHASE_DAYTIME];
	//NSLog(@"enable content. cid=%d, pid=%@, dict=%@", cid, productId, [tmpDict description]);
	[paymentHistory addObject:tmpDict];
	//
	[self savePaymentHistory];
}


#pragma mark - Misc.
- (NSUInteger)count
{
	return [paymentHistory count];
}
- (NSString*)description
{
	int maxCount = [paymentHistory count];
	NSMutableString* resultStr = [[NSMutableString alloc] init];
	for (int i = 0; i < maxCount; i = i + 1) {
		[resultStr appendString:[self descriptionAtIndex:i]];
	}
	return resultStr;
}
- (NSString*)descriptionAtIndex:(NSUInteger)index
{
	if ([paymentHistory count] <= index) {
		return @"";
	}
	
	NSDictionary* tmpDict = [paymentHistory objectAtIndex:index];
	//LOG_CURRENT_LINE;
	//NSLog(@"tmpDict=%@", [tmpDict description]);
	ContentId cid = [[tmpDict valueForKey:PURCHASE_CONTENT_ID] intValue];
	NSString* pid = [tmpDict valueForKey:PURCHASE_PRODUCT_ID];
	
	ContentListDS* tmpList = [[ContentListDS alloc] init];
	NSString* title = [tmpList titleByContentId:cid];
	
	//format date.
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd(E) HH:mm:ss"];
	NSString *purchaseDaytime = [formatter stringFromDate:[tmpDict valueForKey:PURCHASE_DAYTIME]];
	
	return [NSString stringWithFormat:@" %@%c 購入日時:%@%c (ContentId=%@ ProductId=%@)",
			title,
			0x0d,
			purchaseDaytime,
			0x0d,
			[NSString stringWithFormat:@"%d", cid],
			pid
			];
}

@end
