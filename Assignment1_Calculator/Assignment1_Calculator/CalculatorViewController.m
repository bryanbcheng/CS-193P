//
//  CalculatorViewController.m
//  Assignment1_Calculator
//
//  Created by Cheng Bocong on 12/07/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddeOfEnteringANumber;
@property (nonatomic) BOOL decimalPlaced;
@property (nonatomic, strong) CalculatorBrain *brain;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize input = _input;
@synthesize userIsInTheMiddeOfEnteringANumber = _userIsInTheMiddeOfEnteringANumber;
@synthesize decimalPlaced = _decimalPlaced;
@synthesize brain = _brain;

- (CalculatorBrain *)brain {
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)appendInput:(NSString *)newInput {
    self.input.text = [self.input.text stringByAppendingFormat:@"%@%@", newInput, @" "];
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    
    if (self.userIsInTheMiddeOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        
        // Prevent multiple leading 0 fix
        if (![digit isEqualToString:@"0"]) {
            self.userIsInTheMiddeOfEnteringANumber = YES;
        }
    }
}

- (IBAction)decimalPressed {
    if (!self.decimalPlaced) {
        if (self.userIsInTheMiddeOfEnteringANumber) {
            self.display.text = [self.display.text stringByAppendingString:@"."];
        } else {
            // Start new number with decimal
            self.display.text = @"0.";
        }
        
        self.userIsInTheMiddeOfEnteringANumber = YES;
        self.decimalPlaced = YES;
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self appendInput:self.display.text];
    self.userIsInTheMiddeOfEnteringANumber = NO;
    self.decimalPlaced = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddeOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self appendInput:operation];
}

- (IBAction)clearPressed {
    [self.brain clear];
    self.display.text = @"0";
    self.userIsInTheMiddeOfEnteringANumber = NO;
}
- (IBAction)backspacePressed {
    if (self.userIsInTheMiddeOfEnteringANumber) {
        if ([self.display.text length] == 1) {
            self.display.text = @"0";
            self.userIsInTheMiddeOfEnteringANumber = NO;
        } else {
            self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
        }
    } else {
        // Reset display to 0 if backspace pushed after operation
        self.display.text = @"0";
    }
}

@end
