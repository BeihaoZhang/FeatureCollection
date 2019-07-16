//
//  ZBHYMDDatePickerView.h
//  时间选择器
//
//  Created by 张倍浩 on 2019/6/18.
//  Copyright © 2019 张倍浩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZBHYMDDatePickerView;

@protocol ZBHYMDPickerViewDelegate <NSObject>

- (void)ymdPickerView:(ZBHYMDDatePickerView *)pickerView didSelectWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end

@interface ZBHYMDDatePickerView : UIView

@property (nonatomic, weak) id<ZBHYMDPickerViewDelegate> delegate;
@property (nonatomic, strong) NSDate *maximumDate;
@property (nonatomic, strong) NSDate *minimumDate;

@end

NS_ASSUME_NONNULL_END
