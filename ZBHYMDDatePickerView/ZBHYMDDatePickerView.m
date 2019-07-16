//
//  ZBHYMDDatePickerView.m
//  时间选择器
//
//  Created by 张倍浩 on 2019/6/18.
//  Copyright © 2019 张倍浩. All rights reserved.
//

#import "ZBHYMDDatePickerView.h"
#import <Masonry.h>
#import "ZBHYMDDateModel.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ZBHYMDDatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) NSArray<ZBHYearModel *> *yearModelArray;

@end

@implementation ZBHYMDDatePickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.minimumDate && self.maximumDate) {
        [self configData];
        [self.pickerView reloadAllComponents];
    }
}

- (void)configData {
//    NSDate *startDate = [self getPriousorLaterDateFromDate:[NSDate date] withMonth:-1];
//    self.yearModelArray = [self getDatesWithStartDate:startDate endDate:[NSDate date]];
    
    self.yearModelArray = [self getDatesWithStartDate:self.minimumDate endDate:self.maximumDate];
}

- (NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calendar dateByAddingComponents:comps toDate:date options:0];
    return mDate;
}

- (NSArray<ZBHYearModel *> *)getDatesWithStartDate:(NSDate *)start endDate:(NSDate *)end {
    
    NSMutableArray *yearModelArray = [NSMutableArray array];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSComparisonResult result = [start compare:end];
    NSDateComponents *comps;
    
    while (result != NSOrderedDescending) {
        comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitWeekday fromDate:start];
        
        NSInteger year = comps.year;
        NSInteger month = comps.month;
        NSInteger day = comps.day;
        
        // 年的处理
        if (yearModelArray.count == 0) {
            ZBHYearModel *yearModel = [[ZBHYearModel alloc] init];
            yearModel.year = year;
            [yearModelArray addObject:yearModel];
        } else {
            for (ZBHYearModel *model in yearModelArray) {
                if (model.year != year) {
                    ZBHYearModel *newYearModel = [[ZBHYearModel alloc] init];
                    newYearModel.year = year;
                    [yearModelArray addObject:newYearModel];
                    break;
                }
            }
        }
        
        // 月的处理
        BOOL canMonthBreak = NO;
        for (ZBHYearModel *model in yearModelArray) {
            if (canMonthBreak == YES) break;
            
            if (model.year == year) {
                if (model.months.count == 0) {
                    ZBHMonthModel *monthModel = [[ZBHMonthModel alloc] init];
                    monthModel.month = month;
                    [model addMonth:monthModel];
                    canMonthBreak = YES;
                } else {
                    NSMutableArray *monthNumArray = [NSMutableArray array];
                    for (ZBHMonthModel *itemMonthModel in model.months) {
                        [monthNumArray addObject:@(itemMonthModel.month)];
                    }
                    if (![monthNumArray containsObject:@(month)]) {
                        ZBHMonthModel *newMonthModel = [[ZBHMonthModel alloc] init];
                        newMonthModel.month = month;
                        [model addMonth:newMonthModel];
                        canMonthBreak = YES;
                    }
                }
            }
        }
        
        // 日的处理
        BOOL canDayBreak = NO;
        for (ZBHYearModel *model in yearModelArray) {
            if (canDayBreak) break;
            if (model.year == year) {
                for (ZBHMonthModel *monthModel in model.months) {
                    if (monthModel.month == month) {
                        [monthModel addDay:day];
                        canDayBreak = YES;
                        break;
                    }
                }
            }
        }
        
        
        //后一天
        [comps setDay:([comps day]+1)];
        start = [calendar dateFromComponents:comps];
        
        //对比日期大小
        result = [start compare:end];
    }
    
    return [yearModelArray copy];
}

- (void)createUI {
    [self addSubview:self.topLineView];
    [self addSubview:self.pickerView];
    [self addSubview:self.bottomLineView];
    
    [self configLayout];
}

- (void)configLayout {
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.top.equalTo(self);
        make.height.offset(1);
    }];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.topLineView.mas_bottom);
        make.bottom.equalTo(self.bottomLineView.mas_top);
    }];
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.equalTo(self);
        make.height.offset(1);
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) { // 年
        return self.yearModelArray.count;
    } else if (component == 1) { // 月
        NSInteger yearRow = [pickerView selectedRowInComponent:0];
        ZBHYearModel *yearModel = self.yearModelArray[yearRow];
        return yearModel.months.count;
    } else { // 日
        NSInteger yearRow = [pickerView selectedRowInComponent:0];
        ZBHYearModel *yearModel = self.yearModelArray[yearRow];
        NSInteger monthRow = [pickerView selectedRowInComponent:1];
        ZBHMonthModel *monthModel = yearModel.months[monthRow];
        return monthModel.days.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        ZBHYearModel *yearModel = self.yearModelArray[0];
        return [NSString stringWithFormat:@"%ld年", yearModel.year];
    } else if (component == 1) {
        NSInteger yearRow = [pickerView selectedRowInComponent:0];
        ZBHYearModel *yearModel = self.yearModelArray[yearRow];
        ZBHMonthModel *monthModel = yearModel.months[row];
        return [NSString stringWithFormat:@"%ld月", monthModel.month];
    } else {
        NSInteger yearRow = [pickerView selectedRowInComponent:0];
        ZBHYearModel *yearModel = self.yearModelArray[yearRow];
        NSInteger monthRow = [pickerView selectedRowInComponent:1];
        ZBHMonthModel *monthModel = yearModel.months[monthRow];
        NSNumber *dayNum = monthModel.days[row];
        return [NSString stringWithFormat:@"%ld日", dayNum.integerValue];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
    } else if (component == 1) {
        [pickerView reloadComponent:2];
    }
    if ([self.delegate respondsToSelector:@selector(ymdPickerView:didSelectWithYear:month:day:)]) {
        NSInteger yearRow = [pickerView selectedRowInComponent:0];
        ZBHYearModel *yearModel = self.yearModelArray[yearRow];
        NSInteger year = yearModel.year;
        NSInteger monthRow = [pickerView selectedRowInComponent:1];
        ZBHMonthModel *monthModel = yearModel.months[monthRow];
        NSInteger month = monthModel.month;
        NSInteger dayRow = [pickerView selectedRowInComponent:2];
        NSInteger day = monthModel.days[dayRow].integerValue;
        [self.delegate ymdPickerView:self didSelectWithYear:year month:month day:day];
    }
}

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = UIColorFromRGB(0xEEEFF4);
    }
    return _topLineView;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = UIColorFromRGB(0xEEEFF4);
    }
    return _bottomLineView;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        
    }
    return _pickerView;
}

@end
