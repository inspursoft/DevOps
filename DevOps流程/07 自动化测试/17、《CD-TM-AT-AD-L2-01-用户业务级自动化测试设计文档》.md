# CD-TM-AT-AD-L2-01-用户业务级自动化测试设计文档

## 能力项  [自动化测试]

# 前言

软件测试的定义是：在规定的条件下对程序进行操作，以发现程序错误，衡量软件质量，并对其是否能满足设计要求进行评估的过程。自动化测试是使用软件工具和既定程序，对软件所进行的测试活动。

面临需求时间跨度长的困难，如果有自动化测试约束，则其演变一定是一个受控的过程。这恰恰说明了实施自动化测试有非常重要的意义。相对于热补技术这种事后补救技术，自动化测试才是更根本性的质量保障手段。

根据测试金字塔分层模型最底层是单元测试，然后是API接口测试，最后是业务流程自动化测试。其中业务流程自动化测试时从最终用户的角度对业务流程进行模拟测试，测试用例环境集成程度最高，但也面临执行速度慢的问题。

# 目的

本文描述业务流程自动化测试的要求、特点以及设计方法和工具。

# 金字塔分层模型

在敏捷方法中，持续集成是其基石，持续集成的核心是自动化测试。测试金字塔的概念来自Mike Cohn，在他的书《Succeeding with Agile》中有详细描述：测试金字塔最底层是单元测试，然后是业务逻辑测试，最后是端到端的测试（GUI或CLI）。

![Testing Layer](../../docs/imgs/DevOps流程/Testing_Layer.png)

这个比喻非常形象，它让你一眼就知道测试是需要分层的。它还告诉你每一层需要写多少测试。

根据 Mike Cohn 的测试金字塔，建议测试组合应该由以下三层组成（自下往上分别是）：

- 单元测试

- 服务测试

- 用户界面测试

从具体项目的角度来看，测试金字塔似乎过于简单了，因此可能会产生误导。然而，由于其简洁性，在建立适合项目的测试组合时，测试金字塔本身是一条很好的经验法则。Cohn 测试金字塔中提到的两个原则是非常重要的：

- 编写不同粒度的测试

- 层次越高，编写的测试应该越少

为了维持金字塔形状，一个健康、快速、可维护的测试组合应该是这样的：写许多小而快的单元测试。适当写一些更粗粒度的测试，写很少高层次的端到端测试。注意不要让测试组合变成倒三角形，那对维护来说将是一个噩梦，并且跑一遍也需要太多时间。

不要太拘泥于 Cohn 测试金字塔中各层次的名字。事实上，它们可能相当具有误导性：服务测试是一个难以掌握的术语（Cohn 本人说他观察到很多开发人员完全忽略了这一层）。如果项目使用单页应用框架（如 react，angular，ember.js 等），UI 测试显然不必位于金字塔的最高层，完全能够用这些框架对 UI 进行单元测试。

考虑到原始名称的缺点，只要在代码库和团队中通过讨论中达成一致，完全可以为测试层次提供其他名称。

本项目采取单元测试、服务测试、用户界面测试的分层模型，其中使用用户界面测试模拟用户业务进行业务级自动化测试。

# 测试工具

Appium是一个开源的自动化测试工具，其支持iOS和安卓平台上的原生的，基于移动浏览器的，混合的应用。

- “移动原生应用”是指那些用iOS或者 Android SDK 写的应用（Application简称app）。

- “移动web应用”是指使用移动浏览器访问的应用（appium支持iOS上的Safari和Android上的 Chrome）。

- “混合应用”是指原生代码封装网页视图——原生代码和 web 内容交互。比如，像 Phonegap，可以帮助开发者使用网页技术开发应用，然后用原生代码封装，这些就是混合应用。

使用Appium带来的好处：

·         Appium是一个跨平台的工具：它允许测试人员在不同的平台（iOS，Android）使用同一套API来写自动化测试脚本，增加了iOS和Android测试套件间代码的复用性。

·         Appium支持Selenium WebDriver支持的所有语言，如java、Object-C、JavaScript、Php、Python、Ruby、C#、Clojure，或者Perl语言，更可以使用Selenium WebDriver的Api。Appium支持任何一种测试框架.Appium实现了真正的跨平台自动化测试。

Appium 的架构是一个用Node.js编写的HTTP server，它创建、并管理多个 WebDriver sessions 来和不同平台交互，如 iOS ，Android等等。

![Interface Proxy](../../docs/imgs/DevOps流程/Interface_Proxy.jpg)

