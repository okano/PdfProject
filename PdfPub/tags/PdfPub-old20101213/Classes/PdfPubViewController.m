//
//  PdfPubViewController.m
//  PdfPub
//
//  Created by okano on 10/11/18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PdfPubViewController.h"

@implementation PdfPubViewController

static int  _maxPage = 29;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//
	[self setDefaultPdfFile];
	//
	navigationBar.hidden = YES;
	navigationBar.topItem.title = NAVIGATION_BAR_TITLE;
	
	//
	//PdfPubAppDelegate* appDelegate = (PdfPubAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	// 左側のimage viewを作成
    _leftImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_rootScrollView addSubview:_leftImageView];
    
    // 中央のscroll viewを作成
    _centerScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _centerScrollView.minimumZoomScale = 0.5f;
    _centerScrollView.maximumZoomScale = 2.0f;
    _centerScrollView.delegate = self;
    [_rootScrollView addSubview:_centerScrollView];
    
    // 右側のimage viewを作成
    _rightImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_rootScrollView addSubview:_rightImageView];
    
    // ページインデックスの初期値として-1を設定
    _index = -1;
    
    // ページ
    [self _renewPageIndex];
}




//--------------------------------------------------------------//
#pragma mark -- Appearance --
//--------------------------------------------------------------//

