//
//  ZBHInputAndButtonChoiceView.h
//  5i5jAPP
//
//  Created by 张倍浩 on 2019/7/4.
//  Copyright © 2019 NiLaisong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZBHInputAndButtonChoiceView;

@protocol ZBHInputAndButtonChoiceViewDelegate <NSObject>

@optional
- (void)inputAndButtonChoiceViewDidReset:(ZBHInputAndButtonChoiceView *)inputAndButtonChoiceView;
- (void)inputAndButtonChoiceViewDidConfirm:(ZBHInputAndButtonChoiceView *)inputAndButtonChoiceView;

@end

@interface ZBHInputAndButtonChoiceView : UIView

/// 按钮单选还是多选
typedef NS_ENUM(NSInteger, ButtonChoiceType) {
    /// 单选
    ButtonChoiceSingle,
    /// 多选
    ButtonChoiceMultiple
};

- (instancetype)initWithLeftButtonTitlte:(NSString *)leftButtonTitle rightButtonTitle:(NSString *)rightButtonTitle choiceType:(ButtonChoiceType)choiceType;

@property (nonatomic, strong) NSArray<NSString *> *itemArray;
@property (nonatomic, copy) NSAttributedString *attributedTitle;
@property (nonatomic, weak) id <ZBHInputAndButtonChoiceViewDelegate> delegate;

/**
 示例如下：
 @[
 @{@"index": @(0), @"text": @"test_item"},
 @{@"index": @(1), @"text": @"test_item1"}
 ]
 */
@property (nonatomic, strong, readonly) NSArray<NSDictionary *> *selectedItemArray;
@property (nonatomic, assign, readonly) CGFloat totalHeight;
@property (nonatomic, assign, readonly) BOOL isEmpty;

- (void)setSelecteItemIndexes:(NSArray<NSNumber *> *)indexes;
- (void)reset;

/// 如果两个textField的placeholder为nil，就不显示输入框
@property (nonatomic, strong, readonly) UITextField *leftTextField;
@property (nonatomic, strong, readonly) UITextField *rightTextField;


////////////////////////////// 按钮颜色相关（均有默认值） //////////////////////////////
@property (nonatomic, strong) UIColor *itemButtonNormalTitleColor;
@property (nonatomic, strong) UIColor *itemButtonSelectedTitleColor;
@property (nonatomic, strong) UIColor *itemButtonNormalBgColor;
@property (nonatomic, strong) UIColor *itemButtonSelectedBgColor;


////////////////////////////// 按钮排列布局相关（均有默认值，当设置的参数导致按钮重叠时，会自动调整分布） //////////////////////////////
/// 如果不设置，根据 itemArray 中文字的最大长度设置按钮宽度
@property (nonatomic, assign) CGFloat itemWidth;
/// 需要展示几列，如果不设置，将自动调整列数。如果设置了，需要注意手动设置itemWidth时产生的影响。
@property (nonatomic, assign) NSUInteger col;
/// 首列按钮的左边距，默认为 21.0f
@property (nonatomic, assign) CGFloat leftMargin;
/// 水平方向两个按钮之间的间隔，如果设置了，一排按钮的首部和尾部位置与边缘的间距可能不一。
@property (nonatomic, assign) CGFloat interitemSpacing;
/// 每行之间的间距，默认为 10.0f
@property (nonatomic, assign) CGFloat lineSpace;

@end

NS_ASSUME_NONNULL_END
