//
//  UIView+PageCreator.m
//  custompaging
//
//  Created by michalrus on 7/23/13.
//  Copyright (c) 2013 michalrus. All rights reserved.
//

#import "UIView+PageCreator.h"

@implementation UIView (PageCreator)

+ (float)rndFrom:(float)from to:(float)to
{
    // see http://stackoverflow.com/a/5172449
    float r = (double )arc4random() / 0x100000000; // 0.0 to 1.0
    
    float min = MIN(from, to);
    float max = MAX(from, to);
    
    r = r * (max - min) + min;
    
    return r;
}

float PageCreator_previousHue = -1;

+ (UIView*) pageWithWidth:(float)width height:(float)height {
    return [UIView pageWithFrame:CGRectMake(0, 0, width, height)];
}

+ (UIView*) pageWithFrame:(CGRect)frame {
    UIView* r = [[UIView alloc] initWithFrame:frame];
    
    float hue;
    
    do {
        hue = [UIView rndFrom:0 to:1];
    } while (ABS(hue - PageCreator_previousHue) < 0.2);
    
    PageCreator_previousHue = hue;
    
    UIColor* stripeC = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    UIColor* spacerC = [UIColor colorWithHue:hue saturation:0.5 brightness:1 alpha:1];
    
    r.backgroundColor = spacerC;
    
    r.clipsToBounds = YES;
    float stripeH = 20;
    float spacerH = stripeH;
    for (float y = 0; y < frame.size.height; y += stripeH + spacerH) {
        UIView* stripe = [[UIView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, stripeH)];
        stripe.backgroundColor = stripeC;
        
        [r addSubview:stripe];
    }
    
    return r;
}

@end
