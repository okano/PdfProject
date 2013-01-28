//
//  ContentListDS.h
//  PurchaseTest04
//
//  Created by okano on 11/05/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "InAppPurchaseDefine.h"
#import "ProductIdList.h"
#import "FileUtility.h"

@interface ContentListDS : NSObject {
    NSMutableArray* contentList;
	//ProductIdList* productIdListPointer;
	NSMutableDictionary* contentIdDictWithGenre;
	/* no save/load. generate on memory only. */
	/* generate from contentList (one-way. no write-back) */
	/**
	 *
	 * ["genreA"]
	 *   =>["subGenreA-1"]
	 *     =>(NSMutableArray*)1,2,5
	 *   =>["subGenreA-2"]
	 *     =>(NSMutableArray*)3,4,7,3   <-'3' appears twice but no care.
	 *   =>["subGenreA-3"]
	 *     =>(NSMutableArray*)10,11,12
	 * ["genreB"]
	 *   =>["subGenreB-1"]
	 *     =>(NSMutableArray*)21,22,25
	 * ["genreC"]
	 *   =>["subGenreC-1"]
	 *     =>(NSMutableArray*)21,22,25
	 *   =>["subGenreC-2"]
	 *     =>(NSMutableArray*)23,24,27
	 *   =>["subGenreC-3"]
	 *     =>(NSMutableArray*)30,31,32
	 *   =>["subGenreC-4"]
	 *     =>(NSMutableArray*)23,24,27
	 *   =>["NonSubGenre"]
	 *     =>(NSMutableArray*)50,51,52,53,54,55,56
	 * ["NonGenre"]
	 *   =>["NonSubGenre"]
	 *     =>(NSMutableArray*)80,81,82,83,84,85
	 *
	 */
}

@property (nonatomic, retain) NSMutableArray* contentList;
//@property (nonatomic, retain) ProductIdList* productIdListPointer;
@property (nonatomic, retain) NSMutableDictionary* contentIdDictWithGenre;

//Get Count of array.
- (uint)count;
- (uint)countWithGenre:(NSString*)genre;
- (uint)countWithGenre:(NSString*)genre subGenre:(NSString*)subGenre;

//Get Genre.
- (NSArray*)allGenre;
- (NSArray*)allSubGenreWithGenre:(NSString*)genre;

//Get ID.
- (ContentId)contentIdAtIndex:(NSInteger)index;
- (NSDictionary*)contentIdsWithGenre:(NSString*)genre;
- (NSArray*)contentIdsWithGenre:(NSString*)genre subGenre:(NSString*)subGenre;
- (ContentId)contentIdWithGenre:(NSString*)genre subGenre:(NSString*)subGenre index:(NSInteger)index;
- (ContentId)contentIdFromProductId:(NSString*)productId;
- (ContentId)contentIdFromUuid:(NSString*)uuid;
//- (NSString*)productIdFromContentId:(ContentId)cid;
- (NSString*)uuidAtIndex:(NSInteger)index;
- (NSString*)uuidFromContentId:(ContentId)cid;

- (void)setupData;
- (int)loadFromPlist;
- (int)setupDefaultData;
- (void)mergeProductIdIntoContentList;
//
- (void)saveToPlist;
- (NSString*)getPlistFilenameFull;
//Misc.
- (NSString*)description;
- (void)removeAllObjects;
- (void)removeMetadataWithContentId:(ContentId)cid;
- (void)removeMetadataWithUuid:(NSString*)uuid;

//Metadata each content.
- (NSMutableDictionary*)getMetadataByContentId:(ContentId)cid;
- (NSMutableDictionary*)getMetadataByUuid:(NSString*)uuid;
//Add.
- (void)addMetadata:(NSDictionary*)metaDataDict;
- (void)addContentIdArray:(ContentId)cid genre:(NSString*)genre subGenre:(NSString*)subGenre;
//Replace.
- (void)replaceMetadataAtIndex:(NSInteger)index withMetadata:(NSDictionary*)metaDataDict;

//ContentId for download.
- (ContentId)nextContentId;
- (void)stepupContentIdToUserDefault:(ContentId)lastAssignedContentId;

- (NSString*)titleAtIndex:(NSInteger)index;
- (NSString*)titleByContentId:(ContentId)cid;
- (NSString*)titleByUuid:(NSString*)uuid;
- (NSString*)authorAtIndex:(NSInteger)index;
- (NSString*)authorByContentId:(ContentId)cid;
- (NSString*)authorByUuid:(NSString*)uuid;
- (NSString*)descriptionAtIndex:(NSInteger)index;
- (NSString*)descriptionByContentId:(ContentId)cid;
- (NSString*)descriptionByUuid:(NSString*)uuid;
//
- (UIImage*)contentIconAtIndex:(NSInteger)index;
- (UIImage*)contentIconByContentId:(ContentId)cid;
- (UIImage*)contentIconByUuid:(NSString*)uuid;
- (UIImage*)contentIconDummyWithIndex:(NSInteger)index;
- (NSString*)getCoverLocalFilenameFull:(ContentId)cid;

//
- (NSURL*)acquisitionUrlAtIndex:(NSInteger)index;
- (NSURL*)acquisitionUrlByContentId:(ContentId)cid;
- (NSURL*)acquisitionUrlByUuid:(NSString*)uuid;
- (NSURL*)thumbnailUrlAtIndex:(NSInteger)index;
- (NSURL*)thumbnailUrlByContentId:(ContentId)cid;
- (NSURL*)thumbnailUrlByUuid:(NSString*)uuid;
- (NSURL*)coverUrlAtIndex:(NSInteger)index;
- (NSURL*)coverUrlByContentId:(ContentId)cid;
- (NSURL*)coverUrlByUuid:(NSString*)uuid;

#pragma mark - TestData.
- (void)setupTestData;

@end
