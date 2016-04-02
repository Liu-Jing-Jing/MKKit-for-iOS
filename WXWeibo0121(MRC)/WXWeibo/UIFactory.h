//
//  UIFactory.h
//  WXWeibo
//  主题控件工厂类

#import <Foundation/Foundation.h>
#import "ThemeButton.h"
#import "ThemeImageView.h"
#import "ThemeLabel.h"

@interface UIFactory : NSObject

//创建button
+ (ThemeButton *)createButton:(NSString *)imageName highlighted:(NSString *)highlightedName;
+ (ThemeButton *)createButtonWithBackground:(NSString *)backgroundImageName
                                backgroundHighlighted:(NSString *)highlightedName;

//创建ImageView
+ (ThemeImageView *)createImageView:(NSString *)imageName;

//创建Label
+ (ThemeLabel *)createLabel:(NSString *)colorName;

@end
