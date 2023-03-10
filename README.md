# openwrt-wireguard-ddns

适用于 openwrt 的 wireguard ddns 更新脚本

非常遗憾 wireguard 在启动时会解析掉你配置的域名，ddns 对他无效，而且 wireguard-tool 的 ddns 脚本由于在 openwrt 上你找不到 wg 配置文件也无法使用，因此糊了找个脚本。

自己不太熟shell，主体代码由 ChatGPT 生成，人工做了修改让他能跑，也修了点找个模型没考虑到的问题

## 使用

请先确保你的 wg 接口格式为 `wg*` 其他格式的话可能需要对脚本进行部分修改

1. 在你的 openwrt 上找个地方放脚本，不要放在 `/tmp` 里

2. 给他执行权限 `chmod +x ddns.sh`

3. 上计划任务 `crontab -e`，按一下 `o` 新建一行并切换到 insert 模式，写入 `*/2 * * * * 脚本路径`，按 `esc`，输入`:wq`，按回车保存