Appium 开始一个测试后，就会在被测设备（手机）上启动一个 server ，监听来自 Appium server的指令. 每种平台像 iOS 和Android都有不同的运行、和交互方式。所以Appium会用某个桩程序“侵入”该平台，并接受指令，来完成测试用例的运行。

Appium类库封装了标准Selenium客户端类库，为用户提供所有常见的JSON格式selenium命令以及额外的移动设备控制相关的命令，如多点触控手势和屏幕朝向。

Appium客户端类库实现了Mobile JSON Wire Protocol（一个标准协议的官方扩展草稿）和W3C WebDriver spec（一个传输不可预知的自动化协议，该协议定义了MultiAction 接口）的元素。

Appium服务端定义了官方协议的扩展，为appium 用户提供了方便的接口来执行各种设备动作，例如在测试过程中安装/卸载App。这就是为什么我们需要appium特定的客户端，而不是通用的Selenium 客户端。当然，Appium 客户端类库只是增加了一些功能，而实际上这些功能就是简单的扩展了Selenium 客户端，所仍然可以用来运行通用的Selenium会话。

Appium选择了Client/Server的设计模式。只要client能够发送http请求给server，那么的话client用什么语言来实现都是可以的，这就是Appium及Selenium(WebDriver)如何做到支持多语言的原因；

Appium扩展了WebDriver的协议，不用重新去实现。这样的好处是以前的WebDriver API能够直接被继承过来，以前的Selenium（WebDriver）各种语言的binding都可以拿来就用，省去了为每种语言开发一个client的工作量。

| **语言/框架**        | **Github地址**                                               |
| -------------------- | ------------------------------------------------------------ |
| Ruby                 | <https://github.com/appium/ruby_lib>                         |
| Python               | <https://github.com/appium/python-client>                    |
| Java                 | <https://github.com/appium/java-client>                      |
| JavaScript (Node.js) | <https://github.com/admc/wd>                                 |
| Objective C          | <https://github.com/appium/selenium-objective-c>             |
| PHP                  | <https://github.com/appium/php-client>                       |
| C# (.NET)            | <https://github.com/appium/appium-dotnet-driver>             |
| RobotFramework       | <https://github.com/jollychang/robotframework-appiumlibrary> |

 

# 测试用例编写原则

## 关注需求和用户

- 站在用户的角度

- 重视全局，而非细节

- 客户现场场景

## 业务流程用例编写原则

- 需要准备基本数据，以便系统测试多次使用，同时方便自动化工具介入。

- 其他流程要依赖这套数据，使之每个流程可以更有针对性的执行。

- 构建的数据要尽量模拟客户现场，不能使用a、b、c；1、2、3等符号代替。

- 流程要符合用户常用的业务操作习惯，尽量考虑用户的实际操作去编写。

- 流程可大可小，但每一个流程都要是一个典型的业务操作。

- 流程不必覆盖到所有功能点，因为流程用例是功能用例的一个补充。

- 流程不要被具体的模块所限制，各个模块可以交叉。

- 用户实际的业务操作是没有界限的。

## 业务流程用例编写最佳实践

- 系统总流程

- 角色功能流程

- 测试数据流程

- 业务流程测试

## 测试执行原则

- 在系统测试过程中，每轮测试保持测试数据库都是完整的一套初始数据。

- 在数据稳定、界面稳定的前提下通过自动化工具录制业务流程测试脚本或者直接编写测试脚本，避免界面的不确定性

# 测试用例编写

项目中为了简化用例编写，减少开发与维护的工作量，使用Page Object模式进行用例开发。

Page Object定义为抽象页面的对象，通过对页面功能的封装，进行相应操作。它的优点是：

- 减少重复代码，增加复用性。

- 提高代码可读性、稳定性。

- 易于维护。

![Test Model](../../docs/imgs/DevOps流程/Test_Model.png)

UI自动化测试框架的编写方式类似于MVC架构，我测试用例中的业务逻辑、各个页面间的元素以及测试数据相分离后独立编写，以下用排队业务的主流程举例说明如何编写测试用例：

## 测试类组成

测试类的组成包括setUp()，tearDown()方法以及各个测试用例testXXXX()，所有的测试用例必须以小写test开头，如正常排号下的testQueueNormalQueue()：

```java
@Before
public void setUp() throws Exception {
    File apk = new File(APK_NOVA);
    DesiredCapabilities capabilities = DesiredCapabilities.android();
    capabilities.setCapability("device", Platform.ANDROID);
    capabilities.setCapability(CapabilityType.VERSION, "5.1");
    ……       // capabilities各个常量字段
    driver = new AndroidDriver<AndroidElement>(new URL("http://127.0.0.1:4723/wd/hub"), capabilities);
    splashScreen = new SplashScreen(driver);
    mainPage = new MainPage(driver);
    ……       // Page Object初始化
}
@After
public void tearDown() throws Exception {
    driver.quit();
}
@Test
public void testQueueNormalQueue() {
    // 略
}
```

