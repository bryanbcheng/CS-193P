//
//  CalculatorBrain.m
//  Assignment2_Programmable_Calculator
//
//  Created by Cheng Bocong on 12/07/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end


@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack {
    if (!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (id)program {
    return [self.programStack copy];
}

+ (NSString *)describeProgram:(NSMutableArray *)stack {
    NSString *description = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        description = [topOfStack stringValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *symbol = topOfStack;
        
        // Need to add parantheses
        if ([symbol isEqualToString:@"+"]) {
            NSString *addend = [self describeProgram:stack];
            description = [NSString stringWithFormat:@"%@ + %@", [self describeProgram:stack], addend];
        } else if ([symbol isEqualToString:@"*"]) {
            NSString *multiplier = [self describeProgram:stack];
            description = [NSString stringWithFormat:@"%@ * %@", [self describeProgram:stack], multiplier];
        } else if ([symbol isEqualToString:@"-"]) {
            NSString *subtrahend = [self describeProgram:stack];
            description = [NSString stringWithFormat:@"%@ - %@", [self describeProgram:stack], subtrahend];
        } else if ([symbol isEqualToString:@"/"]) {
            NSString *divisor = [self describeProgram:stack];
            description = [NSString stringWithFormat:@"%@ / %@", [self describeProgram:stack], divisor];
        } else if ([symbol isEqualToString:@"sin"]) {
            description = [NSString stringWithFormat:@"sin(%@)", [self describeProgram:stack]];
        } else if ([symbol isEqualToString:@"cos"]) {
            description = [NSString stringWithFormat:@"cos(%@)", [self describeProgram:stack]];
        } else if ([symbol isEqualToString:@"sqrt"]) {
            description = [NSString stringWithFormat:@"sqrt(%@)", [self describeProgram:stack]];
        } else if ([symbol isEqualToString:@"log"]) {
            description = [NSString stringWithFormat:@"log(%@)", [self describeProgram:stack]];
        } else if ([symbol isEqualToString:@"+/-"]) {
            description = [NSString stringWithFormat:@"-(%@)", [self describeProgram:stack]];
        } else {
            // For variables, pi, e
            description = symbol;
        }
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSString *description = @"";
    while ([stack count] != 0) {
        if ([description isEqualToString:@""]) {
            description = [self describeProgram:stack];
        } else {
            description = [NSString stringWithFormat:@"%@, %@", description, [self describeProgram:stack]];
        }
    }
    return description;
}

- (void)pushOperand:(double)operand {
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariable:(NSString *)variable {
    [self.programStack addObject:variable];
}

- (double)performOperation:(NSString *)operation {
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack {
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else if ([operation isEqualToString:@"e"]) {
            result = M_E;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            double operand = [self popOperandOffProgramStack:stack];
            // No imaginary numbers
            if (operand >= 0) result = sqrt(operand);
        } else if ([operation isEqualToString:@"log"]) {
            double operand = [self popOperandOffProgramStack:stack];
            // Log cannot take negative numbers and log(0) = -inf
            if (operand > 0) result = sqrt(operand); 
        } else if ([operation isEqualToString:@"+/-"]) {
            result = -[self popOperandOffProgramStack:stack];
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        
        // replace variables with values
    }
    return [self popOperandOffProgramStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program {
    return nil;
}

- (void)undoProgram {
    if ([self.programStack count] != 0) [self.programStack removeLastObject];
}

- (void)clear {
    [self.programStack removeAllObjects];
}

@end
