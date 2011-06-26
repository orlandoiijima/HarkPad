//
//  Foursquare.m
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Foursquare.h"
#import "FoursquareVenue.h"
#import "GTMHTTPFetcher.h"
#import "CJSONDeserializer.h"

@implementation Foursquare

#define VENUE_ID_ANNA @"4d9e0491baae54817c8aff64"
#define VENUE_ID_HARKEMA @"4a2703d8f964a5209a851fe3	"
#define CLIENT_ID @"PNLJUURK3PBASAV44KCUVXGJRU5VB541ETICCEMXN5NXJQXS"
#define CLIENT_SECRET @"G4A3CJ3ECZK23OGDFXDXODM2YZPPZ1QJB01FQNO5KGPAJ3UN"

- (void)getVenue: (NSString *)venueId  delegate:(id)delegate callback:(SEL)callback userData: (id)userData
{
	NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@?client_id=%@&client_secret=%@",
                         venueId, CLIENT_ID, CLIENT_SECRET];
    NSURL *url = [NSURL URLWithString:urlString];    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = userData;
    [fetcher beginFetchWithDelegate:delegate didFinishSelector:callback];
}

- (void) getVenueCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    NSMutableDictionary *responseDic = [self getResponseFromJson: data];
    FoursquareVenue *venue = [FoursquareVenue venueFromJsonDictionary:responseDic];
    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&venue atIndex:2];
    [invocation invoke];
}

- (id) getResponseFromJson: (NSData *)data
{
    NSError *error = nil;
	NSDictionary *jsonDictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error ];
    if(error != nil)
        return [[[NSMutableDictionary alloc] init] autorelease];
    id response =  [jsonDictionary objectForKey:@"response"];
    if((NSNull *)response == [NSNull null])
        return [[[NSMutableDictionary alloc] init] autorelease];
    return response;
}

@end
