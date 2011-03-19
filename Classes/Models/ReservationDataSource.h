//
//  ReservationDataSource.h
//  HarkPad
//
//  Created by Willem Bison on 19-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ReservationDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *reservations;
    NSMutableDictionary *groupedReservations;
}

@property (retain) NSMutableArray *reservations;
@property (retain) NSMutableDictionary *groupedReservations;

+ (ReservationDataSource *) dataSource;

@end
