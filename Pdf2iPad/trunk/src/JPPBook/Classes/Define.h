/*
 *  Define.h
 *  PdfPub
 *
 *  Created by okano on 10/12/13.
 *  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
 *
 */

/**********************************************************************/
#define MENU_TOP_PAGE_NUMBER	1
#define MENU_COVER_PAGE_NUMBER	2
#define MENU_INFO_URL			@"http://www.google.co.jp/"
#define MENU_HELP_URL			@"http://www.yahoo.co.jp/"
/**********************************************************************/
//Page Transition with Slide/Curl.
#define IS_TRANSITION_CURL 0	/* 0:Slide, 1:Curl*/

/**
 *
 */
#define TAP_AREA_LEFT_X			  0.0f
#define TAP_AREA_LEFT_Y			 75.0f
#define TAP_AREA_LEFT_WIDTH		360.0f
#define TAP_AREA_LEFT_HEIGHT	900.0f
#define TAP_AREA_RIGHT_X		380.0f
#define TAP_AREA_RIGHT_Y		 75.0f
#define TAP_AREA_RIGHT_WIDTH	360.0f
#define TAP_AREA_RIGHT_HEIGHT	900.0f
#define TAP_AREA_TOP_X			  0.0f
#define TAP_AREA_TOP_Y			  0.0f
#define TAP_AREA_TOP_WIDTH		320.0f
#define TAP_AREA_TOP_HEIGHT		 75.0f
#define TAP_AREA_BOTTOM_X			  0.0f
#define TAP_AREA_BOTTOM_Y			900.0f
#define TAP_AREA_BOTTOM_WIDTH		320.0f
#define TAP_AREA_BOTTOM_HEIGHT		 75.0f
#define TAP_AREA_LANDSCAPE_LEFT_X			  0.0f
#define TAP_AREA_LANDSCAPE_LEFT_Y			 75.0f
#define TAP_AREA_LANDSCAPE_LEFT_WIDTH		500.0f
#define TAP_AREA_LANDSCAPE_LEFT_HEIGHT		600.0f
#define TAP_AREA_LANDSCAPE_RIGHT_X			524.0f
#define TAP_AREA_LANDSCAPE_RIGHT_Y			 75.0f
#define TAP_AREA_LANDSCAPE_RIGHT_WIDTH		500.0f
#define TAP_AREA_LANDSCAPE_RIGHT_HEIGHT		600.0f
#define TAP_AREA_LANDSCAPE_TOP_X			  0.0f
#define TAP_AREA_LANDSCAPE_TOP_Y			  0.0f
#define TAP_AREA_LANDSCAPE_TOP_WIDTH		1024.0f
#define TAP_AREA_LANDSCAPE_TOP_HEIGHT		 75.0f
#define TAP_AREA_LANDSCAPE_BOTTOM_X			  0.0f
#define TAP_AREA_LANDSCAPE_BOTTOM_Y			524.0f
#define TAP_AREA_LANDSCAPE_BOTTOM_WIDTH		1024.0f
#define TAP_AREA_LANDSCAPE_BOTTOM_HEIGHT	 75.0f

// for Page Animation.
#define MY_ANIMATION_KIND	@"MyAnimationKind"
#define MY_ANIMATION_KIND_PAGE_FROM_LEFT	@"PushFromLeft"
#define MY_ANIMATION_KIND_PAGE_FROM_RIGHT	@"PushFromRight"
#define MY_ANIMATION_KIND_FADE				@"Fade"
#define PAGE_ANIMATION_DURATION_NEXT	0.2f
#define PAGE_ANIMATION_DURATION_PREV	0.2f

// for Page Image.
#define PAGE_FILE_PREFIX			@"Page_p"
#define PAGE_FILE_EXTENSION			@"png"

// for Marker Pen.
#define MARKERPEN_ARRAY             @"MarkerPen_Array"  /* Top of data */
#define MARKERPEN_PAGE_NUMBER       @"MarkerPen_PageNumber"
#define MARKERPEN_POINT_ARRAY        @"MarkerPen_Line_Array" /* array of CGPointValue. */
#define MARKERPEN_LINE_POSITION_X	@"x"
#define MARKERPEN_LINE_POSITION_Y	@"y"
#define MARKERPEN_COMMENT           @"MarkerPen_Comment"
#define MARKERPEN_LINE_COLOR_R		0.85f
#define MARKERPEN_LINE_COLOR_G		0.85f
#define MARKERPEN_LINE_COLOR_B		0.2f
#define MARKERPEN_LINE_COLOR_A		0.85f
#define MARKERPEN_LINE_WIDTH		2.0f

