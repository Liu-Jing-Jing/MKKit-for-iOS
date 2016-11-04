//
//  DetailViewController.m
//  WXWeibo


#import "DetailViewController.h"
#import "WeiboView.h"
#import "WeiboModel.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "CommentTableView.h"
#import "CommentModel.h"
#import "MKImageView.h"
#import "UserViewController.h"
#import "UserInfoDataModel.h"
#import "MJRefresh/MJRefresh.h"
@interface DetailViewController () // <UITableViewEvenDelegate>

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) NSDictionary *commentDic;
@end

@implementation DetailViewController
- (void)awakeFromNib
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Detail";
    [self.tableView setContentInset:UIEdgeInsetsMake(-55.0f, 0.0f, 0.0f, 0.0f)];
    // self.tableView.delegate = self;
    [self initSubview];
    
    // self.userBarView.userInteractionEnabled = YES;
    // Tap
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setBlockForMKImageView:)];
    [self.userBarView addGestureRecognizer:tapGesture];
    [self setupRefreshView];
    //
    self.tableView.headerView = [self setupViewForHeaderInSection];
    self.tableView.isMore = YES;
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI
- (void)initSubview
{
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    
    // 用户基本信息栏：头像，昵称等
    // 使用Xib画
    self.userImageView.layer.cornerRadius = 21;
    self.userImageView.layer.masksToBounds = YES;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:_weiboModel.user.profile_image_url]];

    // 昵称
    self.nickLabel.text = _weiboModel.user.screen_name;
    self.userBarView.frame = CGRectMake(0, 0, ScreenWidth, 80);
    [tableHeaderView addSubview:self.userBarView];
    // tableHeaderView.height += 60; //userBarView的高度为60
    
    
    // create WeiboView------------------
    float h = [WeiboView getWeiboViewHeight:self.weiboModel isRepost:NO isDetail:YES];
    _weiboView = [[WeiboView alloc] initWithFrame:CGRectMake(10, _userBarView.bottom+10, ScreenWidth-20, h)];
    _weiboView.isDetail = YES; // important 这里写的表示创建时调整子视图的大小
    _weiboView.weiboModel = _weiboModel;
    [tableHeaderView addSubview:_weiboView];
    tableHeaderView.height += (h+100);
    
    // self.tableView.eventDelegate = self;
    self.tableView.tableHeaderView = tableHeaderView;

    
}

- (void)setupRefreshView
{
    [self.tableView addHeaderWithTarget:self action:@selector(pullDownAction)];
    
    [self.tableView addFooterWithTarget:self action:@selector(pullUpAction)];
}

#pragma mark - Data
- (void)loadData
{
    NSString *weiboID = [_weiboModel.weiboId stringValue];
    if(weiboID.length == 0) return;
    
    NSString *requestURL = [WBWeiboTool URLAppendingAccessTokenWithQueryPath:URL_COMMENT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[weiboID, @"20"] forKeys:@[@"id", @"count"]];

    [[MKHTTPTool shareInstance] requestWithURL:requestURL
                                        params:params
                                    httpMethod:@"GET"
                                 completeBlock:^(id result) {
                                     //
                                     [self loadDataFinished:result];
                                 }];
    
    /*
     access_token	true	string	采用OAuth授权方式为必填参数，OAuth授权后获得。
     id	true	int64	需要查询的微博ID。
     注意事项
     只返回授权用户的评论，非授权用户的评论将不返回；
     使用官方移动SDK调用，可多返回30%的非授权用户的评论；
     */
}

- (void)loadDataFinished:(NSDictionary *)result
{
    NSArray *array = [result objectForKey:@"comments"];
    _comments = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dic in array)
    {
        CommentModel *commentModel = [[CommentModel alloc] initWithDataDic:dic];
        [_comments addObject:commentModel];
    }
    
    // bug
    //commentDic = [NSDictionary dictionaryWithDictionary:result];
    
    CommentModel *last = [_comments lastObject];
    self.lastCommentID = [last.commentID stringValue];
    // bug
//    if(array.count>=20)
//    {
//        self.tableView.isMore = YES;
//    }
//    else
//    {
//        self.tableView.isMore = NO;
//    }

    
    self.tableView.data = _comments;
    self.tableView.commentDic = result;
    [self.tableView reloadData];
}



