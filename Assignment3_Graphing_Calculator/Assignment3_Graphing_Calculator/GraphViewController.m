//
//  GraphViewController.m
//  Assignment3_Graphing_Calculator
//
//  Created by Cheng Bocong on 12/08/06.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>

@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UILabel *toolbarDescription;
@property (nonatomic, weak) IBOutlet UISegmentedControl *drawModeSwitch;

@end

@implementation GraphViewController

@synthesize programStack = _programStack;
@synthesize graphView = _graphView;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar; 
@synthesize toolbarDescription = _toolbarDescription;
@synthesize drawModeSwitch = _drawModeSwitch;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    if (_splitViewBarButtonItem != splitViewBarButtonItem) { 
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)setProgramDescription:(NSString *)description {
    self.navigationItem.title = description;
    self.toolbarDescription.text = description;
}

- (void)setProgramStack:(NSArray *)programStack {
    _programStack = programStack;
    
    [self setProgramDescription:[CalculatorBrain descriptionOfProgram:programStack]];
    
    [self.graphView setNeedsDisplay];
}

- (void)setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    UITapGestureRecognizer * tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tripleTap:)];
    tripleTap.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tripleTap];
    self.graphView.dataSource = self;
}

- (IBAction)drawModeSwitched:(UISegmentedControl *)sender {
    [self.graphView setNeedsDisplay];
}

- (float)yValueForGraphView:(GraphView *)sender
              atXCoordinate:(float)x
{
    NSDictionary *xValue = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:x], @"x", nil];
    return [CalculatorBrain runProgram:self.programStack usingVariableValues:xValue];
}

- (NSString *)drawMode
{
    return [self.drawModeSwitch titleForSegmentAtIndex:[self.drawModeSwitch selectedSegmentIndex]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
- (void)viewDidUnload {
    [self setToolbarDescription:nil];
    [self setDrawModeSwitch:nil];
    [super viewDidUnload];
}
@end
