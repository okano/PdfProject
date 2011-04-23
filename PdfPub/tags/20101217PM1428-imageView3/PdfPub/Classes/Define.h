/*
 *  Define.h
 *  PdfPub
 *
 *  Created by okano on 10/12/13.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

// Tap area.
#define TAP_AREA_LEFT_X			  0.0f
#define TAP_AREA_LEFT_Y			 75.0f
#define TAP_AREA_LEFT_WIDTH		140.0f
#define TAP_AREA_LEFT_HEIGHT	600.0f
#define TAP_AREA_RIGHT_X		180.0f
#define TAP_AREA_RIGHT_Y		 75.0f
#define TAP_AREA_RIGHT_WIDTH	320.0f
#define TAP_AREA_RIGHT_HEIGHT	600.0f
#define TAP_AREA_TOP_X			  0.0f
#define TAP_AREA_TOP_Y			  0.0f
#define TAP_AREA_TOP_WIDTH		320.0f
#define TAP_AREA_TOP_HEIGHT		 75.0f

// for Page Animation.
#define MY_ANIMATION_KIND	@"MyAnimationKind"
#define MY_ANIMATION_KIND_PAGE_FROM_LEFT	@"PushFromLeft"
#define MY_ANIMATION_KIND_PAGE_FROM_RIGHT	@"PushFromRight"
#define MY_ANIMATION_KIND_FADE				@"Fade"
#define PAGE_ANIMATION_DURATION_NEXT	0.2f
#define PAGE_ANIMATION_DURATION_PREV	0.2f

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

// for TOC Define.
#define TOC_PAGE			@"Toc_Page"
#define TOC_LEVEL			@"Toc_Level"
#define TOC_TITLE			@"Toc_Title"
//#define TOC_CELL_IMAGE		@"Toc_Cell_Image"
