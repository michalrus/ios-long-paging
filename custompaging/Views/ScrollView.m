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

@property (nonatomic) float touchStartY;

@end

@implementation ScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.pages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addPage:(UIView*)page {
    [self.pages addObject:page];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pos = [((UITouch*) [touches anyObject]) locationInView:self];
    
    self.touchStartY = pos.y;
    
    NSLog(@"touch began at %f", pos.y);
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pos = [((UITouch*) [touches anyObject]) locationInView:self];
    
    NSLog(@"touch ended at %f", pos.y);
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pos = [((UITouch*) [touches anyObject]) locationInView:self];
    
    NSLog(@"touch moved at %f", pos.y);
    [super touchesMoved:touches withEvent:event];
}

@end
