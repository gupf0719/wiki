#ruby gem 使用错误解决办法集合
### mysql
== 错误 1
```
dlopen(/Users/kintaichi/.rvm/gems/ruby-2.2.3/extensions/x86_64-darwin-14/2.2.0-static/mysql2-0.4.4/mysql2/mysql2.bundle, 9): Library not loaded: libmysqlclient.18.dylib (LoadError) 
```

解决办法:

```
sudo ln -s /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/local/lib/libmysqlclient.18.dylib
```


== 错误 2
```
connection_specification.rb:190:in `rescue in spec': Specified 'mysql2' for database adapter, but the gem is not loaded. Add `gem 'mysql2'` to your Gemfile (and ensure its version is at the minimum required by ActiveRecord). (Gem::LoadError)
```

解决办法:

```
mysql2 gem 版本不匹配， 一般使用 0.3.20 或者 0.3.21
```