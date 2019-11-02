//
//  ZBHSiftBarView.h
//  筛选条
//
//  Created by 张倍浩 on 2019/5/31.
//  Copyright © 2019 张倍浩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZBHSiftContainerViewDelegate;
@class ZBHSiftBarView;

@protocol ZBHSiftBarViewDataSource <NSObject>

- (UIView<ZBHSiftContainerViewDelegate> *)siftBarView:(ZBHSiftBarView *)siftBarView containerViewForItemAtIndex:(NSInteger)index;

@end

@protocol ZBHSiftBarViewDelegate <NSObject>

@optional
- (void)siftBarView:(ZBHSiftBarView *)siftBarView didConfirmContainerViewForItemAtIndex:(NSInteger)index;
- (void)siftBarView:(ZBHSiftBarView *)siftBarView didResetConfirmContainerViewForItemAtIndex:(NSInteger)index;

@end

@interface ZBHSiftBarView : UIView

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame itemTitles:(NSArray<NSString *> *)itemTitles;

@property (nonatomic, weak) id<ZBHSiftBarViewDataSource> dataSource;
@property (nonatomic, weak) id<ZBHSiftBarViewDelegate> delegate;
@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIColor *selectTitleColor;
@property (nonatomic, strong) UIImage *indicatorNormalImage;
@property (nonatomic, strong) UIImage *indicatorSelectImage;
@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, strong, readonly) NSDictionary<NSNumber *, id> *containerDatas;

- (void)hide;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
