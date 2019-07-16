//
//  ZBHInputAndButtonChoiceView.m
//  5i5jAPP
//
//  Created by 张倍浩 on 2019/7/4.
//  Copyright © 2019 NiLaisong. All rights reserved.
//

#import "ZBHInputAndButtonChoiceView.h"
#import <Masonry.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define FONT(s) [UIFont systemFontOfSize:s]

@interface ZBHInputAndButtonChoiceView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *leftBottomLineView;
@property (nonatomic, strong) UIView *rightBottomLineView;
@property (nonatomic, strong) UIView *centerLineView;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) NSArray *itemButtonArray;
@property (nonatomic, assign) ButtonChoiceType choiceType;
@property (nonatomic, assign) CGFloat maxItemWidth;
@property (nonatomic, strong) NSMutableArray *selectedButtonArray;
@property (nonatomic, strong, readwrite) UITextField *leftTextField;
@property (nonatomic, strong, readwrite) UITextField *rightTextField;

@end

@implementation ZBHInputAndButtonChoiceView

- (instancetype)initWithLeftButtonTitlte:(NSString *)leftButtonTitle rightButtonTitle:(NSString *)rightButtonTitle choiceType:(ButtonChoiceType)choiceType {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.choiceType = choiceType;
        self.layer.masksToBounds = YES;
        [self.leftButton setTitle:leftButtonTitle forState:UIControlStateNormal];
        [self.rightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
        self.itemButtonNormalBgColor = UIColorFromRGB(0xF7F7F7);
        self.itemButtonSelectedBgColor = [UIColorFromRGB(0xFFB000) colorWithAlphaComponent:0.2];
        self.itemButtonNormalTitleColor = UIColorFromRGB(0x292B33);
        self.itemButtonSelectedTitleColor = UIColorFromRGB(0xFFB000);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidBeginEditText:) name:UITextFieldTextDidBeginEditingNotification object:self.leftTextField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidBeginEditText:) name:UITextFieldTextDidBeginEditingNotification object:self.rightTextField];
        [self createUI];
    }
    return self;
}

- (void)textFieldDidBeginEditText:(NSNotification *)notification {
    NSLog(@"通知");
    for (UIButton *selectedButton in self.selectedButtonArray) {
        selectedButton.selected = NO;
        selectedButton.backgroundColor = self.itemButtonNormalBgColor;
    }
    [self.selectedButtonArray removeAllObjects];        
}

- (void)setSelecteItemIndexes:(NSArray<NSNumber *> *)indexes {
    [self reset];
    
    NSMutableArray *selectedButtonArray = [NSMutableArray arrayWithCapacity:self.itemArray.count];
    for (NSNumber *index in indexes) {
        if (index.unsignedIntegerValue > self.itemArray.count - 1) return;
        UIButton *itemButton = self.itemButtonArray[index.unsignedIntegerValue];
        itemButton.selected = YES;
        itemButton.backgroundColor = self.itemButtonSelectedBgColor;
        [selectedButtonArray addObject:itemButton];
    }
    self.selectedButtonArray = selectedButtonArray;
}

- (NSArray *)selectedItemArray {
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:self.selectedButtonArray.count];
    for (UIButton *selectedButton in self.selectedButtonArray) {
        if (selectedButton.currentTitle == nil) continue;
        NSUInteger index = [self.itemButtonArray indexOfObject:selectedButton];
        NSDictionary *dict = @{@"index": @(index), @"text": selectedButton.currentTitle};
        [mArray addObject:dict];
    }
    return [mArray copy];
}

- (void)createUI {
    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
}

- (void)setItemArray:(NSArray<NSString *> *)itemArray {
    _itemArray = itemArray;
    NSMutableArray *itemButtonArray = [NSMutableArray arrayWithCapacity:itemArray.count];
    CGFloat maxItemWidth = 0;
    for (NSString *item in itemArray) {
        CGFloat width = [item boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : FONT(12)} context:nil].size.width;
        maxItemWidth = width > maxItemWidth? width : maxItemWidth;
        
        UIButton *itemButton = [self createItemButtonWithTitle:item];
        [self addSubview:itemButton];
        [itemButtonArray addObject:itemButton];
    }
    
    self.maxItemWidth = ceilf(maxItemWidth);
    
    self.itemButtonArray = [itemButtonArray copy];
}

- (UIButton *)createItemButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = FONT(12);
    button.backgroundColor = self.itemButtonNormalBgColor;
    [button setTitleColor:self.itemButtonNormalTitleColor forState:UIControlStateNormal];
    [button setTitleColor:self.itemButtonSelectedTitleColor forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateNormal];
    button.layer.cornerRadius = 15;
    [button addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)reset {
    self.leftTextField.text = nil;
    self.rightTextField.text = nil;
    [self.leftTextField resignFirstResponder];
    [self.rightTextField resignFirstResponder];
    for (UIButton *selectedButton in self.selectedButtonArray) {
        selectedButton.selected = NO;
        selectedButton.backgroundColor = self.itemButtonNormalBgColor;
    }
    [self.selectedButtonArray removeAllObjects];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    _attributedTitle = attributedTitle;
    self.titleLabel.attributedText = attributedTitle;
}

