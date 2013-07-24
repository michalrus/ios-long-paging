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

- (int )pageIdxAtY:(float)y {
    float epsilon = 0.25;
    
    float tmpY = y + self.bounds.size.height / 2 + epsilon;
    int currentPageIdx = -2;
    BOOL found = NO;
    
    for (UIView* page in self.pages) {
        currentPageIdx++;
        
        if (tmpY < page.frame.origin.y) {
            found = YES;
            break;
        }
    }
    
    if (!found)
        currentPageIdx++;
    
    return MIN(self.pages.count - 1, MAX(0, currentPageIdx));
}

- (void) moveRollBy:(float)dy animated:(BOOL)animated touchEnded:(BOOL)touchEnded {
    CALayer* l = self.roll.layer;
    
    // keep current (possibly animated) position of our presentation layer
    l.position = ((CALayer *)[l presentationLayer]).position;
    [l removeAllAnimations];
    
    float animDuration = 1.5;
    
    float x = l.position.x;
    float y = l.position.y + dy;
    
    if (!self.pagingEnabled) {
        y = MIN(y, 0);
        y = MAX(y, -(self.roll.bounds.size.height - self.bounds.size.height));
    }
    else {
        int currentPageIdx = [self pageIdxAtY:-l.position.y];
        int targetPageIdx = [self pageIdxAtY:-y];
        
        UIView* currentPage = [self.pages objectAtIndex:currentPageIdx];
        
        if (targetPageIdx > currentPageIdx)
            targetPageIdx = currentPageIdx + 1;
        else if (targetPageIdx < currentPageIdx)
            targetPageIdx = currentPageIdx - 1;
        UIView* targetPage = [self.pages objectAtIndex:targetPageIdx];
        
        BOOL biggerPage = currentPage.frame.size.height > self.frame.size.height;
        
        if (biggerPage) {
            //BOOL atTopEdge = ABS(y + currentPage)
            
            NSLog(@"current page y = %.f", -currentPage.frame.origin.y);
            NSLog(@"move to y = %.0f", y);
        }

        if (touchEnded) {
            animated = YES;
            animDuration = 0.25;
            y = -targetPage.frame.origin.y;
        }
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
        anim.duration = animDuration;
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self moveRollBy:0 animated:NO touchEnded:YES];
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
