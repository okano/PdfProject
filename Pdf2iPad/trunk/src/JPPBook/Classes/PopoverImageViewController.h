//
//  PopoverImageViewController.h
//  Pdf2iPad
//
//  Created by okano on 11/02/07.
//  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKBEngine_PopoverScrollImageViewController.h"
#import "ContentFileUtility.h"

@interface PopoverImageViewController : SKBEngine_PopoverScrollImageViewController <UIScrollViewDelegate> {

}
- (id)initWithImageFilename:(NSString*)filename frame:(CGRect)frame withContentIdStr:(NSString*)cidStr;

@end
