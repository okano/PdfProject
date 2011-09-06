/*
 *  Define.h
 *  SakuttoBook
 *
 *  Created by okano on 10/12/13.
 *  Copyright 2010,2011 Katsuhiko Okano All rights reserved.
 *
 */

//Vertical/Horizon mode in pdf.
#define IS_VERTICAL_PDF 1		/* 0:yokogaki, 1:tategaki*/

//Page Transition with Slide/Curl.
#define IS_TRANSITION_CURL 0	/* 0:Slide, 1:Curl*/

//Page background color.
#define PAGE_BACKGROUND_COLOR_R		0.0f	/* 0.0f - 1.0f */
#define PAGE_BACKGROUND_COLOR_G		0.0f	/* 0.0f - 1.0f */
#define PAGE_BACKGROUND_COLOR_B		0.0f	/* 0.0f - 1.0f */

//Page Transition Enable/Disable with tap left&right side.
#define ENABLED_TRANSITION 1	/* 0:transition disable, 1:enable(normal) */

//Use Multi contents.
#define IS_MULTI_CONTENTS	1	/* 0:single content, 1:multi contents */

//Hide Infomation button on Menu bar.
#define HIDE_INFOMATION_BUTTON 0	/* 0:show, 1:hide */

//Show 2-page in case of LandScape (yokonaga screen) mode.
#define IS_2PAGE_VIEW		1	/* 0:normal single view, 1:2-page view in LandScape view. */

// Tap area. (0.00 - 1.00) (1.00 is "fit to screen")
#define TAP_AREA_LEFT_X			0.00f
#define TAP_AREA_LEFT_Y			0.15f
#define TAP_AREA_LEFT_WIDTH		0.40f
#define TAP_AREA_LEFT_HEIGHT	1.00f
#define TAP_AREA_RIGHT_X		0.60f
#define TAP_AREA_RIGHT_Y		0.15f
#define TAP_AREA_RIGHT_WIDTH	0.40f
#define TAP_AREA_RIGHT_HEIGHT	1.00f
#define TAP_AREA_TOP_X			0.00f
#define TAP_AREA_TOP_Y			0.00f
#define TAP_AREA_TOP_WIDTH		1.00f
#define TAP_AREA_TOP_HEIGHT		0.15f
#define TAP_AREA_BOTTOM_X		0.00f
#define TAP_AREA_BOTTOM_Y		0.00f
#define TAP_AREA_BOTTOM_WIDTH	0.00f
#define TAP_AREA_BOTTOM_HEIGHT	0.00f

// for cache image.
#define CACHE_IMAGE_WIDTH_MIN		 320.0f
#define CACHE_IMAGE_WIDTH_MAX		1536.0f
#define THUMBNAIL_WIDTH				 100.0f

// for Page Animation.
#define MY_ANIMATION_KIND					@"MyAnimationKind"
#define MY_ANIMATION_KIND_PAGE_FROM_LEFT	@"PushFromLeft"
#define MY_ANIMATION_KIND_PAGE_FROM_RIGHT	@"PushFromRight"
#define MY_ANIMATION_KIND_FADE				@"Fade"
#define PAGE_ANIMATION_DURATION_NEXT	0.2f
#define PAGE_ANIMATION_DURATION_PREV	0.2f

// for Pan Gesture.
#define PAN_DISTANCE_MINIMUM	100.0f

// for Page Image.
#define PAGE_FILE_PREFIX			@"Page_p"
#define PAGE_FILE_EXTENSION			@"png"

// for Thumbnail Image.
#define THUMBNAIL_FILE_PREFIX		@"Thumbnail_p"
#define THUMBNAIL_FILE_EXTENSION	@"png"

// for Link Define.
#define LINK_DICT_KEY_URL	@"Url"
#define LINK_DICT_KEY_RECT	@"Rect"

// for Movie Define.
#define MD_PAGE_NUMBER		@"Movie_PageNumber"
#define MD_MOVIE_FILENAME	@"Movie_Filename"
#define MD_AREA_X			@"Movie_Area_X"
#define MD_AREA_Y			@"Movie_Area_Y"
#define MD_AREA_WIDTH		@"Movie_Area_Width"
#define MD_AREA_HEIGHT		@"Movie_Area_Height"

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

// for TOC Define.
#define TOC_PAGE			@"Toc_Page"
#define TOC_LEVEL			@"Toc_Level"
#define TOC_TITLE			@"Toc_Title"
#define TOC_FILENAME		@"Toc_Filename"
//#define TOC_CELL_IMAGE		@"Toc_Cell_Image"

// for Bookmark.
#define BOOKMARK_MULTI_CONTENT	@"Bookmark_MultiContent"
#define BOOKMARK_ARRAY			@"Bookmark_Array"
#define BOOKMARK_PAGE_NUMBER	@"Bookmark_PageNumber"
#define BOOKMARK_PAGE_MEMO		@"Bookmark_PageMemo"

// for latest read page.
#define USERDEFAULT_LATEST_READ_PAGE_MULTICONTENT @"Latest_Read_Page_MultiContent"
#define USERDEFAULT_LATEST_READ_PAGE @"Latest_Read_Page"

// for Information view.
#define DEFAULT_BOOK_SUPPORT_URL_PREFIX	@"http://www.google.co.jp/search?q="
#define PROGRAM_SUPPORT_URL			@"http://www.incunabula.co.jp/book/Sakutto/"

// license key.
#define LICENSE_KEY @"99840053-0000-0000-0008-000000000000"
