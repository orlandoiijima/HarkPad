//
// Created by wbison on 15-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


@protocol TimeRangeDelegate <NSObject>
- (void)didSetLower:(float)upper upper:(float)lower;
@end