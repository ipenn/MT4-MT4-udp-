# MT4-MT4-udp-

startMT4.bat                重启MT4
Martin.A.mq4                喊单账户-EA
Martin.B.mq4                跟单MT4-EA
MT4ManageDll.dll            当出现跳空时候 杀死所有MT4进程，再由 startMT4.bat 重启
WecapitalMT4Socket.dll      两个MT4间通讯-UDP，注意两个mq4中的端口要相反

此策略是由喊单账户（可以用模拟账户）下单，思想马丁格尔，跟单MT4跟单，
当喊单MT4逆势加仓到N个单时，这时跟单账户才开始跟单，这个时候跟单账户下一个跟喊单MT4持仓单总仓位的单。
后面喊单账户自由加仓和跟单账户脱离关系，如果跟单账户提前出场则不再进场直到喊单账户平仓。
