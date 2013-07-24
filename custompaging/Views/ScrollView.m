//
//  ScrollView.m
//  custompaging
//
//  Created by michalrus on 7/23/13.
//  Copyright (c) 2013 michalrus. All rights reserved.
//

#import "ScrollView.h"

#import <QuartzCore/QuartzCore.h>

@interface ScrollView ()

@property (nonatomic,strong) NSMutableArray* pages;
@property (nonatomic,strong) UIView* roll;

@property (nonatomic,strong) NSDate* panPrevDate;

@end

@implementation ScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.pages = [[NSMutableArray alloc] init];
        self.roll = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
        self.roll.backgroundColor = [UIColor blueColor];
        [self addSubview:self.roll];
        
        UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        gestureRecognizer.delegate = self;
        gestureRecognizer.maximumNumberOfTouches = 1;
        gestureRecognizer.minimumNumberOfTouches = 1;
        
        [self addGestureRecognizer:gestureRecognizer];
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
    self.roll.layer.anchorPoint = CGPointMake(0, 0);
    self.roll.layer.position = CGPointMake(0, 0);
}

- (void) moveRollBy:(float)dy animated:(BOOL)animated {
    CALayer* l = self.roll.layer;
    
    float y = l.position.y + dy;
    
    y = MIN(y, 0);
    y = MAX(y, -(self.roll.bounds.size.height - self.bounds.size.height));
    
    NSLog(@"y = %.0f", y);
    
    l.position = CGPointMake(l.position.x, y);
}

- (void)handlePan:(UIPanGestureRecognizer*)gestureRecognizer {
    NSLog(@"pan!");
    
    float dy = [gestureRecognizer translationInView:self].y;
    float dt = -[self.panPrevDate timeIntervalSinceNow];
    self.panPrevDate = [NSDate date];
    
    [self moveRollBy:dy animated:NO];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded && dt < 0.2) {
        float velocity = [gestureRecognizer velocityInView:self].y;
        [self moveRollBy:velocity * 0.5 animated:YES];
    }
    
    // reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
    [gestureRecognizer setTranslation:CGPointZero inView:self];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
