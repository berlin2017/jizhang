# 记账 App (jizhang_app)

这是一个使用 Flutter 构建的跨平台记账应用。用户可以轻松记录每日的收入和支出，并通过图表直观地了解自己的财务状况。

## 功能特性

*   **记录开销**: 快速添加收入或支出条目。
*   **分类管理**: 自定义消费类别，例如餐饮、交通、购物等。
*   **图表分析**: 通过饼图和条形图查看消费分布和趋势。
*   **数据持久化**: 所有数据都存储在本地的 SQLite 数据库中，确保数据的安全和私密。
*   **跨平台**: 一份代码库，可同时在 Android、iOS、Web、Windows、macOS 和 Linux 上运行。

## 环境准备

在开始之前，请确保你已经安装并配置好了 Flutter 开发环境。

1.  **安装 Flutter SDK**:
    *   请访问 [Flutter 官网](https://flutter.dev/docs/get-started/install) 并根据你的操作系统下载和安装 Flutter SDK。
    *   配置好 Flutter 的环境变量。

2.  **安装编辑器**:
    *   推荐使用 [Visual Studio Code](https://code.visualstudio.com/) (并安装 Flutter 扩展) 或 [Android Studio](https://developer.android.com/studio) (并安装 Flutter 插件)。

3.  **检查环境配置**:
    *   运行 `flutter doctor` 命令，确保没有未解决的问题。

## 如何运行

1.  **克隆或下载项目**:
    ```bash
    git clone git@github.com:berlin2017/jizhang.git
    cd jizhang
    ```

2.  **获取项目依赖**:
    在项目根目录下运行以下命令，以下载所有必要的依赖包。
    ```bash
    flutter pub get
    ```

3.  **运行应用**:
    连接你的设备或启动一个模拟器，然后运行以下命令来启动应用。
    ```bash
    flutter run
    ```

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型 (例如，交易、分类)
│   ├── category.dart
│   └── transaction.dart
├── pages/                    # 应用的主要页面 (UI)
│   ├── add_transaction_page.dart
│   ├── charts_page.dart
│   ├── edit_transaction_page.dart
│   ├── home_page.dart
│   ├── manage_categories_page.dart
│   ├── settings_page.dart
│   └── transactions_page.dart
└── services/                 # 服务 (例如，数据库操作)
    ├── database_helper.dart
    └── storage_service.dart
```

## 主要依赖

*   `flutter`: Flutter 框架
*   `cupertino_icons`: iOS 风格的图标
*   `intl`: 用于国际化和日期格式化
*   `fl_chart`: 用于创建图表
*   `sqflite`: 用于本地 SQLite 数据库存储

---

如果你有任何问题或建议，欢迎随时提出！