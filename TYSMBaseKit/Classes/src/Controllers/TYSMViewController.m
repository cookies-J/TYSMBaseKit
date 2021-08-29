//
//  TYSMViewController.m
//  IMUI
//
//  Created by Jele on 1/12/2020.
//

#import "TYSMViewController.h"

@interface TYSMViewController ()

@end

@implementation TYSMViewController
@synthesize model = _model;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    } else {
        return UIStatusBarStyleDefault;
        // Fallback on earlier versions
    }
}

- (NSString *)nibName {
    return NSStringFromClass(self.class);
}

- (NSBundle *)nibBundle {
    return nil;
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
