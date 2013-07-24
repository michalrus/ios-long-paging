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
@property (nonatomic) float touchPrevDY;
@property (nonatomic) double touchPrevTimestamp;

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
}

- (void) moveRollBy:(float)by velocity:(float)velocity {
    float y = self.roll.frame.origin.y + by;
    
    //if (velocity > 0)
    //    NSLog(@"velocity = %f", velocity);
    
    y = MIN(y, 0);
    y = MAX(y, -(self.roll.bounds.size.height - self.bounds.size.height));
    
    self.roll.frame = CGRectMake(0, y, self.roll.bounds.size.width, self.roll.bounds.size.height);
}

- (void)handlePan:(UIPanGestureRecognizer*)gestureRecognizer {
    //if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self];
        
        NSLog(@"dy = %f ; velocity = %f", translation.y, [gestureRecognizer velocityInView:self].y);
        
        // reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
        [gestureRecognizer setTranslation:CGPointZero inView:self];
    //}
}

- (void)handleTouch:(NSSet*)touches began:(BOOL)began ended:(BOOL)ended {
    UITouch* touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    
    if (began) {
        self.touchPrevDY = 0;
    }
    else {
        float velocity;
        float dy = pos.y - self.touchPrevY;
        double dt = touch.timestamp - self.touchPrevTimestamp;
    
        if (!ended) { // if moved
            NSLog(@"moved: dy = %f ; dt = %f", dy, dt);

            velocity = 0;
        }
        else {
            NSLog(@"ended: dy = %f ; dt = %f", dy, dt);
            
            velocity = self.touchPrevDY / dt;
            
            NSLog(@"velocity = %f", velocity);
        }
        [self moveRollBy:dy velocity:velocity];
        
        self.touchPrevDY = dy;
    }
    
    self.touchPrevTimestamp = touch.timestamp;
    self.touchPrevY = pos.y;
    
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
