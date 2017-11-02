//
//  ViewController.m
//  weChatDemoRongCloud
//
//  Created by iOS on 2017/10/31.
//  Copyright © 2017年 iOS. All rights reserved.
//

#import "ViewController.h"

#import "WeChatTableViewCell.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, WeChatTableViewCellDelegate, UIWebViewDelegate>

/**
 聊天表
 */
@property (nonatomic, strong) UITableView *weChatTableView;
/**
 数据模型
 */
@property (nonatomic, strong) NSMutableArray *chatContentArr;
/**
 聊天底部视图
 */
@property (nonatomic, strong) UIView *chatBottomView;
/**
 聊天输入框
 */
@property (nonatomic, strong) UITextView *chatTextView;
/**
  用于记录键盘的高度
 */
@property (nonatomic, assign) CGFloat keyboardHeight;
/**
  底部视图 Y
 */
@property (nonatomic, assign) CGFloat chatBottomViewY;
/**
 底部视图 高度
 */
@property (nonatomic, assign) CGFloat chatBottomViewHeignt;
/**
  记录长按或者点按下的文字信息
 */
@property (nonatomic, copy) NSString *chatContentStr;
/**
 记录选中的 label
 */
@property (nonatomic, strong) UILabel *selectChatLabel;
/**
 连续点击两下弹窗
 */
@property (nonatomic, strong) UIView *alertView;
/**
 弹窗上展示文字 label
 */
@property (nonatomic, strong) UILabel *showLabel;

@end

@implementation ViewController

- (instancetype)init {
    
    if (self = [super init]) {
        //键盘通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ChatViewController";
    
    self.chatBottomViewHeignt = 52;
    [self createTableView];
    [self.view addSubview:self.chatBottomView];
    [self.chatBottomView addSubview:self.chatTextView];
    
}

#pragma mark -- textViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView.text.length > 200) { // 限制输入字数
        textView.text = [textView.text substringToIndex:200];
    }
    
    // 自适应高度
    CGSize sizeThatShouldFitTheContent = [textView sizeThatFits:textView.frame.size];
    CGRect rect = textView.frame;
    rect.size.height = sizeThatShouldFitTheContent.height>100?100:sizeThatShouldFitTheContent.height;
    textView.textContainer.size = CGSizeMake(TEXTVIEWWIDTH, sizeThatShouldFitTheContent.height);
    textView.frame = rect;

    CGRect rectView = _chatBottomView.frame;
    rectView.origin.y = MAINSCREENHEIGHT-self.keyboardHeight-18-(sizeThatShouldFitTheContent.height>100?100:sizeThatShouldFitTheContent.height);
    rectView.size.height = 18+(sizeThatShouldFitTheContent.height>100?100:sizeThatShouldFitTheContent.height);
    _chatBottomView.frame = rectView;
    self.chatBottomViewHeignt = 18+(sizeThatShouldFitTheContent.height>100?100:sizeThatShouldFitTheContent.height);
    CGRect rectTableView = _weChatTableView.frame;
    rectTableView.size.height = MAINSCREENHEIGHT-self.keyboardHeight-self.chatBottomViewHeignt-IPHONEX_MARGIN_TOP;
    _weChatTableView.frame = rectTableView;
    [self tableSelectLastCell];
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        if ([textView.text length]>0) {
            [_chatContentArr addObject:textView.text];
            [_weChatTableView reloadData];
            [self tableSelectLastCell];
            _chatTextView.text = @"";
            [self textViewDidChange:textView];
        }
        return NO;
    }
    return YES;
}
#pragma mark -- 创建聊天表格
- (void)createTableView {
    
    self.weChatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPHONEX_MARGIN_TOP, MAINSCREENWIDTH, MAINSCREENHEIGHT-IPHONEX_MARGIN_TOP-self.chatBottomView.frame.size.height) style:UITableViewStylePlain];
    [self.view addSubview:self.weChatTableView];
    
    if (@available(iOS 11.0, *)) {
        self.weChatTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;//UIScrollView也适用
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.weChatTableView.delegate=self;
    self.weChatTableView.dataSource=self;
    self.weChatTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self tableSelectLastCell];
    
}

