//
//  ZBHSiftBarView.m
//  筛选条
//
//  Created by 张倍浩 on 2019/5/31.
//  Copyright © 2019 张倍浩. All rights reserved.
//

#import "ZBHSiftBarView.h"
#import "ZBHSiftContainerViewDelegate.h"

#define kTextColor [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0]
#define kBottomLineColor [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0]

NSString * const ContainerViewKey = @"containerView";
NSString * const ContainerViewFrameKey = @"containerViewFrame";
NSString * const ContainerDataKey = @"ContainerData";

@interface ZBHSiftBarView ()

@property (nonatomic, strong) NSArray *itemTitles;
@property (nonatomic, strong) NSArray *titleButtonArray;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UIControl *canvasControl;
@property (nonatomic, strong) NSMutableDictionary *containerViewDict; // key是@(index)，value是一个字典
@property (nonatomic, assign) NSInteger previousIndex;
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation ZBHSiftBarView

- (instancetype)initWithFrame:(CGRect)frame itemTitles:(NSArray<NSString *> *)itemTitles {
    if (self = [super initWithFrame:frame]) {
        self.itemTitles = itemTitles;
        self.previousIndex = -1;
        self.selectIndex = -1;
        self.normalTitleColor = kTextColor;
        self.selectTitleColor = [UIColor blackColor];
        [self createUI];
    }
    return self;
}

- (NSDictionary<NSNumber *,id> *)containerDatas {
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    for (NSNumber *indexNum in self.containerViewDict.allKeys) {
        NSDictionary *dict = self.containerViewDict[indexNum];
        if (dict && dict[ContainerDataKey] != nil) {
            [mDict setObject:dict[ContainerDataKey] forKey:indexNum];
        }
    }
    return [mDict copy];
}

- (void)reset {
    for (int i = 0; i < self.itemTitles.count; i++) {
        UIButton *button = self.titleButtonArray[i];
        button.selected = NO;
        [self configNormalStateWithButton:button];
        [button setTitle:self.itemTitles[i] forState:UIControlStateNormal];
        [self updateButtonEdgeInsetsWithButton:button];
        button.imageView.transform = CGAffineTransformIdentity;
        NSMutableDictionary *dict = [self.containerViewDict[@(i)] mutableCopy];
        if (dict) {
            dict[ContainerDataKey] = nil;
        }
        self.containerViewDict[@(i)] = dict;
        id<CBSSiftContainerViewDelegate> containerView = dict[ContainerViewKey];
        if ([containerView respondsToSelector:@selector(resetState)]) {
            [containerView resetState];
        }        
    }
}

