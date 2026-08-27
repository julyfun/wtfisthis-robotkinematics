// [typst 0.13]
#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.4" as fletcher: node, edge
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import "@preview/mmdr:0.2.2": mermaid
#import cosmos.clouds: *
#show: show-theorion

#import "@preview/grayness:0.2.0": *

// #let data = read("img/ignoreme-19.jpg", encoding: none)

// #set page(background: transparent-image(data, alpha: 50%, width: 100%, height: 100%))

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: university-theme.with(
  aspect-ratio: "16-9",
  // align: horizon,
  // config-common(handout: true),
  config-common(frozen-counters: (theorem-counter,)), // freeze theorem counter for animation
  config-info(
    title: [机器人运动学 Utility],
    subtitle: [],
    author: [方俊杰.SJTU],
    date: datetime.today(),
    institution: [],
    logo: emoji.school,
  ),
)

// [my]
// [my.code]
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#show raw: it => {
  set text(font: "0xProto Nerd Font")
  it
}

// [my.config]
#let tea = false
#let tbl = it => {
  if tea {
    it
  }
}

// [my.heading]
#show heading.where(level: 1): set heading(numbering: numbly("{1}.", default: "1.1"))

// [my.code]
#show raw.where(lang: "cpp"): it => {
  set text(12pt)
  it
}
#show raw.where(block: false): it => box(
  fill: rgb(248, 248, 248),
  outset: 4pt,
  radius: 3pt,
  stroke: 0.5pt + gray,
  it,
)
#show raw.where(block: true): it => box(
  fill: rgb(248, 248, 248),
  outset: 8pt,
  radius: 3pt,
  stroke: 0.5pt + gray,
  it,
)
#show raw: it => box()[
  #set text(font: ("Cascadia Mono", "Sarasa Term SC Nerd", "Zed Mono Extended"))
  #it
]

// [my.text]
#set text(20pt)
#set text(font: "PingFang sc")
#show strong: set text(weight: 900) // Songti SC 700 不够粗

#set list(indent: 0.8em)
#show link: underline

// [my.util]
#let emp = it => {
  strong(text(fill: red)[#it])
}

#let alert(body, fill: yellow) = {
  // set text(fill: white)
  rect(
    fill: fill,
    inset: 8pt,
    radius: 4pt,
    [*注意:\ #body*],
  )
}

#let hint(body, fill: blue) = {
  rect(
    fill: fill,
    inset: 8pt,
    radius: 4pt,
    [*#body*],
  )
}

#let lin = line(length: 100%)
#let im(p, h: auto) = {
  if p == 0 {
    figure(image("img/image.png", height: h))
  } else if p == 1 {
    figure(image("img/image copy.png", height: h))
  } else {
    figure(image("img/image copy " + str(p) + ".png", height: h))
  }
}
// [my.end]

// [this]
#set math.mat(delim: "[")
#set math.vec(delim: "[")

//

#title-slide()

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em, depth: 2))

= 位姿空间

== 自由度

=== 刚体自由度

- 硬币有几个自由度？
- #pause 圆心有 3 个自由度，它还可以建立坐标系，可以绕 3 个轴旋转，因此一共是 6 个自由度.
- 从约束的角度看，硬币上取 3 个点，第一个点有 3 个自由度，第二个点与前者有距离约束，因此是 2 个自由度。第三个点有两个距离约束，因此是 1 个自由度.
- 同理 N 维空间坐标系有 $(N(N - 1)) / 2$ 自由度

== 机器人自由度

#grid(
  columns: 4,
  gutter: 2pt,
  im(11, h: 35%),
  im(12, h: 40%),
)
 
机器人关节主要有旋转关节 R，移动关节 P，都只有一个自由度. 稍微不常见的有螺旋关节 H，类似螺丝钉。万向节 U 两个自由度，球铰 S 三个自由度.

#grid(
  columns: 5,
  gutter: 1%,
im(13, h: 33%),
image("img/u.gif", height: 33%),
h(15%),
im(14, h: 33%),
image("img/s.gif", height: 33%),
)

== 变换的几何意义

坐标系 ${A}$ 到坐标系 ${B}$ 的变换如下： 

