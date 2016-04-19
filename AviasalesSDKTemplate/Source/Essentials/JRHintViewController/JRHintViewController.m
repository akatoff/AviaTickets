//
//  JRHintViewController.m
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 08/04/14.
//
//

#import "JRHintViewController.h"

#define kDefaultWidth 290.f

@interface JRHintViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toTitleMargin;

@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *text;

@property (nonatomic) CGFloat width;
@end

@implementation JRHintViewController

- (id)initWithText:(NSString *)text andTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _text = text;
        _titleText = title;
        
        _width = kDefaultWidth;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutViews];
}

- (void)layoutViews
{
    CGRect viewFrame = self.view.frame;
    viewFrame.size.width = self.width;
    self.view.frame = viewFrame;
    
    _titleLabel.text = _titleText;
    _textLabel.text = _text;
    
    if (!_titleText) {
        _toTitleMargin.constant = 0;
        _titleLabel.hidden = YES;
    }
    
    [self.view layoutIfNeeded];
    
    viewFrame.size.height = CGRectGetMaxY(_textLabel.frame) + 16.f;
    self.view.frame = viewFrame;
}


@end
