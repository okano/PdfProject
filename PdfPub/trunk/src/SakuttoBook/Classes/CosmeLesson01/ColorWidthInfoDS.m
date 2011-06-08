//
//  ColorWidthInfoDS.m
//  CosmeLesson01
//
//  Created by okano on 11/06/06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorWidthInfoDS.h"


@implementation ColorWidthInfoDS

- (id)init
{
    self = [super init];
    if (self) {
		[self setupColorWidthInfo];
    }
    return self;
}

- (void)setupColorWidthInfo
{
	colorWidthInfo = [[NSMutableArray alloc] init];
	NSMutableDictionary* tmpDict;
	
	//PK421, Kifujin.
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)(239.0/256.0)] forKey:MARKERPEN_COLOR_R];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)(123.0/256.0)] forKey:MARKERPEN_COLOR_G];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)(165.0/256.0)] forKey:MARKERPEN_COLOR_B];
	[tmpDict setValue:[NSNumber numberWithFloat:0.2f] forKey:MARKERPEN_COLOR_ALPHA];
	[tmpDict setValue:[NSNumber numberWithFloat:4.0f] forKey:MARKERPEN_WIDTH];
	[colorWidthInfo addObject:tmpDict];
	
	//BL603, midnight black.
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)(  0.0/256.0)] forKey:MARKERPEN_COLOR_R];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)( 16.0/256.0)] forKey:MARKERPEN_COLOR_G];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)(107.0/256.0)] forKey:MARKERPEN_COLOR_B];
	[tmpDict setValue:[NSNumber numberWithFloat:0.1f] forKey:MARKERPEN_COLOR_ALPHA];
	[tmpDict setValue:[NSNumber numberWithFloat:9.0f] forKey:MARKERPEN_WIDTH];
	[colorWidthInfo addObject:tmpDict];
	
	//Brawn.
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)(115.0/256.0)] forKey:MARKERPEN_COLOR_R];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)( 33.0/256.0)] forKey:MARKERPEN_COLOR_G];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)(  0.0/256.0)] forKey:MARKERPEN_COLOR_B];
	[tmpDict setValue:[NSNumber numberWithFloat:0.33f] forKey:MARKERPEN_COLOR_ALPHA];
	[tmpDict setValue:[NSNumber numberWithFloat:9.0f] forKey:MARKERPEN_WIDTH];
	[colorWidthInfo addObject:tmpDict];
	
	//GR522, green juely.
	tmpDict = [[NSMutableDictionary alloc] init];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)( 90.0/256.0)] forKey:MARKERPEN_COLOR_R];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)(156.0/256.0)] forKey:MARKERPEN_COLOR_G];
	[tmpDict setValue:[NSNumber numberWithFloat:(CGFloat)(  0.0/256.0)] forKey:MARKERPEN_COLOR_B];
	[tmpDict setValue:[NSNumber numberWithFloat:0.25f] forKey:MARKERPEN_COLOR_ALPHA];
	[tmpDict setValue:[NSNumber numberWithFloat:20.0f] forKey:MARKERPEN_WIDTH];
	[colorWidthInfo addObject:tmpDict];
}
- (NSDictionary*)getColorWidthInfoAtIndex:(NSInteger)index
{
	if ([colorWidthInfo count] < index) {
		LOG_CURRENT_METHOD;
		NSLog(@"illigal index:%d. max=%d", index, [colorWidthInfo count]);
		return nil;
	}
	return [colorWidthInfo objectAtIndex:index];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [colorWidthInfo count];	// 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSDictionary* tmpDict = [colorWidthInfo objectAtIndex:indexPath.row];
	UIColor* color = [UIColor colorWithRed:[[tmpDict valueForKey:MARKERPEN_COLOR_R] floatValue]
									 green:[[tmpDict valueForKey:MARKERPEN_COLOR_G] floatValue]
									  blue:[[tmpDict valueForKey:MARKERPEN_COLOR_B] floatValue]
									 alpha:[[tmpDict valueForKey:MARKERPEN_COLOR_ALPHA] floatValue]];
    CGRect rect = CGRectMake(0.0f, 0.0f, 16.0f, 16.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	cell.imageView.image = image;
	
	CGFloat lineWidth = [[tmpDict valueForKey:MARKERPEN_WIDTH] floatValue];
    cell.textLabel.text = [NSString stringWithFormat:@"width=%3.1f, alpha=%3.1f", lineWidth,
						   [[tmpDict valueForKey:MARKERPEN_COLOR_ALPHA] floatValue]];
	
    return cell;
}
- (NSUInteger)count
{
	return [colorWidthInfo count];
}

@end
