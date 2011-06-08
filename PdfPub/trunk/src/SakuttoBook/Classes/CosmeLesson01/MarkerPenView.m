//
//  TouchPenView.m
//  SimpleTouchPen02
//
//  Created by okano on 11/03/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MarkerPenView.h"


@implementation MarkerPenView
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

- (void)willStartAddLineWithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue Alpha:(CGFloat)alpha Size:(CGFloat)width
{
	//LOG_CURRENT_METHOD;
	NSMutableDictionary* lineDict = [[NSMutableDictionary alloc] init];
	[lineDict setValue:[NSNumber numberWithInt:0] forKey:MARKERPEN_PAGE_NUMBER];
	[lineDict setValue:@"" forKey:MARKERPEN_COMMENT];
	//points
	[lineDict setValue:[[NSMutableArray alloc] init] forKey:MARKERPEN_POINT_ARRAY];
	//color
	[lineDict setValue:[NSNumber numberWithFloat:red]	forKey:MARKERPEN_COLOR_R];
	[lineDict setValue:[NSNumber numberWithFloat:green]	forKey:MARKERPEN_COLOR_G];
	[lineDict setValue:[NSNumber numberWithFloat:blue]	forKey:MARKERPEN_COLOR_B];
	[lineDict setValue:[NSNumber numberWithFloat:alpha]	forKey:MARKERPEN_COLOR_ALPHA];
	//width(size)
	[lineDict setValue:[NSNumber numberWithFloat:width]	forKey:MARKERPEN_WIDTH];
	
	[lineToDraw addObject:lineDict];
	
	//NSLog(@"%d lines in %@", [lineToDraw count], [self class]);
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
	//LOG_CURRENT_METHOD;
	//do nothing.
	//NSLog(@"lineToDraw count=%d", [lineToDraw count]);
}


- (void)clearLine
{
	//LOG_CURRENT_METHOD;
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
    //NSLog(@"count of lineToDraw=%d", [lineToDraw count]);
	//NSLog(@"lineToDraw=%@", [lineToDraw description]);
    for (NSDictionary* lineInfo in lineToDraw) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (! context) {
            NSLog(@"cannot get context.");
            return;
        }
        
        //Set line color and width.
		CGFloat lineColor_R, lineColor_G, lineColor_B, lineColor_Alpha;
		CGFloat lineWidth;
		if ([lineInfo objectForKey:MARKERPEN_COLOR_R]) {
			lineColor_R = [[lineInfo objectForKey:MARKERPEN_COLOR_R] floatValue];
		} else {
			lineColor_R = MARKERPEN_DEFAULT_LINE_COLOR_R;
		}
		if ([lineInfo objectForKey:MARKERPEN_COLOR_G]) {
			lineColor_G = [[lineInfo objectForKey:MARKERPEN_COLOR_G] floatValue];
		} else {
			lineColor_G = MARKERPEN_DEFAULT_LINE_COLOR_G;
		}
		if ([lineInfo objectForKey:MARKERPEN_COLOR_B]) {
			lineColor_B = [[lineInfo objectForKey:MARKERPEN_COLOR_B] floatValue];
		} else {
			lineColor_B = MARKERPEN_DEFAULT_LINE_COLOR_B;
		}
		if ([lineInfo objectForKey:MARKERPEN_COLOR_ALPHA]) {
			lineColor_Alpha = [[lineInfo objectForKey:MARKERPEN_COLOR_ALPHA] floatValue];
		} else {
			lineColor_Alpha = MARKERPEN_DEFAULT_LINE_COLOR_ALPHA;
		}
		if ([lineInfo objectForKey:MARKERPEN_WIDTH]) {
			lineWidth = [[lineInfo objectForKey:MARKERPEN_WIDTH] floatValue];
		} else {
			lineWidth = MARKERPEN_DEFAULT_LINE_WIDTH;
		}
        CGContextSetRGBStrokeColor(context, lineColor_R, lineColor_G, lineColor_B, lineColor_Alpha);
		CGContextSetLineWidth(context, lineWidth);

		//NSLog(@"pageNum=%d", [[lineInfo objectForKey:MARKERPEN_PAGE_NUMBER] intValue]);
		NSArray* pointArrayTmp = [lineInfo objectForKey:MARKERPEN_POINT_ARRAY];
		if ([lineInfo count] <= 0) {
			return;
		}
		
		CGPoint p0 = CGPointFromString([pointArrayTmp objectAtIndex:0]);
		//NSLog(@"start point = %@", NSStringFromCGPoint(p0));
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
