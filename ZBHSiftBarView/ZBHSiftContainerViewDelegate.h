//
//  ZBHSiftContainerViewDelegate.h
//  筛选条
//
//  Created by 张倍浩 on 2019/6/3.
//  Copyright © 2019 张倍浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBHSiftContainerViewDelegate <NSObject>

@optional

- (void)siftContainerViewWithConfirm:(void(^)(NSString *showText, id otherData))confirmBlock;
- (void)siftContainerViewWithReset:(void (^)(void))resetBlock;
/// 当选中某些子项而没有进行确认就收起view，当下次重新展开时，需要恢复到原来的状态
- (void)restoreState;

@end
