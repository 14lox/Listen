//
//  EmptyPlaylistCell.m
//  Listen
//
//  Created by Dai Hovey on 04/12/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import "EmptyPlaylistCell.h"
#import "UIFont+ListenFont.h"

@interface EmptyPlaylistCell ()

@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation EmptyPlaylistCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectedBackgroundView = nil;
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 200)];
        _messageLabel.font = [UIFont boldListenFontOfSize:40];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.text = @"List.en\nplaylist\nis empty.";
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CALayer *line = [CALayer layer];
    line.backgroundColor = UIColorFromRGB(0x000000).CGColor;
    line.frame = self.frame;
    [self.contentView.layer addSublayer:line];
    [self.contentView addSubview:_messageLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
