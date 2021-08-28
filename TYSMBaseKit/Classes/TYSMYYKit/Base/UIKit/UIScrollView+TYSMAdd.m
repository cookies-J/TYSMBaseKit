//
//  UIScrollView+TYSMAdd.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 13/4/5.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIScrollView+TYSMAdd.h"
#import "TYSMYYKitMacro.h"

TYSMSYNTH_DUMMY_CLASS(UIScrollView_TYSMAdd)


@implementation UIScrollView (TYSMAdd)

- (void)tysm_scrollToTop {
    [self tysm_scrollToTopAnimated:YES];
}

- (void)tysm_scrollToBottom {
    [self tysm_scrollToBottomAnimated:YES];
}

- (void)tysm_scrollToLeft {
    [self tysm_scrollToLeftAnimated:YES];
}

- (void)tysm_scrollToRight {
    [self tysm_scrollToRightAnimated:YES];
}

- (void)tysm_scrollToTopAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = 0 - self.contentInset.top;
    [self setContentOffset:off animated:animated];
}

- (void)tysm_scrollToBottomAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    [self setContentOffset:off animated:animated];
}

- (void)tysm_scrollToLeftAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = 0 - self.contentInset.left;
    [self setContentOffset:off animated:animated];
}

- (void)tysm_scrollToRightAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
    [self setContentOffset:off animated:animated];
}

@end