- (void)buttonClick:(UIButton *)button {
    [self configSelectStateWithButton:button];
    NSInteger index = [self.titleButtonArray indexOfObject:button];
    
    
    if ([self.dataSource respondsToSelector:@selector(siftBarView:containerViewForItemAtIndex:)]) {
        UIView<ZBHSiftContainerViewDelegate> *containerView = [self.dataSource siftBarView:self containerViewForItemAtIndex:index];
        if (!containerView) {
            [self hide];
            return;
        }
        self.selectIndex = index;
        __weak typeof(self) weakSelf = self;
        __weak typeof(containerView) weakContainerView = containerView;
        if ([containerView respondsToSelector:@selector(siftContainerViewWithConfirm:)]) {
            [containerView siftContainerViewWithConfirm:^(NSString *showText, id otherData) { // 确定
                __strong typeof(weakSelf) strongSelf = weakSelf;
                __strong typeof(weakContainerView) strongContainerView = weakContainerView;
                if (!showText || showText.length == 0) {
                    [button setTitle:strongSelf.itemTitles[index] forState:UIControlStateNormal];
                } else {
                    [button setTitle:showText forState:UIControlStateNormal];
                }
                
                NSMutableDictionary *dict = [strongSelf.containerViewDict[@(index)] mutableCopy];
                if (dict) {
                    dict[ContainerDataKey] = otherData;
                    dict[ContainerViewKey] = strongContainerView;
                }
                strongSelf.containerViewDict[@(index)] = dict;
                
                [strongSelf updateButtonStateWithIndex:index];
                [strongSelf updateButtonEdgeInsetsWithButton:button];
                
                [strongSelf hide];
                if ([strongSelf.delegate respondsToSelector:@selector(siftBarView:didConfirmContainerViewForItemAtIndex:)]) {
                    [strongSelf.delegate siftBarView:strongSelf didConfirmContainerViewForItemAtIndex:index];
                }
            }];
        }
        if ([containerView respondsToSelector:@selector(siftContainerViewWithReset:)]) {
            [containerView siftContainerViewWithReset:^{ // 重置
                __strong typeof(weakSelf) strongSelf = weakSelf;
                __strong typeof(weakContainerView) strongContainerView = weakContainerView;
                [button setTitle:strongSelf.itemTitles[index] forState:UIControlStateNormal];
                
                NSMutableDictionary *dict = [strongSelf.containerViewDict[@(index)] mutableCopy];
                if (dict) {
                    dict[ContainerDataKey] = nil;
                    dict[ContainerViewKey] = strongContainerView;
                }
                strongSelf.containerViewDict[@(index)] = dict;
                [strongSelf updateButtonEdgeInsetsWithButton:button];
              if ([strongSelf.delegate respondsToSelector:@selector(siftBarView:didResetConfirmContainerViewForItemAtIndex:)]) {
                [strongSelf.delegate siftBarView:strongSelf didResetConfirmContainerViewForItemAtIndex:index];
              }
            }];
        }
        if (containerView.frame.size.height > 0) {
            containerView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
            containerView.layer.masksToBounds = YES;
            
            NSDictionary *itemDict = self.containerViewDict[@(index)];
            if (!itemDict) {
                [self.containerViewDict setObject:@{ContainerViewKey: containerView, ContainerViewFrameKey: NSStringFromCGRect(containerView.frame)} forKey:@(index)];
            } else {
                id data = itemDict[ContainerDataKey];
                if (data) {
                    [self.containerViewDict setObject:@{ContainerViewKey: containerView, ContainerViewFrameKey: NSStringFromCGRect(containerView.frame), ContainerDataKey: data} forKey:@(index)];
                }
            }
        }
        if (![self.canvasControl.subviews containsObject:containerView]) {
            [self.canvasControl addSubview:containerView];
            CGRect newFrame = containerView.frame;
            newFrame.size.height = 0;
            containerView.frame = newFrame;
        }
        
        if (self.previousIndex == -1) {
            [self showViewWithIndex:self.selectIndex completion:nil];
        } else {
            NSDictionary *previousContainerDict = self.containerViewDict[@(self.previousIndex)];
            UIView *previousView = previousContainerDict[ContainerViewKey];
            if (self.previousIndex != index) {
                if (previousView.frame.size.height > 0) {
                    [self hideViewWithIndex:self.previousIndex hideCanvas:NO completion:^(BOOL isFinished) {
                        [self showViewWithIndex:self.selectIndex completion:nil];
                    }];
                } else {
                    [self showViewWithIndex:self.selectIndex completion:nil];
                }
            } else { // self.previousIndex == index
                if (previousView.frame.size.height > 0) {
                    [self hideViewWithIndex:index hideCanvas:YES completion:nil];
                } else {
                    [self showViewWithIndex:index completion:nil];
                }
            }
        }
        
        self.previousIndex = index;
    }
}

- (void)canvasClick:(UIControl *)control {
    [self hide];
}

- (void)showViewWithIndex:(NSInteger)index completion:(void(^)(BOOL isFinished))completion {
    if (index == -1) return;
    UIView *view = self.containerViewDict[@(index)][ContainerViewKey];
    CGRect initFrame = view.frame;
    initFrame.size.height = 0;
    view.frame = initFrame;
    NSString *frameStr = self.containerViewDict[@(index)][ContainerViewFrameKey];
    
    [UIView animateWithDuration:0.15 animations:^{
        UIButton *button = self.titleButtonArray[index];
        button.imageView.transform = CGAffineTransformIdentity;
        self.canvasControl.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            view.frame = CGRectFromString(frameStr);
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }];
}

