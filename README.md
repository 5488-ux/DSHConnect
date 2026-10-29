# DSH Connect

面向 DeepSeek Harness（DSH）的原生 iOS 26 连接壳。图片只作为视觉参考；真正的会话由 DSH 自己的 Web UI 提供，本项目负责发现主机、建立 HTTP(S) 连接、注入可选 Bearer token，并在连接失败时给出可操作的设置和重试入口。

## 连接逻辑

1. 启动后优先通过 Bonjour 搜索 `_dsh._tcp`。
2. 没有 DSH 服务时回退搜索 `_http._tcp`。
3. 仍未发现时读取 `Resources/dsh.yaml` 的 `host`、`port`、`scheme` 和 `path` 自动连接。
4. 连接成功后直接在 `WKWebView` 打开 DSH Web UI，所有会话、审批、项目和终端行为由 DSH 处理。

原生外壳不会写死模型、项目或会话名称。它会尝试读取 DSH 的 `/api/v1`（并兼容 `/api`、根路径）接口；接口返回多少模型、项目、会话和提供商，就显示多少。若当前 DSH 没启用 HTTP API 插件，Web UI 仍然可以正常使用，但原生外壳会显示“未返回数据”，不会捏造内容。官方 Web UI 本身仍负责完整模型与设置页面。DSH 的 Web 服务路由和模型配置由其主机侧提供，详见官方文档与 API 插件说明。[DeepSeek Harness Web Server](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/subsystems/web-server.md)、[DSH Web API](https://github.com/toddpan/dsh-webapi#readme)

## YAML

```yaml
name: DSH
host: 192.168.1.20
port: 3080
scheme: http
path: /
token: ""
autoConnect: true
discovery:
  service: _dsh._tcp
  fallbackServices:
    - _http._tcp
```

把 `host` 改成运行 DSH 的电脑或 Tailscale 地址。DSH 主机需要监听局域网地址，不能只监听 `127.0.0.1`。

## GitHub 无签名 IPA

推送 `v*` 标签或在 Actions 手动运行 `Build unsigned IPA`。工作流在 `macos-14` 上用 XcodeGen 生成工程、关闭代码签名、把 `.app` 打成 `DSHConnect-unsigned.ipa`，产物在 Actions 的 artifact 中。无签名 IPA 需要通过 AltStore、Sideloadly 或开发设备侧载。
