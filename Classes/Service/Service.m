//
//  OrderingService.m
//  HarkPad
//
//  Created by Willem Bison on 01-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Service.h"
#import "Backlog.h"
#import "urls.h"
#import "Reachability.h"
#import "NSDate-Utilities.h"
#import "AuthorisationToken.h"
#import "SeatActionInfo.h"
#import "OrderGridHitInfo.h"
#import "CallbackBlockInfo.h"
#import "Logger.h"
#import "MBProgressHUD.h"
#import "PrintInfo.h"
#import "OrderPrinter.h"
#import "AppVault.h"
#import "Session.h"
#import "AdminLoginViewController.h"

@implementation Service {
@private
    NSString *_location;
}

@synthesize url;
@dynamic host;
@synthesize location = _location;
@synthesize popover = _popover;


#define API_VERSION @"v1"

static Service *_service;

- (id)init {
    if ((self = [super init])) {
        [[NSUserDefaults standardUserDefaults] synchronize];	
        _location = [[[NSProcessInfo processInfo] environment] objectForKey:@"env"];
        if (_location == nil)
            _location = [[NSUserDefaults standardUserDefaults] stringForKey:@"env"];
        url = URL_DEV_LOCAL;
    }
    return self;
}

+ (Service*) getInstance {
    @synchronized(self)
    {
        if(!_service) 
        {
            _service = [[Service alloc] init];
        }
    }
    return _service;
}

+ (void) clear {
    _service  = nil;
    [Cache clear];
}

- (NSString *) host
{
    return [[NSURL URLWithString:self.url] host];
}

- (NSURL *) makeEndPoint:(NSString *)command withQuery: (NSString *) query
{	
	NSString *testUrl = [NSString stringWithFormat:@"%@/json/%@", url, command];
    if([query length] > 0)
        testUrl = [NSString stringWithFormat:@"%@?%@", testUrl, query];
    return [NSURL URLWithString:testUrl];
}

- (NSMutableArray *) getLog
{
    NSURL *urlToGet = [self makeEndPoint:@"getlog" withQuery:@""];
    NSError *error;
   	NSData *data = [NSData dataWithContentsOfURL: urlToGet options:0 error: &error];
    ServiceResult *result = [ServiceResult resultFromData:data error:error];
   	return (NSMutableArray *)result.jsonData;
}

- (void) undockTable: (NSString *)tableId
{
    [self requestResource:@"table" id:tableId action:@"undock" arguments:nil body:nil method:@"POST" success:nil error:nil];
	return;
}

- (void) transferOrder: (int)orderId toTable: (NSString *) tableId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    Order *order = [[Order alloc] init];
    order.id = orderId;
    order.table = [[[Cache getInstance] map] getTable:tableId];
    NSDictionary *orderDic = [order toDictionary];
    [self requestResource:@"order" id:[NSString stringWithFormat:@"%d", orderId] action:nil arguments:nil body:orderDic method:@"PUT" success:nil error:nil];
	return;
}

- (void) insertSeatAtTable: (NSString *) tableId beforeSeat: (int)seat atSide:(TableSide)side success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    SeatActionInfo *info = [SeatActionInfo infoForTable:tableId seat:-1 beforeSeat:seat atSide:side];
    NSDictionary *infoDic = [info toDictionary];
    [self requestResource:@"table" id:tableId action:@"InsertSeat" arguments:nil body:infoDic method:@"POST" success:nil error:nil];
	return;
}

- (void) moveSeat:(int)seat atTable: (NSString *) tableId beforeSeat: (int) beforeSeat atSide:(TableSide)side success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    SeatActionInfo *info = [SeatActionInfo infoForTable:tableId seat:seat beforeSeat:beforeSeat atSide:side];
    NSDictionary *infoDic = [info toDictionary];
    [self requestResource:@"table" id:tableId action:@"MoveSeat" arguments:nil body:infoDic method:@"POST" success:nil error:nil];
	return;
}

- (void)deleteSeat:(int)seat fromTable:(NSString *)tableId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    SeatActionInfo *info = [SeatActionInfo infoForTable:tableId seat:seat beforeSeat:-1 atSide:0];
    NSDictionary *infoDic = [info toDictionary];
    [self requestResource:@"table" id:tableId action:@"DeleteSeat" arguments:nil body:infoDic method:@"POST" success:nil error:nil];
	return;
}

