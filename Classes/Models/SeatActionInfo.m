//
// Created by wbison on 14-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SeatActionInfo.h"
#import "Table.h"


@implementation SeatActionInfo {

}
@synthesize tableId = _tableId;
@synthesize beforeSeat = _beforeSeat;
@synthesize tableSide = _tableSide;
@synthesize seat = _seat;


+ (SeatActionInfo *)infoForTable:(NSString *)tableId seat:(int)seat  beforeSeat:(int)beforeSeat atSide:(TableSide)side {
    SeatActionInfo *info = [[SeatActionInfo alloc] init];
    info.tableId = tableId;
    info.beforeSeat = beforeSeat;
    info.seat = seat;
    info.tableSide = side;
    return info;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: _tableId forKey:@"tableId"];
    [dic setObject: [NSString stringWithFormat:@"%d", _seat] forKey:@"seat"];
    [dic setObject: [NSString stringWithFormat:@"%d", _beforeSeat] forKey:@"beforeSeat"];
    [dic setObject: [NSString stringWithFormat:@"%d", _tableSide] forKey:@"tableSide"];

    return dic;
}

@end