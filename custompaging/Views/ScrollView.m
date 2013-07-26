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

@property (nonatomic) int beginPageIdx;
@property (nonatomic) float beginY;

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

#define epsilon 0.25

- (int )pageIdxAtY:(float)y {
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

- (void) moveRollBy:(float)dy animated:(BOOL)animated touchBegan:(BOOL)touchBegan touchEnded:(BOOL)touchEnded {
    CALayer* l = self.roll.layer;
    
    // keep current (possibly animated) position of our presentation layer
    l.position = ((CALayer *)[l presentationLayer]).position;
    [l removeAllAnimations];
    
    float animDuration = 1.5;
    
    float x = l.position.x;
    float y = l.position.y + dy;
    
    // linear "rubber band"
    if (y > 0 || y < -(self.roll.bounds.size.height - self.bounds.size.height)) {
        y = l.position.y + dy / 2.5;
    }
    
    BOOL bounce = NO;
    float bounceBy = 20;
    
    if (!self.pagingEnabled) {
        y = MIN(y, 0);
        y = MAX(y, -(self.roll.bounds.size.height - self.bounds.size.height));
    }
    else {
        int currentPageIdx = [self pageIdxAtY:-l.position.y];
        int targetPageIdx = [self pageIdxAtY:-y];
        
        if (touchBegan) {
            self.beginPageIdx = currentPageIdx;
            self.beginY = l.position.y;
        }
        
        UIView* currentPage = [self.pages objectAtIndex:currentPageIdx];
        
        if (targetPageIdx > currentPageIdx)
            targetPageIdx = currentPageIdx + 1;
        else if (targetPageIdx < currentPageIdx)
            targetPageIdx = currentPageIdx - 1;
        UIView* targetPage = [self.pages objectAtIndex:targetPageIdx];
        
        BOOL currentPageIsBigger = currentPage.frame.size.height - epsilon > self.frame.size.height;
        
#define maxY(page) (-page.frame.origin.y)
#define minY(page) (-page.frame.origin.y - page.frame.size.height + self.frame.size.height)
        
        if (touchEnded) {
            float newY = y;
            
            if (currentPageIsBigger && targetPageIdx == currentPageIdx) {
                newY = MIN(newY, maxY(currentPage));
                newY = MAX(newY, minY(currentPage));
                
                if (newY != y)
                    bounce = YES;
            }
            else {
                newY = -targetPage.frame.origin.y;
                
                if (currentPageIsBigger && self.beginPageIdx == currentPageIdx && targetPageIdx != currentPageIdx) {
                    
                    BOOL beganAtTopEdge = ABS(self.beginY - maxY(currentPage)) < bounceBy;
                    BOOL beganAtBottomEdge = ABS(self.beginY - minY(currentPage)) < bounceBy;
                    
                    if (targetPageIdx < currentPageIdx && !beganAtTopEdge) {
                        newY = maxY(currentPage);
                        bounce = YES;
                    }
                    else if (targetPageIdx > currentPageIdx && !beganAtBottomEdge) {
                        bounce = YES;
                        newY = minY(currentPage);
                    }
                }
                
                if (newY == -targetPage.frame.origin.y) {
                    // if we're still changing the page
                    BOOL targetPageIsBigger = targetPage.frame.size.height - epsilon > self.frame.size.height;

                    if (targetPageIsBigger) {
                        if (targetPageIdx < currentPageIdx) { // move up?
                            newY = minY(targetPage);
                        }
                    }
                }
            }
            
            if (newY != y) {
                y = newY;
                animated = YES;
                animDuration = 0.25;
            }
        }
    }
    
    if (!animated) {
        l.position = CGPointMake(x, y);
    }
    else {
        CAKeyframeAnimation* anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, l.position.x, l.position.y);
        if (bounce) {
            CGPathAddLineToPoint(path, NULL, x, y + (l.position.y > y ? -1 : 1) * bounceBy);
        }
        CGPathAddLineToPoint(path, NULL, x, y);
        
        anim.path = path;
        anim.duration = (bounce ? 2 : 1) * animDuration;
        CAMediaTimingFunction* t = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        anim.timingFunctions = @[t, t];
        
        anim.fillMode = kCAFillModeForwards;
        anim.removedOnCompletion = NO;
        
        [l addAnimation:anim forKey:@"position"];
    }
}

- (void)handlePan:(UIPanGestureRecognizer*)gestureRecognizer {
    float dy = [gestureRecognizer translationInView:self].y;
    float dt = -[self.panPrevDate timeIntervalSinceNow];
    self.panPrevDate = [NSDate date];
    
    BOOL began = gestureRecognizer.state == UIGestureRecognizerStateBegan;
    BOOL ended = gestureRecognizer.state == UIGestureRecognizerStateEnded;
    
    if (ended && dt < 0.2) {
        float velocity = [gestureRecognizer velocityInView:self].y;
        [self moveRollBy:velocity * 1./3 animated:YES touchBegan:began touchEnded:ended];
    }
    else
        [self moveRollBy:dy animated:NO touchBegan:began touchEnded:ended];
    
    // reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
    [gestureRecognizer setTranslation:CGPointZero inView:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self moveRollBy:0 animated:NO touchBegan:YES touchEnded:NO];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self moveRollBy:0 animated:NO touchBegan:NO touchEnded:YES];
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
