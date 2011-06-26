//
//  FoursquareVenue.h
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FoursquareUser;

@interface FoursquareVenue : NSObject {
    int countCheckins;
    int countUsers;
    NSMutableArray *hereNow;
    FoursquareUser *mayor;
}

@property int countCheckins;
@property int countUsers;
@property (retain) NSMutableArray *hereNow;
@property (retain) FoursquareUser *mayor;

+ (FoursquareVenue *) venueFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end

@interface FoursquareUser : NSObject {
    NSString *firstName;
    NSString *lastName;
    NSString *id;
    NSString *photo;
}

@property (retain) NSString *firstName;
@property (retain) NSString *lastName;
@property (retain) NSString *id;
@property (retain) NSString *photo;
	
@end
