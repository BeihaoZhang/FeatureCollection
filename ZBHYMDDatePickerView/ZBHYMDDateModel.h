//
//  ZBHYMDDateModel.h
//  筛选条
//
//  Created by 张倍浩 on 2019/6/20.
//  Copyright © 2019 张倍浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZBHMonthModel;

@interface ZBHYearModel : NSObject

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, strong, readonly) NSArray<ZBHMonthModel *> *months;

- (void)addMonth:(ZBHMonthModel *)month;


@end

@interface ZBHMonthModel : NSObject

@property (nonatomic, assign) NSInteger month;
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *days;

- (void)addDay:(NSUInteger)day;

@end