测试用例中不用直接对页面元素进行操作，所要做的事情仅仅是业务层面的逻辑，包括表单数据的提交、页面按钮的点击跳转等等。

## 页面类编写

面类的编写采用Page Object模式，包括页面中会使用到的元素、页面元素的操作方法集以及页面元素的检验方法集。

所有的Page子类均继承BasePage父类，它要做的事情很简单，无非就是1个driver，2个driverWait用于延时加载的等待时间，以及页面元素的初始化：

```java
public class BasePage {
    private static final int TIMEOUT = 1;             // short timeout for web-element
    private static final int TIMEOUT_LONG = 10;       // long timeout for web-element
    public AndroidDriver<AndroidElement> driver;
    public WebDriverWait driverWait;
    public WebDriverWait driverLongWait;
    public BasePage(AndroidDriver<AndroidElement> driver) {
        this.driver = driver;
        this.driverWait = new WebDriverWait(this.driver, TIMEOUT);
        this.driverLongWait = new WebDriverWait(this.driver, TIMEOUT_LONG);
        PageFactory.initElements(this.driver, this);  // 这句非常重要，如果不写的话尽管编译不会报错，但是后面要说的页面元素在运行时一个都找不到
    }
}

```

然后是各个Page子类的实现方法：

```java
public class ShopInfoPage extends BasePage {
    public ShopInfoPage(AndroidDriver<AndroidElement> driver) {
        super(driver);
    }
    …… // 页面元素 @FindBy
    …… // 操作方法，比如login()、clickXXXXXXButton()、gotoXXXXXXPage()
    …… // 检验方法，比如checkLoaded()、checkLoginSuccess()、checkQueue_LoginReadyQueue()
}

```

Page子类的元素定位我们使用@FindBy注解方式进行统一的管理。元素定位最基本的方法就是使用id/name/class等，如果不行的话就用相对复杂却无所不能的xpath，如：

```java
// 点击登录按钮
@FindBy(id = "login_tip")
private WebElement clickLoginButton;

// MAPI域名输入框
@FindBy(xpath = "//*[contains(@resource-id, 'id/mapi_item')]//*[contains(@resource-id, 'id/debug_domain')]")
private WebElement mapiDomainText;

```

Page中的操作和检验方法调用已经封装好的BaseUtils中的方法，如：

```java
BaseUtils.waitForElement(driverWait, loginButton).click();                              // 等待元素出现并点击
Assert.assertTrue(BaseUtils.waitForElementVisibility(driverLongWait, usernameText));    // 检验元素应该展示在页面上

```

## BaseUtils方法

BaseUtils中封装好了一些通用的方法，还需要不断完善并扩展。下面介绍其中一些常用及重要的方法：

- openDebugPanel()：每次直接调用该方法来打开Debug面板，由于Debug面板是一个系统层面的悬浮窗，它不属于任何页面中的元素（你完全没办法通过ID甚至XPath获得）。

- clickPoint()：点击某个坐标+持续时间，坐标采用相对屏幕位移的方式（左上为0,0），这里只实现了简单的单指的点击操作，实际上driver.tap可以模拟多指的共同操作。

- swipeToUp() & swipeToDown()：上拉 & 下拉页面操作，需要传的是次数和每次持续时间，模拟手指在屏幕上的滑屏操作，主要用于刷新页面以及绕过某些有坑的scrollTo。

- prepareMockData()：这里要做的就是，在关键步骤操作前传入mock_data_id，我们会将数据请求发送给服务器，然后服务器从数据库拉到对应的mock data并更新。

- saveScreenshot()：顾名思义，截图。在每个重要的页面操作方法中加入即可，需要传入的是case_id以及操作或检查时的keyword，方便在用例执行完以后看截图分析和Bug复现。

- waitForElementXXX()：在预设等待时间内等待元素出现并定位元素。

## 测试运行报告

（待补充）

 

在业务线进行了UI自动化测试实践，相比于之前人工进行主流程测试动辄花费半天的工作量的情况，大大降低了人力成本，将工程师宝贵的时间节约给了更有价值的研发工作。

当然，自动化测试前期的环境搭建、数据准备、用例编写等任务是必不可少的，这些准备工作很多都是一次性投入，一劳永逸，也正是自动化测试的价值所在。