- (void)_renewPageIndex
{
    // 現在のページインデックスを保存
    int oldIndex = _index;
    
    // コンテントオフセットを取得
    CGPoint offset;
    offset = _rootScrollView.contentOffset;
    if (offset.x == 0) {
        // 前のページへ移動
        _index--;
		NSLog(@"goto previous page.");
    }
    if (offset.x >= _rootScrollView.contentSize.width - CGRectGetWidth(_rootScrollView.frame)) {
        // 次のページへ移動
        _index++;
		NSLog(@"goto next page.");
    }
    
    // ページインデックスの値をチェック
    if (_index < 0) {
        _index = 0;
    }
    if (_index >= _maxPage) {
        _index = _maxPage - 1;
    }
    
    if (_index == oldIndex) {
        return;
    }
	[self drawPageWithCurrentIndex];
}
- (void)drawPageWithCurrentIndex
{
	CGRect      rect;
    //NSString*   fileName;
    //NSString*   path;
    UIImage*    image;
	
	PdfPubAppDelegate* appDelegate = (PdfPubAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.currentPageNum = _index;
    
	
    //
    // 左側のimage viewを更新
    //
    
    // 最初のページのとき
    if (_index == 0) {
        // 左側のimage viewは表示しない
        rect = CGRectZero;
        
        image = nil;
    }
    // 最初のページ以外のとき
    else {
        // 左側のimage viewのframe
        rect.origin.x = 0;
        rect.origin.y = 0;
        rect.size.width = IPHONE_SCREEN_WIDTH;		//ipad = 768.0f;
        rect.size.height = IPHONE_SCREEN_HEIGHT - 24.0f;	//ipad =1024.0f;
        
        // 左側のimage viewの画像の読み込み
		/*
        fileName = [NSString stringWithFormat:@"%03ds", _index - 1];
        path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
        image = [[UIImage alloc] initWithContentsOfFile:path];
		*/
		image = [self getPdfPageImageWithPageNum:_index-1];
    }
    
    // 左側のimage viewの設定
    _leftImageView.frame = rect;
    _leftImageView.image = image;
    [image release];
    
    //
    // 中央のscroll view、image viewを更新
    //
	
	//PDF用のビューを生成(拡大縮小用)
	[_centerPdfView removeFromSuperview];
	[_centerPdfView release], _centerPdfView = nil;
	// Create the TiledPDFView based on the size of the PDF page and scale it to fit the view.
	_centerPdfView = [[TiledPDFView alloc] initWithFrame:pageRect andScale:pdfScale];
	image = [self getPdfPageImageWithPageNum:_index];
	[_centerPdfView setPage:page];
	[_centerScrollView addSubview:_centerPdfView];
    
#if 0==1
    // 中央のimage viewの画像の読み込み
    fileName = [NSString stringWithFormat:@"%03d", _index];
    path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
    image = [[UIImage alloc] initWithContentsOfFile:path];
    
    // 中央のimage viewの再作成
    [_centerImageView removeFromSuperview];
    [_centerImageView release], _centerImageView = nil;
    _centerImageView = [[UIImageView alloc] initWithImage:image];	
    [_centerScrollView addSubview:_centerImageView];
#endif    
    
    // 中央のscroll viewのframe
    rect.origin.x = CGRectGetMaxX(_leftImageView.frame) > 0 ?
	CGRectGetMaxX(_leftImageView.frame) /* + 24.0f */ : 0;
    rect.origin.y = 0;
	rect.size.width = IPHONE_SCREEN_WIDTH;		//ipad = 768.0f;
	rect.size.height = IPHONE_SCREEN_HEIGHT - 24.0f;	//ipad =1024.0f;
    
    // 中央のscroll viewの設定
    _centerScrollView.frame = rect;
    _centerScrollView.zoomScale = 1.0f;	//0.5f;	//zoom scale in Default.
    _centerScrollView.contentOffset = CGPointZero;
    _centerScrollView.contentSize = CGSizeMake(IPHONE_SCREEN_WIDTH, IPHONE_SCREEN_HEIGHT);	//(768.0f, 1024.0f);
    [image release];
    
    //
    // 右側のimage viewを更新
    //
    
    // 最後のページのとき
    if (_index >= _maxPage - 1) {
        rect = CGRectZero;
        
        image = nil;
    }
    // 最後のページ以外のとき
    else {
        // 右側のimage viewのframe
        rect.origin.x = CGRectGetMaxX(_centerScrollView.frame) /* + 24.0f*/;
        rect.origin.y = 0;
        rect.size.width = IPHONE_SCREEN_WIDTH;		//768.0f;
        rect.size.height = IPHONE_SCREEN_HEIGHT - 24.0f;	//1024.0f;
        
        // 右側のimage viewの画像の読み込み
		/*
        fileName = [NSString stringWithFormat:@"%03ds", _index + 1];
        path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
        image = [[UIImage alloc] initWithContentsOfFile:path];
		*/
		image = [self getPdfPageImageWithPageNum:_index+1];
    }
    
    // 右側のimage viewの設定
    _rightImageView.frame = rect;
    _rightImageView.image = image;
    [image release];
    
    //
    // root scroll viewを更新
    //
    
    // コンテントサイズとオフセットの設定
    CGSize  size;
    size.width = CGRectGetMaxX(_rightImageView.frame) > 0 ? 
	CGRectGetMaxX(_rightImageView.frame) /* + 24.0f */ : 
	CGRectGetMaxX(_centerScrollView.frame) /* + 24.0f */;
    size.height = 0;
    _rootScrollView.contentSize = size;
    _rootScrollView.contentOffset = _centerScrollView.frame.origin;
}


- (void)renewPageWithIndex:(int)newIndex
{
	_index = newIndex;
	[self drawPageWithCurrentIndex];
}



//--------------------------------------------------------------//
#pragma mark -- UIScrollViewDelegate --
//--------------------------------------------------------------//

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        // ページの更新
        [self _renewPageIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    // ページの更新
    [self _renewPageIndex];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    //return _centerImageView;
	return _centerPdfView;
}


//--------------------------------------------------------------//
#pragma mark -- touch test
//--------------------------------------------------------------//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touche.");
}

