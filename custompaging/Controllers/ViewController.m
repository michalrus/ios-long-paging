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
    
    float w = self.view.bounds.size.width;
    float h = self.view.bounds.size.height;
    
    ScrollView* scrollView = [[ScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [self.view addSubview:scrollView];
    
    [scrollView addPage:[UIView pageWithWidth:w height:h]];
    [scrollView addPage:[UIView pageWithWidth:w height:h]];
    [scrollView addPage:[UIView pageWithWidth:w height:h]];
    [scrollView addPage:[UIView pageWithWidth:w height:h*1.5]];
    [scrollView addPage:[UIView pageWithWidth:w height:h]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