- (void) dockTables: (NSMutableArray*)tables toTable:(Table *)masterTable
{
    NSMutableArray *tableNames = [[NSMutableArray alloc] init];
    for(Table *table in tables) {
        [tableNames addObject:table.name];
    }
    NSDictionary *infoDic = [NSDictionary dictionaryWithObject:tableNames forKey:@"Tables"];
    [self requestResource:@"table" id:masterTable.name action:@"DockTables" arguments:nil body:infoDic method:@"POST" success:nil error:nil];
}

// *********************************

- (void) getReservations: (NSDate *)date success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSString *arg = [NSString stringWithFormat:@"from=%@&to=%@", [date stringISO8601], [date stringISO8601]];
    [self requestResource:@"reservation" id:nil action:nil arguments:arg body:nil method:@"GET" success:success error:error];
}


- (void) updateReservation: (Reservation *)reservation success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSMutableDictionary *reservationDic = [reservation toDictionary];
    [self requestResource:@"reservation" id:nil action:nil arguments:nil body:reservationDic method:@"PUT" success:success error:error];
}

- (void) createReservation: (Reservation *)reservation success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSMutableDictionary *reservationDic = [reservation toDictionary];
    [self requestResource:@"reservation" id:nil action:nil arguments:nil body:reservationDic method:@"POST" success:success error:error];
}

- (void) deleteReservation: (int)reservationId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"reservation" id:[NSString stringWithFormat:@"%d", reservationId] action:nil arguments:nil body:nil method:@"DELETE" success:success error:error];
}

- (void) searchReservationsForText: (NSString *)query success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"reservation" id:nil action:nil arguments:[NSString stringWithFormat:@"q=%@", query] body:nil method:@"GET" success:success error:error];
}

- (void) getPreviousReservationsForReservation: (int) reservationId delegate:(id)delegate callback:(SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation retainArguments];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"getpreviousreservations"
                withQuery:[NSString stringWithFormat:@"reservationId=%d", reservationId]
                 delegate: self
                 callback:@selector(getReservationsCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) getCountAvailableSeatsPerSlotFromDate: (NSDate *)from toDate: (NSDate *)to success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSString *arg = [NSString stringWithFormat:@"from=%@&to=%@", [from stringISO8601], [to stringISO8601]];
    [self requestResource:@"reservationslot" id:nil action:nil arguments:arg body:nil method:@"GET" success:success error:error];
}

// *********************************

- (void) updateProduct: (Product *)product success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

- (void) createProduct: (Product *)product success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

// *********************************

- (void) updateCategory: (ProductCategory *)category success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

- (void) createCategory: (ProductCategory *)category success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

// *********************************

- (ServiceResult *) deleteOrderLine: (OrderLine *)orderLine
{
    Order *order = [[Order alloc] init];
    order.id = orderLine.order.id;
    orderLine.entityState = EntityStateDeleted;
    [order addOrderLine:orderLine];
    NSDictionary *orderDic = [order toDictionary];
    [self requestResource:@"order" id:[NSString stringWithFormat:@"%d", order.id] action:nil arguments:nil body:orderDic method:@"PUT" success:nil error:nil];
    return nil;
}

- (void) getBacklogStatistics : (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"backlog" id:nil action:nil arguments:nil body:nil method:@"GET" success:success error:error];
    return;
}

- (void) getDashboardStatistics : (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"dashboard" id:[[NSDate date] stringISO8601] action:nil arguments:nil body:nil method:nil success:nil error:nil];
}

- (void) getInvoices:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"invoice" id:nil action:nil arguments:nil body:nil method:@"GET" success:success error:error];
}

- (Order *) getOrder: (int) orderId success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"order" id:[NSString stringWithFormat:@"%d", orderId] action:nil arguments:nil body:nil method:@"GET" success:success error:error];
    return nil;
}

- (void) startCourse: (int) courseId forOrder:(Order *)order success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    OrderPrinter *printer = [OrderPrinter printerAtTrigger: TriggerRequestCourse order: order];
    [printer print];

    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:courseId] forKey:@"id"];
    [self requestResource:@"order" id:[NSString stringWithFormat:@"%d", order.id] action:@"StartCourse" arguments:nil body:dictionary method:@"POST" success:success error:error];
	return;
}

