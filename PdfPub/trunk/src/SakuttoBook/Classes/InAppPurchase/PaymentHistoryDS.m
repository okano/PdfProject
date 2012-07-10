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
@synthesize productIdListPointer;

#pragma mark - initialize.
- (id)init
{
    self = [super init];
    if (self) {
		paymentHistory = [[NSMutableArray alloc] init];
		productIdListPointer = [[ProductIdList alloc] init];
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


#pragma mark -
- (BOOL)isEnabledContent:(ContentId)cid
{
	//Check if Free Content.
	NSString* pid = [productIdListPointer getProductIdentifier:cid];
	//LOG_CURRENT_METHOD;
	//NSLog(@"cid=%d, pid=%@", cid, pid);
	if ([productIdListPointer isFreeContent:pid] == TRUE)
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

- (void)buyContent:(NSString*)productId
{
	LOG_CURRENT_METHOD;
	NSLog(@"productId=%@", productId);
	//Check enable payment.
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
		return;
	}
	
	//Process Payment.
	SKPayment* payment = [SKPayment paymentWithProductIdentifier:productId];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)enableContent:(ContentId)cid
{
	//LOG_CURRENT_METHOD;
	NSString* pid = [productIdListPointer getProductIdentifier:cid];

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
	ContentId cid = [productIdListPointer getContentIdentifier:productId];
	if (cid == InvalidContentId) {
		NSLog(@"cid is InvalidContentId");
	}
	
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
	ContentId cid = [productIdListPointer getContentIdentifier:productId];
	[self recordHistoryOnceWithContentId:cid
							   ProductId:productId];
}

- (void)recordHistoryOnceWithContentId:(ContentId)contentId ProductId:(NSString*)productId
{
	[self recordHistoryOnceWithContentId:contentId
							   ProductId:productId
									date:[NSDate dateWithTimeIntervalSinceNow:0.0f]];
}

- (void)recordHistoryOnceWithContentId:(ContentId)contentId ProductId:(NSString*)productId date:(NSDate*)date
{
	if ([self isExistSameRecordWithContentId:contentId ProductId:productId date:date] == YES) {
		//Same record exists. do nothing.
		return;
	}
	
	NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:productId forKey:PURCHASE_PRODUCT_ID];
	[tmpDict setValue:[NSNumber numberWithInt:contentId] forKey:PURCHASE_CONTENT_ID];
	//[tmpDict setValue:[NSDate dateWithTimeIntervalSinceNow:0.0f] forKey:PURCHASE_DAYTIME];
	[tmpDict setValue:date forKey:PURCHASE_DAYTIME];
	[paymentHistory addObject:tmpDict];
	//
	[self savePaymentHistory];
}

- (BOOL)isExistSameRecordWithContentId:(ContentId)contentId ProductId:(NSString*)productId date:(NSDate*)date
{
	for (NSMutableDictionary *record in paymentHistory)
	{
		NSString* candidateProductId = [record objectForKey:PURCHASE_PRODUCT_ID];
		NSNumber* candidateContentIdNumber = [record objectForKey:PURCHASE_CONTENT_ID];
		ContentId candidateContentId = [candidateContentIdNumber intValue];
		NSDate* candidatePurchaseDate = [record objectForKey:PURCHASE_DAYTIME];
		NSString* candidatePurchaseDateStr = [self date2str:candidatePurchaseDate];
		NSLog(@"candidateProductId=%@, candidateContentId=%d, candidatePurchaseDate=%@(str=%@)", candidateProductId, candidateContentId, [candidatePurchaseDate description], candidatePurchaseDateStr);
		//NSLog(@"date class=%@, candidatePurchaseDate class=%@", [date class], [candidatePurchaseDate class]);
		
		//if (contentId == candidateContentId) { LOG_CURRENT_LINE; }
		//if ([productId compare:candidateProductId] == NSOrderedSame) { LOG_CURRENT_LINE; }
		//if ([date compare:candidatePurchaseDate] == NSOrderedSame) { LOG_CURRENT_LINE; }
		
		if (   (contentId == candidateContentId)
			&& ([productId compare:candidateProductId] == NSOrderedSame)
			&& ([date compare:candidatePurchaseDate] == NSOrderedSame))
		{
			//LOG_CURRENT_LINE;
			NSLog(@"same record exist in paymentHistory.");
			return YES;
		}
	}
	return NO;
}


//Utility method.
- (NSMutableDictionary*)transcation2StringDict:(SKPaymentTransaction*)transaction
{
	NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
	//transactionIdentifier
	[tmpDict setValue:transaction.transactionIdentifier forKey:PURCHASE_TRANSACTION_DESCRIPTION_TRANSACTION_IDENTIFIER];
	
	
	//transactionDate
	NSString* transactionDateStr = [self date2str:transaction.transactionDate];
	[tmpDict setValue:transactionDateStr forKey:PURCHASE_TRANSACTION_DESCRIPTION_TRANSACTION_DATE];
	
	
	//transactionState
	NSString* transactionStateStr;
	switch (transaction.transactionState) {
		case SKPaymentTransactionStatePurchasing:
			transactionStateStr = TRANSACTION_STATE_STRING_PURCHASING;
			break;
		case SKPaymentTransactionStatePurchased:
			transactionStateStr = TRANSACTION_STATE_STRING_PURCHASED;
			break;
		case SKPaymentTransactionStateFailed:
			transactionStateStr = TRANSACTION_STATE_STRING_FAILED;
			break;
		case SKPaymentTransactionStateRestored:
			transactionStateStr = TRANSACTION_STATE_STRING_RESTORED;
			break;
			
		default:
			break;
	}
	[tmpDict setValue:transactionStateStr forKey:PURCHASE_TRANSACTION_DESCRIPTION_TRANSACTION_STATE];
	
	
	//originalTransaction
	//The contents of this property are undefined EXCEPT when transactionState is set to SKPaymentTransactionStateRestored.
	NSString* originalTransactionIdentifier;
	if (transaction.transactionState == SKPaymentTransactionStateRestored) {
		originalTransactionIdentifier = transaction.originalTransaction.transactionIdentifier;
	} else {
		originalTransactionIdentifier = @"";
	}
	[tmpDict setValue:originalTransactionIdentifier forKey:PURCHASE_TRANSACTION_DESCRIPTION_ORIGINAL_TRANSACTION_IDENTIFIER];
	
	
	return tmpDict;
}

- (NSString*)date2str:(NSDate*)targetDate
{
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	NSLocale* loc = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];					//Locale.
    [formatter setLocale:loc];
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier: NSJapaneseCalendar];	//Calender.
	[formatter setCalendar: cal];
	[formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss z"];	//[formatter setDateFormat:@"(GGyy年)YYYY-MM-dd(EEEE) HH:mm:ss"];
	NSString* date_converted = [formatter stringFromDate:targetDate];
	[loc release];
	[formatter release];
	
	return date_converted;
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
