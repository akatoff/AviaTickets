//
//  ASTWebBrowserViewController.m
//  AviasalesSDKTemplate
//
//  Created by Seva Billevich on 23.01.14.
//  Copyright (c) 2014 Go Travel Un LImited. All rights reserved.
//

#import "ASTWebBrowserViewController.h"

@interface ASTWebBrowserViewController () {
    NSURLRequest *_request;
}

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIView *waitingView;
@property (nonatomic, weak) IBOutlet UILabel *waitingLabel;

@end

@implementation ASTWebBrowserViewController

- (id)initWithRequest:(NSURLRequest *)request {
    self = [super initWithNibName:@"ASTWebBrowserViewController" bundle:AVIASALES_BUNDLE];
    if (self) {
        _request = request;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_webView setScalesPageToFit:YES];
    
    _waitingView.hidden = NO;
    [self.view addSubview:_waitingView];
    [_waitingLabel setText:AVIASALES_(@"AVIASALES_PLEASE_WAIT")];
    
    if (_request && [_request isKindOfClass:[NSURLRequest class]]) {
        [_webView loadRequest:_request];
    }
}

- (void)viewWillLayoutSubviews {
    [_waitingView setFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_waitingView setHidden:YES];
}
    
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_waitingView setHidden:YES];
}

@end