- (void)serveCourse:(int)courseId forOrderId:(int)orderId success:(void (^)(ServiceResult *))success error: (void (^)(ServiceResult*))error
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:courseId] forKey:@"id"];
    [self requestResource:@"order" id:[NSString stringWithFormat:@"%d", orderId] action:@"ServeCourse" arguments:nil body:dictionary method:@"POST" success:nil error:nil];
	return;
}

- (void) getWorkInProgress : (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"workinprogress" id:nil action:nil arguments:nil body:nil method:@"GET" success:success error:error];
}

- (void) processPayment: (int) paymentType forOrder: (int) orderId
{
    Order *order = [[Order alloc] init];
    order.id = orderId;
    order.paymentType = (PaymentType) paymentType;
    NSDictionary *orderDic = [order toDictionary];
    [self requestResource:@"order" id:[NSString stringWithFormat:@"%d", orderId] action:nil arguments:nil body:orderDic method:@"PUT" success:nil error:nil];
	return;
}

- (void)getSalesForDate:(NSDate *)date success:(void (^)(ServiceResult *))success error:(void (^)(ServiceResult *))error progressInfo:(ProgressInfo *)progressInfo {
    [self requestResource:@"Sales" id:[date inJson] action:nil arguments:nil body:nil method:@"GET" success:success error:error progressInfo:progressInfo];
}

- (void) getTablesInfoForAllDistricts: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"DistrictInfo" id:nil action:nil arguments:nil body:nil method:@"GET" success:success error:error];
}

- (void) getTablesInfoForDistrictBlock:(NSString *)district success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"districtinfo" id:district action:nil arguments:nil body:nil method:@"GET" success:success error:error];
}

- (void) getOpenOrderByTable: (NSString *)tableId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"TableOrder" id:tableId action:nil arguments:nil body:nil method:@"GET" success:success error:error];
}

- (void) getOpenOrdersForDistrict: (int)districtId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResource:@"TableOrder" id:districtId == -1 ? nil : [NSString stringWithFormat:@"%d", districtId] action:nil arguments:nil body:nil method:@"GET" success:success error:error];
}

- (void) updateOrder: (Order *) order success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    OrderPrinter *printer = [OrderPrinter printerAtTrigger: TriggerOrder order: order];
    [printer print];

    NSMutableDictionary *orderAsDictionary = [order toDictionary];
    [self requestResource:@"order" id:[NSString stringWithFormat:@"%d", order.id] action:nil arguments:nil body:orderAsDictionary method:@"PUT" success:success error:error];
}

- (void) createOrder: (Order *) order success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    OrderPrinter *printer = [OrderPrinter printerAtTrigger: TriggerOrder order: order];
    [printer print];

    NSMutableDictionary *orderAsDictionary = [order toDictionary];
    [self requestResource:@"order" id:nil action:nil arguments:nil body:orderAsDictionary method:@"POST" success:success error:error];
}

- (void) getConfig: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error progressInfo:(ProgressInfo *)progressInfo {
    [self requestResource:@"config" id:@"1" action:nil arguments:nil body:nil method:@"GET" success:success error:error progressInfo:progressInfo];
}

- (void) createLocation: (Location *)location credentials:(Credentials *)credentials success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error progressInfo:(ProgressInfo *)progressInfo
{
    [self requestResource:@"location" id:nil action:nil arguments:nil body:[location toDictionary] method:@"POST" success:success error:error progressInfo:progressInfo];
}

- (void) registerDeviceAtLocation:(int)locationId withCredentials: (Credentials *)credentials success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error progressInfo:(ProgressInfo *)progressInfo
{
//    NSMutableDictionary *dictionary  = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt:locationId], @"locationId",  nil];
    [self requestResource:@"device" id:nil action:nil arguments:nil body:nil method:@"POST" success:success error:error progressInfo:progressInfo];
}

- (void) signon: (Signon *)signon success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSMutableDictionary *dictionary  = [signon toDictionary];
    [self requestResource:@"tenant" id:nil action:nil arguments:nil body:dictionary method:@"POST" success:success error:error];
}

- (void)requestResource:(NSString *)resource id:(NSString *)id action:(NSString *)action arguments:(NSString *)arguments body:(NSDictionary *)body method:(NSString *)method success:(void (^)(ServiceResult *))onSuccess error:(void (^)(ServiceResult *))onError {
    [self requestResource:resource id:id action:action arguments:arguments body:body method:method success:onSuccess error:onError progressInfo:nil];
}