- (void)rightClick {
    NSLog(@"确定");
    [self.leftTextField resignFirstResponder];
    [self.rightTextField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(inputAndButtonChoiceViewDidConfirm:)]) {
        [self.delegate inputAndButtonChoiceViewDidConfirm:self];
    }
}

- (void)leftClick {
    NSLog(@"清空条件");
    [self reset];
    if ([self.delegate respondsToSelector:@selector(inputAndButtonChoiceViewDidReset:)]) {
        [self.delegate inputAndButtonChoiceViewDidReset:self];
    }
}

- (void)itemClick:(UIButton *)button {
    self.leftTextField.text = nil;
    self.rightTextField.text = nil;
    [self.leftTextField resignFirstResponder];
    [self.rightTextField resignFirstResponder];
    button.selected = !button.selected;
    if (button.selected) {
        if (self.choiceType == ButtonChoiceSingle) { // 选中，单选情况
            [self reset];
            [self.selectedButtonArray addObject:button];
        } else { // 选中，多选情况
            if (![self.selectedButtonArray containsObject:button]) {
                [self.selectedButtonArray addObject:button];
            }
        }
        button.backgroundColor = self.itemButtonSelectedBgColor;
        button.selected = YES;
    } else { // 未选中
        button.backgroundColor = self.itemButtonNormalBgColor;
        if ([self.selectedButtonArray containsObject:button]) {
            [self.selectedButtonArray removeObject:button];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat firstTopMargin = 10.0f;
    
    if (self.attributedTitle && self.attributedTitle.length > 0) {
        if (!self.titleLabel.superview) {
            [self addSubview:self.titleLabel];
        }
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(23);
            make.top.equalTo(self).offset(firstTopMargin);
        }];
    }
    
    if (self.leftTextField.placeholder && self.rightTextField.placeholder)
        {            
            if (!self.leftTextField.superview) {
                [self addSubview:self.leftTextField];
            }
            if (!self.rightTextField.superview) {
                [self addSubview:self.rightTextField];
            }
            
            [self.leftTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(21);
                make.top.equalTo(self.titleLabel.mas_bottom).offset(32);
                make.size.sizeOffset(CGSizeMake((kMainScreenWidth - 21 * 2 - 37) / 2, 16));
            }];
            [self.rightTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-21);
                make.size.equalTo(self.leftTextField);
                make.top.equalTo(self.leftTextField);
            }];
            
            if (!self.leftBottomLineView.superview && !self.rightBottomLineView.superview) {
                [self addSubview:self.leftBottomLineView];
                [self addSubview:self.rightBottomLineView];
            }
            
            [self.leftBottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.leftTextField);
                make.top.equalTo(self.leftTextField.mas_bottom).offset(15);
                make.height.offset(0.5);
            }];
            [self.rightBottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.rightTextField);
                make.top.height.equalTo(self.leftBottomLineView);
            }];
            
            if (!self.centerLineView.superview) {
                [self addSubview:self.centerLineView];
            }
            [self.centerLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.leftTextField);
                make.left.equalTo(self.leftBottomLineView.mas_right).offset(15);
                make.right.equalTo(self.rightBottomLineView.mas_left).offset(-15);
                make.height.offset(1);
            }];
        }
    
    NSInteger count = self.itemButtonArray.count;
    CGFloat leftMargin = self.leftMargin > 0? self.leftMargin : 21.0f;
    CGFloat rightMargin = leftMargin;
    
    CGFloat lineSpace = self.lineSpace > 0? self.lineSpace : 10.0f;
    CGFloat width = (self.itemWidth > 0? self.itemWidth : self.maxItemWidth) + 14.0f;
    CGFloat height = 30.0f;
    NSInteger col;
    if (self.interitemSpacing > 0) {
        col = self.col > 0? self.col : ((kMainScreenWidth - leftMargin - rightMargin - self.interitemSpacing) / (width + self.interitemSpacing));
    } else {
        col = self.col > 0? self.col : ((kMainScreenWidth - leftMargin - rightMargin) / width);
    }
    CGFloat interitemSpacing = self.interitemSpacing > 0? self.interitemSpacing : ((kMainScreenWidth - leftMargin - rightMargin - (col * width)) / (col - 1));
    
    CGFloat minInteritemSpacing = 5;
    if (interitemSpacing < minInteritemSpacing) {
        col = col - 1;
        interitemSpacing = self.interitemSpacing > 0? self.interitemSpacing : ((kMainScreenWidth - leftMargin - rightMargin - (col * width)) / (col - 1));
    }
    
    CGFloat itemButtonFirstTopMargin = self.leftTextField.superview? 24 : firstTopMargin;
    for (int i = 0; i < count; i++) {
        UIButton *itemButton = self.itemButtonArray[i];
        [itemButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.sizeOffset(CGSizeMake(width, 30));
            CGFloat topDistance = itemButtonFirstTopMargin + (height + lineSpace) * (i / col);
            CGFloat leftDistance = leftMargin + (width + interitemSpacing) * (i % col);
            if (self.leftTextField.superview) {
                make.top.equalTo(self.leftBottomLineView.mas_bottom).offset(topDistance);
            } else {
                make.top.equalTo(self).offset(topDistance);
            }
            make.left.equalTo(self).offset(leftDistance);
        }];
    }
    
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(21);
        make.bottom.equalTo(self).offset(-18);
        make.size.sizeOffset(CGSizeMake((kMainScreenWidth - 21 * 3) / 2, 37));
    }];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-21);
        make.bottom.equalTo(self.leftButton);
        make.size.equalTo(self.leftButton);
    }];
    
    NSUInteger lines = count / col;
    if (count % col > 0) {
        lines += 1;
    }
    if (self.leftTextField.superview) {
        self.height = firstTopMargin + 74 + itemButtonFirstTopMargin + height * lines + lineSpace * (lines - 1) + 79.0f;
    } else {
        self.height = firstTopMargin + height * lines + lineSpace * (lines - 1) + 79.0f;
    }
}

