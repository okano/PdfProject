//
//  PaymentConductor.m
//  SakuttoBook
//
//  Created by okano on 11/06/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaymentConductor.h"


@implementation PaymentConductor
@synthesize parentVC;
@synthesize paymentHistoryDS;

#pragma mark - Get product infomation from Store, notify with Delegate.

//- (void)getProductInfomation:(ContentId)cid
- (void)getProductInfomation:(NSString*)productId
{
	//Check if disabled payment.(like on simulator)
	if (! [SKPaymentQueue canMakePayments]) {
		NSLog(@"cannot make payments");
		UIAlertView *alert = [[[UIAlertView alloc]
							   initWithTitle:nil
							   message:@"cannot make payments."
							   delegate:nil
							   cancelButtonTitle:nil
							   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
#if TARGET_IPHONE_SIMULATOR
		NSLog(@"simulator not support SKProductsRequest.");
		[parentVC productRequestDidFailed:nil];
#endif
	}
	
	//Make Payments.
	LOG_CURRENT_METHOD;
	NSLog(@"can make payments");
	NSLog(@"productId=%@", productId);
	NSSet* productIdListSet =[NSSet setWithObject:productId];
	//NSString* fullProductId = [InAppPurchaseUtility productIdWithFullQualifier:productId];
	//NSLog(@"fullProductId=%@", fullProductId);
	//NSSet* productIdList =[NSSet setWithObject:fullProductId];
	
	/*
	NSString* productName = [NSString stringWithFormat:@"jp.kounago.PurchaseTest02.Product2_1"];

	//SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:fullProductId]];
	SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdList];
	
	request.delegate = self;
	[request start];
	*/
	/*
	SKProductsRequest* request = [[SKProductsRequest alloc]
								  initWithProductIdentifiers:[NSSet setWithObject:productName]];
	request.delegate = self;
	[request start];
	 */
	
	
	SKProductsRequest* pRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdListSet];
	pRequest.delegate = self;
	[pRequest start];
	 

}

#pragma mark - Get product infomation from Store, SKProductsRequestDelegate methods.
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
	
	if (0 < [responseParameters.products count]) {
		for (SKProduct* resultProduct in responseParameters.products) {
			NSLog(@"valid productIdentifier=%@, localizedTitle=%@, localizedDescription=%@, price=%@, priceLocale=%@", 
				  resultProduct.productIdentifier,
				  resultProduct.localizedTitle,
				  resultProduct.localizedDescription,
				  resultProduct.price,
				  resultProduct.priceLocale
				  );
		}
		
		[parentVC productRequestDidSuccess:[responseParameters.products objectAtIndex:0]];
	} else {
		[parentVC productRequestDidFailed:@"no product in result."];
	}
	
	[request autorelease];
}

