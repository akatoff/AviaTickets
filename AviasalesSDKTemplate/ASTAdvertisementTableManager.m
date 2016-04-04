//
//  ASTAdvertisementTableManager.m
//  AviasalesSDKTemplate
//
//  Created by Denis Chaschin on 04.04.16.
//  Copyright © 2016 Go Travel Un LImited. All rights reserved.
//

#import "ASTAdvertisementTableManager.h"

static NSString *const kCellReusableId = @"ASTAdvertisementTableManagerAdCell";
static NSInteger const kAdViewTag = 567134;

@implementation ASTAdvertisementTableManager

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.ads.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *res = [tableView dequeueReusableCellWithIdentifier:kCellReusableId];

    if (res == nil) {
        res = [[UITableViewCell alloc] init];
    } else {
        [[res.contentView viewWithTag:kAdViewTag] removeFromSuperview];
    }

    UIView *const adView = self.ads[indexPath.section];
    [adView removeFromSuperview];
    adView.frame = res.contentView.bounds;
    adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [res.contentView addSubview:adView];
    return res;
}
@end
