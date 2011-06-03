//
//  PaymentConductor.m
//  SakuttoBook
//
//  Created by okano on 11/06/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaymentConductor.h"


@implementation PaymentConductor
@synthesize productsRequestDelegate;
@synthesize paymentHistoryDS;

#pragma mark - Get product infomation from Store, notify with Delegate.

- (void)getProductInfomation:(ContentId)cid
{
	//Check if disabled payment.(like on simulator)
	if (! [SKPaymentQueue canMakePayments]) {
		NSLog(@"cannot make payments");
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:nil
							  message:@"cannot make payments."
							  delegate:nil
							  cancelButtonTitle:nil
							  otherButtonTitles:@"OK", nil];
		[alert show];
#if TARGET_IPHONE_SIMULATOR
		NSLog(@"simulator not support SKProductsRequest.");
		[productsRequestDelegate productsRequest:nil
							  didReceiveResponse:nil];
#endif
	}
	
	//Make Payments.
	NSLog(@"can make payments");
	NSString* productId = [paymentHistoryDS getProductIdentifier:cid];
	NSSet* productIdList =[NSSet setWithObject:productId];
	SKProductsRequest* pRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdList];
	pRequest.delegate = self;
	[pRequest start];
	
	NSLog(@"productId=%@", [productId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
	id obj2 = [SKPaymentQueue defaultQueue];
	NSLog(@"obj2 class=%@", [obj2 class]);
	NSLog(@"paymentQueue=%@", [SKPaymentQueue description]);
	
}

#pragma mark - SKProductsRequestDelegate methods.
- (void)productsRequest:(SKProductsRequest *)request
	 didReceiveResponse:(SKProductsResponse *)responseParameters
{
	LOG_CURRENT_METHOD;
	NSLog(@"result: OK=%d, NG=%d", [responseParameters.products count], [responseParameters.invalidProductIdentifiers count]);
	if (0 < [responseParameters.invalidProductIdentifiers count]) {
		for (NSString* tmpProductId in responseParameters.invalidProductIdentifiers){
			NSLog(@"invalid product id = %@", tmpProductId);
		}
		for (id obj in responseParameters.invalidProductIdentifiers){
			NSLog(@"obj class=%@", [obj class]);
		}
	}
	
	for (SKProduct* resultProduct in responseParameters.products) {
		NSLog(@"valid productIdentifier=%@, localizedTitle=%@, localizedDescription=%@, price=%@, priceLocale=%@", 
			  resultProduct.productIdentifier,
			  resultProduct.localizedTitle,
			  resultProduct.localizedDescription,
			  resultProduct.price,
			  resultProduct.priceLocale
			  );
	}
	
	[productsRequestDelegate productsRequest:request
						  didReceiveResponse:responseParameters];
	
	[request autorelease];
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
	[paymentHistoryDS enableContentWithProductId:productID];
	
	//Delete complete transaction in queue.
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
- (void)restoreTransaction:(SKPaymentTransaction*)transaction{;}
- (void)failedTransaction:(SKPaymentTransaction*)transaction{;}


@end
