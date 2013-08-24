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

- (JLTextView *)textView
{
    if (!_textView) {
        CGRect newTextViewRect = CGRectInset(self.view.bounds, 8., 0.);
        
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(newTextViewRect.size.width, CGFLOAT_MAX)];
        container.widthTracksTextView = YES;
        [layoutManager addTextContainer:container];
        
        NSTextStorage *textStorage = [[NSTextStorage alloc] init];
        [textStorage addLayoutManager:layoutManager];
        
        JLTextView *textView = [[JLTextView alloc] initWithFrame:newTextViewRect textContainer:container];
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
    
    self.textView.frame = self.view.frame;
    [self.view addSubview:self.textView];
    self.view.backgroundColor = self.textView.backgroundColor;
    self.navigationController.navigationBar.translucent = TRUE;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's
    // coordinate system. The bottom of the text view's frame should align with the top
    // of the keyboard's final position.
    //
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.textView.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.textView.frame = self.view.bounds;
    
    [UIView commitAnimations];
}

@end
