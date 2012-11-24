#import <QuartzCore/QuartzCore.h>
#import "OrderLineCell.h"
#import "Utils.h"
#import "ToggleButton.h"
#import "Order.h"
#import "OrderGridHitInfo.h"

@implementation OrderLineCell

@synthesize isEditable, nLineIcon, orderLine, price, name, note, props, seat, course, quantity, showSeat, showPrice, showProductProperties, isInEditMode = _isInEditMode, stepperView, notesView, heightInEditMode, delegate, showStepper;
@synthesize isBlinking = _isBlinking;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showProductProperties = YES;
        self.propertyViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    float right = self.contentView.bounds.size.width - 13;
    float height = self.bounds.size.height;
    self.notesView.frame = CGRectMake(50, self.notesView.frame.origin.y, right - 50, self.notesView.frame.size.height);
    if (self.showStepper) {
        stepperView.frame = CGRectMake(right-94, stepperView.frame.origin.y, 94, height);
        right -= self.stepperView.frame.size.width + 10;
    }
    if (self.showPrice) {
        self.price.frame = CGRectMake(right - 60, 0, 60, self.price.frame.size.height);
        right -= self.price.frame.size.width;
    }
    if (self.showSeat) {
        self.seat.frame = CGRectMake(right - self.seat.frame.size.width, 0, self.seat.frame.size.width, self.seat.frame.size.height);
        right -= self.seat.frame.size.width;
    }
    self.name.frame = CGRectMake(self.name.frame.origin.x, self.name.frame.origin.y, right - self.name.frame.origin.x, self.name.frame.size.height);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

-(void)setIsBlinking:(BOOL)blinking {
    _isBlinking = blinking;
    if (blinking) {
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations: ^
        {
            self.name.transform = CGAffineTransformMakeTranslation(-10, 0);
            self.quantity.transform = CGAffineTransformMakeTranslation(-10, 0);
            self.seat.transform = CGAffineTransformMakeTranslation(-10, 0);
        } completion: nil];
    }
    else {
        [self.name.layer removeAllAnimations];
        self.name.transform = CGAffineTransformIdentity;
        [self.quantity.layer removeAllAnimations];
        self.quantity.transform = CGAffineTransformIdentity;
        [self.seat.layer removeAllAnimations];
        self.seat.transform = CGAffineTransformIdentity;
    }
}