#pragma mark - Buy Content.
- (void)buyContent:(NSString*)productId
{
	LOG_CURRENT_METHOD;
	NSLog(@"productId=%@", productId);
	//Check enable payment.
	if (! [SKPaymentQueue canMakePayments]) {
		NSLog(@"cannot make payments");
		
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
														 message:@"cannot make payments."
														delegate:nil
											   cancelButtonTitle:nil
											   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
		return;
	}
	
	//Process Payment.
	//NSString* fullProductId = [InAppPurchaseUtility productIdWithFullQualifier:productId];
	//NSLog(@"fullProductId=%@", fullProductId);
	//SKPayment* payment = [SKPayment paymentWithProductIdentifier:fullProductId];
	
	SKPayment* payment = [SKPayment paymentWithProductIdentifier:productId];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark - Handle purhcase. (SKPaymentTransactionObserver Protocol methods.)
//Handling Transactions
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	//LOG_CURRENT_METHOD;
	VerificationController* vc;
	vc = [VerificationController sharedInstance];
	BOOL verificateResult = NO;
	for (SKPaymentTransaction* transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased:
				//NSLog(@"SKPaymentTransactionStatePurchased, transactionIdentifier=%@", [transaction transactionIdentifier]);
				//Verificate Transaction.
				verificateResult = [vc verifyPurchase:transaction];
				if (verificateResult == NO) {
					NSLog(@"purchased transaction does not verificate. description=%@", [transaction description]);
					return;
				} else {
					[self completeTransaction:transaction];
				}
				break;
			case SKPaymentTransactionStateFailed:
				NSLog(@"SKPaymentTransactionStateFailed, transactionIdentifier=%@", [transaction transactionIdentifier]);
				[self failedTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
				NSLog(@"SKPaymentTransactionStateRestored, transactionIdentifier=%@", [transaction transactionIdentifier]);
				//Verificate Transaction.
				verificateResult = [vc verifyPurchase:transaction];
				if (verificateResult == NO) {
					NSLog(@"restored transaction does not verificate. description=%@", [transaction description]);
					return;
				} else {
					[self restoreTransaction:transaction];
					[self completeTransaction:transaction];
				}
				break;
			case SKPaymentTransactionStatePurchasing:
				//NSLog(@"SKPaymentTransactionStatePurchasing, transactionIdentifier=%@", [transaction transactionIdentifier]);
				break;
				
			default:
				break;
		}
	};
}



#pragma mark - handle purchase. (related SKPaymentTransactionObserver methods.)
- (void)completeTransaction:(SKPaymentTransaction*)transaction
{
	LOG_CURRENT_METHOD;
	
	//Record Transaction.
	NSData* receipt = [transaction transactionReceipt];
	NSMutableDictionary* dict = [NSPropertyListSerialization propertyListWithData:receipt
																		  options:NSPropertyListMutableContainersAndLeaves 
																		   format:NULL
																			error:NULL];
	//NSLog(@"dict = %@", [dict description]);
	//NSLog(@"environment=%@", [dict valueForKey:@"environment"]);
	//NSLog(@"pod=%@", [dict valueForKey:@"pod"]);
	//NSLog(@"purchase-info=%@", [dict valueForKey:@"purchase-info"]);
	//NSLog(@"signature=%@", [dict valueForKey:@"signature"]);
	//NSLog(@"signing-status=%@", [dict valueForKey:@"signing-status"]);
	
	NSString* productID = transaction.payment.productIdentifier;
	
	//Enable contents.
	if (transaction.transactionState == SKPaymentTransactionStatePurchased)
	{
		//(Add Download(purchase) history.)
		[paymentHistoryDS enableContentWithProductId:productID WithDict:dict];
	}
	
	//Delete complete transaction in queue.
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	
	
	//Throw to parent.
	[parentVC purchaseDidSuccess:productID];
}
#pragma mark - Handling Restored Transactions
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	LOG_CURRENT_METHOD;
	[parentVC paymentQueue:queue restoreCompletedTransactionsFailedWithError:error];
}
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	LOG_CURRENT_METHOD;
	[parentVC paymentQueueRestoreCompletedTransactionsFinished:queue];
}
- (void)restoreTransaction:(SKPaymentTransaction*)transaction
{
	LOG_CURRENT_METHOD;
	
	//Add payment history.
	[parentVC restoreDidSuccess:transaction];
}




- (void)failedTransaction:(SKPaymentTransaction*)transaction {
	//Delete failed transaction in queue.
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	//
	[parentVC purchaseDidFailed:transaction.error];
}
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
	LOG_CURRENT_METHOD;
}

#pragma mark -
- (void)myRestoreCompletedTransactions
{
	LOG_CURRENT_METHOD;
	
	//Check enable payment.
	if (! [SKPaymentQueue canMakePayments]) {
		NSLog(@"cannot restore transaction.");
		
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
														 message:@"cannot restore transaction."
														delegate:nil
											   cancelButtonTitle:nil
											   otherButtonTitles:@"OK", nil]
							  autorelease];
		[alert show];
		return;
	}
	
	//Do restore with SKPaymentQueue.
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


@end
