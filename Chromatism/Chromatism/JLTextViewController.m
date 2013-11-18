//
//  JLTextViewController.m
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-13.
//  Copyright (c) 2013 Johannes Lund
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.//

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
    
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Content Insets and Keyboard

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    UIScrollView *scrollView = self.textView;
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = scrollView.contentInset;
    contentInsets.bottom = kbSize.height;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    CGPoint point = [self.textView caretRectForPosition:self.textView.selectedTextRange.start].origin;
    point.y = MIN(point.y, self.textView.frame.size.height - kbSize.height);
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, point) ) {
        
        CGRect rect = CGRectMake(point.x, point.y, 1, 1);
        rect.size.height = kbSize.height;
        rect.origin.y += kbSize.height;
        [self.textView scrollRectToVisible:rect animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    UIScrollView *scrollView = self.textView;
    UIEdgeInsets contentInsets = scrollView.contentInset;
    contentInsets.bottom = 0;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

@end
