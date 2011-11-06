
#import "OrderLineCell.h"
#import "OrderLine.h"
#import "OrderLinePropertyValue.h"
//#import "OrderViewDetailController.h"
#import "OrderTableView.h"
#import "Utils.h"

@implementation OrderLineCell

@synthesize nLineIcon, orderLine, price, name, note, props, seat, course, quantity, showProductProperties;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showProductProperties = YES;
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

+ (OrderLineCell *) cellWithOrderLine: (OrderLine *) line
{
    OrderLineCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderLineCell" owner:self options:nil] lastObject];
    cell.orderLine = line;
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.frame.size.height < 40) {
        name.font = [UIFont systemFontOfSize:14];
        price.font = [UIFont systemFontOfSize:14];
    }
}

- (void) setOrderLine : (OrderLine *) line
{
    orderLine = line;
    
    seat.titleLabel.text = [Utils getSeatChar: line.guest.seat];
    course.titleLabel.text = [Utils getCourseChar:line.course.offset];
    quantity.text = [NSString stringWithFormat:@"%d", line.quantity];
    if(line.quantity == 1)
    {
//        int offset = quantity.frame.origin.x - name.frame.origin.x;
//        name.frame = CGRectOffset(name.frame, offset, 0);
//        note.frame = CGRectOffset(note.frame, offset, 0);
        quantity.hidden = YES;
    }
    name.text = line.product.key;

    if(line.entityState == New)
    {
        name.font = [UIFont boldSystemFontOfSize:18];
        price.font = [UIFont boldSystemFontOfSize:18];
    }
    else
    {
        nLineIcon.hidden = YES;
    }
    
    if (showProductProperties) {
        if(line.note.length > 0) {
            note.text = line.note;
            name.frame = CGRectOffset(name.frame, 0, -5);
            quantity.frame = CGRectOffset(quantity.frame, 0, -5);
        }
        else
            note.text = @"";

        props.text = @"";
        for(OrderLinePropertyValue *propertyValue in line.propertyValues)
        {
            props.text = [NSString stringWithFormat:@"%@ %@", props.text, propertyValue.displayValue];
        }
    }
    else {
        note.text = @"";
        props.text = @"";
    }

    NSDecimalNumber *q = [NSDecimalNumber decimalNumberWithDecimal: [[NSNumber numberWithInt:line.quantity] decimalValue]];
    NSDecimalNumber *amount = [line.product.price decimalNumberByMultiplyingBy:q]; 
    price.text = [Utils getAmountString: amount withCurrency:NO];

    self.backgroundColor = [orderLine.product.category.color colorWithAlphaComponent:0.8];			
    self.opaque = NO;
}


@end
