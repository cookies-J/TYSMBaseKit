//
//  ViewController.m
//  TYSMBaseKit_Macos
//
//  Created by Jele Lam on 2021/8/28.
//  Copyright © 2021 cooljele@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import <TYSMBaseKit/TYSMBaseKit.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TYSMLog addLogger];
    
    TYSMLogInfo(@"");
    TYSMLogWarn(@"");
    TYSMLogDebug(@"");
    TYSMLogVerbose(@"");
    TYSMLogError(@"");
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
