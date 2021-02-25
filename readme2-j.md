# About
[オリジナル](https://github.com/mariosanchez23/simplemirror)を元に、クラウド、コンテナ内などVIPを使用しない(動作しない)環境でのミラー構成の例を作成しました。手元で(コストを気にせず)気軽にいろいろと試せる環境の作成を目的にしています。  
ミラーを使用するため、コミュニティエディションでは動作しません。[ミラーが有効なx64コンテナ用のライセンスキー](https://wrc.intersystems.com/wrc/coDistEvaluation.csp) をご用意ください。

# How to setup.
Dmitriy氏の[web gateway container](https://github.com/caretdev/iris-webgateway-example)を使用しています。[関連ポスト](https://community.intersystems.com/post/apache-and-containerised-iris)。

下記の追加要素を加えるために、上記のレポ取得後に、webgateway-entrypoint.sh,webgateway.confを置き換える必要があります。
- ミラー構成
- /api/パスの認識

```
$ git clone https://github.com/IRISMeister/simplemirror.git
$ git clone https://github.com/caretdev/iris-webgateway-example
$ copy ./simplemirror/webgateway-entrypoint.sh iris-webgateway-example/
$ copy ./simplemirror/webgateway.conf iris-webgateway-example/
$ cd iris-webgateway-example
$ docker-compose build
$ cd ../simplemirror
$ cp ミラーが有効なx64コンテナ用のライセンスキー ./iris.key
$ ./start.sh
or
$ ./start-single-bridge.sh   (mimics typical cloud env where you have only one NIC)
```

# コンテナ群
起動すると、下記のコンテナ群を起動します。
|コンテナサービス名|コンテナイメージ|Web公開ポート|用途|AWSでの読み替え|
|:--|:--|:--|:--|:--|
|nginx|nginx|80|LBとして機能|LB|
|webgw1|独自|8080|Web gateway #1|EC2|
|webgw2|独自|8081|Web gateway #2|EC2|
|ap1a|iris|9092|AP1ミラークラスタのメンバ|EC2|
|ap1b|iris|9093|AP1ミラークラスタのメンバ|EC2|
|ap2a|iris|9094|AP2ミラークラスタのメンバ|EC2|
|ap2b|iris|9095|AP2ミラークラスタのメンバ|EC2|

- AP1,AP2はそれぞれHAミラークラスタを構成する単位です。AP1はap1a,ap1bコンテナで構成されます。同様にAP2はap2a,ap2bコンテナで構成されます。
- Web gateway #1と#2は負荷分散目的で、全く同じ構成を持ちます。
- NGINXは上記、Web gateway #1,#2をアップストリームに持つreverse proxyとして機能します。
- 各コンテナは、ポート番号が重複しないように、ポートを変更してホストO/Sにエンドポイントを公開しています。  
- 各コンテナ要素をAWSの要素に置き換えて考えることができます。その場合、docker-composeはVPC環境、ホストO/Sはインターネットに相当すると考えます。

[構成図](https://github.com/IRISMeister/doc-images/blob/main/simplemirror/diagram.png)

# Web endpoints
Webサーバが複数(専用Apache*2, IRIS同梱のApache*4, LB代わりのNGINXの計7台)存在するため、多数のエンドポイントが用意されますが、主たる用途を考慮すると使用に適したものは限定されます。

## Web gateway management portal
利便性のため、全てのポートをO/Sに公開していますが、管理画面なので、外部(LB)からのアクセスは無く、ネットワーク(VPC)内部からのアクセスが主になります。

|要素|エンドポイント|備考|
|:--|:--|:--|
|AP1A組み込みApache|http://irishost:9092/csp/bin/Systems/Module.cxw|You are not authorized to use this facility|
|AP1B組み込みApache|http://irishost:9093/csp/bin/Systems/Module.cxw|You are not authorized to use this facility|
|AP2A組み込みApache|http://irishost:9094/csp/bin/Systems/Module.cxw|You are not authorized to use this facility|
|AP2B組み込みApache|http://irishost:9095/csp/bin/Systems/Module.cxw|You are not authorized to use this facility|
|Web Gateway#1|http://irishost:8080/csp/bin/Systems/Module.cxw||
|Web Gateway#2|http://irishost:8081/csp/bin/Systems/Module.cxw||
|NGINX|http://irishost/csp/bin/Systems/Module.cxw|本用途に不向き|

## system management portal

|要素|エンドポイント|備考|
|:--|:--|:--|
|AP1A組み込みApache|http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen||
|AP1B組み込みApache|http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen||
|AP2A組み込みApache|http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen||
|AP2A組み込みApache|http://irishost:9092/csp/sys/%25CSP.Portal.Home.zen||
|Web Gateway#1|http://irishost:8080/ap1a/csp/sys/%25CSP.Portal.Home.zen|AP1A|
|Web Gateway#1|http://irishost:8080/ap1b/csp/sys/%25CSP.Portal.Home.zen|AP1B|
|Web Gateway#1|http://irishost:8080/ap2a/csp/sys/%25CSP.Portal.Home.zen|AP2A|
|Web Gateway#1|http://irishost:8080/ap2b/csp/sys/%25CSP.Portal.Home.zen|AP2B|
|Web Gateway#2|http://irishost:8081/ap1a/csp/sys/%25CSP.Portal.Home.zen|AP1A|
|Web Gateway#2|http://irishost:8081/ap1b/csp/sys/%25CSP.Portal.Home.zen|AP1B|
|Web Gateway#2|http://irishost:8081/ap2a/csp/sys/%25CSP.Portal.Home.zen|AP2A|
|Web Gateway#2|http://irishost:8081/ap2b/csp/sys/%25CSP.Portal.Home.zen|AP2B|
|Web Gateway#1|http://irishost:8080/ap1/csp/sys/%25CSP.Portal.Home.zen |AP1クラスタのプライマリメンバ,本用途に不向き|
|Web Gateway#1|http://irishost:8080/ap2/csp/sys/%25CSP.Portal.Home.zen |AP2クラスタのプライマリメンバ,本用途に不向き|
|Web Gateway#2|http://irishost:8081/ap1/csp/sys/%25CSP.Portal.Home.zen |AP1クラスタのプライマリメンバ,本用途に不向き|
|Web Gateway#2|http://irishost:8081/ap2/csp/sys/%25CSP.Portal.Home.zen |AP2クラスタのプライマリメンバ,本用途に不向き|

## IRIS provided REST APIs

|要素|エンドポイント|備考|
|:--|:--|:--|
|AP1A組み込みApache|http://irishost:9092/api/mgmnt/||
|AP1B組み込みApache|http://irishost:9093/api/mgmnt/||
|AP2A組み込みApache|http://irishost:9094/api/mgmnt/||
|AP2A組み込みApache|http://irishost:9095/api/mgmnt/||
|Web Gateway#1|http://irishost:8080/ap1a/api/mgmnt/|AP1A|
|Web Gateway#1|http://irishost:8080/ap1b/api/mgmnt/|AP1B|
|Web Gateway#1|http://irishost:8080/ap2a/api/mgmnt/|AP2A|
|Web Gateway#1|http://irishost:8080/ap2b/api/mgmnt/|AP2B|
|Web Gateway#2|http://irishost:8081/ap1a/api/mgmnt/|AP1A|
|Web Gateway#2|http://irishost:8081/ap1b/api/mgmnt/|AP1B|
|Web Gateway#2|http://irishost:8081/ap2a/api/mgmnt/|AP2A|
|Web Gateway#2|http://irishost:8081/ap2b/api/mgmnt/|AP2B|
|Web Gateway#1|http://irishost:8080/ap1/api/mgmnt/ |AP1クラスタのプライマリメンバ,用途次第|
|Web Gateway#1|http://irishost:8080/ap2/api/mgmnt/ |AP2クラスタのプライマリメンバ,用途次第|
|Web Gateway#2|http://irishost:8081/ap1/api/mgmnt/ |AP1クラスタのプライマリメンバ,用途次第|
|Web Gateway#2|http://irishost:8081/ap2/api/mgmnt/|AP2クラスタのプライマリメンバ,用途次第|

- アクセス時には認証が必要です
```
$ curl http://irishost:9092/api/mgmnt/ -u SuperUser:SYS -s | jq
```

## Health Check 

|要素|エンドポイント|備考|
|:--|:--|:--|
|Web Gateway#1|http://irishost:8080/ap1a/csp/mirror_status.cxw|AP1A|
|Web Gateway#1|http://irishost:8080/ap1b/csp/mirror_status.cxw|AP1B|
|Web Gateway#1|http://irishost:8080/ap2a/csp/mirror_status.cxw|AP2A|
|Web Gateway#1|http://irishost:8080/ap2b/csp/mirror_status.cxw|AP2B|
|Web Gateway#2|http://irishost:8081/ap1a/csp/mirror_status.cxw|AP1A|
|Web Gateway#2|http://irishost:8081/ap1b/csp/mirror_status.cxw|AP1B|
|Web Gateway#2|http://irishost:8081/ap2a/csp/mirror_status.cxw|AP2A|
|Web Gateway#2|http://irishost:8081/ap2b/csp/mirror_status.cxw|AP2B|

## App end point

|要素|エンドポイント|備考|
|:--|:--|:--|
|Web Gateway#1|http://irishost/ap1/csp/mirrorns/get|AP1クラスタのプライマリメンバ|
|Web Gateway#2|http://irishost/ap2/csp/mirrorns/get|AP2クラスタのプライマリメンバ|

- アクセス時には認証が必要です
```
$ curl http://irishost/ap1/csp/mirrorns/get -u SuperUser:SYS -s | jq
```

# Health Checkの振る舞い
各ミラーの状態に置けるHealth Checkの応答は下記のようになります。  
注意) Active Health Checksは有償のNGINX Plusのみで提供されているので、動作はPassiveになります。
> つまり、mirror_status.cxwは使用していません。  
(要確認)InterSystems API Manager (KONG)には Active Health Check機能が含まれています。

## ap1a:Primary, ap1b:Backup 
起動直後の状態です。
```
$ curl -m 5 http://irishost:8080/ap1a/csp//mirror_status.cxw -v
$ curl -m 5 http://irishost:8081/ap1a/csp//mirror_status.cxw -v
< HTTP/1.1 200 OK
SUCCESS
$ curl -m 5 http://irishost:8080/ap1b/csp//mirror_status.cxw -v
$ curl -m 5 http://irishost:8081/ap1b/csp//mirror_status.cxw -v
< HTTP/1.1 503 Service Unavailable
FALIED
```
アプリケーションに見立てた下記のAPIコールで、リクエストがap1a(AP1クラスタのプライマリメンバ)、ap2a(AP2クラスタのプライマリメンバ)に到達していることが確認できます。
```
$ curl http://irishost/ap1/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "ap1a",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/25/2021 12:54:22",
  "ImageBuilt": ""
}
$ curl http://irishost/ap2/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "ap2a",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/25/2021 12:55:58",
  "ImageBuilt": ""
}
```

## ap1a:down, ap1b:Primary
ap1aのIRISを停止して、ap1bをプライマリに昇格させます。
```
$ docker-compose exec ap1a iris stop iris quietly
$ curl -m 5 http://irishost:8080/ap1a/csp/mirror_status.cxw -v
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
$ curl -m 5 http://irishost:8080/ap1b/csp/mirror_status.cxw -v
< HTTP/1.1 200 OK
SUCCESS
```
ap1aが応答しなくなったため、curlでtimeout(5秒)が発生しました。(Active Healthcheckであれば、この接続を無効にマークします)

```
$ curl http://irishost/ap1/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "ap1b",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/25/2021 13:01:31",
  "ImageBuilt": ""
}
```
期待通り、アプリケーションはap1bに到達しています。

## ap1a:down, ap1b:down
ap1ミラークラスタの全IRISメンバを停止状態にします。
```
$ docker-compose exec ap1b iris stop iris quietly
$ curl -m 5 http://irishost:8080/ap1a/csp/mirror_status.cxw -v
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
$ curl -m 5 http://irishost:8080/ap1b/csp//mirror_status.cxw -v
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
```
誰も応答しないので、curlでtimeout(5秒)が発生しました。

```
curl http://irishost/ap1/csp/mirrorns/get -u SuperUser:SYS -s
<html>
<head><title>504 Gateway Time-out</title></head>
<body>
<center><h1>504 Gateway Time-out</h1></center>
<hr><center>nginx/1.19.7</center>
</body>
</html>
```
curlのタイムアウトを設定しなかったので、Webの設定値次第ですが、どこかでタイムアウトが発生します。今回のケースでは、Web Gateway#2がタイムアウトしました。その後、NGINXがWeb gateway #1をトライしましたが、そちらもタイムアウトを起こしたので、最終的にNGINXからcurlにエラー(504 Gateway Time-out)が返っています。

```
$ docker-compose logs -f webgw2
  ・
  ・
webgw2     | 10.0.100.13 - - [25/Feb/2021:14:09:51 +0900] "GET /ap1/csp/mirrorns/get HTTP/1.0" 500 -

$ docker-compose logs -f nginx
  ・
  ・
nginx      | 2021/02/25 14:10:51 [warn] 30#30: *29 upstream server temporarily disabled while reading response header from upstream, client: 10.0.100.1, server: nginx, request: "GET /ap1/csp/mirrorns/get HTTP/1.1", upstream: "http://10.0.100.12:80/ap1/csp/mirrorns/get", host: "irishost"
nginx      | 2021/02/25 14:10:51 [error] 30#30: *29 upstream timed out (110: Connection timed out) while reading response header from upstream, client: 10.0.100.1, server: nginx, request: "GET /ap1/csp/mirrorns/get HTTP/1.1", upstream: "http://10.0.100.12:80/ap1/csp/mirrorns/get", host: "irishost"
nginx      | 2021/02/25 14:11:51 [warn] 30#30: *29 upstream server temporarily disabled while reading response header from upstream, client: 10.0.100.1, server: nginx, request: "GET /ap1/csp/mirrorns/get HTTP/1.1", upstream: "http://10.0.100.11:80/ap1/csp/mirrorns/get", host: "irishost"
nginx      | 2021/02/25 14:11:51 [error] 30#30: *29 upstream timed out (110: Connection timed out) while reading response header from upstream, client: 10.0.100.1, server: nginx, request: "GET /ap1/csp/mirrorns/get HTTP/1.1", upstream: "http://10.0.100.11:80/ap1/csp/mirrorns/get", host: "irishost"
nginx      | 10.0.100.1 - SuperUser [25/Feb/2021:14:11:51 +0900] "GET /ap1/csp/mirrorns/get HTTP/1.1" 504 167 "-" "curl/7.58.0" "-" "10.0.100.12:80, 10.0.100.11:80"

$ docker-compose logs -f webgw1
webgw      | 10.0.100.13 - - [25/Feb/2021:14:10:51 +0900] "GET /ap1/csp/mirrorns/get HTTP/1.0" 500 -
```

## ap1a:Primary, ap1b:down
ap1aを起動します。ap1aはプライマリになります。
```
$ docker-compose exec ap1a iris start iris quietly
$ curl -m 5 http://irishost:8080/ap1a/csp//mirror_status.cxw -v
< HTTP/1.1 200 OK
SUCCESS
$ curl -m 5 http://irishost:8080/ap1b/csp//mirror_status.cxw -v
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
```
ap1bは停止状態ですので、curlでtimeout(5秒)が発生しました。

```
$ curl http://irishost/ap1/csp/mirrorns/get -u SuperUser:SYS -s | jq
{
  "HostName": "ap1a",
  "UserName": "SuperUser",
  "Status": "OK",
  "TimeStamp": "02/25/2021 14:19:13",
  "ImageBuilt": ""
}
```
期待通り、アプリケーションはap1aに到達しています。

# 負荷をかけてみる
正常な状態で起動します。
```
$ ./stop.sh
$ ./start.sh
```

連続でリクエストを発生させても正常に動作することを確認します。
```
$ curl -m 5 http://irishost:8080/ap1a/csp//mirror_status.cxw?[1-100]
$ curl http://irishost/ap1/csp/mirrorns/get?[1-100] -u SuperUser:SYS 
```
Web gateway managemtnのSystem Statusで、どのような接続が作成されているかを確認します。  
下記で、Web gatewayを再起動して接続やカウンタをリセットする事ができます。
```
$ docker-compose restart webgw1
$ docker-compose restart webgw2
```

補足)
Web gateway management portalで[Status=Server]が[複数発生](https://www.intersystems.com/jp/support-learning/support/product-news-alerts/support-alert/alert-possible-resource-starvation-due-to-orphaned-processes/)していたので、無効化しました。
```
[SYSTEM]
REGISTRY_METHODS=Disabled

```
