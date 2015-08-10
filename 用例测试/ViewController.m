//
//  ViewController.m
//  用例测试
//
//  Created by nianfangge on 15/7/25.
//  Copyright (c) 2015年 farben. All rights reserved.
//

#import "ViewController.h"
#import "UserModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"my" ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    UserModel *model = [UserModel makeDataModelByJson:jsonString];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.view.bounds.size.width, 400)];
//    label.backgroundColor = [UIColor redColor];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    label.text = [NSString stringWithFormat:@"json数据装换成UserModel数据如下:\n\n%@",model];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
