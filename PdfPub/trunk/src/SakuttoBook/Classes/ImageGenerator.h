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

@interface ImageGenerator : NSObject {
}

//
- (NSString*)getPageFilenameFull:(int)pageNum;
//- (NSString*)getThumbnailFilenameFull:(int)pageNum;
//
- (void)generateImageWithPageNum:(NSUInteger)pageNum fromUrl:(NSURL*)pdfURL minWidth:(CGFloat)minWidth;



@end
