//
//  JLTextViewController.m
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLTextViewController.h"
#import "JLTextStorage.h"
#import "JLTokenizer.h"
#import "JLTokenizer.h"
#import "CHLayoutManager.h"

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

+ (NSDictionary *)colorsFromTheme:(JLTokenizerTheme)theme;
@end

@implementation JLTextViewController
@synthesize theme = _theme, themes = _themes, colors = _colors;

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
    // Create a tokenizer
    self.tokenizer = [JLTokenizer new];
    self.tokenizer.colors = self.colors;
    
    CHLayoutManager *layoutManager = [[CHLayoutManager alloc] init];
    layoutManager.allowsNonContiguousLayout = YES;
        
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    
    _textView = [[UITextView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] textContainer:container];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _textView.scrollEnabled = YES;
    _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    _textView.font = [UIFont fontWithName:@"Menlo" size:12];
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    _textView.delegate = self;
    _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [_textView.textStorage addLayoutManager:layoutManager];
    layoutManager.textStorage = [NSTextStorage new];
    layoutManager.textStorage.delegate = self.tokenizer;

    
    self.theme = JLTokenizerThemeDusk;
    
    [self setView:_textView];
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

#pragma mark - Color Themes

- (NSDictionary *)defaultAttributes
{
    if (!_defaultAttributes) _defaultAttributes = @{NSForegroundColorAttributeName: self.colors[JLTokenTypeText], NSFontAttributeName : [UIFont fontWithName:@"Menlo" size:12]};
    return _defaultAttributes;
}

-(void)setTheme:(JLTokenizerTheme)theme
{
    self.colors = [self.class colorsFromTheme:theme];
    self.textView.typingAttributes = @{ NSForegroundColorAttributeName : self.colors[JLTokenTypeText]};
    _theme = theme;
    
    //Set font, text color and background color back to default
    UIColor *backgroundColor = self.colors[JLTokenTypeBackground];
    [self.textView setBackgroundColor:backgroundColor ? backgroundColor : [UIColor whiteColor] ];
}

- (NSDictionary *)colors
{
    if (!_colors) {
        self.colors = [self.class colorsFromTheme:self.theme];
    }
    return _colors;
}

- (void)setColors:(NSDictionary *)colors
{
    _colors = colors;
    [self.tokenizer setColors:colors];
}

- (NSArray *)themes
{
    if (!_themes) _themes = @[@(JLTokenizerThemeDefault),@(JLTokenizerThemeDusk)];
    return _themes;
}

- (JLTokenizerTheme)theme
{
    if (!_theme) _theme = JLTokenizerThemeDefault;
    return _theme;
}

// Just a bunch of colors
+ (NSDictionary *)colorsFromTheme:(JLTokenizerTheme)theme
{
    NSDictionary* colors;
    switch(theme) {
        case JLTokenizerThemeDefault:
            colors = @{JLTokenTypeText: [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],
                           JLTokenTypeBackground: [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],
                           JLTokenTypeComment: [UIColor colorWithRed:0.0/255 green:131.0/255 blue:39.0/255 alpha:1],
                           JLTokenTypeDocumentationComment: [UIColor colorWithRed:0.0/255 green:131.0/255 blue:39.0/255 alpha:1],
                           JLTokenTypeDocumentationCommentKeyword: [UIColor colorWithRed:0.0/255 green:76.0/255 blue:29.0/255 alpha:1],
                           JLTokenTypeString: [UIColor colorWithRed:211.0/255 green:45.0/255 blue:38.0/255 alpha:1],
                           JLTokenTypeCharacter: [UIColor colorWithRed:40.0/255 green:52.0/255 blue:206.0/255 alpha:1],
                           JLTokenTypeNumber: [UIColor colorWithRed:40.0/255 green:52.0/255 blue:206.0/255 alpha:1],
                           JLTokenTypeKeyword: [UIColor colorWithRed:188.0/255 green:49.0/255 blue:156.0/255 alpha:1],
                           JLTokenTypePreprocessor: [UIColor colorWithRed:120.0/255 green:72.0/255 blue:48.0/255 alpha:1],
                           JLTokenTypeURL: [UIColor colorWithRed:21.0/255 green:67.0/255 blue:244.0/255 alpha:1],
                           JLTokenTypeOther: [UIColor colorWithRed:113.0/255 green:65.0/255 blue:163.0/255 alpha:1],
                           JLTokenTypeOtherMethodNames :  [UIColor colorWithHex:@"7040a6" alpha:1],
                           JLTokenTypeOtherClassNames :  [UIColor colorWithHex:@"7040a6" alpha:1]
                           
                           
                           
                           };
            break;
        case JLTokenizerThemeDusk:
            colors = @{JLTokenTypeText: [UIColor whiteColor],
                           JLTokenTypeBackground: [UIColor colorWithRed:30.0/255.0 green:32.0/255.0 blue:40.0/255.0 alpha:1],
                           JLTokenTypeComment: [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
                           JLTokenTypeDocumentationComment: [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
                           JLTokenTypeDocumentationCommentKeyword: [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
                           JLTokenTypeString: [UIColor colorWithRed:230.0/255 green:66.0/255 blue:75.0/255 alpha:1],
                           JLTokenTypeCharacter: [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],
                           JLTokenTypeNumber: [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],
                           JLTokenTypeKeyword: [UIColor colorWithRed:195.0/255 green:55.0/255 blue:149.0/255 alpha:1],
                           JLTokenTypePreprocessor: [UIColor colorWithRed:198.0/255.0 green:124.0/255.0 blue:72.0/255.0 alpha:1],
                           JLTokenTypeURL: [UIColor colorWithRed:35.0/255 green:63.0/255 blue:208.0/255 alpha:1],
                           JLTokenTypeOther: [UIColor colorWithRed:0.0/255 green:175.0/255 blue:199.0/255 alpha:1],
                           JLTokenTypeOtherClassNames :  [UIColor colorWithHex:@"04afc8" alpha:1],
                           JLTokenTypeOtherMethodNames :  [UIColor colorWithHex:@"04afc8" alpha:1]
                           };
            break;
    }
    return colors;
}

@end
