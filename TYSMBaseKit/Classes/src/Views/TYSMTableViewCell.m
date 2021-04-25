//
//  TYSMTableViewCell.m
//  IMUI
//
//  Created by Jele on 1/12/2020.
//

#import "TYSMTableViewCell.h"

@implementation TYSMTableViewCell
@synthesize model = _model;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor =
    self.contentView.backgroundColor = UIColor.whiteColor;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