$R = mat(
  0.96, -0.259, 0.108;
  0.267, 0.961, -0.069;
  -0.086, 0.095, 0.992
), t = vec(1.115, 0.03, 0.997)$

#pause

- 含义：如果某个向量在 {A} 坐标系中是 $p_A = vec(x, y, z)$，那么在 {B} 坐标系中是 $p_B = R vec(x, y, z) + t$. 即 $R, t$ 描述了向量从 A 坐标系变换到 B 坐标系的变换方式. #footnote[称呼约定：对于 $A$ 到 $B$ 的变换，ROS2 等库会称 $B$ 为父坐标系 (目标 / target / parent), $A$ 为子坐标系（源 / source / child). Weird.]

为了简化，可将 $R, t$ 表示到一个矩阵内 $T_A^B = mat(R, t; 0, 1)$，则变换简化为 $p_B = T_A^B p_A$.（需要用齐次坐标 $[x, y, z, 1]$. 另外，$T_A^B$ 也可以写成 $T_"BA"$）

== 变换的几何意义

=== 以下说法等价

+ $T = mat(R, t; 0, 1)$ 为坐标系 A 到坐标系 B 的变换. (A to B)
+ 某点在 A 下的坐标为 $p$, B 下坐标为 $T p$， (A to B)
+ $t$ 为 A 的原点在 B 下的坐标, $R$ 的三列向量为 A 的三个轴在 B 下的表示. (A in B)

=== 注意
- $T_A^C = T_B^C T_A^B$ （左乘)

=== 例子 1

关节 1 和关节 2 到机器人基坐标系的变换分别为 $T_1$ 和 $T_2$. 那么关节 2 到关节 1 的变换为？

Answer: $2 -> "base" "左乘" "base" -> 1$. 

即 $T_2^1 = T_1^(-1) T_2$

=== 例子 2

#im(3, h: 33%)

根据上图，写出 b 到 a 的变换. 思路："b to a" is "b in a"。因此矩阵第一列就是 b 的 x 轴在 a 下的表示. 矩阵第四列就是 b 的原点在 a 下的表示.

$
mat(0, -1, 0, x; 
    1,  0, 0, y; 
    0,  0, 1, z; 
    0,  0, 0, 1)
$

旋转有包括 $R$ 矩阵在内的多种表示，下页开始介绍。

#pagebreak()

== 1. 旋转矩阵 3x3

例：坐标系 A 到坐标系 B 的旋转如下表示： 

$R_A^B = mat(
  0.96, -0.259, 0.108;
  0.267, 0.961, -0.069;
  -0.086, 0.095, 0.992
)$


#grid(
  columns: 2,
  im(2, h: 70%),
  text[
    - 性质：正交矩阵. 每行每列都是单位向量. $R R^T = bold(I); R^T = R^(-1)$. 行列式 = 1. （行列式 = -1 则为左手坐标系）
    - R 的第一列就是 $x_A$ 在 $B$ 下的表示.
    - R 的第二列就是 $y_A$ 在 $B$ 下的表示.
    - R 的第三列就是 $z_A$ 在 $B$ 下的表示.
    - R 的第一行就是 $x_B$ 在 $A$ 下的表示, etc.
    - 优点：最通用。根据这个性质可以看建模图手写旋转矩阵.
    - 缺点：高冗余，不适合存储和作为 loss.
  ]
)

== 2. 欧拉角 Euler Angles（混乱邪恶）

#grid(
  columns: 2,
  gutter: 20pt,
  grid.cell(im(1, h: 50%)),
  grid.cell(image("img/Euler2a.gif", height: 50%)),
)

如上所示#footnote[有些库坐标系是 $y$ 朝上，如 Unity，ARKit，也有的是 $z$ 朝上，如 ROS, Unreal.]。用绕自身三轴的分别旋转某个角度。用这三个角表示整个旋转, e.g. 先后绕 zxy 轴旋转 $(45 degree, 60 degree, 45 degree)$. 有时候 xyz 旋转被标记为 rpy.

