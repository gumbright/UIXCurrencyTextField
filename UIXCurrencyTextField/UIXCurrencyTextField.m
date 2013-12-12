//
//  UIXCurrencyTextField.m
//  UIXCurrencyTextField
//
//  Created by Guy Umbright on 8/23/11.
//  Copyright 2011 Kickstand Software. All rights reserved.
//

#import "UIXCurrencyTextField.h"

@interface UIXCurrencyTextField ()
@property (nonatomic, assign) float currentValue;
@property (nonatomic, assign) NSDecimalNumber* currentDecimalValue;

@property (nonatomic, strong) UITextField* entryField;
@property (nonatomic, strong) UILabel* display;
@property (nonatomic, strong) NSNumberFormatter* formatter;
@property (nonatomic, strong) UIView* blinky;
@property (nonatomic, strong) NSTimer* blinkyTimer;
@end

@implementation UIXCurrencyTextField

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) commonInitialization
{
    self.entryField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.entryField.delegate = self;
    self.entryField.keyboardType =  UIKeyboardTypeNumberPad;
    self.entryField.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(editValueChanged:) 
                                                 name:UITextFieldTextDidChangeNotification 
                                               object:self.entryField];
    
    [self addSubview:self.entryField];
#if !(__has_feature(objc_arc))
    [entryField release];
#endif
    
    self.display = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width-10, self.bounds.size.height)];
    self.display.backgroundColor = [UIColor clearColor];
    self.display.textColor = [UIColor blackColor];
    self.display.userInteractionEnabled = YES;
    self.display.textAlignment = NSTextAlignmentRight;
    self.display.adjustsFontSizeToFitWidth = YES;
    self.display.minimumFontSize = 13.0;
    [self addSubview:self.display];
#if !(__has_feature(objc_arc))
    [display release];
#endif
    
    UITapGestureRecognizer* gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    
    gr.numberOfTapsRequired = 1;
    gr.numberOfTouchesRequired = 1;
    [self.display addGestureRecognizer:gr];
#if !(__has_feature(objc_arc))
    [gr release];
#endif
    
    self.blinky = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-10, 5, 5, self.bounds.size.height-10)];
    self.blinky.backgroundColor = self.display.textColor;
    self.blinky.hidden = 1.0;
    [self addSubview:self.blinky];
#if !(__has_feature(objc_arc))
    [blinky release];
#endif
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    self.display.text = [self.formatter stringFromNumber:[NSNumber numberWithFloat:0.0]];
    
    self.caretWidth = 10;
//    NSLog(@"min=%u max=%u",formatter.minimumFractionDigits,formatter.maximumFractionDigits);
    
//    currentValueString = [[NSMutableString alloc] init];
    
    //initialize values
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self commonInitialization];
    }
    return self;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) awakeFromNib
{
    [self commonInitialization];
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [currentValueString release];
#if !(__has_feature(objc_arc))
    [formatter release];
    [super dealloc];
#endif
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) updateDisplay
{
    if (self.entryField.text.length == 0)
    {
        self.display.text = [self.formatter stringFromNumber:[NSNumber numberWithFloat:0.0]];
    }
    else
    {
        self.display.text = [self.formatter stringFromNumber:self.currentDecimalValue];
    }
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) editValueChanged:(NSNotification*) notification
{
    [self updateCurrentValue];
    [self updateDisplay];
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (string.length > 0)
//    {
//        [entryField.text appendString:string];
//    }
//    else
//    {
//        [currentValueString deleteCharactersInRange:NSMakeRange(currentValueString.length-1, 1)];
//    }
//    
//    [self updateDisplay];
//    return YES;
//}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) updateCurrentValue
{
    NSDecimalNumber* num = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:[self.entryField.text intValue]] decimalValue]];
    NSDecimalNumber* scale = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:10] decimalValue]];
    scale = [scale decimalNumberByRaisingToPower:[self.formatter maximumFractionDigits]];
    self.currentDecimalValue = [num decimalNumberByDividingBy:scale];
    double d = [self.currentDecimalValue doubleValue];
    self.currentValue = (float) d;
    
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (float) value
{
    return self.currentValue;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) setValue:(float)inputValue
{
    NSString* floatString = [NSString stringWithFormat:@"%f",inputValue];
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain 
                                                                                                      scale:[self.formatter maximumFractionDigits] 
                                                                                           raiseOnExactness:FALSE 
                                                                                            raiseOnOverflow:TRUE 
                                                                                           raiseOnUnderflow:TRUE 
                                                                                        raiseOnDivideByZero:TRUE]; 
    
    [self.formatter setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber* n = [self.formatter numberFromString:floatString];
    [self.formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[n decimalValue]];

    NSDecimalNumber *roundedDecimalNumber = [decimalNumber decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    NSDecimalNumber* scale = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:10] decimalValue]];
    scale = [scale decimalNumberByRaisingToPower:[self.formatter maximumFractionDigits]];
    NSDecimalNumber* num = [roundedDecimalNumber decimalNumberByMultiplyingBy:scale];
   
    self.entryField.text = [num stringValue];
    [self updateCurrentValue];
    [self updateDisplay];
}


