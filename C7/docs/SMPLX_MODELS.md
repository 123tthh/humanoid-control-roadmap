# C7 SMPL-X 人体模型安装

GMR 的 SMPL-X 重定向需要受许可保护的官方人体模型。官方仓库与课程 PDF 要求从
[SMPL-X 官方站点](https://smpl-x.is.tue.mpg.de/)注册后下载，不能以来源不明的公开镜像替代。

下载完成后，将文件放到：

```text
/home/gtk/UNITREE/C7/gmr/assets/body_models/smplx/
```

最终文件名必须是：

```text
SMPLX_NEUTRAL.pkl
SMPLX_FEMALE.pkl
SMPLX_MALE.pkl
```

课程中 GMR 使用 `.pkl` 模型；安装 `smplx` Python 包后还应按 GMR README 将其
`smplx/body_models.py` 的模型扩展名配置为 `pkl`。该变更只应在 C7 专用 `gmr310`
环境安装完成后进行，不能修改 C1 的环境。