- 优点：对于简单旋转而言，几何上直观
- 缺点：有万向锁; 对于三轴旋转是最不直观的表示法; 欧拉角表示方法超过 12 种.
- 欧拉角常用于表示单轴旋转，例如 Flexiv Elements 的 TCP 设置 UI.

=== 内旋 vs 外旋

欧拉角允许表示为 `绕自身轴旋转` 或者 `绕固定轴旋转`，分别叫做内旋和外旋. 内旋用小写字母表示，例如 zxy; 外旋大写, 例如 YXZ. 三轴顺序任意，没有统一标准. 另外：

$
"intrinsic" "zxy" (a, b, c) = "extrinsic" "YXZ" (c, b, a)
$

=== 万向锁

旋转第二个轴时如果转了 $plus.minus 90$ 度，则第一个轴和第三个轴共线. 如 XYZ 中若 Y 轴转了 90 度，则 $X + Z$ 是定值的任意组合都是同一旋转。https://quaternions.online 导致：
- 万向锁时有无数组解
- 数值不稳定：在万向锁附近，欧拉角剧变. 比如 rpy = (90, 89, 90) 和 rpy = (1, 89, 179) 表示的是十分接近的旋转.
- 在欧拉角上线性插值不平滑.

#im(23)

== 3. 旋转向量 Rotation Vector

#im(4, h: 50%)

旋转向量 $vec(a_x, a_y, a_z)$，其方向表示旋转轴 $hat(omega)$，模长表示旋转角度 $theta$.

- 优点：简洁.
- 缺点：不怎么直观. 角度在接近 $plus.minus pi$ 时不连续
- 有的工作使用旋转向量表示 EEF delta rotation. 据他们说是因为这个 delta action 的旋转角一般较小.

#pagebreak()

旋转向量可通过罗德里格斯公式（Rodrigues' rotation formula）直接转换为旋转矩阵：

$ "Rot"(hat(omega), theta) = e^([hat(omega)]theta) = I + sin theta [hat(omega)] + (1 - cos theta) [hat(omega)]^2 $

== 4. 四元数 Quaternion

#im(6, h: 35%)

四元数是复数的推广，$q = w + x i + y j + z k$. 其中  i² = j² = k² = ijk = -1. 可记作 $vec(w, x, y, z)$. 而满足 $w^2 + x^2 + y^2 + z^2 = 1$ 的单位四元数均对应一个三维旋转. 由旋转向量计算：

$ "旋转向量" vec(a_x, a_y, a_z) --> "四元数" vec(cos theta / 2, hat(omega) sin theta / 2) $

- 注意：四元数取负表示的是同一个旋转.
- 优点：数据存储常用四元数. 它没有奇异性，而且组合旋转可以直接相乘. $q = q_1 q_2$. 插值方便，可以直接 $q_"itp" = "normalize"((1 - t)q_x + t q_y) $
- 缺点：顺序没有统一标准，非常坑人. 比如 scipy / ros 默认就需要传入 `x, y, z, w`，而 Eigen 和 Mujoco 是 `w, x, y, z`.

== 5. 6d vec

#im(7, h: 40%)

- 6d vec $in RR^6$ 就是旋转矩阵的前两列. 与此同时，我们希望它每一维都可以任意变换，所以我们去掉单位正交约束.
- 不正交的情况下，投影得到正交的第二轴，cross 得到第三轴.
- 优点：完全连续，可以避免万向锁 / $pi$ 跳变 / 四元数取负问题，网络学习时梯度会比较平滑.

== scipy

本质是取 sin cos 等，不需要记，比如我们可以用 `scipy` 来做.

```python
from scipy.spatial.transform import Rotation as R

# 从任一种表示构造 Rotation, from_matrix, from_quat, from_rotvec
r = R.from_euler("ZYX", [30, 20, 10], degrees=True)

# 转为各种表示
euler  = r.as_euler("xyz", degrees=True)
matrix = r.as_matrix()
quat   = r.as_quat()       # [x, y, z, w]
rotvec = r.as_rotvec()     # 方向=轴，模长=角度(rad)
# 6d vec 非标准形式，需要手写.
```

== 相机上的成像变换

