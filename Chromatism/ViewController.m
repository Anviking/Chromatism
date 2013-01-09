//
//  ViewController.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-01-08.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "ViewController.h"
#import "JLTextView.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //There are some problems with the textView when setting text while its frame isn't yet set.
    self.textView.text = [[NSString alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"text" withExtension:@"txt"] encoding:NSUTF8StringEncoding error:nil];
}

- (void)loadView
{
    JLTextView *textView = [[JLTextView alloc] initWithFrame:CGRectZero];
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    textView.font = [UIFont fontWithName:@"Menlo-Regular" size:13];
    textView.syntaxTokenizer = [[JLTokenizer alloc] init];
    textView.syntaxTokenizer.theme = kTokenizerThemeDusk;
    self.view = textView;
    self.textView = textView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
