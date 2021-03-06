/*
 * Hedgewars-iOS, a Hedgewars port for iOS devices
 * Copyright (c) 2009-2011 Vittorio Giovara <vittorio.giovara@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * File created on 30/08/2010.
 */


#import "HelpPageViewController.h"
#import "CommodityFunctions.h"

@implementation HelpPageViewController
@synthesize scrollView;

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
    return rotationManager(interfaceOrientation);
}

-(void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.scrollView = nil;
}

// on iPhone the XIBs contain UIScrollView
-(void) viewDidLoad {
    if (scrollView.tag == 0)    // ipad
        scrollView.contentSize = CGSizeMake(480,650);
    else                        // iphone
        scrollView.contentSize = CGSizeMake(480,470);
    scrollView.maximumZoomScale = 4.0;
    scrollView.minimumZoomScale = 0.75;
    scrollView.clipsToBounds = YES;
    scrollView.delegate = self;
    [super viewDidLoad];
}

-(void) viewDidUnload {
    [super viewDidUnload];
    self.scrollView = nil;
}

-(void) dealloc {
    [scrollView release];
    [super dealloc];
}

-(IBAction) dismiss {
    [UIView beginAnimations:@"helpingame" context:NULL];
    self.view.alpha = 0;
    [UIView commitAnimations];
    [self.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];
}

@end
