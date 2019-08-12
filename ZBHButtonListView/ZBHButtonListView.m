//
//  ZBHButtonListView.m
//  按钮列表
//
//  Created by 张倍浩 on 2019/7/4.
//  Copyright © 2019 张倍浩. All rights reserved.
//

#import "ZBHButtonListView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ZBHButtonListView ()

@property (nonatomic, strong) NSArray *itemButtonArray;
@property (nonatomic, assign) ButtonChoiceType choiceType;
@property (nonatomic, assign) ButtonWidthStyle widthStyle;
@property (nonatomic, assign) CGFloat maxItemWidth;
@property (nonatomic, strong) NSMutableArray *selectedButtonArray;
@property (nonatomic, strong) NSArray<NSString *> *buttonWidthArray;

@end

@implementation ZBHButtonListView

- (instancetype)initWithChoiceType:(ButtonChoiceType)choiceType widthStyle:(ButtonWidthStyle)widthStyle {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.choiceType = choiceType;
        self.widthStyle = widthStyle;
        self.layer.masksToBounds = YES;
        self.fontSize = 12;
        self.itemButtonNormalBgColor = UIColorFromRGB(0xF7F7F7);
        self.itemButtonSelectedBgColor = [UIColorFromRGB(0xFFB000) colorWithAlphaComponent:0.2];
        self.itemButtonNormalTitleColor = UIColorFromRGB(0x292B33);
        self.itemButtonSelectedTitleColor = UIColorFromRGB(0xFFB000);
    }
    return self;
}

- (void)setUnSelectedItemIndexes:(NSArray<NSNumber *> *)indexs {
    for (NSNumber *index in indexs) {
        if (index.unsignedIntegerValue > self.itemArray.count - 1) return;
        UIButton *itemButton = self.itemButtonArray[index.unsignedIntegerValue];
        if (![self.selectedButtonArray containsObject:itemButton]) continue;
        itemButton.selected = NO;
        itemButton.backgroundColor = self.itemButtonNormalBgColor;
        [self.selectedButtonArray removeObject:itemButton];
    }
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
    [self.selectedButtonArray removeAllObjects];
    [self.selectedButtonArray addObjectsFromArray:selectedButtonArray];
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

- (void)setItemArray:(NSArray<NSString *> *)itemArray {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _itemArray = itemArray;
    NSMutableArray *itemButtonArray = [NSMutableArray arrayWithCapacity:itemArray.count];
    CGFloat maxItemWidth = 0;
    NSMutableArray *buttonWidthArray = [NSMutableArray array];
    for (NSString *item in itemArray) {
        CGFloat width = [item boundingRectWithSize:CGSizeMake(kMainScreenWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : FONT(12)} context:nil].size.width;
        if (self.widthStyle == ButtonFlexibleStyle) {
            [buttonWidthArray addObject:[NSString stringWithFormat:@"%.0f", ceilf(width + 28)]];
        }
        maxItemWidth = width > maxItemWidth? width : maxItemWidth;
        
        UIButton *itemButton = [self createItemButtonWithTitle:item];
        [self addSubview:itemButton];
        [itemButtonArray addObject:itemButton];
    }
    
    self.buttonWidthArray = [buttonWidthArray copy];
    
    self.maxItemWidth = ceilf(maxItemWidth);
    
    self.itemButtonArray = [itemButtonArray copy];
    self.height = self.totalHeight;
}

- (UIButton *)createItemButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = FONT(12);
    [self configButtonState:button];
    [button setTitle:title forState:UIControlStateNormal];
    button.layer.cornerRadius = 15;
    [button addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)configButtonState:(UIButton *)button {
    button.backgroundColor = self.itemButtonNormalBgColor;
    [button setTitleColor:self.itemButtonNormalTitleColor forState:UIControlStateNormal];
    [button setTitleColor:self.itemButtonSelectedTitleColor forState:UIControlStateSelected];
}

- (void)reset {
    for (UIButton *selectedButton in self.selectedButtonArray) {
        selectedButton.selected = NO;
        selectedButton.backgroundColor = self.itemButtonNormalBgColor;
    }
    [self.selectedButtonArray removeAllObjects];
}

- (void)itemClick:(UIButton *)button {
    button.selected = !button.selected;
    
    if ([self.delegte respondsToSelector:@selector(buttonListView:didClick:index:isSelected:)]) {
        NSInteger index = [self.itemButtonArray indexOfObject:button];
        [self.delegte buttonListView:self didClick:self.itemArray[index] index:index isSelected:button.selected];
    }
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
    
    for (UIButton *button in self.itemButtonArray) {
        [self configButtonState:button];
        button.titleLabel.font = FONT(self.fontSize);
        if (self.itemHeight > 0) {
            button.layer.cornerRadius = self.itemHeight / 2;
        }
    }
    if (self.widthStyle == ButtonFixedStyle) {
        [self layoutButtonsWithFixedStyle];
    } else {
        [self layoutButtonsWithFlexibleStyle];
    }
}

- (void)layoutButtonsWithFlexibleStyle {
    NSInteger count = self.itemButtonArray.count;
    CGFloat leftMargin = self.leftMargin > 0? self.leftMargin : 21.0f;
    CGFloat rightMargin = 5;
    
    CGFloat lineSpace = self.lineSpace > 0? self.lineSpace : 10.0f;
    CGFloat height = self.itemHeight > 0? self.itemHeight : 30.0f;
    
    CGFloat interitemSpacing = self.interitemSpacing > 0? self.interitemSpacing : 15;
    UIButton *previousButton;
    for (int i = 0; i < count; i++) {
        UIButton *itemButton = self.itemButtonArray[i];
        
        CGFloat width = [self.buttonWidthArray[i] floatValue];
        if (width > ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin)) {
            width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
        }
        CGFloat originX = 0.0f;
        CGFloat originY = 0.0f;
        if (i == 0) {
            originX = leftMargin;
            originY = 0;
            
        } else {
            originX = CGRectGetMaxX(previousButton.frame) + interitemSpacing;
            if (originX + interitemSpacing + width + rightMargin > [UIScreen mainScreen].bounds.size.width) {
                originX = leftMargin;
                originY = CGRectGetMaxY(previousButton.frame) + lineSpace;
            }
            originY = previousButton.frame.origin.y;
        }
        
        itemButton.frame = CGRectMake(originX, originY, width, height);
        previousButton = itemButton;
    }
    self.height = CGRectGetMaxY(previousButton.frame);
}

