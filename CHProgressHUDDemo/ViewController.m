//
//  ViewController.m
//  CHProgressHUDDemo
//
//  Created by Chausson on 16/4/8.
//  Copyright © 2016年 Chausson. All rights reserved.
//

#import "ViewController.h"
#import "CHProgressHUD.h"
static NSArray *data;
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    data = [NSArray arrayWithObjects:@"Show Activity",@"Show Custom",@"Show PlainText",@"Show ActivityText", nil];
    self.view.backgroundColor = [UIColor whiteColor];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITableViewCell description]];
        cell.textLabel.text = data[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [CHProgressHUD  show:YES];
            [CHProgressHUD hide:YES afterDelay:3.0f completionBlock:^{
                NSLog(@"image dismiss after 3.0");
            }];
            break;
        case 1:{
            UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
            image.image = [UIImage imageNamed:@"CustomLoding"];
            [CHProgressHUD setCustomView:image];
            [CHProgressHUD setMode:CHRotateCustomView];
            [CHProgressHUD show:YES];
            [CHProgressHUD hide:YES afterDelay:3.0f completionBlock:^{
                NSLog(@"image dismiss after 3.0");
            }];
        }break;
        case 2:
            [CHProgressHUD setLabelText:@"网络不好检查下网络连接"];
            [CHProgressHUD setMode:CHPlainText];
            [CHProgressHUD show:YES];
            break;
        case 3:
            [CHProgressHUD setLabelText:@"登录中，请稍等"];
            [CHProgressHUD setMode:CHActivityText];
            [CHProgressHUD showHUDAddedTo:self.view animated:YES];
            [self performSelector:@selector(hide) withObject:nil afterDelay:3.5];
            break;
            
        default:
            break;
    }
}
- (void)hide{
        [CHProgressHUD hideWithText:@"手机密码错误" animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
