//
//  TYSMTableView.m
//  cengage
//
//  Created by jele lam on 28/3/2021.
//

#import "TYSMTableView.h"

@implementation TYSMTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor =
    self.backgroundView.backgroundColor = UIColor.whiteColor;
}
@end