- (void)setBlockForMKImageView:(UITapGestureRecognizer *)tap
{
    // 防止循环引用
    // __block DetailViewController *this = self;
    // _userImageView.touchBlock = ^{
        NSString *nickName = self.weiboModel.user.screen_name;
        
        UserViewController *userVC = [[UserViewController alloc] init];
        userVC.userName = nickName;
        [self.navigationController pushViewController:userVC animated:YES];
        //};
    
}

- (UIView *)setupViewForHeaderInSection
{
    _countLabel = [[UILabel alloc] init];
    int reposts = [_weiboModel.repostsCount intValue];
    int comments = [_weiboModel.commentsCount intValue];
    // NSNumber *total = [commentDic objectForKey:@"total_number"];
    // 数据不准确 bug
    
    if (reposts>=0 && comments>=0)
    {
        _countLabel.hidden = NO;
        _countLabel.text = [NSString stringWithFormat:@"Reposts:%d  | Comments:%d",reposts, comments];
        _countLabel.font = [UIFont systemFontOfSize:12.0];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor lightGrayColor];
        _countLabel.frame  =CGRectMake(0, _weiboView.bottom+20, 80, 20);
        [_countLabel sizeToFit];
        _countLabel.right = _weiboView.right;
    }
    
    
    // 为下面的小icon计算宽度
    _commentLabel = [[UILabel alloc] init];
    _commentLabel.text = [NSString stringWithFormat:@":Comments:%d", comments];
    _commentLabel.font = [UIFont systemFontOfSize:12.0f];
    _commentLabel.backgroundColor = [UIColor clearColor];
    _commentLabel.textColor = [UIColor lightGrayColor];
    _commentLabel.frame  =CGRectMake(0, _weiboView.bottom+20, 80, 20);
    [_commentLabel sizeToFit];
    
    
    _countLabel.top = 5;
    UIView *selected_icon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _commentLabel.width-4, 1)];
    selected_icon.backgroundColor = [UIColor blackColor];
    selected_icon.top = _countLabel.bottom+5;
    selected_icon.right = _countLabel.right;
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    [_headerView addSubview:_countLabel];
    [_headerView addSubview:selected_icon];
    // [tableHeaderView addSubview:selected_icon];
    // [tableHeaderView addSubview:_countLabel];
    // tableHeaderView.height += 20;
    
    
    return _headerView;
}


#pragma mark - TableView Datasource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return nil;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Data
- (void)loadUserData
{
    /*
     access_token	true	string	采用OAuth授权方式为必填参数，OAuth授权后获得。
     uid	false	int64	需要查询的用户ID。
     screen_name	false	string	需要查询的用户昵称。
     注意事项
     参数uid与screen_name二者必选其一，且只能选其一；
     接口升级后，对未授权本应用的uid，将无法获取其个人简介、认证原因、粉丝数、关注数、微博数及最近一条微博内容。
     */
    
    NSString *requestURL = [WBWeiboTool URLAppendingAccessTokenWithQueryPath:URL_USER_SHOW];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:_weiboModel.user.screen_name forKey:@"screen_name"];
    
    [[MKHTTPTool shareInstance] requestWithURL:requestURL
                                        params:params
                                    httpMethod:@"GET"
                                 completeBlock:^(id result) {
                                     [self loadUserDataFinished:result];
                                 }];
    
}


- (void)loadUserDataFinished:(NSDictionary *)result
{
    // NSLog(@"%@", result);
    // 数据错误，粉丝和关注人数都为0
    UserModel *userModel = [[UserModel alloc] initWithDataDic:result];

    /*
     access_token	true	string	采用OAuth授权方式为必填参数，OAuth授权后获得。
     uids	true	string	需要获取数据的用户UID，多个之间用逗号分隔，最多不超过100个。
     注意事项
     接口升级后，对未授权本应用的uid，将无法获取其粉丝数、关注数及微博数。
     */
    NSString *requestURL = [WBWeiboTool URLAppendingAccessTokenWithQueryPath:URL_USERS_COUNT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:userModel.idstr forKey:@"uids"];
    
    [[MKHTTPTool shareInstance] requestWithURL:requestURL
                                        params:params
                                    httpMethod:@"GET"
                                 completeBlock:^(id result) {
                                     [self loadCountDataFinished:result];
                                 }];
}

