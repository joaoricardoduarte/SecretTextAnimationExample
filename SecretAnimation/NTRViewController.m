//
//  NTRViewController.m
//  SecretAnimation
//
//  Created by Natasha Murashev on 4/13/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRViewController.h"

@interface NTRViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel1;
@property (weak, nonatomic) IBOutlet UILabel *textLabel2;

@property (strong, nonatomic) NSAttributedString *attributedString;
@property (assign, nonatomic) NSUInteger numWhiteCharacters;

@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UILabel *bottomLabel;

@end

@implementation NTRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textLabel1.alpha = 0;
    self.textLabel2.alpha = 0;
    
    // this is based on the view hierarchy in the storyboard
    self.topLabel = self.textLabel2;
    self.bottomLabel = self.textLabel1;
    
    NSString *mySecretMessage = @"This is a my replication of Secret's text animation. It looks like one fancy label, but it's actually two UITextLabels on top of each other! What do you think?";
    
    self.numWhiteCharacters = 0;
    
    __block NSAttributedString *initialAttributedText = [self randomlyFadedAttributedStringFromString:mySecretMessage];
    self.topLabel.attributedText = initialAttributedText;
    
    __weak NTRViewController *weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.topLabel.alpha = 1;
    } completion:^(BOOL finished) {
        weakSelf.attributedString = [weakSelf randomlyFadedAttributedStringFromAttributedString:initialAttributedText];
        weakSelf.bottomLabel.attributedText = weakSelf.attributedString;
        [weakSelf performAnimation];
    }];
}

- (void)performAnimation
{
    __weak NTRViewController *weakSelf = self;
    [UILabel animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         weakSelf.bottomLabel.alpha = 1;
                     } completion:^(BOOL finished) {
                         [weakSelf resetLabels];
                         
                         // keep performing the animation until all letters are white
                         if (weakSelf.numWhiteCharacters == [weakSelf.attributedString length]) {
                             [weakSelf.bottomLabel removeFromSuperview];
                         } else {
                             [weakSelf performAnimation];
                         }
                     }];
}

- (void)resetLabels
{
    [self.topLabel removeFromSuperview];
    self.topLabel.alpha = 0;
    
    // recalculate attributed string with the new white color values
    self.attributedString = [self randomlyFadedAttributedStringFromAttributedString:self.attributedString];
    self.topLabel.attributedText = self.attributedString;
    
    [self.view insertSubview:self.topLabel belowSubview:self.bottomLabel];
    
    //  the top label is now on the bottom, so switch
    UILabel *oldBottom = self.bottomLabel;
    UILabel *oldTopLabel = self.topLabel;
    
    self.bottomLabel = oldTopLabel;
    self.topLabel = oldBottom;
}

- (NSAttributedString *)randomlyFadedAttributedStringFromString:(NSString *)string
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    for (NSUInteger i = 0; i < [string length]; i ++) {
        UIColor *color = [self whiteColorWithClearColorProbability:10];
        [attributedString addAttribute:NSForegroundColorAttributeName value:(id)color range:NSMakeRange(i, 1)];
        [self updateNumWhiteCharactersForColor:color];
    }
    
    return [attributedString copy];
}

- (NSAttributedString *)randomlyFadedAttributedStringFromAttributedString:(NSAttributedString *)attributedString
{
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    
    __weak NTRViewController *weakSelf = self;
    for (NSUInteger i = 0; i < attributedString.length; i ++) {
        [attributedString enumerateAttribute:NSForegroundColorAttributeName
                                     inRange:NSMakeRange(i, 1)
                                     options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                                      UIColor *initialColor = value;
                                      UIColor *newColor = [weakSelf whiteColorFromInitialColor:initialColor];
                                      if (newColor) {
                                          [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:newColor range:range];
                                          [weakSelf updateNumWhiteCharactersForColor:newColor];
                                      }
                                  }];
        
    }
    
    return [mutableAttributedString copy];
}

- (void)updateNumWhiteCharactersForColor:(UIColor *)color
{
    CGFloat alpha = CGColorGetAlpha(color.CGColor);
    if (alpha == 1.0) {
        self.numWhiteCharacters++;
    }
}

- (UIColor *)whiteColorFromInitialColor:(UIColor *)initialColor
{
    UIColor *newColor;
    if ([initialColor isEqual:[UIColor clearColor]])
    {
        newColor = [self whiteColorWithClearColorProbability:4];
    } else {
        CGFloat alpha = CGColorGetAlpha(initialColor.CGColor);
        if (alpha != 1.0) {
            newColor = [self whiteColorWithMinAlpha:alpha];
        }
    }
    return newColor;
}

- (UIColor *)whiteColorWithClearColorProbability:(NSInteger)probability
{
    UIColor *color;
    NSInteger colorIndex = arc4random() % probability;
    if (colorIndex != 0) {
        color = [UIColor clearColor];
    } else {
        color = [self whiteColorWithMinAlpha:0];
    }
    return color;
}

- (UIColor *)whiteColorWithMinAlpha:(CGFloat)minAlpha
{
    NSInteger randomNumber = minAlpha * 100 + arc4random_uniform(100 - minAlpha * 100 + 1);
    CGFloat randomAlpha = randomNumber / 100.0;
    return [UIColor colorWithWhite:1.0 alpha:randomAlpha];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
