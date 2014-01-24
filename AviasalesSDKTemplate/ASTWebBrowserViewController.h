//
//  ASTWebBrowserViewController.h
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 23.01.14.
//  Copyright (c) 2014 Go Travel Un LImited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASTWebBrowserViewController : UIViewController<UIWebViewDelegate>

- (id)initWithRequest:(NSURLRequest *)request;

@end
