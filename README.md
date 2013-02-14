* git clone git://github.com/mix3/chrome-pixiv-search-redirect.git
* EDITOR=vim ppit set www.pixiv.net
<pre>
---
"pass": 'your pass'
"pixiv_id": 'your pixiv_id'
</pre>
* plackup app.psgi -p 5050
* chrome: 環境設定 > 拡張機能 > パッケージ化されていない拡張機能を読み込む > cloneしたディレクトリを選択
* タブを開く
