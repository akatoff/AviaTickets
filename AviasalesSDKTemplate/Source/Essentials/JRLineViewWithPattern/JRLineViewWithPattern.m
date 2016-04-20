//
//  JRVerticalLineViewWithPattern.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRLineViewWithPattern.h"
#import "NSLayoutConstraint+JRConstraintMake.h"

@interface JRLineViewWithPattern ()
@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@end


@implementation JRLineViewWithPattern

static void * JRSearchFormLineViewFrameChangeContext = &JRSearchFormLineViewFrameChangeContext;

- (void)setPatternImage:(UIImage *)patternImage
{
	[self setBackgroundColor:nil];
	if (!_patternImage) {
        
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
		_patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
        
		UIImageView *dots = [[UIImageView alloc] initWithImage:_patternImage highlightedImage:_patternImage];
		[dots setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self addSubview:dots];
        
        
		[self addConstraint:JRConstraintMake(dots, NSLayoutAttributeCenterX, NSLayoutRelationEqual, self, NSLayoutAttributeCenterX, 1, 0)];
		[self addConstraint:JRConstraintMake(dots, NSLayoutAttributeCenterY, NSLayoutRelationEqual, self, NSLayoutAttributeCenterY, 1, 0)];
        
		_widthConstraint = JRConstraintMake(dots, NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, 0);
		_heightConstraint = JRConstraintMake(dots, NSLayoutAttributeHeight, NSLayoutRelationEqual, nil, NSLayoutAttributeNotAnAttribute, 1, 0);
        
		[self addConstraint:_widthConstraint];
		[self addConstraint:_heightConstraint];
        
		[self updateImageViewSize];
        
		[self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:JRSearchFormLineViewFrameChangeContext];
	}
}

- (void)updateImageViewSize
{
	CGFloat heightConstant = floorf(self.bounds.size.height / _patternImage.size.height) * _patternImage.size.height;
	CGFloat widthConstant = floorf(self.bounds.size.width / _patternImage.size.width) * _patternImage.size.width;
	_heightConstraint.constant = isfinite(heightConstant) ? heightConstant : 0;
	_widthConstraint.constant = isfinite(widthConstant) ? widthConstant : 0;
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if (context == JRSearchFormLineViewFrameChangeContext) {
		[self updateImageViewSize];
	}
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"bounds" context:JRSearchFormLineViewFrameChangeContext];
}

@end