#grid(
  columns: 2,
  align: center + horizon,
  $Z_c dot$, im(9, h: 24%),
)

#grid(
  columns: 2,
  align: horizon,
  im(10, h: 42%),
[
- 内参可通过*内参标定*获得.
- 外参是一个复合变换，如下图中就包含 $"标定板" -->^"放置位置" "基座" -->^"关节角" "EEF" -->^"相机安装方式" "相机"  $. 其中 EEF -> 相机常常需要通过*手眼标定*获得. #im(25, h: 35%)
]
)

== 手眼标定

= 运动学

== 运动学

机器人运动学 Kinematics：讨论关节和末端的运动状态，不讨论其如何由力矩产生
- 位置/速度/加速度
- 姿态/角速度/角加速度

机器人动力学 Dynamics：讨论力/力矩如何产生运动
- Work & Energy
- 今天没有动力学内容

== 不同自由度的机械臂

#grid(
  columns: 3,
  gutter: 30pt,
  align: bottom,
  im(15, h: 45%),
  im(18, h: 55%),
  im(17, h: 55%),
)

- SO100: *5-DOF*
- COBOT Magic (ALOHA): *6-DOF*，和末端位姿自由度一样
- Flexiv Rizon 4: *7-DOF*, 额外的自由度可以用于避障或优化最小功率等目标函数

为了描述机器人构型，我们可以使用*齐次变换法、DH 表示法或旋量表示法*. URDF 文件就是一种齐次变换表示法.

== FK 和齐次变换法

#pagebreak()

URDF 会给出相邻关节之间的零位变换 `<origin>` 和旋转轴 `<axis>`:

```xml
<robot name="rizon4">
    <joint name="joint1" type="revolute">  <!-- 关节类型为旋转 -->
        <parent link="base_link"/> <child link="link1"/>
        <origin rpy="0.0 0.0 -3.141592653589793" xyz="0.0 0.0 0.155"/>
        <axis xyz="0 0 1"/>  <!-- 旋转轴在自己 origin 坐标系下描述 -->
        <limit effort="123" lower="-2.7925" upper="2.7925" velocity="2.0944"/>
    </joint>
    <link name="link6">
        <inertial>...</inertial>
        <visual name="ring">...</visual>
        <collision name="hull"><mesh filename="xxx.stl"/></collision>
    </link>
```

#pagebreak()

- 最后一个关节常在法兰 (flange) 中心. 其上固定的工具称为 end effector (EEF)#footnote[EEF 坐标系可以在工具（如夹爪）上的任意指定点，有时也叫作  Tool Center Point (TCP).].

- #strong[F]orward #strong[K]inematics: 给定关节角，计算 EEF pose. 如果给定了类似 URDF 的零位变换和旋转轴，计算就比较直接.

```xml
<origin rpy="0.0 0.0 -3.141592653589793" xyz="0.0 0.0 0.155"/>
<axis xyz="0 0 1"/>
```

$ T_1^0(q_1) =
  "Trans"(0, 0, 0.155)
  "Rot"_z (-pi)
  "Rot"_z (q_1)
$

$
T_6^0(q) = T_1^0 T_2^1 T_3^2 T_4^3 T_5^4 T_6^5
$

- 各种运动学库可以帮助我们解析 URDF 文件，因此无需手写上述变换.

为了减少参数量，我们还会使用 *DH 表示法*或者*旋量表示法*.

== DH 表示法

#grid(
  columns: 1,
  gutter: 2%,
  image("assets/image-2.png", height: 78%),
  text[DH 表示法规定关节坐标系原点和朝向，如 X 轴必须沿相邻两关节轴线的公垂线，原点必须位于公垂线和轴线的交点. 好处：每个关节只需 4 个参数 $alpha, a, theta, d$ 就表示了 6 个自由度的内容。缺点：需要好好的设置坐标系才可以，连 URDF 也不会遵循此规定.]
)

== 旋量指数积 (PoE) 法

DH 法需要为每个关节都规定坐标系，而旋量表示法只需要定义一个固定的基坐标系 {0} 和末端坐标系 {T}，中间所有关节只需要确定它们的旋转轴方向和轴线上任意一点.

