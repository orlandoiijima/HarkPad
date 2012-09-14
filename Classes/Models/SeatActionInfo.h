//
// Created by wbison on 14-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Table.h"


@interface SeatActionInfo : NSObject
@property(nonatomic, copy) NSString *tableId;
@property(nonatomic) int beforeSeat;
@property(nonatomic) enum TableSide tableSide;
@property(nonatomic) int seat;

+ (SeatActionInfo *)infoForTable:(NSString *)tableId seat:(int)seat beforeSeat:(int)beforeSeat atSide:(TableSide)side;
- (NSMutableDictionary *)toDictionary;

@end