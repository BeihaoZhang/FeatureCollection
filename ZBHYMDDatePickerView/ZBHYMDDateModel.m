//
//  ZBHYMDDateModel.m
//  筛选条
//
//  Created by 张倍浩 on 2019/6/20.
//  Copyright © 2019 张倍浩. All rights reserved.
//

#import "ZBHYMDDateModel.h"

@interface ZBHYearModel ()

@property (nonatomic, strong) NSMutableArray *mutableMonthArray;

@end

@implementation ZBHYearModel

- (void)addMonth:(ZBHMonthModel *)month {
    [self.mutableMonthArray addObject:month];
}

- (NSArray<ZBHMonthModel *> *)months {
    return [self.mutableMonthArray copy];
}

- (NSMutableArray *)mutableMonthArray {
    if (!_mutableMonthArray) {
        _mutableMonthArray = [NSMutableArray array];
    }
    return _mutableMonthArray;
}

@end

@interface ZBHMonthModel ()

@property (nonatomic, strong) NSMutableArray *mutableDayArray;

@end

@implementation ZBHMonthModel

- (NSArray<NSNumber *> *)days {
    return [self.mutableDayArray copy];
}

- (void)addDay:(NSUInteger)day {
    [self.mutableDayArray addObject:@(day)];
}

- (NSMutableArray *)mutableDayArray {
    if (!_mutableDayArray) {
        _mutableDayArray = [NSMutableArray array];
    }
    return _mutableDayArray;
}

@end
