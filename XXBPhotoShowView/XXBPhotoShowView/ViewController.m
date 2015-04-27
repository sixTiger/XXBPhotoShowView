//
//  ViewController.m
//  XXBPhotoShowView
//
//  Created by 杨小兵 on 15/4/27.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "ViewController.h"
#import "XXBPhotoShowView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImage *image = [UIImage imageNamed:@"test"];
    XXBPhotoShowView *photoView = [[XXBPhotoShowView alloc] initWithFrame:self.view.bounds];
    photoView.image = image;
    photoView.autoresizingMask = (1 << 6) -1;
    
    [self.view addSubview:photoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
