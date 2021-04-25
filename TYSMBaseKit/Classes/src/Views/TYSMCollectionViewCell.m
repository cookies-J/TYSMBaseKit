//
//  TYSMCollectionViewCell.m
//  IMUI
//
//  Created by Jele on 1/12/2020.
//

#import "TYSMCollectionViewCell.h"

@implementation TYSMCollectionViewCell

@synthesize model = _model;

@synthesize modelClassName = _modelClassName;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundView.backgroundColor =
    self.contentView.backgroundColor =
    self.backgroundColor =
    UIColor.whiteColor;
}
@end
