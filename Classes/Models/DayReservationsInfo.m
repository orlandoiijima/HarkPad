//
//  Created by wbison on 10-12-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DayReservationsInfo.h"


@implementation DayReservationsInfo {

}

@synthesize date = _date;
@synthesize slots = _slots;
@synthesize lunchStatus = _lunchStatus;
@synthesize dinnerStatus = _dinnerStatus;


+ (DayReservationsInfo *)infoFromJsonDictionary: (NSDictionary *)jsonDictionary {
    DayReservationsInfo *info = [[DayReservationsInfo alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    info.date = [formatter dateFromString: [jsonDictionary objectForKey:@"date"]];
    info.lunchStatus = statusFull;
    info.dinnerStatus = statusFull;
    info.slots = [[NSMutableDictionary alloc] init];
    id slots = [jsonDictionary objectForKey:@"available"];
    for(id slotInfo in slots)
    {
        NSString *slot = [slotInfo objectForKey:@"slot"];
        int hour = [slot integerValue];
        id count = [slotInfo objectForKey:@"count"];
        if ([count isKindOfClass:[NSString class]] && ([((NSString *)count) isEqualToString:@"closed"])) {
            if (hour > 16)
                info.dinnerStatus = statusClosed;
            else
                info.lunchStatus = statusClosed;
        }
        else {
            bool isFull = [count intValue] <= 0;
            if (isFull == false) {
                if (hour > 16)
                    info.dinnerStatus = statusAvailable;
                else
                    info.lunchStatus = statusAvailable;
            }
            [info.slots setObject:count forKey:slot];
        }
    }
    
    return info;
}

@end