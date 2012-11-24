#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OrderLine.h"
#import "OrderDelegate.h"
#import "SeatView.h"
#import "SeatGridView.h"

@interface OrderLineCell : UITableViewCell
{
}

@property (retain, nonatomic) OrderLine* orderLine;
@property (retain) IBOutlet UILabel *name;
@property (retain) IBOutlet UILabel *note;
@property (retain) IBOutlet UILabel *price;
@property (retain) IBOutlet UILabel *props;
@property (retain) IBOutlet UIButton *course;
@property (retain) IBOutlet SeatGridView *seat;
@property (retain) IBOutlet UILabel *quantity;
@property (retain) IBOutlet UIImageView *nLineIcon;
@property (retain) UITextField * notesView;
@property (retain) UIStepper * stepperView;
@property (retain) id<OrderDelegate> delegate;

@property bool showProductProperties;
@property (nonatomic) BOOL isInEditMode;
@property BOOL isEditable;
@property BOOL showPrice;
@property BOOL showStepper;
@property BOOL showSeat;
@property int heightInEditMode;

@property(nonatomic, assign) BOOL isBlinking;

@property(nonatomic, strong) NSMutableArray *propertyViews;

+ (OrderLineCell *) cellWithOrderLine: (OrderLine *) line isEditable: (BOOL)isEditable showPrice: (bool)showPrice showProperties: (bool)showProperties showSeat: (bool)showSeat showStepper: (bool)showStepper guests: (NSMutableArray *)guests delegate: (id) delegate rowHeight: (float)rowHeight fontSize: (float)fontSize;

+ (float) getExtraHeightForEditMode: (OrderLine *)line width: (float)width;

@end