- (void)requestResource:(NSString *)resource id:(NSString *)id action:(NSString *)action arguments:(NSString *)arguments body:(NSDictionary *)body method:(NSString *)method success:(void (^)(ServiceResult *))onSuccess error:(void (^)(ServiceResult *))onError progressInfo:(ProgressInfo *)progressInfo {
    if (([method isEqualToString:@"PUT"] || [method isEqualToString:@"POST"]) && [body count] == 0)
        [Logger Info:@"Put or post without data"];

    CallbackBlockInfo *info = [CallbackBlockInfo infoWithSuccess:onSuccess error:onError progressInfo:progressInfo];

    NSError *error = nil;

    NSString *urlRequest = [NSString stringWithFormat:@"%@/api/%@/%@", url, API_VERSION, resource];
    if ([id length] > 0)
        urlRequest = [urlRequest stringByAppendingFormat:@"/%@", id];
    if ([action length] > 0)
        urlRequest = [urlRequest stringByAppendingFormat:@"/%@", action];
    if ([arguments length] > 0)
        urlRequest = [urlRequest stringByAppendingFormat:@"?%@", arguments];
    [Logger Info:[NSString stringWithFormat:@"%@: %@", method, urlRequest]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlRequest]];
    request.timeoutInterval = 20;
    [request setHTTPMethod: method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (body != nil) {
        NSString *jsonString = [[CJSONSerializer serializer] serializeObject: body error:&error];
        if(error != nil)
            [Logger Info:error.description];
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [Logger Info:jsonString];
    }

    NSArray *adminResources = [NSArray arrayWithObjects:@"location", nil];
    info.isAdminRequired = [adminResources containsObject:resource];

    if (info.isAdminRequired && [Session isAuthenticatedAsAdmin] == false) {
        AdminLoginViewController *loginController = [AdminLoginViewController
                controllerDidEnterAuthentication:^(Credentials *credentials) {
                    [_popover dismissPopoverAnimated:YES];
                    [self beginAuthorizedFetchRequest:request withInfo:info];
                }
                                       didCancel:^{
                                           return;
                                       }];
        _popover = [[UIPopoverController alloc] initWithContentViewController:loginController];
        _popover.delegate = self;
        UIView *view = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
        [_popover presentPopoverFromRect: view.frame inView: view permittedArrowDirections:0 animated:YES];
        return;
        }

    [self beginAuthorizedFetchRequest:request withInfo:info];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return NO;
}

- (void) beginAuthorizedFetchRequest:(NSMutableURLRequest *)request withInfo: (CallbackBlockInfo *)info {
    if (info != nil && info.progressInfo != nil)
        [info.progressInfo start];

    AuthorisationToken *authorisationToken = [AuthorisationToken tokenFromVault];
    [authorisationToken addCredentials: [Session credentials]];
    [request setValue:[authorisationToken toHttpHeader] forHTTPHeaderField:@"Authorization"];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = info;
    [fetcher beginFetchWithDelegate:self didFinishSelector: @selector(callbackWithBlock:finishedWithData:error:)];
}

- (void) callbackWithBlock:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    CallbackBlockInfo *info = fetcher.userData;
    if (info == nil) return;

    if (info.progressInfo != nil)
        [info.progressInfo stop];

    ServiceResult *result = [ServiceResult resultFromData:data error:error];
    if (result == nil) return;

    if (result.isSuccess) {
        if(info.isAdminRequired)
            [Session setIsAuthenticatedAsAdmin:YES];
        if (info.success)
            info.success(result);
    }
    else {
        if (info.error)
            info.error(result);
    }
}

- (NSString *)urlEncode: (NSString *)unencodedString
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
        NULL,
        (__bridge CFStringRef)unencodedString,
        NULL,
        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
        kCFStringEncodingUTF8 );    
}

- (void)getPageCallback: (NSString *)page withQuery: (NSString *)query  delegate:(id)delegate callback:(SEL)callback userData: (id)userData
{
    NSURL *u = [self makeEndPoint:page withQuery:query];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: u];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = userData;
    [fetcher beginFetchWithDelegate:delegate didFinishSelector:callback];
}

- (BOOL) checkReachability {
    Reachability *reachability = [Reachability reachabilityWithHostname: self.host];
    return reachability.isReachable && !reachability.isConnectionRequired;
}

@end