- (CGFloat)totalHeight {
    [self.superview setNeedsLayout];
    return self.height;
}

- (BOOL)isEmpty {
    if (self.leftTextField.superview) {
        return (self.leftTextField.text.length == 0 && self.rightTextField.text.length == 0 && self.selectedButtonArray.count == 0);
    } else {
        return self.selectedButtonArray.count == 0;
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UITextField *)leftTextField {
    if (!_leftTextField) {
        _leftTextField = [[UITextField alloc] init];
        _leftTextField.textAlignment = NSTextAlignmentCenter;
        _leftTextField.keyboardType = UIKeyboardTypeNumberPad;
        _leftTextField.font = FONT(14);
    }
    return _leftTextField;
}

- (UITextField *)rightTextField {
    if (!_rightTextField) {
        _rightTextField = [[UITextField alloc] init];
        _rightTextField.textAlignment = NSTextAlignmentCenter;
        _rightTextField.keyboardType = UIKeyboardTypeNumberPad;
        _rightTextField.font = FONT(14);
    }
    return _rightTextField;
}

- (UIView *)leftBottomLineView {
    if (!_leftBottomLineView) {
        _leftBottomLineView = [[UIView alloc] init];
        _leftBottomLineView.backgroundColor = UIColorFromRGB(0xEEEEEE);
    }
    return _leftBottomLineView;
}

- (UIView *)rightBottomLineView {
    if (!_rightBottomLineView) {
        _rightBottomLineView = [[UIView alloc] init];
        _rightBottomLineView.backgroundColor = UIColorFromRGB(0xEEEEEE);
    }
    return _rightBottomLineView;
}

- (UIView *)centerLineView {
    if (!_centerLineView) {
        _centerLineView = [[UIView alloc] init];
        _centerLineView.backgroundColor = UIColorFromRGB(0xBABABA);
    }
    return _centerLineView;
}

- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [[UIButton alloc] init];
        [_leftButton setTitleColor:UIColorFromRGB(0x292B33) forState:UIControlStateNormal];
        _leftButton.titleLabel.font = FONT(15);
        [_leftButton addTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
        _leftButton.backgroundColor = UIColorFromRGB(0xF7F7F7);
        _leftButton.layer.cornerRadius = 8;
        _leftButton.layer.masksToBounds = YES;
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] init];
        [_rightButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        _rightButton.titleLabel.font = FONT(15);
        [_rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
        CAGradientLayer *gl = [CAGradientLayer layer];
        CGFloat width = (kMainScreenWidth - 21 * 3) / 2;
        CGFloat height = 37;
        gl.frame = CGRectMake(0,0,width,height);
        gl.startPoint = CGPointMake(0, 0);
        gl.endPoint = CGPointMake(1, 1);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:195/255.0 blue:14/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:255/255.0 green:173/255.0 blue:0/255.0 alpha:1.0].CGColor];
        gl.locations = @[@(0.0),@(1.0)];        
        [_rightButton.layer insertSublayer:gl atIndex:0];
        _rightButton.layer.cornerRadius = 8;
        _rightButton.layer.masksToBounds = YES;
    }
    return _rightButton;
}

- (NSMutableArray *)selectedButtonArray {
    if (!_selectedButtonArray) {
        _selectedButtonArray = [NSMutableArray array];
    }
    return _selectedButtonArray;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:self.leftTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:self.rightTextField];
}

@end
