//
//  UIXCurrencyTextField.h
//  UIXCurrencyTextField
//
//  Created by Guy Umbright on 8/23/11.
//  Copyright 2011 Kickstand Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIXCurrencyTextField;

@protocol UIXCurrencyTextFieldDelegate

//return YES if editing should stop
- (BOOL)currencyTextFieldShouldEndEditing:(UIXCurrencyTextField *)currencyTextField;

@end

@interface UIXCurrencyTextField : UIView <UITextFieldDelegate>

@property (nonatomic, readwrite) UIColor* textColor;
@property (nonatomic, readwrite) UIFont* font;
@property (nonatomic, assign) CGFloat caretWidth;

@property (nonatomic, strong) UIView* inputAccessoryView;

@property (nonatomic, assign) float value;
@property (unsafe_unretained, nonatomic, readonly) NSDecimalNumber* decimalValue;
@property (nonatomic, unsafe_unretained) NSObject<UIXCurrencyTextFieldDelegate>* delegate;

- (void) setDecimalValue:(NSDecimalNumber *)decimalValue;

//utility
- (NSDecimalNumber*) floatToAppropriateNSDecimalNumber:(float) f;


@end
