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

+ (UIView*) rectangleWithHue:(float)hue maxW:(float)maxW maxH:(float)maxH {
    int a = [UIView rndFrom:0.2 to:0.5] * maxW;
    int x = [UIView rndFrom:-0.3 to:1.3] * maxW;
    int y = [UIView rndFrom:-0.3 to:1.3] * maxH;
    
    int mod = 15;
    a -= a % mod;
    x -= x % mod;
    y -= y % mod;
    
    UIView* r = [[UIView alloc] initWithFrame:CGRectMake(x, y, a, a)];
    
    float alph = [UIView rndFrom:0.25 to:0.75];
    float hueMod = [UIView rndFrom:-1 to:1] * 0.2;
    r.backgroundColor = [UIColor colorWithHue:hue + hueMod saturation:1 brightness:1 alpha:alph];
    
    return r;
}

+ (UIView*) pageWithWidth:(float)width height:(float)height {
    UIView* r = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    float hue = [UIView rndFrom:0 to:1];
    UIColor* base = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    
    r.backgroundColor = base;
    
    r.clipsToBounds = YES;
    for (int i = 0; i < 50; i ++)
        [r addSubview:[UIView rectangleWithHue:hue maxW:width maxH:height]];
    
    return r;
}

@end
