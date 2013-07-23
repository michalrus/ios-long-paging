//
//  ScrollView.m
//  custompaging
//
//  Created by michalrus on 7/23/13.
//  Copyright (c) 2013 michalrus. All rights reserved.
//

#import "ScrollView.h"

@interface ScrollView ()

@property (nonatomic,strong) NSMutableArray* pages;
@property (nonatomic,strong) UIView* roll;

@property (nonatomic) float touchPrevY;

@end

@implementation ScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.pages = [[NSMutableArray alloc] init];
        self.roll = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
        self.roll.backgroundColor = [UIColor blueColor];
        [self addSubview:self.roll];
    }
    return self;
}

- (void) addPage:(UIView*)page {
    [self.pages addObject:page];
    
    float rollH = self.roll.bounds.size.height;
    float rollW = self.roll.bounds.size.width;
    
    float w = page.bounds.size.width;
    float h = page.bounds.size.height;
    
    page.frame = CGRectMake(0, rollH, w, h);
    self.roll.frame = CGRectMake(0, 0, rollW, rollH + h);
    [self.roll addSubview:page];
}

- (void) moveRollBy:(float)by {
    float y = self.roll.frame.origin.y + by;
    
    y = MIN(y, 0);
    y = MAX(y, -(self.roll.bounds.size.height - self.bounds.size.height));
    
    self.roll.frame = CGRectMake(0, y, self.roll.bounds.size.width, self.roll.bounds.size.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pos = [((UITouch*) [touches anyObject]) locationInView:self];
    
    self.touchPrevY = pos.y;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pos = [((UITouch*) [touches anyObject]) locationInView:self];
    
    [self moveRollBy:pos.y - self.touchPrevY];
    self.touchPrevY = pos.y;
}

@end
