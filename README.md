# FeatureCollection

一些功能封装的合集（只作为学习的记录，不考虑编译错误问题）

### ZBHYMDDatePickerView

自定义的年月日时间选择器，主要功能是在添加最小时间和最大时间后，只保留区间范围内的时间段做滚动，区间外的时间不展示。
### ZBHSiftBarView

筛选条的封装。创建展开筛选条下方的视图，该视图需要遵守协议 `ZBHSiftContainerViewDelegate`，筛选条上的按钮展开和收起时机不用做判断。目的是为了让筛选条和展开的 view 进行隔离，达到解耦的目的。