1. 把机械臂拉到零位（$q=bold(0)$），记录此时末端相对于基的表示 $M∈"SE"(3)$.
2. 取零位状态下第 i 个关节轴在基坐标系中的方向 $omega_i$.
3. 计算由旋转引起的线速度分量 $v_i = -omega_i times q_i$，其中 $q_i$ 为该旋转轴任意一点在基坐标系中的坐标，螺旋轴 $S_i = vec(bold(omega)_i, bold(v)_i) in RR^6$.
4. 计算转动 $theta_i$ 产生的 {T} 在 {0} 下的变换，其为矩阵指数形式：

$ e^([S_i] theta_i) = exp(mat([omega_i], v_i; 0, 0)theta_i) in "SE"(3) $

使用罗德里格斯公式:

$
exp(mat([omega_i], v_i; 0, 0) theta_i)
&=
mat(
  R_i(theta_i), p_i(theta_i);
  0, 1
) \

R_i(theta_i)
&=
I + sin(theta_i) [omega_i]
  + (1 - cos(theta_i)) [omega_i]^2 \

p_i(theta_i)
&=
(I - R_i(theta_i))(omega_i times v_i)
+ omega_i omega_i^T v_i theta_i \
$

5. 近的关节运动会带动远的关节运动。所以只需从远及近运动，$S_i$ 就可以全用基坐标系表示：

$
#let skew = it => {$[#it]$}
T(0) &= M\
T(theta_6) &= e^(skew(S_6) theta_6) M \
T(theta_5, theta_6) &= e^(skew(S_5) theta_5) e^(skew(S_6) theta_6) M \
... \
T(theta_1, theta_2, theta_3, theta_4, theta_5, theta_6) &= e^(skew(S_1) theta_1) e^(skew(S_2) theta_2) e^(skew(S_3) theta_3) e^(skew(S_4) theta_4) e^(skew(S_5) theta_5) e^(skew(S_6) theta_6) M \
$

- 优点：无需规定中间关节的坐标系。
- PoE 和 DH 表示法的关系：DH 四个参数中有三个常数项，剩下的 $theta$ 项也可以用 PoE 表示，化简得到的还是 PoE 公式.

#im(24, h: 50%)

== 机器人雅可比

=== 速度和雅可比

如何衡量每个关节的运动速度对末端位姿 $f(theta)$ 变化的影响？i.e. 末端速度 $dot(x)$ 与关节角速度向量 $dot(theta) in RR^n$ 的关系.

$ dot(x) = (partial f(theta)) / (partial theta) (partial theta(t)) / (partial t) = J(theta) dot(theta), space J(theta) in RR^(6 times n)  $

空间机器人用旋量衡量末端速度: $cal(V) = vec(omega, v) = J(theta) dot(theta)$. #footnote[旋量 $cal(V)$ 和单个螺旋轴 $cal(S)$ 的关系：$cal(V) = cal(S)dot(theta)$. $cal(S)$ 是 $cal(V)$ 的归一化表示，表示旋转方向、平移半径及方向.] 此时雅可比矩阵的第 i 行表示当前位形 (configuration) 下，第 i 关节速度 $dot(theta) = 1$ 而其他关节速度为 0 时末端旋量 $cal(V)$.

=== 从旋量表示法计算雅可比

对于固定坐标系下雅可比 $J_s(theta)$，第 $i$ 列计算方式为 $J_(s i)(theta) = ["Ad"_(e^([S_1]theta_1) ... e^([S_(i - 1)]theta_(i - 1)))] S_i in RR^6$. 基于 DH 和齐次变换法同样可以计算.

== 奇异性分析

关节数：n=6且满秩，则雅可比矩阵可逆，则容易根据关节角速度求出末端速度。

但是n不是6，或者机器人奇异的时候，雅可比矩阵不可逆。n < 6则机器人不能实现任意的末端速度，n > 6为冗余机器人，n - 6个自由度不能反映到机器人末端。

奇异点指的是雅可比矩阵失去满秩的位形，此时末端在特定方向上失去运动能力。

=== 6 轴机械臂发生运动学奇异的情况

