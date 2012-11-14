//
//  main.m
//  Hello World
//
//  Created by Alex Muller on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Hello_WorldAppDelegate.h"

int main(int argc, char *argv[])
{
    int retVal = 0;
    @autoreleasepool {
        retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([Hello_WorldAppDelegate class]));
    }
    return retVal;
}
