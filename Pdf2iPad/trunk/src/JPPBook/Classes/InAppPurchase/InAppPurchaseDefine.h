//
//  Define.h
//  PurchaseTest04
//
//  Created by okano on 11/05/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#define CONTENT_CID					@"ContentId"
#define CONTENT_STORE_PRODUCT_ID	@"StoreProductId"
#define CONTENT_TITLE				@"Title"
#define CONTENT_AUTHOR				@"Autohr"
#define CONTENT_DESCRIPTION			@"Description"
#define CONTENT_ICONFILE_PREFIX		@"ContentIcon_"
#define CONTENT_ICONFILE_EXTENSION	@"png"
#define CONTENT_ACQUISITION_LINK	@"AcquisitionLink"

#define HISTORY_CID					@"ContentId"
#define HISTORY_PAYMENT_DAYTIME		@"PaymentDaytime"
#define HISTORY_RECEPT_ID			@"ReceptId"

//typedef	NSString*	ContentId;
typedef	NSUInteger	ContentId;	/* 1-start. */
#define InvalidContentId			(-1)
#define UndefinedContentId			(-2)
#define InvalidProductId			@"InvalidProductId"

#define PAYMENT_STATUS_PAYED			(NSUInteger)1
#define PAYMENT_STATUS_NOT_PAYED		(NSUInteger)2

#define PRODUCT_KIND_FREE			0
#define PRODUCT_KIND_CONSUMABLE		1
#define PRODUCT_KIND_NON_CONSUMABLE	2



#ifdef TARGET_IPHONE_SIMULATOR
#  define LOG_CURRENT_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#  define LOG_CURRENT_LINE NSLog(@"%s line %d", __FILE__, __LINE__);
#  define LOG_RECT(rect) NSLog(@"%@=(x,y),(width,height)", NSStringFromCGRect(rect));
#else
#  define LOG_CURRENT_METHOD ;
#  define LOG_CURRENT_LINE ;
#  define LOG_RECT ;
#endif
