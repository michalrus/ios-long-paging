//
//  UIView+PageCreator.h
//  custompaging
//
//  Created by michalrus on 7/23/13.
//  Copyright (c) 2013 michalrus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PageCreator)

+ (UIView*) pageWithWidth:(float)width height:(float)height;
+ (UIView*) pageWithFrame:(CGRect)frame;

@end