- (void)layoutButtonsWithFixedStyle {
    NSInteger count = self.itemButtonArray.count;
    CGFloat leftMargin = self.leftMargin > 0? self.leftMargin : 21.0f;
    CGFloat rightMargin = leftMargin;
    
    CGFloat lineSpace = self.lineSpace > 0? self.lineSpace : 10.0f;
    CGFloat width = self.itemWidth > 0? self.itemWidth : (self.maxItemWidth + 14.0f);
    CGFloat height = self.itemHeight > 0? self.itemHeight : 30.0f;
    NSInteger col;
    if (self.interitemSpacing > 0) {
        col = self.col > 0? self.col : ((kMainScreenWidth - leftMargin - rightMargin - self.interitemSpacing) / (width + self.interitemSpacing));
    } else {
        col = self.col > 0? self.col : ((kMainScreenWidth - leftMargin - rightMargin) / width);
    }
    CGFloat interitemSpacing = self.interitemSpacing > 0? self.interitemSpacing : ((kMainScreenWidth - leftMargin - rightMargin - (col * width)) / (col - 1));
    
    CGFloat minInteritemSpacing = 4;
    if (interitemSpacing < minInteritemSpacing) {
        col = col - 1;
        interitemSpacing = self.interitemSpacing > 0? self.interitemSpacing : ((kMainScreenWidth - leftMargin - rightMargin - (col * width)) / (col - 1));
    }
    
    for (int i = 0; i < count; i++) {
        UIButton *itemButton = self.itemButtonArray[i];
        CGFloat topDistance = (height + lineSpace) * (i / col);
        CGFloat leftDistance = leftMargin + (width + interitemSpacing) * (i % col);
        itemButton.frame = CGRectMake(leftDistance, topDistance, width, height);
    }
    
    NSUInteger lines = count / col;
    if (count % col > 0) {
        lines += 1;
    }
    
    self.height = height * lines + lineSpace * (lines - 1);
}

- (CGFloat)totalHeight {
    if (self.widthStyle == ButtonFixedStyle) {
        [self layoutButtonsWithFixedStyle];
    } else {
        [self layoutButtonsWithFixedStyle];
    }
    return self.height;
}

- (BOOL)isEmpty {
    return self.selectedButtonArray.count == 0;
}

- (NSMutableArray *)selectedButtonArray {
    if (!_selectedButtonArray) {
        _selectedButtonArray = [NSMutableArray array];
    }
    return _selectedButtonArray;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end
