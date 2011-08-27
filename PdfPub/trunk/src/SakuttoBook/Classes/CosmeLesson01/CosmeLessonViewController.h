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
	bool isShownImagePicker;
	//pan for MarkerPen.
	UIPanGestureRecognizer* panRecognizer1;
	UIPanGestureRecognizer* panRecognizer2;
    CGPoint prevOffset;
	//menuBar.
    UIToolbar* menuBarForMakerPen;
	
	//Color and Width selector.
	UIView* colorSelectorView;
	UIToolbar* colorSelectorToolbar;
	ColorSelectorTableViewController* colorSelectorTVC;
	ColorWidthInfoDS* colorWidthInfoDS;
	
	//Image Picker.
	UIPopoverController* popoverController;
	
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
	
	//Zoom level.
	int zoomLevel;
}
@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) ColorWidthInfoDS* colorWidthInfoDS;

- (void)setupThisView;
- (void)setupThisViewWithImage:(UIImage*)image;
- (UIImage*)loadDefaultImage;
- (void)setupImage:(UIImage*)newImage;
- (void)addScalableSubview:(UIView *)view withNormalizedFrame:(CGRect)normalizedFrame;
- (void)cleanupSubviews;
- (IBAction)hideCosmeLessonView;
- (IBAction)switchToContentPlayerView;
- (IBAction)showImageSelector;
- (void)switchToCosmeLessonView;	//switch this view with new image.

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
- (void)handlePan2:(UIPanGestureRecognizer*)gestureRecognizer;
//Menubar.
- (void)showMenuBarForMarker;
- (void)hideMenuBarForMarker;
//Color and Width.
- (IBAction)showColorAndSizeSelector;
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
- (IBAction)prepareDeleteMarkerPenWithCurrentPage;
- (void)deleteMarkerPenAtPage:(NSUInteger)pageNum;
- (void)clearMarkerPenView;
//Delete single line.
- (IBAction)deleteLastLine:(id)sender;
//Change zoom level.
- (IBAction)changeZoomLevel;
@end

//
//imagePicker
@interface CosmeLessonViewController (ImagePicker) <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
- (void)openImagePickerFromBarButtonItem:(UIBarButtonItem*)button;
@end