+ (OrderLineCell *) cellWithOrderLine: (OrderLine *) line isEditable: (BOOL)isEditable showPrice: (bool)showPrice showProperties: (bool)showProperties showSeat: (bool)showSeat showStepper: (bool)showStepper guests: (NSMutableArray *)guests delegate: (id) delegate rowHeight: (float)rowHeight fontSize: (float)fontSize
{
    OrderLineCell *cell = [[OrderLineCell alloc] init];

    cell.selectionStyle = (UITableViewCellSelectionStyle) UITableViewCellEditingStyleNone;
    cell.clipsToBounds = YES;

    cell.delegate = delegate;
    cell.isEditable = isEditable;
    cell.showProductProperties = showProperties;
    cell.showPrice = showPrice;
    cell.showSeat = showSeat;
    cell.showStepper = showStepper;
    float height = rowHeight == 0 ? 44 : rowHeight;
    float width = cell.contentView.bounds.size.width;

    if (line == nil) {
        return cell;
    }

    cell.quantity = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, height)];
    [cell.contentView addSubview:cell.quantity];
    cell.quantity.textAlignment = NSTextAlignmentRight;
    cell.quantity.backgroundColor = [UIColor clearColor];
    if (fontSize != 0)
        cell.quantity.font = [UIFont systemFontOfSize:fontSize];
    if (isEditable == false)
        cell.quantity.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    cell.name = [[UILabel alloc] initWithFrame:CGRectMake(cell.quantity.frame.origin.x + cell.quantity.frame.size.width + 3, 0, 200, height)];
    [cell.contentView addSubview:cell.name];
    if (isEditable == false)
        cell.name.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    cell.name.backgroundColor = [UIColor clearColor];
    if (fontSize != 0)
        cell.name.font = [UIFont systemFontOfSize:fontSize];
    cell.name.shadowColor = [UIColor lightGrayColor];
    cell.name.shadowOffset = CGSizeMake(0, 1);

    float right = width;
    if (showStepper) {
        cell.stepperView = [[UIStepper alloc] initWithFrame:CGRectMake(right-94, (height-27)/2, 94, height)];
        [cell.contentView addSubview: cell.stepperView];
        cell.stepperView.minimumValue = 0;
        cell.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.stepperView addTarget:cell action:@selector(quantityUpdated:) forControlEvents:UIControlEventValueChanged];
        cell.stepperView.value = line.quantity;

        right -= cell.stepperView.frame.size.width - 10;
    }
    
    if (cell.showPrice) {
        cell.price = [[UILabel alloc] initWithFrame:CGRectMake(right-50, 0, 50, height)];
        [cell.contentView addSubview:cell.price];
        cell.price.textAlignment = NSTextAlignmentRight;
        cell.price.backgroundColor = [UIColor clearColor];
        cell.price.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        if (fontSize != 0)
            cell.price.font = [UIFont systemFontOfSize:fontSize];
        if (isEditable == false)
            cell.price.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        right -= cell.price.frame.size.width - 5;
    }

    if (cell.showSeat && line.order != nil && line.order.table != nil) {
        cell.seat = [SeatGridView viewWithFrame: CGRectMake(right-36, 0, 36, height) table:line.order.table guests: guests];
        [cell.contentView addSubview:cell.seat];
        if (isEditable == false)
            cell.seat.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        else
            cell.seat.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        right -= cell.seat.frame.size.width - 5;
    }

    if (isEditable) {
        cell.showsReorderControl = YES;
        float x = 50;
        float y = rowHeight;
        float vSpace = 5;
        float controlHeight = 28;
        if ([line.product.properties count] > 0) {
            for(NSString *property in line.product.properties) {

                CGSize size = [property sizeWithFont: [UIFont boldSystemFontOfSize:18]];
                ToggleButton *sw = [ToggleButton buttonWithTitle: property frame: CGRectMake(x, y, size.width + 20, controlHeight)];
                [cell.contentView addSubview:sw];
                [sw addTarget: cell action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.propertyViews addObject:sw];
                y += controlHeight + vSpace;
            }
        }
        x = 50;   
        cell.notesView = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width - 8, controlHeight)];
        cell.notesView.text = line.note;
        [cell.notesView addTarget: cell action:@selector(noteTextUpdated) forControlEvents:UIControlEventEditingChanged];
        cell.notesView.placeholder = NSLocalizedString(@"Note", nil);
        cell.notesView.backgroundColor = [UIColor whiteColor];
        cell.notesView.borderStyle = UITextBorderStyleBezel;
        [cell.contentView addSubview: cell.notesView];
        
        cell.heightInEditMode = (int) (y + cell.notesView.bounds.size.height + 5);
    }

    cell.orderLine = line;

    return cell;
}

+ (float) getExtraHeightForEditMode: (OrderLine *)line width: (float)width
{
    if (line == nil || line.product == nil)
        return 0;
    return 33 * (1 + [line.product.properties count]);
}

- (void) noteTextUpdated {
    orderLine.note = notesView.text;
}

- (void) quantityUpdated: (id)sender {
    orderLine.quantity = (int) stepperView.value;
    quantity.text = [NSString stringWithFormat:@"%d", orderLine.quantity];
    self.orderLine = self.orderLine;
    if ([delegate respondsToSelector:@selector(updatedCell:)])
        [self.delegate updatedCell:self];
}

- (void) switchChanged: (id)sender {
    for(int i=0; i < [_propertyViews count]; i++) {
        ToggleButton *toggleButton = [self.propertyViews objectAtIndex:i];
        if(toggleButton == sender) {
            NSString *property = [orderLine.product.properties objectAtIndex:i];
            if (toggleButton.isOn)
                [orderLine addProperty:property];
            else
                [orderLine removeProperty:property];
            return;
        }        
    }
}

- (void) setOrderLine : (OrderLine *) line
{
    orderLine = line;

    if (line.guest == nil) {
        seat.hidden = YES;
    }
    else {
//        seat.titleLabel.text = [Utils getSeatChar: line.guest.seat];
        seat.hidden = NO;
    }

    course.titleLabel.text = [Utils getCourseChar:line.course.offset];

    quantity.text = [NSString stringWithFormat:@"%d", line.quantity];
    quantity.hidden = line.quantity == 1;

    if (line.product != nil) {
        name.text = line.product.name;
        if ([line.propertyValues count] > 0 || line.note != nil) {
            name.text = [name.text stringByAppendingString:@" *"];
        }
    }
    else {
        name.text = NSLocalizedString(@"Tap to select course", nil);
        name.textColor = [UIColor colorWithWhite:0.3 alpha:1];
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
        for(NSString *propertyValue in line.propertyValues)
        {
            props.text = [NSString stringWithFormat:@"%@ %@", props.text, propertyValue];
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

    self.isInEditMode = self.isSelected;
}

- (void) setIsInEditMode: (BOOL)value {
    quantity.hidden = !_isInEditMode && orderLine.quantity == 1;
}

@end
