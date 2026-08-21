#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [机器人运动学：从坐标到动作],
    subtitle: [给大二同学的直觉式入门],
    author: [Robot Kinematics 101],
    institution: [科学汇报模板 · Typst + Touying],
  ),
)

#set text(font: ("PingFang SC", "STSong", "Arial"), fill: rgb("EAF2F8"))
#set page(fill: rgb("0B1220"))
#set heading(numbering: none)

#let cyan = rgb("57D3FF")
#let orange = rgb("FFB86B")
#let green = rgb("8BE28B")
#let muted = rgb("A8B6C8")
#let panel(body, color: rgb("152337")) = box(fill: color, radius: 8pt, inset: 12pt, body)
#let tag(t, color: cyan) = box(fill: color.lighten(70%), radius: 3pt, inset: (x: 6pt, y: 3pt), text(fill: color, weight: "bold", size: 11pt)[#t])
#let eq(body) = block(fill: rgb("101C2E"), radius: 6pt, inset: 12pt, align(center, text(size: 21pt, fill: orange)[#body]))
#let note(body) = text(fill: muted, size: 13pt)[#body]

#title-slide[
  #align(center + horizon)[
    #text(size: 34pt, fill: cyan, weight: "bold")[机器人运动学：从坐标到动作]
    #v(14pt)
    #text(size: 22pt, fill: orange, weight: "bold")[Robot Kinematics 101]
    #v(20pt)
    #line(length: 55%, stroke: 1.5pt + cyan)
    #v(14pt)
    #text(size: 17pt, fill: muted)[坐标变换 · 相机 · 手眼 · FK · IK · 插值]
    #v(16pt)
    #text(size: 13pt, fill: muted)[你不需要先会高等数学；先学会“谁相对谁”。]
  ]
]

== 先建立一张地图

#grid(columns: (1fr, 1fr, 1fr), gutter: 12pt,
  panel([
    #tag[01 · 表达]
    #v(8pt)
    #text(size: 20pt, weight: "bold")[坐标变换]
    #v(6pt)
    #note[把点从一个坐标系搬到另一个坐标系]
  ]),
  panel([
    #tag[02 · 感知], orange)
    #v(8pt)
    #text(size: 20pt, weight: "bold")[相机与手眼]
    #v(6pt)
    #note[让机器人知道“我看到了什么”]
  ]),
  panel([
    #tag[03 · 运动], green)
    #v(8pt)
    #text(size: 20pt, weight: "bold")[FK / IK / 插值]
    #v(6pt)
    #note[从关节角到末端动作，再反过来]
  ]),
)
#v(18pt)
#eq[$bold(p)^A = T_B^A bold(p)^B$]
#align(center)[#note[所有“运动学”问题，最后都在问这一句。]]

== 坐标系：给每个物体一套“描述语言”