#pragma mark -- WeChatTableViewCellDelegate
- (void)labelTapGest:(UITapGestureRecognizer *)tapGest withLabel:(UILabel *)label {
    [self doubleClickAlertViewWithStr:label.text];
}
- (void)labelTapGest2:(UITapGestureRecognizer *)tapGest withLabel:(UILabel *)label {
    [self urlLabeltapGest:tapGest withLabel:label];
}
- (void)labelLongPressGest:(UILongPressGestureRecognizer *)longPressGest withLabel:(UILabel *)label {
    [self urlLabelLongPressGest:longPressGest withLabel:label];
}
- (void)urlLabelLongPressGest:(UILongPressGestureRecognizer *)longGest withLabel:(UILabel *)label {
    
    self.chatContentStr = label.text;
    self.selectChatLabel = label;
    [label becomeFirstResponder]; // 用于UIMenuController显示，缺一不可
    if (longGest.state==UIGestureRecognizerStateBegan) {
        label.backgroundColor = [UIColor lightGrayColor];
    }
    //UIMenuController：可以通过这个类实现点击内容，或者长按内容时展示出复制等选择的项，每个选项都是一个UIMenuItem对象
    UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copy:)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyLink, nil]];
    [[UIMenuController sharedMenuController] setTargetRect:label.frame inView:label.superview];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    
}
#pragma mark -- 网址点击跳转
- (void)urlLabeltapGest:(UITapGestureRecognizer *)tapGest withLabel:(UILabel *)label {
    NSError *error;
    NSDataDetector *dataDetector=[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *arrayOfAllMatches=[dataDetector matchesInString:label.text options:NSMatchingReportProgress range:NSMakeRange(0, label.text.length)];
    if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=10.0f) {
        
    }
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString *url_str = [label.text substringWithRange:match.range];
        NSString *url_suffix = [url_str substringToIndex:4];
        NSURL *url;
        if (![url_suffix isEqualToString:@"http"]) {
            url = [[ NSURL alloc ] initWithString:[NSString stringWithFormat:@"https://%@",[label.text substringWithRange:match.range]]];
        } else {
            url = [[ NSURL alloc ] initWithString:url_str];
        }
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=10.0f) {
            
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                
                [[UIApplication sharedApplication] openURL:url options:[NSMutableDictionary dictionary] completionHandler:^(BOOL success) {
                    
                }];
                
            } else {
                
            }
        } else {
            
            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            webView.delegate = self;
            [webView loadRequest:request];
            [self.view addSubview:webView];
            
        }
        
    }
    
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}
// 可以控制响应的方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:));
}
//针对响应方法的实现，最主要的复制的两句代码
- (void)copy:(id)sender{
    //UIPasteboard：该类支持写入和读取数据，类似剪贴板
    //    NSError *error;
    //    NSDataDetector *dataDetector=[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    //    NSArray *arrayOfAllMatches=[dataDetector matchesInString:self.onLineUrl.text options:NSMatchingReportProgress range:NSMakeRange(0, self.onLineUrl.text.length)];
    
    //    for (NSTextCheckingResult *match in arrayOfAllMatches)
    //    {
    //        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    //        pasteBoard.string = [self.onLineUrl.text substringWithRange:match.range];
    //    }
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = self.chatContentStr;
    self.selectChatLabel.backgroundColor = [UIColor clearColor];
    
}
#pragma mark -- delegate===dataSorce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatContentArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WeChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weChatTableViewCellId"];
    if (!cell) {
        cell = [[WeChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"weChatTableViewCellId"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.delegate=self;
    }
   
    cell.chatContentLabel.tag=indexPath.row;
    chatModel *model = self.chatContentArr[indexPath.row];
    cell.model=model;
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *model = self.chatContentArr[indexPath.row];
    return [WeChatTableViewCell cellHeightForModel:model];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_chatTextView resignFirstResponder];
    self.selectChatLabel.backgroundColor = [UIColor clearColor];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.selectChatLabel.backgroundColor = [UIColor clearColor];
}

#pragma mark -- layzload
- (NSMutableArray *)chatContentArr {
    if (!_chatContentArr) {
        _chatContentArr = [[NSMutableArray alloc] initWithObjects:
                           @"开始",
                           @"李达康医生？",
                           @"是的，请问你怎么啦",
                           @"我拉肚子了，好久了，都没好",
                           @"建议到正规医院就诊，可能是肠胃炎。后果很严重",
                           @"你这医生怎么诅咒别人呢？",
                           @"谁诅咒你了？说话，注意点，会被监控的，明白吗？",
                           @"你好！我想问一下，没吃饭能体检吗",
                           @"没吃饭？体检？找死？",
                           @"能好好说话吗？",
                           @"my world is a update my world is a update my world is a update my world is a update my world is a update ",
                           @"my world is a update ",
                           @"my world is a update my world is a update my world is a update my world is a update my world is a update ",
                           @"别问这么弱智的问题OK？",
                           @"不想在平台混了？",
                           @"大不了走呗？",
                           @"还对付不了你这种人？",
                           @"www.baidu.com",
                           @"结束",nil];
    }
    return _chatContentArr;
}

