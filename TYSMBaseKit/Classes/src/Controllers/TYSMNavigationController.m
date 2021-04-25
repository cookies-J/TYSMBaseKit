//
//  TYSMNavigationController.m
//  IMUI
//
//  Created by Jele on 1/12/2020.
//

#import "TYSMNavigationController.h"

@interface TYSMNavigationController ()
//<UIGestureRecognizerDelegate>

@end

@implementation TYSMNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.navigationBar.barTintColor = UIColor.whiteColor;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : UIColor.blackColor};
    self.navigationItem.backButtonTitle = @" ";
    
    
    
//    UIImage *backButtonBackgroundImage = [[UIImage systemImageNamed:@"chevron.backward"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UINavigationBar *barAppearance = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[self.class]];
    barAppearance.backIndicatorImage = [UIImage new];
    barAppearance.backIndicatorTransitionMaskImage = [UIImage new];
//    //设置右滑返回手势的代理为自身
//    __weak typeof(self) weakself = self;
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.interactivePopGestureRecognizer.delegate = (id)weakself;
//    }
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

#pragma mark - UIGestureRecognizerDelegate
////这个方法是在手势将要激活前调用：返回YES允许右滑手势的激活，返回NO不允许右滑手势的激活
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
//        //屏蔽调用rootViewController的滑动返回手势，避免右滑返回手势引起crash
//        if (self.viewControllers.count < 2 ||
//            self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
//            return NO;
//        }
//    }
//    //这里就是非右滑手势调用的方法啦，统一允许激活
//    return YES;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
