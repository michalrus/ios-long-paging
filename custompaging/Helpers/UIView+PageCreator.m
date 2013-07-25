//
//  UIView+PageCreator.m
//  custompaging
//
//  Created by michalrus on 7/23/13.
//  Copyright (c) 2013 michalrus. All rights reserved.
//

#import "UIView+PageCreator.h"
#import <QuartzCore/QuartzCore.h>

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
    r.clipsToBounds = YES;
    
    float hue;
    
    do {
        hue = [UIView rndFrom:0 to:1];
    } while (ABS(hue - PageCreator_previousHue) < 0.2);
    
    PageCreator_previousHue = hue;
    
    r.backgroundColor = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    
    for (int i = 0; i < 30; i++) {
        float w = [UIView rndFrom:10 to:frame.size.width];
        float h = w;//[UIView rndFrom:10 to:frame.size.height];
        float x = [UIView rndFrom:0 to:frame.size.width];
        float y = [UIView rndFrom:0 to:frame.size.height];
        float sat = [UIView rndFrom:0.5 to:1];
        float bri = [UIView rndFrom:0.5 to:1];
        UIView* rect = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        rect.backgroundColor = [UIColor colorWithHue:hue saturation:sat brightness:bri alpha:1.0]; //[[UIColor whiteColor] colorWithAlphaComponent:0.2];
        rect.layer.cornerRadius = w;
        [r addSubview:rect];
    }
    
    return r;
}

@end
