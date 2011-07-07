//
//  MyImageGenerator.h
//  SakuttoBook
//
//  Created by okano on 11/02/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#import "FileUtility.h"
#import "Define.h"
#import "InAppPurchaseDefine.h"

@interface ImageGenerator : NSObject {
	ContentId currentContentId;
}
@property (nonatomic) ContentId currentContentId;

//
- (NSString*)getPageFilenameFull:(int)pageNum;
//- (NSString*)getThumbnailFilenameFull:(int)pageNum;
//
- (void)generateImageWithPageNum:(NSUInteger)pageNum fromUrl:(NSURL*)pdfURL minWidth:(CGFloat)minWidth maxWidth:(CGFloat)maxWidth;



@end
