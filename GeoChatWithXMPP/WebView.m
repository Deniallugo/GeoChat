//
//  WebView.m
//  GeoChatWithXMPP
//
//  Created by Данил on 20.03.15.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "WebView.h"


@interface WebView ()

@end

@implementation WebView

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];

    NSURL* url = [NSURL URLWithString:@"http://apple.com"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];

    [webView loadRequest:request];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