// for Thumbnail Image.
#define THUMBNAIL_WIDTH				100.0f
#define THUMBNAIL_FILE_PREFIX		@"Thumbnail_p"
#define THUMBNAIL_FILE_EXTENSION	@"png"

// for Link Define.
#define LINK_DICT_KEY_URL	@"Url"
#define LINK_DICT_KEY_RECT	@"Rect"

// for Movie Define.
#define MD_PAGE_NUMBER		@"Movie_PageNumber"
#define MD_AREA_X			@"Movie_Area_X"
#define MD_AREA_Y			@"Movie_Area_Y"
#define MD_AREA_WIDTH		@"Movie_Area_Width"
#define MD_AREA_HEIGHT		@"Movie_Area_Height"
#define MD_MOVIE_FILENAME	@"Movie_Filename"

// for Sound Define.
#define SD_PAGE_NUMBER		@"Sound_PageNumber"
#define SD_SOUND_FILENAME	@"Sound_Filename"

// for PageJump Link.
#define PJ_PAGE_NUMBER		@"PageJumpLink_PageNumber"
#define PJ_PAGE_AREA_X		@"PageJumpLink_Area_X"
#define PJ_PAGE_AREA_Y		@"PageJumpLink_Area_Y"
#define PJ_PAGE_AREA_WIDTH	@"PageJumpLink_Area_Width"
#define PJ_PAGE_AREA_HEIGHT	@"PageJumpLink_Area_Height"
#define PJ_PAGE_JUMPTO		@"PageJumpLink_JumpTo"

// for InPage ScrollView Define.
#define IPSD_PAGE_NUMBER	@"InPageScrollView_PageNumber"
#define IPSD_AREA_X			@"InPageScrollView_Area_X"
#define IPSD_AREA_Y			@"InPageScrollView_Area_Y"
#define IPSD_AREA_WIDTH		@"InPageScrollView_Area_Width"
#define IPSD_AREA_HEIGHT	@"InPageScrollView_Area_Height"
#define IPSD_FILENAMES		@"InPageScrollView_Filenames"	//multi file(s).
//#define IPSD_BACKGROUND_COLOR [UIColor whiteColor]
#define IPSD_BACKGROUND_COLOR [UIColor whiteColor]
#define IPSD_SCROLL_INDICATOR_INSET_STRING @"{3.0,8.0,1.0,5.0}"

// for InPage Pdf Define / InPagePngDefine.
#define IPPD_PAGE_NUMBER	@"InPagePdf_PageNumber"
#define IPPD_AREA_X			@"InPagePdf_Area_X"
#define IPPD_AREA_Y			@"InPagePdf_Area_Y"
#define IPPD_AREA_WIDTH		@"InPagePdf_Area_Width"
#define IPPD_AREA_HEIGHT	@"InPagePdf_Area_Height"
#define IPPD_FILENAME		@"InPagePdf_Filename"	//multi file(s).

// for TOC Define.
#define TOC_PAGE			@"Toc_Page"
#define TOC_LEVEL			@"Toc_Level"
#define TOC_TITLE			@"Toc_Title"
#define TOC_FILENAME		@"Toc_Filename"
//#define TOC_CELL_IMAGE		@"Toc_Cell_Image"
#define TOC_FONTNAME		@"HiraKakuProN-W3"
#define TOC_FONTSIZE		12.0f
#define TOC_VIEW_WIDTH		400.0f

// for HELP Screen. -> Web.
//#define HELP_SCREEN_IMAGE	@"help.png"

// for Bookmark.
#define BOOKMARK_ARRAY			@"Bookmark_Array"
#define BOOKMARK_PAGE_NUMBER	@"Bookmark_PageNumber"
#define BOOKMARK_PAGE_MEMO		@"Bookmark_PageMemo"

// for latest read page.
#define USERDEFAULT_LATEST_READ_PAGE @"Latest_Read_Page"
