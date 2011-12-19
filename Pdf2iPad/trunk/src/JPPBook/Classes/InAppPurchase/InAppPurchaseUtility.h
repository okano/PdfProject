//
//  InAppPurchaseUtility.h
//  SakuttoBook
//
//  Created by okano on 11/06/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "Utility.h"
#import "InAppPurchaseDefine.h"
#import "FileUtility.h"
#import "UrlDefine.h"

@interface InAppPurchaseUtility : NSObject {
    NSMutableArray* productIdList;
}
//ProductIdList.
- (void)loadProductIdList;
- (void)saveProductIdList;
- (void)refreshProductIdListFromNetwork;
- (void)loadProductIdListFromMainBundle;	//for first launch.
- (NSString*)getProductIdListUrl;


//Get id from file.
+ (NSString*)getProductIdentifier:(ContentId)cid;
+ (ContentId)getContentIdentifier:(NSString*)pid;
+ (NSArray*)getAllProductIdentifier;
//Convert productId with/without Full.
+ (NSString*)productIdWithFullQualifier:(NSString*)sinpleProductId;
+ (NSString*)productIdWithoutFullQualifier:(NSString*)fullProductId;
//Judge free comtent.
+ (BOOL)isFreeContent:(NSString*)productId;
//+ (NSString*)getBookDefineFilename:(ContentId)cid;

//Misc.
- (NSUInteger)count;
- (NSString*)description;
- (NSString*)descriptionAtIndex:(NSUInteger)index;
@end


#define PRODUCT_ID_LIST_FILENAME	@"productIdList.csv"

#define PRODUCT_ID_LIST_ARRAY	@"Product_Id_List_Array"
//#define PURCHASE_CONTENT_ID		@"Purchase_ContentId"
//#define PURCHASE_DAYTIME		@"Purchase_DayTime"	/* time when call method. */
//#define PURCHASE_PRODUCT_ID		@"Purchase_ProductId"
