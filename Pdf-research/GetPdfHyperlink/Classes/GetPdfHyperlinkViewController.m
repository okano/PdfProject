//
//  GetPdfHyperlinkViewController.m
//  GetPdfHyperlink
//
//  Created by okano on 10/12/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GetPdfHyperlinkViewController.h"

@implementation GetPdfHyperlinkViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
	
	// Open the PDF document
	NSString* filename;
	filename = @"CM1010-23.pdf";	// PDF with inner-link, URL-link(hyperlink).
	NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
	pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	
	//先頭ページのサイズから表示サイズを設定
	page = CGPDFDocumentGetPage(pdf, 1);
	pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	pdfScale = self.view.frame.size.width / pageRect.size.width;
	pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
	
	//
	UIGraphicsBeginImageContext(pageRect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self renderPageAtIndex:1
				  inContext:context];
	
}



- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	
	CGPDFPageRef page2 = CGPDFDocumentGetPage(pdf, index+1);
	//CGAffineTransform transform1 = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
	//										 CGContextGetClipBoundingBox(ctx));
	//CGContextConcatCTM(ctx, transform1);
	CGContextDrawPDFPage(ctx, page2);
	
	
    CGPDFPageRef pageAd = CGPDFDocumentGetPage(pdf, index);
	
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(pageAd);
	
    CGPDFArrayRef outputArray;
    if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
        return;
    }
	
    int arrayCount = CGPDFArrayGetCount( outputArray );
    if(!arrayCount) {
        //continue;
    }
	
    for( int j = 0; j < arrayCount; ++j ) {
        CGPDFObjectRef aDictObj;
        if(!CGPDFArrayGetObject(outputArray, j, &aDictObj)) {
            return;
        }
		
        CGPDFDictionaryRef annotDict;
        if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
            return;
        }
		
        CGPDFDictionaryRef aDict;
        if(!CGPDFDictionaryGetDictionary(annotDict, "A", &aDict)) {
            return;
        }
		
        CGPDFStringRef uriStringRef;
        if(!CGPDFDictionaryGetString(aDict, "URI", &uriStringRef)) {
            return;
        }
		
        CGPDFArrayRef rectArray;
        if(!CGPDFDictionaryGetArray(annotDict, "Rect", &rectArray)) {
            return;
        }
		
        int arrayCount = CGPDFArrayGetCount( rectArray );
        CGPDFReal coords[4];
        for( int k = 0; k < arrayCount; ++k ) {
            CGPDFObjectRef rectObj;
            if(!CGPDFArrayGetObject(rectArray, k, &rectObj)) {
                return;
            }
			
            CGPDFReal coord;
            if(!CGPDFObjectGetValue(rectObj, kCGPDFObjectTypeReal, &coord)) {
                return;
            }
			
            coords[k] = coord;
        }               
		
        char *uriString = (char *)CGPDFStringGetBytePtr(uriStringRef);
		
        NSString *uri = [NSString stringWithCString:uriString encoding:NSUTF8StringEncoding];
        CGRect rect = CGRectMake(coords[0],coords[1],coords[2],coords[3]);
		
        CGPDFInteger pageRotate = 0;
        CGPDFDictionaryGetInteger( pageDictionary, "Rotate", &pageRotate ); 
        CGRect pageRect2 = CGRectIntegral( CGPDFPageGetBoxRect( page, kCGPDFMediaBox ));
        if( pageRotate == 90 || pageRotate == 270 ) {
            CGFloat temp = pageRect2.size.width;
            pageRect2.size.width = pageRect2.size.height;
            pageRect2.size.height = temp;
        }
		
        rect.size.width -= rect.origin.x;
        rect.size.height -= rect.origin.y;
		
        CGAffineTransform trans = CGAffineTransformIdentity;
        trans = CGAffineTransformTranslate(trans, 0, pageRect2.size.height);
        trans = CGAffineTransformScale(trans, 1.0, -1.0);
		
        rect = CGRectApplyAffineTransform(rect, trans);
		
		// do whatever you need with the coordinates.
		// e.g. you could create a button and put it on top of your page
		// and use it to open the URL with UIApplication's openURL
		NSURL *url = [NSURL URLWithString:uri];
		NSLog(@"URL: %@", url);
		//          CGPDFContextSetURLForRect(ctx, (CFURLRef)url, rect);
		UIButton *button = [[UIButton alloc] initWithFrame:rect];
		[button setTitle:@"LINK" forState:UIControlStateNormal];
		[button addTarget:self action:@selector(openLink:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:button];
		// CFRelease(url);
	}
    //} 
	
	
}

- (void)openLink:(id)sender
{
	NSLog(@"openLink function.");
}

#pragma mark other methods.
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
