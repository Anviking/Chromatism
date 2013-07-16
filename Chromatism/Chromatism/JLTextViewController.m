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

NSString *const JLTokenTypeText = @"text";
NSString *const JLTokenTypeBackground = @"background";
NSString *const JLTokenTypeComment = @"comment";
NSString *const JLTokenTypeDocumentationComment = @"documentation_comment";
NSString *const JLTokenTypeDocumentationCommentKeyword = @"documentation_comment_keyword";
NSString *const JLTokenTypeString = @"string";
NSString *const JLTokenTypeCharacter = @"character";
NSString *const JLTokenTypeNumber = @"number";
NSString *const JLTokenTypeKeyword = @"keyword";
NSString *const JLTokenTypePreprocessor = @"preprocessor";
NSString *const JLTokenTypeURL = @"url";
NSString *const JLTokenTypeAttribute = @"attribute";
NSString *const JLTokenTypeProject = @"project";
NSString *const JLTokenTypeOther = @"other";
NSString *const JLTokenTypeOtherMethodNames = @"other_method_names";
NSString *const JLTokenTypeOtherClassNames = @"other_class_names";

@interface JLTextViewController ()

@end

@implementation JLTextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    JLTextView *textView = [[JLTextView alloc] init];
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self setView:textView];
    [self setTextView:textView];
}

- (JLTokenizer *)tokenizer
{
    return self.textView.syntaxTokenizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = TRUE;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
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

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up {
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.textView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    keyboardFrame.size.height -= self.tabBarController.tabBar.frame.size.height;
    newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
    self.textView.frame = newFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:NO];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}



@end