- (void)loadCountDataFinished:(NSArray *)result
{
    //UserInfoDataModel *countModel = [[UserInfoDataModel alloc] initWithDataDic:[result firstObject]];
    
    //refreshUI
    // 完成加载 更新数据
    //[super hideHUBLoading];
    //self.tableView.hidden = NO;
}

- (void)loadStatusCountData
{
    /*
     access_token	true	string	采用OAuth授权方式为必填参数，OAuth授权后获得。
     ids	true	string	需要获取数据的微博ID，多个之间用逗号分隔，最多不超过100个。
     */
    
    NSString *requestURL = [WBWeiboTool URLAppendingAccessTokenWithQueryPath:URL_STATUES_COUNT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:_weiboModel.weiboId forKey:@"ids"];
    
    [[MKHTTPTool shareInstance] requestWithURL:requestURL
                                        params:params
                                    httpMethod:@"GET"
                                 completeBlock:^(id result) {
                                     [self loadStatusCountFinshed:result];
                                     [self.tableView headerEndRefreshing];
                                 }];
    
}

- (void)loadStatusCountFinshed:(id)result
{
    if([result isKindOfClass:[NSArray class]])
    {
        NSDictionary *countsDic = [(NSArray *)result firstObject];
        //update UI
        int reposts = [countsDic[@"reposts"] intValue];
        int comments = [countsDic[@"comments"] intValue];
        _countLabel.text = [NSString stringWithFormat:@"Reposts:%d  | Comments:%d",reposts, comments];
    }
}
#pragma mark TableView EventDelegate
// 下拉
- (void)pullDownAction
{
    [self loadStatusCountData];
}

// 上拉
- (void)pullUpAction
{
    [self pullUpData];
}

// 点击cell
- (void)tableView:(BaseTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"CLICK CELL");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




 // 上拉加载最新微博
 - (void)pullUpData
{
    if(self.lastCommentID.length == 0)
    {
        NSLog(@"Weibo id is null");
        return;
    }
    NSString *weiboID = [_weiboModel.weiboId stringValue];
    if(weiboID.length == 0) return;
    
    NSString *requestURL = [WBWeiboTool URLAppendingAccessTokenWithQueryPath:URL_COMMENT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[weiboID, @"20", self.lastCommentID] forKeys:@[@"id", @"count", @"max_id"]];
    
    [[MKHTTPTool shareInstance] requestWithURL:requestURL
                                        params:params
                                    httpMethod:@"GET"
                                 completeBlock:^(id result) {
                                     //
                                     [self pullUpFinishData:result];
                                     [self.tableView footerEndRefreshing];
                                 }];
    
    /*
     access_token	true	string	采用OAuth授权方式为必填参数，OAuth授权后获得。
     id	true	int64	需要查询的微博ID。
     注意事项
     只返回授权用户的评论，非授权用户的评论将不返回；
     使用官方移动SDK调用，可多返回30%的非授权用户的评论；
     */
    
}

/*
 NSArray *array = [result objectForKey:@"comments"];
 _comments = [NSMutableArray arrayWithCapacity:array.count];
 for (NSDictionary *dic in array)
 {
 CommentModel *commentModel = [[CommentModel alloc] initWithDataDic:dic];
 [_comments addObject:commentModel];
 [commentModel release];
 }
*/
 // 上拉加载完成
 - (void)pullUpFinishData:(id)result
{
    NSArray *array = [result objectForKey:@"comments"];
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dic in array)
    {
        CommentModel *commentModel = [[CommentModel alloc] initWithDataDic:dic];
        [newArray addObject:commentModel];
    }
 
    // 更新last ID
    if (newArray.count > 0)
    {
        CommentModel *last = [newArray lastObject];
        self.lastCommentID = [last.commentID stringValue];
        
        // 去掉重复的微博
        [newArray removeObjectAtIndex:0];
    }
    [_comments addObjectsFromArray:newArray];


    if(array.count<20)
    {
        self.tableView.isMore = NO;
    }
    else
    {
        self.tableView.isMore = YES;
    }
     // refresh UI
     self.tableView.data = _comments;
     [self.tableView reloadData];
 
}

@end