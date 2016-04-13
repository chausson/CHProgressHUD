//
//  ViewController.m
//  CHProgressHUDDemo
//
//  Created by Chausson on 16/4/8.
//  Copyright © 2016年 Chausson. All rights reserved.
//
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"
#import "ViewController.h"
#import "CHProgressHUD.h"
@interface ViewController ()

@end

@implementation ViewController{
    MBProgressHUD *mbHud;
    CHProgressHUD *hud;
    UIView *_view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
}
- (IBAction)changed:(UIButton *)sender {
    [CHProgressHUD setMode:CHProgressHUDModeActivityIndicator];
    [CHProgressHUD showHUDAddedTo:self.view animated:YES];
    [CHProgressHUD hide:YES afterDelay:2.0f completionBlock:nil];

}
- (IBAction)hide:(UIButton *)sender {
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    image.image = [UIImage imageNamed:@"CustomLoding"];
    [CHProgressHUD setCustomView:image];
    [CHProgressHUD setMode:CHProgressHUDModeCustomView];
    [CHProgressHUD show:YES];
    [CHProgressHUD hide:YES afterDelay:2.0f completionBlock:nil];

}
- (void)dismiss{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