- (UIView *)chatBottomView {
    if (!_chatBottomView) {
        _chatBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MAINSCREENHEIGHT-self.chatBottomViewHeignt, MAINSCREENWIDTH, self.chatBottomViewHeignt)];
        _chatBottomView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    }
    return _chatBottomView;
}

- (UITextView *)chatTextView {
    if (!_chatTextView) {
        NSTextStorage* textStorage = [[NSTextStorage alloc] init];
        NSLayoutManager* layoutManager = [NSLayoutManager new];
        [textStorage addLayoutManager:layoutManager];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(TEXTVIEWWIDTH, self.chatBottomViewHeignt-18)];
        textContainer.widthTracksTextView = YES;
        textContainer.heightTracksTextView = YES;
        [layoutManager addTextContainer:textContainer];
        _chatTextView = [[UITextView alloc] initWithFrame:CGRectMake(30, 9, TEXTVIEWWIDTH, 34) textContainer:textContainer];
        _chatTextView.delegate=self;
        _chatTextView.font = [UIFont systemFontOfSize:15];
        _chatTextView.returnKeyType=UIReturnKeySend;
        _chatTextView.layer.masksToBounds=YES;
        _chatTextView.layer.cornerRadius=2.0f;
        _chatTextView.layer.borderWidth=0.5f;
        _chatTextView.layer.borderColor=[UIColor greenColor].CGColor;
    }
    return _chatTextView;
}

#pragma mark - KeyBoard Notification
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardHeight = kbSize.height;
    _chatBottomView.frame = CGRectMake(0, MAINSCREENHEIGHT-self.chatBottomViewHeignt-kbSize.height, MAINSCREENWIDTH, self.chatBottomViewHeignt);
    CGRect rect = _weChatTableView.frame;
    rect.size.height = MAINSCREENHEIGHT-kbSize.height-self.chatBottomViewHeignt-IPHONEX_MARGIN_TOP;
    _weChatTableView.frame = rect;
    [self tableSelectLastCell];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    _chatBottomView.frame = CGRectMake(0, MAINSCREENHEIGHT-self.chatBottomViewHeignt, MAINSCREENWIDTH, self.chatBottomViewHeignt);
    CGRect rect = _weChatTableView.frame;
    rect.size.height = MAINSCREENHEIGHT-self.chatBottomViewHeignt-IPHONEX_MARGIN_TOP;
    _weChatTableView.frame = rect;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_chatTextView resignFirstResponder];
    self.selectChatLabel.backgroundColor = [UIColor clearColor];
}

#pragma mark -- tableView 选中最后一个 cell 的方法
- (void)tableSelectLastCell {
    [self.weChatTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatContentArr.count-1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

#pragma mark -- 双击弹窗
- (void)doubleClickAlertViewWithStr:(NSString *)str {
    
    CGFloat chatContentLabelHeight = [str boundingRectWithSize:CGSizeMake(MAINSCREENWIDTH-60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:22]} context:nil].size.height;
    CGFloat chatContentLabelWidth = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, 17) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:22]} context:nil].size.width;

    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAINSCREENWIDTH, MAINSCREENHEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:self.alertView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAINSCREENWIDTH, MAINSCREENHEIGHT)];
    [self.alertView addSubview:view];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    view.userInteractionEnabled=YES;
    UITapGestureRecognizer *viewTapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapGest)];
    [view addGestureRecognizer:viewTapGest];
    
    UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, (MAINSCREENHEIGHT-chatContentLabelHeight)/2, MAINSCREENWIDTH-60, chatContentLabelHeight+1)];
    [self.alertView addSubview:showLabel];
    showLabel.numberOfLines=0;
    showLabel.text = str;
    if (chatContentLabelWidth+1>MAINSCREENWIDTH-60) {
        showLabel.textAlignment=NSTextAlignmentLeft;
    } else {
        showLabel.textAlignment=NSTextAlignmentCenter;
    }
    showLabel.font = [UIFont boldSystemFontOfSize:22];
    
    showLabel.userInteractionEnabled=YES;
    UILongPressGestureRecognizer *showLabelLongPressGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showLabelLongPressGest:)];
    [showLabel addGestureRecognizer:showLabelLongPressGest];
    self.showLabel = showLabel;
    
}

- (void)viewTapGest {
    [self.alertView removeFromSuperview];
}

- (void)showLabelLongPressGest:(UILongPressGestureRecognizer *)longPressGest {
    [self urlLabelLongPressGest:longPressGest withLabel:self.showLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
