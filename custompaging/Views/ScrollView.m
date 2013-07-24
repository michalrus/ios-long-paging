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
        self.pagingEnabled = NO;
        
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

- (void) moveRollBy:(float)dy animated:(BOOL)animated touchEnded:(BOOL)ended {
    CALayer* l = self.roll.layer;

    // keep current (possibly animated) position of our presentation layer
    l.position = ((CALayer *)[l presentationLayer]).position;
    [l removeAllAnimations];
    
    float x = l.position.x;
    float y = l.position.y + dy;
    
    y = MIN(y, 0);
    y = MAX(y, -(self.roll.bounds.size.height - self.bounds.size.height));
    
    if (self.pagingEnabled) {
        float tmpY = -l.position.y + self.bounds.size.height / 2 + 0.25;
        int currentPage = -2;
        BOOL found = NO;
        for (UIView* page in self.pages) {
            currentPage++;
            
            if (tmpY < page.frame.origin.y) {
                found = YES;
                break;
            }
        }
        if (!found)
            currentPage++;
        
        BOOL biggerPage = ((UIView* )[self.pages objectAtIndex:currentPage]).frame.size.height > self.frame.size.height;
    }
    
    if (!animated) {
        l.position = CGPointMake(x, y);
    }
    else {
        CAKeyframeAnimation* anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, l.position.x, l.position.y);
        CGPathAddLineToPoint(path, NULL, x, y);
        
        anim.path = path;
        anim.duration = 1.5;
        anim.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        
        anim.fillMode = kCAFillModeForwards;
        anim.removedOnCompletion = NO;
        
        [l addAnimation:anim forKey:@"position"];
    }
}

- (void)handlePan:(UIPanGestureRecognizer*)gestureRecognizer {
    float dy = [gestureRecognizer translationInView:self].y;
    float dt = -[self.panPrevDate timeIntervalSinceNow];
    self.panPrevDate = [NSDate date];
    
    BOOL ended = gestureRecognizer.state == UIGestureRecognizerStateEnded;
    
    if (ended && dt < 0.2) {
        float velocity = [gestureRecognizer velocityInView:self].y;
        [self moveRollBy:velocity * 2./3 animated:YES touchEnded:ended];
    }
    else
        [self moveRollBy:dy animated:NO touchEnded:ended];
    
    // reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
    [gestureRecognizer setTranslation:CGPointZero inView:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self moveRollBy:0 animated:NO touchEnded:NO];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
