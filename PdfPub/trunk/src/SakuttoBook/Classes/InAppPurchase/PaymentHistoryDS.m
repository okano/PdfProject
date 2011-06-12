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
    }
    return self;
}

#pragma mark - save/load with file.
- (void)savePaymentHistory{;}
- (void)loadPaymentHistory{;}

#pragma mark - Get id from file.
- (NSString*)getProductIdentifier:(ContentId)cid
{
	
	//parse csv file.
	NSString* csvFilePath = [[NSBundle mainBundle] pathForResource:@"productIdList" ofType:@"csv"];
	NSError* error = nil;
	NSString* text = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		LOG_CURRENT_METHOD;
		LOG_CURRENT_LINE;
		NSLog(@"error=%@, error code=%d", [error localizedDescription], [error code]);
		if ([error code] == NSFileReadInvalidFileNameError) {
			NSLog(@"Read error because of an invalid file name. (file not exist?)");
		}
		return @"";
	}
	
	NSArray* lines = [text componentsSeparatedByString:@"\n"];
	if (cid < [lines count]) {
		return [lines objectAtIndex:(cid-1)];
	}
	return @"";
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
	return FALSE;
}
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
- (void)enableContent:(ContentId)cid{;}
- (void)enableContentWithProductId:(NSString *)productId
{
	LOG_CURRENT_METHOD;
	
}
//- (void)disableContent:(ContentId)cid{;}

@end
