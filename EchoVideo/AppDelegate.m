//
//  AppDelegate.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/4/30.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "AppDelegate.h"
#import "EVHomeViewController.h"
#import "EVLoginViewController.h"
#import "EVLoginUserModel.h"
#import "EVNetwork+User.h"
#import "Constant.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self switchBlankVC];
    if ([[EVLoginUserModel sharedInstance] verifyTokenValid] == TokenExpired) {
        //无token或者token已过期
        [self switchLoginVc];
    } else if ([[EVLoginUserModel sharedInstance] verifyTokenValid] == TokenNeedRefresh) {
        //token将要过期，刷新token
        [self performSelector:@selector(refreshToken) withObject:nil afterDelay:1];
    } else {
        //token正常状态
        [self switchHomeVc];
    }
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchHomeVc) name:SWITCH_HOME_NOTIFICATION_NAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchLoginVc) name:SWITCH_LOGIN_NOTIFICATION_NAME object:nil];
    
    return YES;
}

- (void)switchBlankVC {
    EVBaseViewController *baseVC = [[EVBaseViewController alloc] init];
    self.window.rootViewController = baseVC;
}

- (void)switchLoginVc {
    EVLoginViewController *vc = [[EVLoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
}

- (void)switchHomeVc {
    EVHomeViewController *vc = [[EVHomeViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
}

- (void)refreshToken {
    __weak typeof(self) weakSelf = self;
    [[[EVNetwork alloc] init] refreshTokenWithSuccessBlock:^(NSString * _Nonnull access_token, NSString * _Nonnull expired_date) {
        [EVLoginUserModel sharedInstance].access_token = access_token;
        [EVLoginUserModel sharedInstance].expired_date = expired_date;
        [[EVLoginUserModel sharedInstance] save];
        [weakSelf switchHomeVc];
    } failureBlock:^(NSString * _Nonnull msg) {
        [weakSelf switchLoginVc];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