#align(center)[
  #box(width: 82%, height: 90pt, fill: rgb("101C2E"), radius: 8pt)[
    #place(top + left, dx: 42pt, dy: 28pt)[#line(length: 95pt, angle: 0deg, stroke: 2pt + cyan)];
    #place(top + left, dx: 42pt, dy: 28pt)[#line(length: 75pt, angle: -35deg, stroke: 2pt + orange)];
    #place(top + left, dx: 42pt, dy: 28pt)[#circle(radius: 5pt, fill: green)]
    #place(top + left, dx: 142pt, dy: 16pt)[#text(fill: cyan, size: 16pt)[$x$]]
    #place(top + left, dx: 95pt, dy: -6pt)[#text(fill: orange, size: 16pt)[$y$]]
    #place(top + left, dx: 28pt, dy: 38pt)[#text(fill: green, size: 16pt)[$O$]]
    #align(center + horizon)[#text(size: 22pt)[同一个点，换一套坐标就会换一组数字]]
  ]
]
#v(0pt)
#grid(columns: (1fr, 1fr), gutter: 18pt,
  panel([#text(size: 18pt, weight: "bold", fill: cyan)[位姿 = 位置 + 姿态]#v(6pt)#note[位置：3 个数；姿态：描述“朝哪儿”]]),
  panel([#text(size: 18pt, weight: "bold", fill: orange)[齐次矩阵]#v(6pt)#note[把旋转、平移塞进一个 4×4 矩阵，便于连乘]]),
)

== 旋转的四种说法

#table(columns: (1.2fr, 1.4fr, 1.6fr), inset: 8pt, fill: (x, y) => if y == 0 { rgb("1D334A") } else { rgb("101C2E") },
  [*表示法*], [*参数*], [*什么时候好用*],
  [欧拉角], [3 个角；内旋 / 外旋], [人类直觉强，但有万向节锁],
  [旋转向量], [轴 × 角度（3）], [最小参数，优化常用],
  [四元数], [4 个数，单位范数], [插值稳定，工程库常用],
  [6D rotation], [两个 3D 列向量], [神经网络回归更平滑],
)
#v(5pt)
#align(center)[#note[四元数不是“更神秘”，只是把旋转组合写得更顺手。]]

== 内旋、外旋：同样的角度，不同的故事

#grid(columns: (1fr, 1fr), gutter: 16pt,
  panel([
    #text(size: 19pt, weight: "bold", fill: cyan)[内旋 intrinsic]
    #v(8pt)
    #note[绕“物体自己会跟着转的轴”旋转]
    #v(10pt)
    #eq[$R = R_z(γ) R_y(β) R_x(α)$]
  ]),
  panel([
    #text(size: 19pt, weight: "bold", fill: orange)[外旋 extrinsic]
    #v(8pt)
    #note[绕“世界固定的轴”依次旋转]
    #v(10pt)
    #eq[$R = R_x(α) R_y(β) R_z(γ)$]
  ]),
)
#v(16pt)
#align(center)[#text(size: 18pt, fill: green, weight: "bold")[口诀：看清楚轴是谁的，再看矩阵乘法从右往左。]]

== scipy：先用库，再理解库

#panel([
  #text(size: 17pt, fill: cyan, weight: "bold")[Python 小实验]
  #v(8pt)
  #raw("from scipy.spatial.transform import Rotation as R\\nrot = R.from_euler('zyx', [30, 20, 10], degrees=True)\\nrot.as_quat()      # (x, y, z, w)\\nrot.as_rotvec()    # 旋转向量\\nrot.as_matrix()    # 3 × 3", block: true, lang: "python")
])
#v(12pt)
#grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
  panel([#text(size: 17pt, fill: orange, weight: "bold")[自由度 DoF]#v(5pt)#note[独立可动的数量：平面 3，自由空间刚体 6]]),
  panel([#text(size: 17pt, fill: green, weight: "bold")[关节 ≠ DoF]#v(5pt)#note[约束、耦合、闭环会减少自由度]]),
  panel([#text(size: 17pt, fill: cyan, weight: "bold")[单位一致]#v(5pt)#note[角度、长度、坐标系约定先写在纸上]]),
)

== 相机成像：3D 点如何变成 2D 像素

#align(center)[
  #box(width: 90%, height: 145pt, fill: rgb("101C2E"), radius: 8pt)[
    #place(top + left, dx: 25pt, dy: 47pt)[#line(length: 90pt, stroke: 2pt + cyan)]
    #place(top + left, dx: 25pt, dy: 47pt)[#circle(radius: 5pt, fill: cyan)]
    #place(top + left, dx: 125pt, dy: 25pt)[#line(length: 95pt, angle: 90deg, stroke: 2pt + orange)]
    #place(top + left, dx: 220pt, dy: 47pt)[#circle(radius: 5pt, fill: green)]
    #place(top + left, dx: 245pt, dy: 32pt)[#text(fill: green, size: 16pt)[$P=(X,Y,Z)$]]
    #place(top + left, dx: 35pt, dy: 24pt)[#text(fill: cyan, size: 16pt)[光心]]
    #place(top + left, dx: 130pt, dy: 112pt)[#text(fill: orange, size: 16pt)[成像平面]]
    #place(top + left, dx: 390pt, dy: 47pt)[#text(size: 18pt, fill: muted)[投影]]
  ]
]
#v(12pt)
#eq[$s mat(u, v, 1) = K [R | t] mat(X, Y, Z, 1)$]
#align(center)[#note[$K$ 是相机内参；$R,t$ 描述相机相对世界的位置。]]

== 内参标定：用“已知的格子”反推相机

#grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
  panel([#text(size: 18pt, fill: cyan, weight: "bold")[1 · 拍棋盘格]#v(8pt)#note[不同距离、不同角度，收集多张图]]),
  panel([#text(size: 18pt, fill: orange, weight: "bold")[2 · 找角点]#v(8pt)#note[像素坐标 ↔ 棋盘格坐标]]),
  panel([#text(size: 18pt, fill: green, weight: "bold")[3 · 最小化误差]#v(8pt)#note[让重投影点尽量贴回观测点]]),
)
#v(16pt)
#eq[$min_K sum_i (hat(p_i(K) - p_i))^2$]
#align(center)[#note[标定的本质：让模型“重新画出来”的点，和照片中的点重合。]]

== 畸变：镜头不是理想小孔

#grid(columns: (1fr, 1fr), gutter: 16pt,
  panel([
    #text(size: 19pt, fill: orange, weight: "bold")[径向畸变]
    #v(8pt)
    #note[离光心越远，弯得越明显；桶形 / 枕形]
    #v(8pt)
    #eq[$x_d = x(1+k_1r^2+k_2r^4)$]
  ]),
  panel([
    #text(size: 19pt, fill: cyan, weight: "bold")[切向畸变]
    #v(8pt)
    #note[镜头与成像平面不完全平行]
    #v(8pt)
    #eq[$x_d = x + 2 p_1 x y + p_2(r^2+2 x^2)$]
  ]),
)
#v(12pt)
#align(center)[#text(size: 18pt, fill: green, weight: "bold")[先去畸变，再做几何；否则误差会被放大。]]

== 手眼标定：让“手”和“眼”说同一种语言

#align(center)[
  #box(width: 88%, height: 145pt, fill: rgb("101C2E"), radius: 8pt)[
    #place(top + left, dx: 28pt, dy: 50pt)[#circle(radius: 24pt, fill: cyan.lighten(45%))]
    #place(top + left, dx: 18pt, dy: 44pt)[#text(fill: rgb("0B1220"), weight: "bold")[相机]]
    #place(top + left, dx: 140pt, dy: 60pt)[#line(length: 155pt, stroke: 2pt + orange)]
    #place(top + left, dx: 325pt, dy: 50pt)[#rect(width: 55pt, height: 40pt, fill: orange.lighten(55%), radius: 5pt)]
    #place(top + left, dx: 333pt, dy: 62pt)[#text(fill: rgb("0B1220"), weight: "bold")[机械臂]]
    #place(top + left, dx: 475pt, dy: 54pt)[#circle(radius: 20pt, fill: green.lighten(45%))]
    #place(top + left, dx: 464pt, dy: 48pt)[#text(fill: rgb("0B1220"), weight: "bold")[靶标]]
  ]
]
#v(12pt)
#eq[$A_i X = X B_i$]
#align(center)[#note[多组运动数据一起解，得到相机与末端之间的固定变换 $X$。]]

== FK：给定关节角，末端在哪里？

#text(size: 19pt, fill: cyan, weight: "bold")[DH 表示法：每一节只记 4 个参数]
#v(8pt)
#table(columns: (1fr, 1fr, 1fr, 1fr), inset: 8pt, fill: (x, y) => if y == 0 { rgb("1D334A") } else { rgb("101C2E") },
  [α · 扭转], [a · 杆长], [d · 偏距], [θ · 关节角],
  [绕 x 旋转], [沿 x 平移], [沿 z 平移], [绕 z 旋转],
)
#v(12pt)
#eq[$T_0^n = A_1(α_1,a_1,d_1,θ_1) dots A_n(α_n,a_n,d_n,θ_n)$]
#align(center)[#note[推荐看台大机器人运动学：先画坐标系，再写矩阵，最后乘起来。]]

== IK：末端想去那里，关节怎么配？

#grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
  panel([#text(size: 18pt, fill: cyan, weight: "bold")[零解]#v(8pt)#note[目标超出工作空间，怎么也够不到]]),
  panel([#text(size: 18pt, fill: orange, weight: "bold")[一解 / 多解]#v(8pt)#note[同一个姿态，肘上 / 肘下都可能成立]]),
  panel([#text(size: 18pt, fill: green, weight: "bold")[无穷解]#v(8pt)#note[冗余机械臂：7 DoF 可以“绕路”避障]]),
)
#v(16pt)
#eq[$f(q)=x_d  arrow.r q = f^(-1)(x_d)$]
#align(center)[#note[但 $f^{-1}$ 往往不是函数，而是一簇候选解。]]

== 构型与奇异位形：Flexiv Rizon 4 的提醒

#align(center)[
  #box(width: 88%, height: 125pt, fill: rgb("101C2E"), radius: 8pt)[
    #grid(columns: (1fr, 1fr, 1fr), gutter: 18pt,
      [#align(center + horizon)[#text(size: 17pt, fill: cyan)[肘上] #text(size: 34pt, fill: cyan)[↗]]],
      [#align(center + horizon)[#text(size: 17pt, fill: orange)[肘下] #text(size: 34pt, fill: orange)[↘]]],
      [#align(center + horizon)[#text(size: 17pt, fill: green)[腕部对齐] #text(size: 34pt, fill: green)[∥]]],
    )
  ]
]
#v(12pt)
#text(size: 18pt, fill: muted)[工程上常用的选择准则：]
#v(5pt)
#grid(columns: (1fr, 1fr), gutter: 14pt,
  panel([#text(size: 17pt, fill: cyan)[离关节限位远]#v(5pt)#note[留出安全余量]]),
  panel([#text(size: 17pt, fill: orange)[离奇异位形远]#v(5pt)#note[让雅可比矩阵保持“可用”]]),
)

== 其他运动学问题：从台大教程继续追问

#grid(columns: (1fr, 1fr), gutter: 14pt,
  panel([#text(size: 18pt, fill: cyan, weight: "bold")[雅可比 Jacobian]#v(6pt)#note[关节速度 → 末端速度；还能看奇异性]]),
  panel([#text(size: 18pt, fill: orange, weight: "bold")[静力学]#v(6pt)#note[末端受力 → 每个关节要多大力矩]]),
  panel([#text(size: 18pt, fill: green, weight: "bold")[工作空间]#v(6pt)#note[所有可达位置的集合，不只是一个球]]),
  panel([#text(size: 18pt, fill: cyan, weight: "bold")[冗余与避障]#v(6pt)#note[在满足任务的同时，选更舒服的姿态]]),
)
#v(16pt)
#align(center)[#text(size: 19pt, fill: orange, weight: "bold")[运动学把“动作”变成了可计算的约束。]]

== 运动学插值：别让机器人“瞬移”

#grid(columns: (1fr, 1fr, 1fr), gutter: 10pt,
  panel([#text(size: 18pt, fill: cyan, weight: "bold")[关节空间]#v(7pt)#note[$q(t)$ 逐关节插值；实现最简单]]),
  panel([#text(size: 18pt, fill: orange, weight: "bold")[笛卡尔空间]#v(7pt)#note[末端走直线；姿态用四元数 SLERP]]),
  panel([#text(size: 18pt, fill: green, weight: "bold")[时间参数化]#v(7pt)#note[速度、加速度、加加速度都要连续]]),
)
#v(16pt)
#eq[$q(t) = q_0 + (q_1-q_0)(3s^2-2s^3),  s=t/T$]
#align(center)[#note[平滑起停的关键：不要只插位置，还要管速度与加速度。]]

== 一页带走：机器人运动学的学习路线

#grid(columns: (1fr, 1fr, 1fr, 1fr), gutter: 8pt,
  panel([#text(size: 19pt, fill: cyan, weight: "bold")[1]#v(7pt)#note[坐标系\n把“谁相对谁”说清楚]]),
  panel([#text(size: 19pt, fill: orange, weight: "bold")[2]#v(7pt)#note[变换\n旋转 + 平移 + 连乘]]),
  panel([#text(size: 19pt, fill: green, weight: "bold")[3]#v(7pt)#note[求解\nFK 正推，IK 反解]]),
  panel([#text(size: 19pt, fill: cyan, weight: "bold")[4]#v(7pt)#note[验证\n仿真、标定、插值、上机]]),
)
#v(20pt)
#align(center)[#text(size: 24pt, fill: orange, weight: "bold")[下一步：用 scipy + 一个 2-link 小机械臂，把每个公式跑起来。]]
#v(12pt)
#align(center)[#note[参考：SciPy Rotation 文档；OpenCV Camera Calibration；台大机器人学教学视频；Touying 文档。]]
