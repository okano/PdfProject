//
//  CosmeLessonView.h
//  CosmeLesson01
//
//  Created by okano on 11/06/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#import "MarkerPenView.h"
#import "ColorSelectorTableViewController.h"
#import "colorWidthInfoDS.h"

@interface CosmeLessonViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIToolbar* toolbar;
	IBOutlet UIScrollView* scrollView;
	IBOutlet UIImageView* imageView;
	UIImage* image;
	
	// MarkerPen.
	MarkerPenView* markerPenView;
    NSMutableArray* markerPenArray;
	NSMutableArray* pointsForSingleLine;
	CGFloat currentLineColor_R;
	CGFloat currentLineColor_G;
	CGFloat currentLineColor_B;
	CGFloat currentLineColor_Alpha;
	CGFloat currentLineWidth;
	
	bool isMarkerPenMode;
	//pan for MarkerPen.
	UIPanGestureRecognizer* panRecognizer1;
    CGPoint prevTouchPointForMakerPen;
	//menuBar.
    UIToolbar* menuBarForMakerPen;
	
	//Color and Width selector.
	UIView* colorSelectorView;
	UIToolbar* colorSelectorToolbar;
	ColorSelectorTableViewController* colorSelectorTVC;
	ColorWidthInfoDS* colorWidthInfoDS;
	
	// Page number at current showing. (for save/load marker info to UserDefault)
    int             currentPageNum;
	
	//Size.
	CGSize originalPageSize;
	CGFloat originalPageWidth;
	CGFloat originalPageHeight;
	//Aspect.
	CGFloat scaleWithAspectFitWidth;
	CGFloat scaleWithAspectFitHeight;
	CGFloat scaleForDraw;

}
@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) ColorWidthInfoDS* colorWidthInfoDS;

- (void)setupThisView;
- (void)loadDefaultImage;
- (void)addScalableSubview:(UIView *)view withNormalizedFrame:(CGRect)normalizedFrame;
- (IBAction)hideCosmeLessonView;
- (IBAction)switchToContentPlayerView;

@end

//
//Marker Pen
//
@protocol ColorSelectorTableDelegate <NSObject>
- (void)hideColorAndSizeSelector;
@end
@interface CosmeLessonViewController (MarkerPen) <UIActionSheetDelegate, ColorSelectorTableDelegate>
//Maker mode.
- (IBAction)enterMarkerMode;
- (void)setupMarkerPenView:(CGRect)frame;
- (void)setupMarkerPenMenu;
- (IBAction)exitMarkerMode;
//Handle pan.
- (void)handlePan:(UIPanGestureRecognizer*)gestureRecognizer;
//Menubar.
- (void)showMenuBarForMarker;
- (void)hideMenuBarForMarker;
//Color and Width.
- (void)showColorAndSizeSelector;
//- (void)setLineColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (void)setLineColorAndWidthWithIndex:(NSInteger)index;
- (void)setLineColor:(NSDictionary*)colorDict;
- (void)setLineWidth:(CGFloat)width;
//Save/Load.
- (void)saveMarkerPenToUserDefault;
- (void)loadMarkerPenFromUserDefault;
//Rendering.
- (void)renderMarkerPenFromUserDefaultAtPage:(NSUInteger)pageNum;
//Delete.
- (void)prepareDeleteMarkerPenWithCurrentPage;
- (void)deleteMarkerPenAtPage:(NSUInteger)pageNum;
- (void)clearMarkerPenView;
//Delete single line.
- (IBAction)deleteLastLine:(id)sender;
@end