- 2 个旋转关节共轴. 此时 J 有两列相同.
- 3 个旋转关节轴线平行.
- ...

在奇异点附近，为了产生特定的末端位移，IK 机械臂关节角可能剧变（见下面）.

== IK: Inverse Dynamics

给定末端位姿，求解关节角. 例如：遥操 VR 给出手腕位姿，要让机器人末端执行; Policy 输出 TCP 位姿.

对于特定构型的 6 轴机械臂 IK，一般是有限个解. 如果满足两个充分条件中的一个，还可以得到封闭解：

#grid(
  columns: 2,
  gutter: 20pt,
  [
+ 三个相邻关节轴相交于一点
+ 三个相邻关节轴相互平行],
  im(19, h: 40%)
)


人手臂是 7 自由度的，同一个手腕位姿通常有无数个解. 另外 n < 6 则无解. 这些情况都可以考虑数值解.

== IK 数值解

=== 牛顿拉弗森法

#grid(
columns: (1fr, 1.5fr),
align: horizon,
[IK 求解的是 $g(theta) = f(theta) - x_d = bold(0)$ 的问题. $x_d$ 是目标位姿.

右图是标量情况下的经典例子.],
im(20, h: 70%)
)

对于 n = 6, $J(theta) in RR^(6 times 6)$:

$ theta^(k+1) = theta^k + J^(-1)(theta_k)(x_d - f(theta^k)) $

对于 n > 6 的冗余机器人，$J in RR^(6 times n)$, $J^(-1)$ 不存在，可以采用右逆替代:

$ J^dagger = J^T (J J^T)^(-1) in RR^(n times 6) $

$ J J^dagger = I_6 $

对于 n < 6 的欠驱动机器人，采用左逆也是可以求一个数值解的:

$ J^dagger = (J^T J)^(-1) J^T in RR^(n times 6) $
$ J^dagger J = I_n $ 

在奇异点附近，$||J^(-1)|| -> oo$，即使位姿误差极小，乘上 $J^(-1)$ 也会数值极大. 容易不收敛. 下页展示了改进方法.

#pagebreak()

=== CLIK

实践中会采用 CLIK（引入阻尼因子 `damp` 和数值积分） 等方法改进数值稳定性.

```python
# CLIK
while True:
    pinocchio.forwardKinematics(model, data, q)
    iMd = data.oMi[JOINT_ID].actInv(oMdes)
    err = pinocchio.log(iMd).vector  # in joint frame
    if norm(err) < eps or i >= IT_MAX:
        break
    J = pinocchio.computeJointJacobian(model, data, q, JOINT_ID)
    J = -np.dot(pinocchio.Jlog6(iMd.inverse()), J)
    v = -J.T.dot(solve(J.dot(J.T) + damp * np.eye(6), err))
    q = pinocchio.integrate(model, q, v * DT) # DT = 0.1
    i += 1
```

== IK 优化

#grid(
columns: 2,
gutter: 20pt,
text[我们还可以引入一些优化目标：
- 关节角变化量
- 避障
- 同时优化多个关节位姿

优化法对于各种自由度机械臂都适用. 例如 `pink` 库使用 QP 求解器求解带权重任务的 IK.
],
[
#set text(14pt)
```python
from pink.tasks import FrameTask, PostureTask
tasks = {
    "base": FrameTask(
        "base",
        position_cost=1.0, # [cost] / [m]
        orientation_cost=1.0, # [cost] / [rad]
    ),
    "left_contact": FrameTask(
        "left_contact",
        position_cost=[0.1, 0.0, 0.1], 
        orientation_cost=0.0,
    ),
    "right_contact": FrameTask(
        "right_contact",
        position_cost=[0.1, 0.0, 0.1],
        orientation_cost=0.0,
    ),
    "posture": PostureTask(
        cost=1e-3,
    ),
}
```
]
)

== Retargetting 问题

考虑灵巧手遥操作，VR 头显可以视觉识别人手的关节角度（以及每个关节的位姿），我们要用这个信息控制灵巧手。

关节映射是不可行的，首先自由度不一定相同，而各个部位的尺寸也有很大差别. 因此目标可以设定为：让灵巧手某些关键点的位姿和人手对应关键点尽量接近 #footnote[https://robot-tv.github.io, https://do-as-i-do.com/].

