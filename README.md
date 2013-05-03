uploador
========

马上上传！

## 怎样让该程序在本地跑起来

### 准备工作

* 安装 [nodejs](http://nodejs.org/), [bower](http://bower.io/)
* 申请一个新浪微博APP,得到它的APPKEY和APPSECRET，并设置它的OAuth重定向地址为`http://uploador.micy.in/oauth_callback`。
* 设置本地的`/etc/hosts`文件，使`uploador.micy.in`指向自己，即`127.0.0.1`
* 设置本地的防火墙，映射本地80端口到3000端口（临时映射一下），方法可参考： [linux](http://www.cyberciti.biz/faq/linux-port-redirection-with-iptables/)、[OSX](http://deansli.st/archives/452)

### 配置一下

该程序的配置通过环境变量进行，以下环境变量需要配置

```sh
export WEIBO_CALLBACK="http://uploador.micy.in/oauth_callback"
export WEIBO_KEY="366xxxxxxx"
export WEIBO_SECRET="3aa4xxxxxxxxxxxxxxxxxxxxxxxx"
```

### 安装依赖

```sh
npm install
bower install
```

### 启动

```sh
node .
```
