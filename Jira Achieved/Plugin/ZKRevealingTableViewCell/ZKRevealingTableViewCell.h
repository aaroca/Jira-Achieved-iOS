//
//  ZKRevealingTableViewCell.h
//  ZKRevealingTableViewCell
//
//  Created by Alex Zielenski on 4/29/12.
//  Copyright (c) 2012 Alex Zielenski.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense,  and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//
//  DDBadgeViewCell.m
//  DDBadgeViewCell
//
//  Created by digdog on 1/23/10.
//  Copyright 2010 Ching-Lan 'digdog' HUANG. http://digdog.tumblr.com
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//   
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//   
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>

@class ZKRevealingTableViewCell;
@class DDBadgeView;

typedef enum {
	ZKRevealingTableViewCellDirectionRight = 0,
	ZKRevealingTableViewCellDirectionLeft,
	ZKRevealingTableViewCellDirectionBoth,
	ZKRevealingTableViewCellDirectionNone,
} ZKRevealingTableViewCellDirection;

@protocol ZKRevealingTableViewCellDelegate <NSObject>

@optional
- (BOOL)cellShouldReveal:(ZKRevealingTableViewCell *)cell;
- (void)cellDidBeginPan:(ZKRevealingTableViewCell *)cell;
- (void)cellDidReveal:(ZKRevealingTableViewCell *)cell;

@end

@interface ZKRevealingTableViewCell : UITableViewCell {
@private
	DDBadgeView *	badgeView_;
	
	NSString *		summary_;
	NSString *		detail_;
	NSString *		badgeText_;
	UIColor *		badgeColor_;
	UIColor *		badgeHighlightedColor_;
}

@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, assign, getter = isRevealing) BOOL revealing;
@property (nonatomic, assign) id <ZKRevealingTableViewCellDelegate> delegate;
@property (nonatomic, assign) ZKRevealingTableViewCellDirection direction;
@property (nonatomic, assign) BOOL shouldBounce;

@property (nonatomic, copy) NSString *      summary;
@property (nonatomic, copy) NSString *      detail;
@property (nonatomic, copy) NSString *		badgeText;
@property (nonatomic, retain) UIColor *		badgeColor;
@property (nonatomic, retain) UIColor *		badgeHighlightedColor;

@end
