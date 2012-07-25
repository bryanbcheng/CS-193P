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

- (void)removeEquals {
    if ([self.input.text hasSuffix:@"= "]) {
        self.input.text = [self.input.text substringToIndex:[self.input.text length] - 2];
    }
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    
    if (self.userIsInTheMiddeOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        [self removeEquals];
        
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
            [self removeEquals];
        }
        
        self.userIsInTheMiddeOfEnteringANumber = YES;
        self.decimalPlaced = YES;
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self removeEquals];
    [self appendInput:self.display.text];
    [self appendInput:@"="];
    self.userIsInTheMiddeOfEnteringANumber = NO;
    self.decimalPlaced = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    [self removeEquals];
    NSString *operation = [sender currentTitle];
    
    if (self.userIsInTheMiddeOfEnteringANumber) {
        if ([operation isEqualToString:@"+/-"]) {
            self.display.text = [NSString stringWithFormat:@"%g", -[self.display.text doubleValue]];
            return;
        }
        [self enterPressed];
    }
    
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self appendInput:operation];
    [self appendInput:@"="];
}

- (IBAction)clearPressed {
    [self.brain clear];
    self.display.text = @"0";
    self.input.text = @"";
    self.userIsInTheMiddeOfEnteringANumber = NO;
    self.decimalPlaced = NO;
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
        [self removeEquals];
    }
}

@end
