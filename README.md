# TurntableView-Demo

基于UIScrollView实现的圆环转盘效果。

实现效果：

![TurntableView-Demo_1](https://github.com/Rogue24/JPCover/raw/master/TurntableView-Demo/TurntableView-Demo_1.gif)

## 实现方案

### 1. 坐标计算

从设计图可得知，半边星球最多展示6个用户，一圈360°，半圈180°，也就是多个用户依次相隔30°环绕星球中心摆放。

已知圆心、半径、每个用户的弧度，通过三角函数就可以计算出每个用户的（初始）坐标了：

```swift
let centerX: CGFloat = circlePoint.x + radius * cos(radian)
let centerY: CGFloat = circlePoint.y + radius * sin(radian)
```

### 2. 手指转动

现在每个用户的位置都可以确定了，还需要通过手指进行转动。

既然是用手指进行转动，是不是加个`UIPanGestureRecognizer`然后改变弧度就可以实现转动了呢？

是可以，只不过**只能单纯转动，没有任何惯性**，效果很是生硬，虽然也可以通过一些数学公式实现惯性效果，不过对于我来说过于复杂且不好控制，所以作罢。

那`UIKit`里面有没有这种惯性拖动的控件呢？--- 很明显，`UIScrollView`自带惯性效果，这能满足我的需求。

首先，想要`UIScrollView`能够拖动，就得设置一个比它自身`Size`还要大的`contentSize`，至于要设置多高的`contentSize`（这里需求是垂直方向，因此只需要设置`contentSize.height`即可）才合适呢？

由设计图可得知，星球**一圈最多12个，半圈则是6个**，也就是说，`contentSize.height`等于**1个星球高度**时可容纳**6个用户**，等于**2个星球高度**可容纳**12个用户**，也就是刚好容纳一圈用户所需的内容高度。所以平均一个用户占用内容高度为`planet.height / 6`，很好，这样不管有多少个用户，都可以动态设置`contentSize.height`了。

```swift
contentSize.height = (planet.height / 6) * CGFloat(peopleViews.count)
```

确定好`contentSize.height`了，接下来该如何通过拖拽进行转动呢？

既然已经知道了容纳一圈用户所需的内容高度，也知道了一个用户的占用内容高度和角度，那就可以根据**当前偏移量**和**容纳一圈用户的内容高度**，算出**转动百分比**，有了这个**转动百分比**，去刷新所有用户的**当前转动位置**了。

```swift
let radian360 = CGFloat.pi * 2
let radian90 = CGFloat.pi / 2
let singlePeopleRadian = radian360 / 12.0


let oneRoundContentHeight = planet.frame.height * 2
let offsetY = scrollView.contentOffset.y
let progress = offsetY / oneRoundContentHeight


peopleViews.forEach { peopleView in
    let index = peopleView.tag
    
    // 弧度
    var radian: CGFloat = singlePeopleRadian * CGFloat(index) - radian90 // iOS的0°为水平位置，-90°为了回去会垂直位置
    radian -= progress * radian360 // 逆时针转动，相减
    
    // 中点
    let centerX: CGFloat = circlePoint.x + radius * cos(radian)
    let centerY: CGFloat = circlePoint.y + radius * sin(radian)
    
    // 加上offsetY是为了让所有用户转动时能保持在scrollView的显示区域内
    peopleView.center = CGPoint(x: centerX, y: offsetY + centerY)
}
```

## 其他需求

有了这个**转动百分比**，剩下的需求就很容易实现了，例如控制名字的渐变显示、只显示右半屏的用户等，这些都是给定一个限值，然后根据百分比慢慢刷新的事情，这里就不赘述了。

![TurntableView-Demo_2](https://github.com/Rogue24/JPCover/raw/master/TurntableView-Demo/TurntableView-Demo_2.gif)

## 优化

1.  复用机制【已实现】：从视觉上，一个屏幕也就最多显示6~7个关系用户，那就可以参考`UITableView`的做法，使用一个集合当作关系用户的缓存池，转动过程中，但转出显示范围（半屏）就把该视图丢进缓存池，然后下一个用户即将显示时则从缓存池里取出来。**最多只需要创建8个关系用户视图，即可实现无数个用户的转动效果**，大大减少CPU的计算量。

![TurntableView-Demo_3](https://github.com/Rogue24/JPCover/raw/master/TurntableView-Demo/TurntableView-Demo_3.gif)

2.  动态插入/删除【未实现】：如果用整体刷新的动画来进行插入/删除，更新只会以两个用户之间的**直线轨迹**进行位移动画，这不符合转盘的形式，需加入圆弧动画，*目前暂未实现，将日后提供*。
