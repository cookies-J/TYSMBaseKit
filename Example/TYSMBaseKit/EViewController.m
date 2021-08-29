//
//  EViewController.m
//  TYSMBaseKit_Example
//
//  Created by Jele Lam on 2021/8/28.
//  Copyright © 2021 cooljele@gmail.com. All rights reserved.
//

#import "EViewController.h"
#import "EAPIRequestManager.h"

@interface EViewController ()

@end

@implementation EViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TYSMLog addLogger];
    
    [[EAPIRequestManager shareInstance] configureBaseUrl:@"https://api.github.com"];
    
    [[EAPIRequestManager shareInstance] getGithubUsers:^(id  _Nonnull data) {
        TYSMLogInfo(@"%@",data);
    } failure:^(id  _Nonnull error) {
        TYSMLogInfo(@"%@",error);
    }];
    
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
