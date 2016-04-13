# CHProgressHUD
一个继承于`UIView`的HUD常用控件,可以自定义样式以及选择添加到不同的父视图.

### Versioning notes
当前版本为测试版本,有些功能和代码尚未实现完善.

#Setup with CocoaPods

```
pod 'CHProgressHUD', '~> 0.0.1'

use_frameworks!
```

#Setup with Local

下载当前工程zip，找到相应文件夹CHProgressHUD拖至工程中.

##代码示例
```objc
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [(ScrollingNavigationController *)self.navigationController followScrollView:self.tableView delay:50.0f];
}
```
