//
//  TYSMNavigationController.m
//  IMUI
//
//  Created by Jele on 1/12/2020.
//

#import "TYSMNavigationController.h"

@interface TYSMNavigationController ()

@end

@implementation TYSMNavigationController


- (void)removeBackStyle {
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.navigationBar.barTintColor = UIColor.whiteColor;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : UIColor.blackColor};
    self.navigationItem.backButtonTitle = @" ";
    
    UINavigationBar *barAppearance = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[self.class]];
    barAppearance.backIndicatorImage = [UIImage new];
    barAppearance.backIndicatorTransitionMaskImage = [UIImage new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
