//
//  TYSMCollectionView.m
//  cengage
//
//  Created by Jele on 11/3/2021.
//

#import "TYSMCollectionView.h"

@implementation TYSMCollectionView
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
    self.backgroundColor =
    self.backgroundView.backgroundColor = UIColor.whiteColor;
}

@end
