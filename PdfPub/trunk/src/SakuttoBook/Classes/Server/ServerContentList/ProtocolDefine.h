//
//  ProtocolDefine.h
//  JPPBook
//
//  Created by okano on 11/08/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <StoreKit/StoreKit.h>
@protocol MyTableViewVCProtocol
- (void)reloadData;
//
- (void)didFinishParseOpdsRoot:(NSURL*)elementUrl;
- (void)didFailParseOpdsRoot;
- (void)didFinishParseOpdsElement:(NSMutableArray*)resultArray;
- (void)didFailParseOpdsElement;
@optional
- (void)didStartParseOpdsRoot;
- (void)didStartParseOpdsElement;
@end
/*
@protocol ContentListProtocol
- (void)didFinishParseOpds:(NSMutableArray*)resultArray;
@end

@protocol OpdsParserProtocol
- (void)didFinishParseOpdsRoot:(NSMutableArray*)resultArray;
- (void)didFailParseOpdsRoot:(NSMutableArray*)resultArray;
- (void)didFinishParseOpdsElement:(NSMutableArray*)resultArray;
- (void)didFailParseOpdsElement:(NSMutableArray*)resultArray;
@end
*/

@protocol VCWithInAppPurchaseProtocol
- (void)productRequestDidSuccess:(SKProduct*)product;
- (void)productRequestDidFailed:(NSString*)invalidProductIdentifier;
- (void)purchaseDidSuccess:(NSString*)productId;
- (void)purchaseDidFailed:(NSError*)error;
//Restore Transaction.
@optional
- (void)restoreTransaction;
- (void)restoreDidSuccess:(SKPaymentTransaction*)transaction;
- (void)restoreDidFailed:(SKPaymentTransaction*)transaction;
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue;
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error;
@end