//
//  TouchPenView.m
//  SimpleTouchPen02
//
//  Created by okano on 11/03/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchPenView.h"


@implementation TouchPenView
@synthesize lineToDraw;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self setupView];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
		[self setupView];
    }
    return self;
}

- (void)setupView
{
    lineToDraw = [[NSMutableArray alloc] init];
    self.opaque =  FALSE;
	/*
	//Setup background for white-panrental.
    self.backgroundColor = [[UIColor alloc] initWithRed: 1.0f
                                                  green: 1.0f
                                                   blue: 1.0f
                                                  alpha: 0.3f];
	*/
}

/*
- (void)addLineInfoFrom:(CGPoint)p0 to:(CGPoint)p1
{
    //NSLog(@"p0=%@, p1=%@", NSStringFromCGPoint(p0), NSStringFromCGPoint(p1));
    NSDictionary* tmpDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:p0.x], MARKERPEN_LINE_POSITION_X0,
                             [NSNumber numberWithFloat:p0.y], MARKERPEN_LINE_POSITION_Y0,
                             [NSNumber numberWithFloat:p1.x], MARKERPEN_LINE_POSITION_X1,
                             [NSNumber numberWithFloat:p1.y], MARKERPEN_LINE_POSITION_Y1,
                             nil];
    //NSLog(@"count of lineToDraw=%d", [lineToDraw count]);
    [lineToDraw addObject:tmpDict];
    //NSLog(@"count of lineToDraw=%d", [lineToDraw count]);
}

- (void)addLineInfoWithArray:(NSArray*)lineInfoArray
{
    for (int i = 0; i < [lineInfoArray count] - 1; i = i + 1) {
        [self addLineInfoFrom:[[lineInfoArray objectAtIndex:i] CGPointValue]
                           to:[[lineInfoArray objectAtIndex:i+1] CGPointValue]];
    }
}
*/

- (void)addLinesWithDictionary:(NSDictionary*)dict
{
	//LOG_CURRENT_METHOD;
	if (! lineToDraw) {
		NSLog(@"add data to lineToDraw before initialize!");
		lineToDraw = [[NSMutableArray alloc] init];
	}
	[lineToDraw addObject:dict];
}

#pragma mark -
- (void)willStartAddLine
{
	LOG_CURRENT_METHOD;
	NSMutableDictionary* lineDict = [[NSMutableDictionary alloc] init];
	[lineDict setValue:[NSNumber numberWithInt:0] forKey:MARKERPEN_PAGE_NUMBER];
	[lineDict setValue:@"" forKey:MARKERPEN_COMMENT];
	[lineDict setValue:[[NSMutableArray alloc] init] forKey:MARKERPEN_POINT_ARRAY];
	[lineToDraw addObject:lineDict];
	
	NSLog(@"%d lines in %@", [lineToDraw count], [self class]);
	//NSLog(@"lineToDraw=%@", [lineToDraw description]);
}

- (void)addLineWithPoint:(CGPoint)p
{
	//LOG_CURRENT_METHOD;
	
	if ([lineToDraw count] <= 0) {
		return;
	}
	
	NSMutableDictionary* lineDict = [lineToDraw lastObject];
	//NSLog(@"lineDict=%@", [lineDict description]);
	
	NSMutableArray* lineArray = [lineDict objectForKey:MARKERPEN_POINT_ARRAY];
	if (! lineArray){
		NSLog(@"lineArray is nil");
	}
	
	[lineArray addObject:NSStringFromCGPoint(p)];
	//NSLog(@"%d lines in %@", [lineToDraw count], [self class]);
}

- (void)didEndAddLine
{
	LOG_CURRENT_METHOD;
	//do nothing.
	NSLog(@"lineToDraw count=%d", [lineToDraw count]);
}


- (void)clearLine
{
	LOG_CURRENT_METHOD;
	if (! lineToDraw) {
		NSLog(@"clear data to lineToDraw before initialize!");
		lineToDraw = [[NSMutableArray alloc] init];
	}

    [lineToDraw removeAllObjects];
}

#pragma mark -
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	//LOG_CURRENT_METHOD;
    if (! lineToDraw) {
        lineToDraw = [[NSMutableArray alloc] init];
    }
    
    // Drawing code
    NSLog(@"count of lineToDraw=%d", [lineToDraw count]);
	//NSLog(@"lineToDraw=%@", [lineToDraw description]);
    for (NSDictionary* lineInfo in lineToDraw) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (! context) {
            NSLog(@"cannot get context.");
            return;
        }
        
        //Set line color.
        CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 1.0f, 1.0f);
		
		//NSLog(@"pageNum=%d", [[lineInfo objectForKey:MARKERPEN_PAGE_NUMBER] intValue]);
		NSArray* pointArrayTmp = [lineInfo objectForKey:MARKERPEN_POINT_ARRAY];
		if ([lineInfo count] <= 0) {
			return;
		}
		
		CGPoint p0 = CGPointFromString([pointArrayTmp objectAtIndex:0]);
		NSLog(@"start point = %@", NSStringFromCGPoint(p0));
		for (NSString* p1str in pointArrayTmp) {
			//Draw line.
			CGPoint p1 = CGPointFromString(p1str);
			CGContextMoveToPoint(context, p0.x, p0.y);
			CGContextAddLineToPoint(context, p1.x, p1.y);
			CGContextStrokePath(context);
			//NSLog(@"LINE: p0=%@, p1=%@", NSStringFromCGPoint(p0), NSStringFromCGPoint(p1));
			
			//step next point.
			p0 = p1;
			
        /*
        NSLog(@"line = (%f, %f) - (%f, %f)",[[lineInfo objectForKey:MARKERPEN_LINE_POSITION_X0] floatValue], [[lineInfo objectForKey:MARKERPEN_LINE_POSITION_Y0] floatValue],
              [[lineInfo objectForKey:MARKERPEN_LINE_POSITION_X1] floatValue], [[lineInfo objectForKey:MARKERPEN_LINE_POSITION_Y1] floatValue]);
        */
			/*
        CGContextMoveToPoint(context, [[lineInfo objectForKey:MARKERPEN_LINE_POSITION_X0] floatValue], [[lineInfo objectForKey:MARKERPEN_LINE_POSITION_Y0] floatValue]);
        CGContextAddLineToPoint(context, [[lineInfo objectForKey:MARKERPEN_LINE_POSITION_X1] floatValue], [[lineInfo objectForKey:MARKERPEN_LINE_POSITION_Y1] floatValue]);
        CGContextStrokePath(context);
			 */
		}
    }
    
    //[lineToDraw removeAllObjects];
}


- (void)dealloc
{
    [super dealloc];
}

@end
