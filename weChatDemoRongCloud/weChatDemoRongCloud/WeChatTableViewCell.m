//
//  WeChatTableViewCell.m
//  weChatDemoRongCloud
//
//  Created by iOS on 2017/10/31.
//  Copyright © 2017年 iOS. All rights reserved.
//

#import "WeChatTableViewCell.h"
#import "YYText.h"

@implementation WeChatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpUI];
    }
    return self;
    
}

- (void)setUpUI {
    
    // 时间
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, MAINSCREENWIDTH-30, 17)];
    [self.contentView addSubview:timeLabel];
    timeLabel.text = @"2017-10-31 17:45:45";
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.textColor = [UIColor greenColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel = timeLabel;
    
    // 聊天头像
    UIImageView *iconImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:iconImageView];
    self.iconImageView=iconImageView;
    
    // 聊天内容背景视图
    UIImageView *chatBgImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:chatBgImageView];
    chatBgImageView.image = [UIImage imageNamed:@"liaotiankuangleft"];
    self.chatBgImageView=chatBgImageView;
    
    // 内容 label
    UILabel *chatContentLabel = [[UILabel alloc] init];
    [self.contentView addSubview:chatContentLabel];
    chatContentLabel.numberOfLines=0;
    chatContentLabel.font = [UIFont systemFontOfSize:15];
    chatContentLabel.textColor = [UIColor blackColor];
    chatContentLabel.userInteractionEnabled=YES;
    self.chatContentLabel = chatContentLabel;
    
    // 分隔线
    UILabel *spLine = [[UILabel alloc] init];
    [self.contentView addSubview:spLine];
//    spLine.backgroundColor = [UIColor redColor];
    self.spLine = spLine;
    
    [self labelAddGestAction];
    
}

- (void)setModel:(chatModel *)model {
    
    if (_model!=model) {
        _model=model;
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"2017-10-31 %zd:%zd:%zd", arc4random_uniform(24),arc4random_uniform(60),arc4random_uniform(60)];
    
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:(NSString *)model];
    NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle1.alignment=NSTextAlignmentJustified;
    
    NSDictionary *dic =@{
                         NSParagraphStyleAttributeName:paragraphStyle1,
                         NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleNone],
                         NSFontAttributeName:[UIFont systemFontOfSize:15.0]
                         };
   
    [attributedString1 setAttributes:dic range:NSMakeRange(0, attributedString1.length)];
    
    NSError *error;
    NSDataDetector *dataDetector=[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *arrayOfAllMatches=[dataDetector matchesInString:(NSString *)model options:NSMatchingReportProgress range:NSMakeRange(0, [(NSString *)model length])];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSRange range = match.range;
        [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:range];
    }
    
    [self.chatContentLabel setAttributedText:attributedString1];
    
    [self layoutSubviews];
    
}

