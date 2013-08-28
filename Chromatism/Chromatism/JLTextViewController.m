//
//  JLTextViewController.m
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLTextViewController.h"
#import "JLTokenizer.h"
#import "JLTokenizer.h"
#import "JLTextView.h"

@interface JLTextViewController ()
/// Only set from -initWithText: and directly set to nil in -loadView
@property (nonatomic, strong) NSString *defaultText;
@end

@implementation JLTextViewController

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        _defaultText = text;
    }
    return self;
}

- (void)loadView
{
    self.view = self.textView;
}

- (JLTextView *)textView
{
    if (!_textView) {
        JLTextView *textView = [[JLTextView alloc] initWithFrame:CGRectZero];
        textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        if (self.defaultText) {
            textView.text = self.defaultText;
            self.defaultText = nil;
        }
        
        [self setTextView:textView];
    }
    return _textView;
}

- (JLTokenizer *)tokenizer
{
    return self.textView.syntaxTokenizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = self.textView.backgroundColor;
    self.navigationController.navigationBar.translucent = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
