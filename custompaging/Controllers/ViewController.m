//
//  ViewController.m
//  custompaging
//
//  Created by michalrus on 7/23/13.
//  Copyright (c) 2013 michalrus. All rights reserved.
//

#import "ViewController.h"
#import "ScrollView.h"
#import "UIView+PageCreator.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    float w = self.view.bounds.size.width / 2;
    float h = self.view.bounds.size.height;
    
    // custom ScrollView
    
    ScrollView* scrollView = [[ScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [self.view addSubview:scrollView];
    
    [scrollView addPage:[UIView pageWithWidth:w height:h]];
    [scrollView addPage:[UIView pageWithWidth:w height:h]];
    [scrollView addPage:[UIView pageWithWidth:w height:h]];
    [scrollView addPage:[UIView pageWithWidth:w height:h*1.5]];
    [scrollView addPage:[UIView pageWithWidth:w height:h]];
    
    // UIScrollView
    
    UIScrollView* uiScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(w, 0, w, h)];
    [self.view addSubview:uiScrollView];

    float y = 0;
    [uiScrollView addSubview:[UIView pageWithFrame:CGRectMake(0, y, w, h)]]; y += h;
    [uiScrollView addSubview:[UIView pageWithFrame:CGRectMake(0, y, w, h)]]; y += h;
    [uiScrollView addSubview:[UIView pageWithFrame:CGRectMake(0, y, w, h)]]; y += h;
    [uiScrollView addSubview:[UIView pageWithFrame:CGRectMake(0, y, w, h * 1.5)]]; y += h * 1.5;
    [uiScrollView addSubview:[UIView pageWithFrame:CGRectMake(0, y, w, h)]]; y += h;
    [uiScrollView setContentSize:CGSizeMake(w, y)];
//    uiScrollView.pagingEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