#image("assets/image.png", height: 54%)

Retargetting 还应用于全身遥操作#footnote[https://beyondmimic.github.io/]、人形机器人跨形态到非人形机器人，以及 Ego 数据转动作数据#footnote[https://qwen.ai/blog?id=qwen-robotmanip]等问题上，复杂的 retargetting 可使用 RL 方法#footnote[https://github.com/NVlabs/GR00T-WholeBodyControl].

= 轨迹规划

== 插值

给定目标关节角 (e.g. IK 得到)，如何平滑地运动过去？或者避障？

=== 线性插值

每个关节以指定速度运动到目标关节角.

问题：$alpha prop τ prop I$

- 常规控制：控制器还会进行插值或轨迹规划，避免巨大加速度.

- 透传控制：跳过控制器内部规划处理. 直接线性插值可能产生震荡或者烧坏电机.

=== 带有技巧的插值

- S 曲线插值: 对于每个关节角，限制 $v_max, a_max, j_max$ 并给定目标 $x, v, a$，求解关节运动轨迹. S 曲线插值通过分类讨论，任意时刻的 $j in {-j_max, 0, j_max}$，将加速度分为 7 段，实现该限制下时间最短的轨迹.
- Ruckig 库: S 曲线的工程优化版，支持多关节同时到达以及约束初末状态等功能.

#pagebreak()

比如对于其中一个关节角，插值结果可能长这样#footnote[https://blog.csdn.net/m0_61616957/article/details/141220514]：

#im(21, h: 78%)

=== 同时到达

如果想要所有关节同时到达目标点. 一种 trivial 的方法是放缩目标关节角差到同等大小，取最严格的约束，插值后再映射回原比例.

=== Waypoint 规划

要求在指定时间通过一系列中间点. 常规上使用三次或者五次多项式插值方法，Ruckig 也支持输入时间限制，它内部同样先求解最快到达时间，然后简单放缩 $v_max, a_max, j_max$.

虽然 Policy 输出的 action chunk 符合 waypoint 规划形式，但通常做法是缓存 chunk，在 $Delta t = 1 / "控制频率"$ 后直接把下一个 pose 发给求解器作为下一个目标点.

=== 精细的轨迹规划

大多数机器人，随着路径不同，其实关节能提供的最大速度和加速度也是变化的（由动力学方程约束）。对此存在一种接收 $v, a$ 约束的*时间标度算法*. 当然，我并没有用过。

== 运动规划

除了平滑以外，我们可能会希望检测和避免碰撞. 因此位形空间可以被划分为两部分，自由空间和障碍空间。

=== 到障碍物的距离

可以用不同分辨率的球体来模拟机器人和障碍物，所以机器人和障碍物之间的距离为：机器人和障碍物上最近的球体的球心的距离减去两个球体的半径。

=== A\* 算法

#grid(
  gutter: 20pt,
  columns: 2,
  im(22),
[
既然在位形空间中存在若干障碍区域，我们可以使用 A\* 算法。本质就是 dijkstra 算法，只是把选择 $min("已走距离")$ 的点替换为了选择 $min("已走距离" + "未来距离估计值")$.

此外，还存在 RRT\*，势场法，非线性优化法等方法.
]
)

== 滤波

原始信号可能存在噪声

- VR 遥操作时，识别到的手腕位姿存在很大噪声.
- Policy 产生的位姿以及逆解存在的关节角可能震荡.

通过最简单的低通滤波 $y_n = alpha x_n + (1 - alpha) y_(n - 1)$ 可以让这些信号更丝滑. 其中旋转部分可以在三维旋转向量空间中做残差滤波.

- 卡尔曼滤波：遇事不决上 Kalman. 相比低通滤波，还可以估计当前速度并消除匀速运动下的固定延迟.
- 粒子滤波：在状态空间中维护 100\~500 个采样点，并赋置信权重，每步更新用新观测会增删粒子.

== Modern Robotics

https://hades.mech.northwestern.edu/images/7/7f/MR.pdf
