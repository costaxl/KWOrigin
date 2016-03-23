//
//  IDZViewController.m
//  IDZWebBrowser
//
//  Created by idz on 11/16/13.
//
// Copyright (c) 2013 iOSDeveloperZone.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "DocBrowserController.h"
#import "GUIModelService.h"

@interface DocBrowserController () <UIWebViewDelegate>
@property (nonatomic,retain) IBOutlet UIWebView *webView;

- (void)loadRequestFromString:(NSString*)urlString;
- (void)updateButtons;
@end
#define TestDOCURL "ShareViewSWFS_v0.7_130716.doc"
#define TestXLSURL "User stories.xls"
#define TestPPTURL "Peer_Media_Streaming_Protocol.ppt"


@implementation DocBrowserController
@synthesize fileName;

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
    NSAssert([self.webView isKindOfClass:[UIWebView class]], @"You webView outlet is not correctly connected.");
	// Do any additional setup after loading the view, typically from a nib.
    self.webView.delegate = self;
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:self.fileName];

    //[self loadRequestFromString:@"http://iosdeveloperzone.com"];
    //[self loadRequestFromString:@"https://developer.apple.com/library/ios/DOCUMENTATION/UIKit/Reference/UIViewController_Class/UIViewController_Class.pdf"];
    [self loadRequestFromString:[fileURL absoluteString]];

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_WillAbsent];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                        object:nil userInfo:dic];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // enter present state
 
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
    dic[@"PresentState"] = [NSNumber numberWithInt:kNSSPresentState_Present];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSPresentStateDidChangeNotification
                                                        object:self.view userInfo:dic];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRequestFromString:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}

#pragma mark - Updating the UI
- (void)updateButtons
{
    NSLog(@"%s loading = %@", __PRETTY_FUNCTION__, self.webView.loading ? @"YES" : @"NO");
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

@end
