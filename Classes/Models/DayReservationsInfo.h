//
//  Created by wbison on 10-12-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

typedef enum {statusNothing, statusAvailable, statusFull, statusClosed} SlotStatus;

@interface DayReservationsInfo : NSObject {
    NSDate *_date;
    NSMutableDictionary *_slots;
    SlotStatus lunchStatus;
    SlotStatus dinnerStatus;
}

@property (retain) NSDate *date;
@property (retain) NSMutableDictionary *slots;
@property SlotStatus lunchStatus;
@property SlotStatus dinnerStatus;

+ (DayReservationsInfo *)infoFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end