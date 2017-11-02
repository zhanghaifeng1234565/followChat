//
//  WeChatTableViewCell.h
//  weChatDemoRongCloud
//
//  Created by iOS on 2017/10/31.
//  Copyright © 2017年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chatModel.h"

#define MAINSCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define MAINSCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define iPhoneX ([UIScreen mainScreen].bounds.size.width == 375 && [UIScreen mainScreen].bounds.size.height == 812)
#define IPHONEX_MARGIN_TOP       (iPhoneX ? 88:64)
#define IPHONEX_MARGIN_BOTTOM    (iPhoneX ? 83:49)
#define IPHONEX_MARGIN_STATUS       (iPhoneX ? 44:20)
#define CHATCONTENTWIDTH MAINSCREENWIDTH/4*3
#define BGIMAGEVIEWMARGIN 20
#define TEXTVIEWWIDTH MAINSCREENWIDTH-100


@protocol WeChatTableViewCellDelegate <NSObject>

/** label 点击调用 */
- (void)labelTapGest:(UITapGestureRecognizer *)tapGest withLabel:(UILabel *)label;
- (void)labelTapGest2:(UITapGestureRecognizer *)tapGest withLabel:(UILabel *)label;
/** label 长按调用 */
- (void)labelLongPressGest:(UILongPressGestureRecognizer *)longPressGest withLabel:(UILabel *)label;

@end

@interface WeChatTableViewCell : UITableViewCell<UIGestureRecognizerDelegate,UIWebViewDelegate>

/**
 时间标签
 */
@property (nonatomic, strong) UILabel *timeLabel;
/**
 聊天人的头像
 */
@property (nonatomic, strong) UIImageView *iconImageView;
/**
 聊天背景图片
 */
@property (nonatomic, strong) UIImageView *chatBgImageView;
/**
  聊天内容标签
 */
@property (nonatomic, strong) UILabel *chatContentLabel;
/**
 分割线
 */
@property (nonatomic, strong) UILabel *spLine;

@property (nonatomic, strong) chatModel *model;

@property (nonatomic, weak) id <WeChatTableViewCellDelegate> delegate;

/**
 cell 行高计算

 @param model 要计算文字的内容
 @return  cell 行高
 */
+ (CGFloat)cellHeightForModel:(NSString *)model;

@end
