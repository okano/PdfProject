//
//  TouchPenView.h
//  SimpleTouchPen02
//
//  Created by okano on 11/03/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import "DefineCosmeLesson.h"
#import "Utility.h"

@interface MarkerPenView : UIView {
    NSMutableArray* lineToDraw;
}
@property (nonatomic, retain) NSMutableArray* lineToDraw;

- (void)setupView;
//- (void)addLineInfoFrom:(CGPoint)p0 to:(CGPoint)p1;
//- (void)addLineInfoWithArray:(NSArray*)lineInfoArray;
- (void)clearLine;
- (void)deleteLastLine;


- (void)willStartAddLineWithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue Alpha:(CGFloat)alpha Size:(CGFloat)width;
- (void)addLinesWithDictionary:(NSDictionary*)dict;
- (void)addLineWithPoint:(CGPoint)p0;
- (void)didEndAddLine;

@end