- (void)layoutSubviews {
    
    CGFloat chatContentLabelHeight = [self.chatContentLabel.text boundingRectWithSize:CGSizeMake(CHATCONTENTWIDTH, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.height;
    CGFloat chatContentLabelWidth = [self.chatContentLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 17) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.width;
    
    int num = arc4random_uniform(2);
    if (num==1) {
        
        self.iconImageView.image=[UIImage imageNamed:@"leftimageview"];
        self.chatBgImageView.image=[UIImage imageNamed:@"liaotiankuangleft"];
        
        self.iconImageView.frame=CGRectMake(15, self.timeLabel.frame.origin.y+self.timeLabel.frame.size.height+15, 32, 32);
        self.chatContentLabel.frame = CGRectMake(15+16, self.iconImageView.frame.origin.y+self.iconImageView.frame.size.height+15, chatContentLabelWidth+1>CHATCONTENTWIDTH ? CHATCONTENTWIDTH:chatContentLabelWidth+1, chatContentLabelHeight+1);
        self.chatBgImageView.frame = CGRectMake(5+16, self.iconImageView.frame.origin.y+self.iconImageView.frame.size.height+5, chatContentLabelWidth+1>CHATCONTENTWIDTH ? CHATCONTENTWIDTH+BGIMAGEVIEWMARGIN:chatContentLabelWidth+21, chatContentLabelHeight+20);
        self.spLine.frame = CGRectMake(0, self.chatContentLabel.frame.origin.y+self.chatContentLabel.frame.size.height+15, MAINSCREENWIDTH, 0.5);
        
    } else {
        
        self.iconImageView.image=[UIImage imageNamed:@"rightimageview"];
        self.chatBgImageView.image=[UIImage imageNamed:@"liaotiankuangright"];
        
        self.iconImageView.frame = CGRectMake(MAINSCREENWIDTH-32-15, self.timeLabel.frame.origin.y+self.timeLabel.frame.size.height+15, 32, 31);
        self.chatContentLabel.frame = CGRectMake(MAINSCREENWIDTH-15-16-(chatContentLabelWidth+1>CHATCONTENTWIDTH ? CHATCONTENTWIDTH:chatContentLabelWidth+1), self.iconImageView.frame.origin.y+self.iconImageView.frame.size.height+15, chatContentLabelWidth+1>CHATCONTENTWIDTH ? CHATCONTENTWIDTH:chatContentLabelWidth+1, chatContentLabelHeight+1);
        self.chatBgImageView.frame = CGRectMake(MAINSCREENWIDTH-5-16-(chatContentLabelWidth+1>CHATCONTENTWIDTH ? CHATCONTENTWIDTH+BGIMAGEVIEWMARGIN:chatContentLabelWidth+21), self.iconImageView.frame.origin.y+self.iconImageView.frame.size.height+5, chatContentLabelWidth+1>CHATCONTENTWIDTH ? CHATCONTENTWIDTH+BGIMAGEVIEWMARGIN:chatContentLabelWidth+21, chatContentLabelHeight+20);
        self.spLine.frame = CGRectMake(0, self.chatContentLabel.frame.origin.y+self.chatContentLabel.frame.size.height+15, MAINSCREENWIDTH, 0.5);
        
    }
    
}

+ (CGFloat)cellHeightForModel:(NSString *)model {
    
    CGFloat chatContentLabelHeight = [model boundingRectWithSize:CGSizeMake(CHATCONTENTWIDTH, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.height;
    
    return chatContentLabelHeight+30+1+0.5+32+15+17+10;
    
}

#pragma mark -- label 添加点击和长按手势
- (void)labelAddGestAction {
    
    // 点按手势
    UITapGestureRecognizer *labelTapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapGest:)];
    labelTapGest.numberOfTapsRequired=1;
    [self.chatContentLabel addGestureRecognizer:labelTapGest];
    
    // 点按手势
    UITapGestureRecognizer *labelTapGest2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapGest2:)];
    labelTapGest.numberOfTapsRequired=2;
    [self.chatContentLabel addGestureRecognizer:labelTapGest2];
    
    // 长按手势
    UILongPressGestureRecognizer *labelLongPressGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(labelLongPressGest:)];
    labelLongPressGest.minimumPressDuration=0.5f;
    [self.chatContentLabel addGestureRecognizer:labelLongPressGest];
    
}

- (void)labelTapGest:(UITapGestureRecognizer *)tapGest {
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(labelTapGest:withLabel:)]) {
        [self.delegate labelTapGest:tapGest withLabel:self.chatContentLabel];
    }
    
}

- (void)labelTapGest2:(UITapGestureRecognizer *)tapGest {
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(labelTapGest2:withLabel:)]) {
        [self.delegate labelTapGest2:tapGest withLabel:self.chatContentLabel];
    }
    
}

- (void)labelLongPressGest:(UILongPressGestureRecognizer *)longPressGest {
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(labelLongPressGest:withLabel:)]) {
        [self.delegate labelLongPressGest:longPressGest withLabel:self.chatContentLabel];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
