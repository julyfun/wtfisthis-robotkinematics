// [typst 0.13]
#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.4" as fletcher: node, edge
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
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

#title-slide()

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= Transforms

== Do you understand?

- 2 维空间的方向（单位向量）有几个自由度？
- 3 维空间的方向有几个自由度？
- 3 维空间中的坐标系变换有几个自由度？
  - 平移
  - 旋转：注意区分坐标系旋转和向量的旋转

== Do you really understand?

坐标系 B 到坐标系 A 的变换如下表示： 

$R = mat(
  0.96, -0.259, 0.108;
  0.267, 0.961, -0.069;
  -0.086, 0.095, 0.992
), t = vec(1.115, 0.03, 0.997)$

#pause

- 意义：如果某个向量在 A 坐标系中是 $p_A = vec(x, y, z)$，那么在 B 坐标系中是 $p_B = R vec(x, y, z) + t$. 即 $R, t$ 描述了向量从 A 坐标系变换到 B 坐标系的变换方式。注意是先旋转后平移。

- 行业约定：对于 $A$ 到 $B$ 的变换，通常称 $B$ 为父坐标系 (目标 / target / parent), $A$ 为子坐标系（源 / source /child). 
可将 $R, t$ 表示到一个矩阵内，即变换 $T_A^B = mat(R, t; 0, 1), p_B = T_A^B p_A$. 所有的三维旋转构成 $"SO"(3)$ 群，所有三维变换构成 $"SE"(3)$ 群.

== 以下说法等价

+ $T = mat(R, t; 0, 1)$ 为坐标系 A 到坐标系 B 的变换. (A to B)
+ 某点在 A 下的坐标为 $p$, B 下坐标为 $T p$，
+ A 的原点在 B 下的坐标为 $t$, A 的三个轴在 B 下的表示为 R 的三列向量. (A in B)

=== 注意
- $T_A^C = T_B^C T_A^B$ （左乘）

=== 例子 1

关节 1 和关节 2 到机器人基坐标系的变换分别为 $T_1$ 和 $T_2$. 那么关节 2 到关节 1 的变换为？

Answer: $2 -> "base" -> 1$. 即 $T_2^1 = T_1^(-1) T_2$

=== 例子 2

#im(3, h: 40%)

根据上图，写出 b 到 a 的变换. 思路："b to a" is "b in a"。因此矩阵第一列就是 b 的 x 轴在 a 下的表示. 矩阵第四列就是 b 的原点在 a 下的表示.

$
mat(0, -1, 0, x; 
    1,  0, 0, y; 
    0,  0, 1, z; 
    0,  0, 0, 1)
$

旋转有包括 $R$ 矩阵在内的多种表示，下页开始介绍。

#pagebreak()

== 1.旋转矩阵 3x3

坐标系 A 到坐标系 B 的旋转如下表示： 

$R_A^B = mat(
  0.96, -0.259, 0.108;
  0.267, 0.961, -0.069;
  -0.086, 0.095, 0.992
)$


#grid(
  columns: 2,
  im(2, h: 70%),
  text[
    - 性质：正交矩阵. 每行和每列的都是单位向量. $R R^T = bold(I); R^T = R^(-1)$
    - R 的第一列就是 $x_A$ 在 $B$ 下的表示.
    - R 的第二列就是 $y_A$ 在 $B$ 下的表示.
    - R 的第三列就是 $z_A$ 在 $B$ 下的表示.
    - R 的第一行就是 $x_B$ 在 $A$ 下的表示, etc.
    - 优点：最通用。根据这个性质可以看建模图直接手写旋转矩阵.
    - 缺点：高冗余，不适合存储和作为 loss.
    - 注意旋转都是只有 3 个自由度的.
  ]
)

== 2. 欧拉角

#grid(
  columns: 2,
  gutter: 20pt,
  grid.cell(im(1, h: 50%)),
  grid.cell(image("img/Euler2a.gif", height: 50%)),
)

如上所示。用绕自身三轴的分别旋转某个角度。用这三个角表示整个旋转, e.g. 先后绕 xyz 轴旋转 $(45 degree, 60 degree, 45 degree)$.

一般绕朝前轴的转角成为 roll-滚动，绕竖直轴为 yaw-偏航，绕左右轴为 pitch-俯仰.

