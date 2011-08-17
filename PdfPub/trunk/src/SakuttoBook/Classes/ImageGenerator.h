//
//  MyImageGenerator.h
//  SakuttoBook
//
//  Created by okano on 11/02/21.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#import "Define.h"
#import "InAppPurchaseDefine.h"

#import "FileUtility.h"

@interface ImageGenerator : NSObject {
	ContentId currentContentId;
}
@property (nonatomic) ContentId currentContentId;

//
//- (NSString*)getPageFilenameFull:(int)pageNum;
//- (NSString*)getPageFilenameFull:(int)pageNum WithContentId:(ContentId)cid;
////- (NSString*)getThumbnailFilenameFull:(int)pageNum;
//
- (void)generateImageWithPageNum:(NSUInteger)pageNum fromUrl:(NSURL*)pdfURL minWidth:(CGFloat)minWidth maxWidth:(CGFloat)maxWidth;



@end
