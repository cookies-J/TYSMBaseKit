//
//  TYSMView.m
//  IMUI
//
//  Created by Jele on 1/12/2020.
//

#import "TYSMView.h"

@implementation TYSMView
@synthesize model = _model;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = UIColor.whiteColor;
}
@end
