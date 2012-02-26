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
    SlotStatus _lunchStatus;
    SlotStatus _dinnerStatus;
    int _lunchCount;
    int _dinnerCount;
}

@property (retain) NSDate *date;
@property (retain) NSMutableDictionary *slots;
@property SlotStatus lunchStatus;
@property SlotStatus dinnerStatus;
@property int lunchCount;
@property int dinnerCount;

+ (DayReservationsInfo *)infoFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end