////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) setTextColor:(UIColor *)textColor
{
    if (_textColor == textColor) return;
    
    _textColor = textColor;
    self.display.textColor = _textColor;
    self.blinky.backgroundColor = _textColor;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    if (_backgroundColor == backgroundColor) return;
    
    _backgroundColor = backgroundColor;
    self.display.backgroundColor = _backgroundColor;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) setFont:(UIFont *)font
{
    if (_font == font) return;
    
    _font = font;
    self.display.font = _font;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void)textFieldDidBeginEditing:(UITextField *)textField
{    
        self.blinkyTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 
                                                       target:self
                                                     selector:@selector(handleBlinky:) 
                                                     userInfo:nil 
                                                      repeats:YES];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(currencyTextFieldShouldEndEditing:)])
    {
        result = [self.delegate currencyTextFieldShouldEndEditing:self];
    }
    return result;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) handleBlinky:(NSTimer*) timer
{
    if (self.blinky.alpha == 0.0)
    {
        [UIView animateWithDuration:0.15 
                              delay:0.0 
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^(void) {self.blinky.alpha = 0.8;} 
                         completion:nil];
    }
    else
    {
        [UIView animateWithDuration:0.15 
                              delay:0.0 
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^(void) {self.blinky.alpha = 0.0;} 
                         completion:nil];
    }
}


////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) handleBecomeFirstResponder
{
    if (!self.entryField.isFirstResponder)
    {
        [self.entryField becomeFirstResponder];
    }
    self.blinky.alpha = 0.0;
    self.blinky.hidden = NO;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) handleResignFirstResponder
{
    if (self.entryField.isFirstResponder)
    {
        [self.entryField resignFirstResponder];
    }
    
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.blinkyTimer invalidate];
    self.blinky.hidden = YES;
    [super resignFirstResponder];
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) tapped: (UIGestureRecognizer*) gr
{
    [self handleBecomeFirstResponder];
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) setDecimalValue:(NSDecimalNumber *)decValue
{
    NSDecimalNumber* scale = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:10] decimalValue]];
    scale = [scale decimalNumberByRaisingToPower:[self.formatter maximumFractionDigits]];
    NSDecimalNumber* num = [decValue decimalNumberByMultiplyingBy:scale];
    
    self.entryField.text = [num stringValue];
    [self updateDisplay];

}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (NSDecimalNumber*) decimalValue
{
    NSDecimalNumber* num = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:[self.entryField.text intValue]] decimalValue]];
    NSDecimalNumber* scale = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:10] decimalValue]];
    scale = [scale decimalNumberByRaisingToPower:[self.formatter maximumFractionDigits]];
    num = [num decimalNumberByDividingBy:scale];
    
    return num;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (NSDecimalNumber*) floatToAppropriateNSDecimalNumber:(float) value
{
    NSString* floatString = [NSString stringWithFormat:@"%f",value];
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain 
                                                                                                      scale:[self.formatter maximumFractionDigits] 
                                                                                           raiseOnExactness:FALSE 
                                                                                            raiseOnOverflow:TRUE 
                                                                                           raiseOnUnderflow:TRUE 
                                                                                        raiseOnDivideByZero:TRUE]; 
    
    [self.formatter setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber* n = [self.formatter numberFromString:floatString];
    [self.formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[n decimalValue]];
    
    NSDecimalNumber *roundedDecimalNumber = [decimalNumber decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return roundedDecimalNumber;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (UIView*) fieldInputAccessoryView
{
    return _entryField.inputAccessoryView;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) setFieldInputAccessoryView:(UIView *)inputAccessoryView
{
    self.entryField.inputAccessoryView = inputAccessoryView;
}
@end