- (void)hideViewWithIndex:(NSInteger)index hideCanvas:(BOOL)hideCanvas completion:(void(^)(BOOL isFinished))completion {
    if (index == -1) return;
    
    UIButton *hiddenButton = self.titleButtonArray[index];
    
    UIView<ZBHSiftContainerViewDelegate> *view = self.containerViewDict[@(index)][ContainerViewKey];
    
    // 防止view的高度更新后，展开时返回旧的高度值
    NSString *oldFrameStr = self.containerViewDict[@(index)][ContainerViewFrameKey];
    CGRect oldFrame = CGRectFromString(oldFrameStr);
    CGSize size = oldFrame.size;
    size.height = view.frame.size.height;
    oldFrame.size = size;
    NSString *newFrameStr = NSStringFromCGRect(oldFrame);
    NSMutableDictionary *dict = [self.containerViewDict[@(index)] mutableCopy];
    [dict setObject:newFrameStr forKey:ContainerViewFrameKey];
    self.containerViewDict[@(index)] = [dict copy];
    
    [UIView animateWithDuration:0.15 animations:^{
        CGRect frame = view.frame;
        frame.size.height = 0;
        view.frame = frame;
        
        [self updateButtonStateWithIndex:index];
        if ([self haveContainerViewDataWithIndex:index]) {
            hiddenButton.imageView.transform =  CGAffineTransformMakeRotation(M_PI);
        } else {
            hiddenButton.imageView.transform = CGAffineTransformIdentity;
        }
        
    } completion:^(BOOL finished) {
        if ([view respondsToSelector:@selector(restoreState)]) {
            [view restoreState];
        }
        if (hideCanvas) {
            [UIView animateWithDuration:0.15 animations:^{
                self.canvasControl.alpha = 0.0;
                if (completion) {
                    completion(finished);
                }
            }];
        } else {
            self.canvasControl.alpha = 1.0;
            if (completion) {
                completion(finished);
            }
        }
    }];
}

- (void)updateButtonStateWithIndex:(NSInteger)index {
    UIButton *button = self.titleButtonArray[index];
    BOOL hasData = [self haveContainerViewDataWithIndex:index];
    if (hasData) {
        [self configSelectStateWithButton:button];
    } else {
        [self configNormalStateWithButton:button];
    }
}

- (void)configSelectStateWithButton:(UIButton *)button {
    [button setTitleColor:self.selectTitleColor forState:UIControlStateNormal];
    [button setImage:self.indicatorSelectImage forState:UIControlStateNormal];
}

- (void)configNormalStateWithButton:(UIButton *)button {
    [button setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
    [button setImage:self.indicatorNormalImage forState:UIControlStateNormal];
}

- (BOOL)haveContainerViewDataWithIndex:(NSInteger)index {
    if (index == -1) return NO;
    NSDictionary *dict = self.containerViewDict[@(index)];
    return dict[ContainerDataKey] != nil;
}

- (void)hide {
    [self hideViewWithIndex:self.selectIndex hideCanvas:YES completion:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIButton *button in self.titleButtonArray) {
        [button setImage:self.indicatorNormalImage forState:UIControlStateNormal];
        if (self.fontSize) {
            button.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
        }
        [self configNormalStateWithButton:button];
        [self updateButtonEdgeInsetsWithButton:button];
    }
}

- (void)createUI {
    CGSize buttonSize = CGSizeMake(self.frame.size.width / self.itemTitles.count, self.frame.size.height);
    CGFloat originX = 0.0;
    NSMutableArray *tempTitleButtonArray = [NSMutableArray arrayWithCapacity:self.itemTitles.count];
    for (int i = 0; i < self.itemTitles.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(originX, 0, buttonSize.width, buttonSize.height);
        originX = CGRectGetMaxX(button.frame);
        [self configNormalStateWithButton:button];
        [button setTitle:self.itemTitles[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [tempTitleButtonArray addObject:button];
    }
    self.titleButtonArray = [tempTitleButtonArray copy];
    
    [self addSubview:self.bottomLineView];
}

- (void)updateButtonEdgeInsetsWithButton:(UIButton *)button {
    // 防止button.titleLabel获取到的size为0的情况
    [button setNeedsLayout];
    [button layoutIfNeeded];
    
    CGFloat titleLabelWidth = button.titleLabel.frame.size.width;
    CGFloat space = 4;
    CGFloat imageWidth = button.currentImage.size.width;
    // 系统默认：图片在左，文字在右
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth + space / 2), 0, imageWidth + space / 2);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, titleLabelWidth + space / 2, 0, -(titleLabelWidth + space / 2));
    if (CGRectGetMaxX(button.imageView.frame) > button.frame.size.width) { // 说明超出边界了
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, titleLabelWidth, 0, -titleLabelWidth);
    }
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = kBottomLineColor;
        _bottomLineView.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
    }
    return _bottomLineView;
}

- (UIControl *)canvasControl {
    if (!_canvasControl) {
        _canvasControl = [[UIControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.frame), self.frame.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(self.frame))];
        [self.superview addSubview:_canvasControl];
        _canvasControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        [_canvasControl addTarget:self action:@selector(canvasClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _canvasControl;
}

- (NSMutableDictionary *)containerViewDict {
    if (!_containerViewDict) {
        _containerViewDict = [NSMutableDictionary dictionaryWithCapacity:self.itemTitles.count];
    }
    return _containerViewDict;
}

- (void)dealloc {
  NSLog(@"siftBarView 已释放");
}

@end
