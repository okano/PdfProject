//
//  PopoverScrollImageViewController.h
//  SakuttoBook
//
//  Created by okano on 11/03/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKBEngine_PopoverScrollImageViewController.h"

@interface PopoverScrollImageViewController : SKBEngine_PopoverScrollImageViewController <UIScrollViewDelegate> {
    
}
//with small zoomup.(min scale is not 1.0 but 0.75)
- (id)initWithImageFilename:(NSString*)filename frame:(CGRect)frame;	//(over-ride method.)
@end