- 优点：对于简单旋转而言，几何上直观 https://quaternions.online
- 缺点：有万向锁; 对于三轴旋转是最不直观的表示法; 欧拉角表示方法超过 12 种.
- 常用于表示单轴旋转，例如 Flexiv Elements 的 TCP 设置 UI.

=== 内旋 vs 外旋

任何旋转可以表示为 `绕自身轴旋转` 或者 `绕固定轴旋转`，分别叫做内旋和外旋. 内旋用小写字母表示，例如 xzy. 外旋大写,例如 ZYX. 三轴顺序任意，没有统一标准. 另外：

$
"intrinsic" "XZY" (a, b, c) = "extrinsic" "ZYX" (c, b, a)
$

=== 万向锁

旋转第二个轴时如果转了 $plus.minus 90$ 度，则第一个轴和第三个轴重合. 例如 ZYX 中若 Y 轴转了 90 度，则 X - Z 是定值则的任意组合都是同一旋转。导致：
- 万向锁时非唯一解
- 数值不稳定：在万向锁附近，欧拉角剧变
- 在欧拉角上线性插值不平滑.

== 3. 旋转向量 rotation vector

#im(4, h: 50%)

旋转向量 $vec(a_x, a_y, a_z)$，其方向表示旋转轴，长度表示旋转角度 $theta$.

- 缺点: 角度在接近 $pi$ 时不连续
- 有的工作使用旋转向量表示 EEF delta rotation. 据他们说是因为这个 delta action 的旋转角一般较小.

#pagebreak()

通过罗德里格斯公式（Rodrigues' rotation formula）直接转换为旋转矩阵：

#im(5, h: 14%)

== 4. 单位四元数

#im(6, h: 35%)

四元数是复数的推广，$q = w + x i + y j + z k$. 其中  i² = j² = k² = ijk = -1. 可记作 $vec(w, x, y, z)$. 而满足 $w^2 + x^2 + y^2 + z^2 = 1$ 的四元数必定对应一个三维旋转. 由旋转向量计算得到：

$ vec(cos theta / 2, a_x sin theta / 2, a_y sin theta / 2, a_z sin theta / 2) $

- 注意：四元数取负表示的是同一个旋转.
- 优点：数据存储常用四元数. 它没有奇异性，而且组合旋转可以直接相乘. $q = q_1 q_2$. 插值方便，可以直接 $q_"itp" = (1 - t)q_x + t q_y$
- 缺点：顺序没有统一标准，非常坑人. 比如 scipy / ros 默认就需要传入 `x, y, z, w`，而 Eigen 和 Mujuco 是 `w, x, y, z`.

== 5. 6d vec

#im(7, h: 40%)

- 6d vec 就是旋转矩阵的前两列.
- 但 6d vec 允许两列不单位正交，不正交的情况下，投影得到正交的第二轴，cross 得到第三轴，避免万向锁 / $pi$ 跳变 / 四元数取负问题. 连续性比较好.

== 相互转换

本质是取 sin cos 等，不需要记，我们可以用 `scipy` 来做.

```python
from scipy.spatial.transform import Rotation as R

# 从任一种表示构造 Rotation, from_matrix, from_quat, from_rotvec
r = R.from_euler("ZYX", [30, 20, 10], degrees=True)

# 转为各种表示
euler  = r.as_euler("xyz", degrees=True)
matrix = r.as_matrix()
quat   = r.as_quat()       # [x, y, z, w]
rotvec = r.as_rotvec()     # 方向=轴，模长=角度(rad)
```

= 镜头

顺便讲一下.

== 镜头

=== 按照焦距分类: 短焦/中焦/长焦

焦距决定了相机适合观察什么距离的物体，短焦一般适合观察近距离物体，长焦一般适合观察远距离物体。

=== 按照视角大小分类
- 广角 特点：视角大，可观测范围广。但同时会产生较大畸变。
- 标准 特点：视角小，但产生的畸变也较小。

#im(8, h: 45%)

#im(9, h: 30%)

#im(10, h: 60%)

== 手眼标定

= 

== FK 和 DH 表示

机器人运动学：讨论关节和末端的运动状态，不讨论其如何由力矩产生
- 位置/速度/加速度
- 姿态/角速度/角加速度
- e.g. 为了让机械臂末端处于某个姿态，关节角应该是？

机器人动力学：讨论力/力矩如何产生运动
- Work & Energy
- e.g. 关节电机需要输出什么力矩才能达到特定运动状态
- 今天没有这个内容

=== Joint & Link

== IK

.

== 插值和滤波

.
