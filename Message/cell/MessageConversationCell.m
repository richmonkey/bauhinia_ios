//
//  MessageConversationCell.m
//  Message
//
//  Created by daozhu on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageConversationCell.h"


//#define kCatchWidth 148.0f
#define kCatchWidth 74.0f


@interface MessageConversationCell () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *myScrollView;
@property (nonatomic, weak) UIView *scrollViewContentView;
@property (nonatomic, weak) UIView *scrollViewButtonView;

@end


@implementation MessageConversationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
    
    CALayer *imageLayer = [self.headView layer];   //获取ImageView的层
    [imageLayer setMasksToBounds:YES];
    [imageLayer setCornerRadius:self.headView.frame.size.width/2];
    
}

- (void)setup {

	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
	scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + kCatchWidth, CGRectGetHeight(self.bounds));
	scrollView.delegate = self;
	scrollView.showsHorizontalScrollIndicator = NO;
	

	
	UIView *scrollViewButtonView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - kCatchWidth, 0.0f, kCatchWidth, CGRectGetHeight(self.bounds))];
	self.scrollViewButtonView = scrollViewButtonView;
	[scrollView addSubview:scrollViewButtonView];
/*
	// Set up our two buttons
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
	moreButton.frame = CGRectMake(0.0f, 0.0f, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
	[moreButton setTitle:@"更多" forState:UIControlStateNormal];
	[moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[moreButton addTarget:self action:@selector(userPressedMoreButton:) forControlEvents:UIControlEventTouchUpInside];
	[self.scrollViewButtonView addSubview:moreButton];
    
*/
	UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	deleteButton.backgroundColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f];
//	deleteButton.frame = CGRectMake(kCatchWidth / 2.0f, 0.0f, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
    	deleteButton.frame = CGRectMake(0.0f, 0.0f, kCatchWidth, CGRectGetHeight(self.bounds));
	[deleteButton setTitle:@"删除" forState:UIControlStateNormal];
	[deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[deleteButton addTarget:self action:@selector(userPressedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
	[self.scrollViewButtonView addSubview:deleteButton];
	
    //使用自己的contentView
    self.scrollViewContentView = self.myContentView;
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.scrollViewContentView addGestureRecognizer:singleFingerTap];
    
	[scrollView addSubview: self.scrollViewContentView];
   
    [self.contentView addSubview: scrollView];
	self.myScrollView = scrollView;
    
}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.delegate orignalCellDidSelected:self];
}


- (void)hideMenuOptions {
	[self.myScrollView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Private Methods

- (void)userPressedDeleteButton:(id)sender {
	[self.delegate cellDidSelectDelete:self];
	[self.myScrollView setContentOffset:CGPointZero animated:YES];
}

- (void)userPressedMoreButton:(id)sender {
	[self.delegate cellDidSelectMore:self];
}

#pragma mark - Overridden Methods

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.myScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + kCatchWidth, CGRectGetHeight(self.bounds));
	self.myScrollView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
	self.scrollViewButtonView.frame = CGRectMake(CGRectGetWidth(self.bounds) - kCatchWidth, 0.0f, kCatchWidth, CGRectGetHeight(self.bounds));
	self.scrollViewContentView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
}

- (void)prepareForReuse {
	[super prepareForReuse];
	[self.myScrollView setContentOffset:CGPointZero animated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	self.myScrollView.scrollEnabled = !self.editing;
    self.scrollViewButtonView.hidden = editing;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if (scrollView.contentOffset.x > kCatchWidth) {
        targetContentOffset->x = kCatchWidth;
    }
    else {
        *targetContentOffset = CGPointZero;
        dispatch_async(dispatch_get_main_queue(), ^{
            [scrollView setContentOffset:CGPointZero animated:YES];
        });
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointZero;
    }
    
    self.scrollViewButtonView.frame = CGRectMake(scrollView.contentOffset.x + (CGRectGetWidth(self.bounds) - kCatchWidth), 0.0f, kCatchWidth, CGRectGetHeight(self.bounds));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