//--------------------------------------------------------------//
#pragma mark -- PDF method --
//--------------------------------------------------------------//
-(void)setDefaultPdfFile
{
	// Open the PDF document
	NSString* filename;
	//filename= @"TestPage.pdf";
	//filename = @"TestPage2.pdf";
	//filename = @"TestPage3.pdf";
	//filename = @"TestPage4.pdf";
	filename = @"CM1010-23.pdf";	// PDF with inner-link, URL-link(hyperlink).
	//filename = @"TestPageWithMovie.pdf";	// PDF with Movie(flash).
	NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
	pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	
	//先頭ページのサイズから表示サイズを設定
	page = CGPDFDocumentGetPage(pdf, 1);
	pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	pdfScale = self.view.frame.size.width / pageRect.size.width;
	pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
}


/*
- (void)drawPdf:(uint)pageNum
{
	// Get the PDF Page that we will be drawing
	page = CGPDFDocumentGetPage(pdf, pageNum);
	CGPDFPageRetain(page);
	
	// determine the size of the PDF page
	pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	pdfScale = self.view.frame.size.width / pageRect.size.width;
	pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
	
	
	UIImage *backgroundImage = [self getPdfPageImage:page
											pageRect:pageRect
											   scale:pdfScale
											 pageNum:pageNum];
	
	[backgroundImageView removeFromSuperview];
	[backgroundImageView initWithImage:backgroundImage];
	//backgroundImageView.frame = pageRect;
	backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.view addSubview:backgroundImageView];
	[self.view sendSubviewToBack:backgroundImageView];
	
#if 0==1
	// Create the TiledPDFView based on the size of the PDF page and scale it to fit the view.
	pdfView = [[TiledPDFView alloc] initWithFrame:pageRect andScale:pdfScale];
	[pdfView setPage:page];
	
	[self.view addSubview:pdfView];
#endif	
}
*/

/**
 *
 *note:pageNum is 0-start. but pdf file page is 1-start.
 *
 */
- (UIImage*)getPdfPageImageWithPageNum:(NSUInteger)pageNum
{
	// Create a low res image representation of the PDF page to display before the TiledPDFView
	// renders its content.
	UIGraphicsBeginImageContext(pageRect.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// First fill the background with white.
	CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
	CGContextFillRect(context, pageRect);
	
	CGContextSaveGState(context);
	// Flip the context so that the PDF page is rendered
	// right side up.
	CGContextTranslateCTM(context, 0.0, pageRect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Scale the context so that the PDF page is rendered 
	// at the correct size for the zoom level.
	CGContextScaleCTM(context, pdfScale, pdfScale);	
	
	page = CGPDFDocumentGetPage(pdf, pageNum + 1);
	if (! page) {
		NSLog(@"illigal page. source line=%d, pageNum=%d", __LINE__, pageNum);
		return nil;
	}
	
	CGPDFPageRetain(page);	/**/
	CGContextDrawPDFPage(context, page);
	CGContextRestoreGState(context);
	
	UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
	[backgroundImage retain];//(needs count down in calling method.
	
	UIGraphicsEndImageContext();
	if (! backgroundImage) {
		NSLog(@"UIGraphicsGetImageFromCurrentImageContext returns nil.");
	}
	return backgroundImage;
}

//--------------------------------------------------------------//
#pragma mark -- Show / Hide TOC View.
//--------------------------------------------------------------//
- (IBAction)showTocView:(id)sender
{
	TocViewController* tocViewController = [[TocViewController alloc] initWithNibName:@"TocView" bundle:[NSBundle mainBundle]];
	// Open with ModalView.
	[self presentModalViewController:tocViewController animated:YES];
}
- (void)closeTocView:(int)newHtmlFileNum
{
	[self dismissModalViewControllerAnimated:YES];
}


//--------------------------------------------------------------//
#pragma mark -- Show / Hide Navigation Bar.
//--------------------------------------------------------------//
- (void)toggleNavigationBar
{
	//[self.navigationController setNavigationBarHidden:(!self.navigationController.navigationBarHidden) animated:YES];
	if (navigationBar.hidden) {
		// show.
		navigationBar.hidden = FALSE;
	} else {
		// hide.
		navigationBar.hidden = TRUE;
	}
	
}


//--------------------------------------------------------------//
#pragma mark -- other method --
//--------------------------------------------------------------//

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
