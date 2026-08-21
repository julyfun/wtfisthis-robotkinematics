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
#set text(font: "Microsoft YaHei")
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

== Do you understand?

- 2 维空间的方向有几个自由度？其实就是单位向量.
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

- 意义：如果某个向量在 B 坐标系中是 $p_B = vec(x, y, z)$，那么在 A 坐标系中是 $p_A = R vec(x, y, z) + t$. 即 $R, t$ 描述了向量从 B 坐标系变换到 A 坐标系的变换方式。注意是先旋转后平移。

- 行业约定：对于 $B$ 到 $A$ 的变换，通常称 $A$ 为父坐标系 (目标 / target / parent), $B$ 为子坐标系（源 / source /child). 
可将 $R, t$ 表示到一个矩阵内，即 $T_B^A = mat(R, t; 0, 1), p_A = T_B^A p_B$.

旋转除了 $R$ 矩阵以外有多种表示，下页开始介绍。

#pagebreak()

== 1.旋转矩阵 3x3

坐标系 B 到坐标系 A 的旋转如下表示： 

$R_B^A = mat(
  0.96, -0.259, 0.108;
  0.267, 0.961, -0.069;
  -0.086, 0.095, 0.992
)$

性质：正交矩阵. 每行和每列的都是单位向量. $R R^T = bold(I); R^T = R^(-1)$

#grid(
  columns: 2,
  im(2, h: 55%),
  text[
    - R 的第一列就是 $x_B$ 在 $A$ 下的表示.
    - R 的第二列就是 $y_B$ 在 $A$ 下的表示.
    - R 的第三列就是 $z_B$ 在 $A$ 下的表示.
    - R 的第一行就是 $x_A$ 在 $B$ 下的表示, etc.
    - 根据这个性质可以看建模图直接手写旋转矩阵.
    - 注意旋转都是只有 3 个自由度的.
  ]
)

== 2. 欧拉角

- 好处：对于简单旋转而言，几何上直观 https://quaternions.online
- 坏处：万向锁; 对于三轴旋转是最不直观的表示法; 欧拉角表示方法多达 12 种.
- 常用于表示单轴旋转，例如 Flexiv Elements 的 TCP 设置 UI.

#grid(
  columns: 2,
  gutter: 20pt,
  grid.cell(im(1, h: 50%)),
  grid.cell(image("img/Euler2a.gif", height: 50%)),
)

=== 内旋 vs 外旋

可以绕自身轴旋转或者绕固定轴旋转，分别叫做内旋和外旋. 内旋用小写字母表示，例如 xzy. 外旋大写,例如 ZYX. 三轴顺序任意，没有统一标准.

=== 万向锁

旋转第二个轴时如果转了 $plus.minus 90$ 度，则第一个轴和第三个轴重合. 例如 ZYX 中若 Y 轴转了 90 度，则 X - Z 是定值则的任意组合都是同一旋转。导致：
- 非唯一解
- 数值不稳定：在万向锁附近，欧拉角剧变
- 在欧拉角上线性插值不平滑.

== 还有三种

3. 旋转向量 $vec(a_x, a_y, a_z)$，其方向表示旋转轴，长度表示旋转角度.
  - 角度在接近 $pi$ 时不连续
  - 有的工作使用旋转向量表示 EEF delta rotation. 因为这个旋转角不会大.
4. 单位四元数 $vec(cos theta / 2, a_x sin theta / 2, a_y sin theta / 2, a_z sin theta / 2)$: 插值方便，可以直接 $q = (1 - t)q_x + t q_y$
  - 四元数每一位都取反表示的是同一个旋转.
  - 数据存储较常用. 但是究竟是 `w, x, y, z` 还是 `x, y, z, w` 没有统一标准，非常坑人.
5. 6dvec
  - 就是旋转矩阵的前两列.
  - 6dvec 允许两列不单位正交，不正交的情况下，投影得到正交的第二轴，cross 得到第三轴，避免万向锁、$pi$ 跳变和四元数. 连续性比较好.

== 相机内参和畸变标定

顺便讲一下.


== 手眼标定

== FK 和 DH 表示

== IK

== 插值和滤波