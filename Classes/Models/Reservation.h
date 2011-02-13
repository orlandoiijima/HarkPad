//
//  Reservation.h
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Reservation : NSObject {
    int id;
    NSString *name;
    NSString *phone;
    NSString *email;
    NSString *notes;
    NSDate *startsOn;
    NSDate *endsOn;
    NSDate *createdOn;
    int countGuests;
    BOOL mailingList;
}

@property int id;
@property (retain) NSString *name;
@property (retain) NSString *phone;
@property (retain) NSString *email;
@property (retain) NSString *notes;
@property (retain) NSDate *startsOn;
@property (retain) NSDate *endsOn;
@property (retain) NSDate *createdOn;
@property int countGuests;
@property BOOL mailingList;

+ (Reservation *) reservationFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
