# yet another phpenv

[CHH/phpenv](https://github.com/CHH/phpenv)はrbenvを一部置換するしくみ。一部なのでrbenvと干渉する。

こちらは全部置換してみた。

## 使い方

```shell
curl -fsSL https://raw.githubusercontent.com/pen/ya-phpenv/main/install-ya-phpenv.sh | sh
```

.zshrc、.bashrc に追記して再起動する(オリジナルと同じ)

```shell
export PATH=$HOME/.phpenv/bin:$PATH
eval "$(phpenv init -)" 
```

### おまけ

Macの人は

```
curl -fsSL https://raw.githubusercontent.com/pen/ya-phpenv/main/ya-phpenv-install-mac.sh | sh -s 8.0.7
```

などであまり失敗せずPHPをインストールできるだろう。

システムに足りないものがあるときは指摘してくるので、主にbrewで入れてリトライを。

## 参考

- [sstephenson/rbenv](http://github.com/sstephenson/rbenv)
- [CHH/phpenv](https://github.com/CHH/phpenv)
- [CHH/php-build](https://github.com/CHH/php-build)
- [ngyuki/phpenv-composer](https://github.com/ngyuki/phpenv-composer)
- [sergeyklay/phpenv-config-add](https://github.com/sergeyklay/phpenv-config-add)
