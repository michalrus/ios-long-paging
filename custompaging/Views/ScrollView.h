//
//  ScrollView.h
//  custompaging
//
//  Created by michalrus on 7/23/13.
//  Copyright (c) 2013 michalrus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL pagingEnabled;

- (void) addPage:(UIView*)page;

@end
