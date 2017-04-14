rails 多数据库连接

环境: ruby 1.9.3 rails 3.2.8  mysql 5.X
项目名称 : test_database_connect
数据库图(仅以development模式为例):
  1) 项目自建数据库:
 	test_database_connect_development(库)
		|
		|---users(表)
		|__(表)
   2) 另外已知数据库
	project_database
		|
		|--- users_info
		|__ resources
项目自建数据库就不说了,看一下Rails怎么连接另一个数据库(project_database).
第一步.首先打开 config/database.yml 文件
最后添加 一下代码:

project_database:
  defaults: &defaults
    adapter: mysql2
    reconnect: false
    encoding: utf8
    pool: 5
    user: root
    password:
    socket: /tmp/mysql.sock
    
  development:
    <<: *defaults
    database: project_database
    
  test:
    <<: *defaults
    database: project_database
  
  production:
    <<: *defaults
    database: project_database
格式与原生的类似,每个字段代表什么意思也就不用我再啰嗦了.呵呵….
第二步,在 models文件下添加 project_database.rb 文件,然后在这个文件内添加代码
class ProjectDatabase < ActiveRecord::Base
#表示这个模型类不会与库中的任何表有关系，也就是一个抽象的类
  self.abstract_class = true
#就是配置连接
  establish_connection configurations["project_database"][::Rails.env]
end
到这里,数据库连接配置完成,我到这里是没有问题的.
第三步,最后 为每一个表建立具体模型类,这里只用resource为例
 建立步骤与上面一步是一样的,文件名称为resource,文件内容要修改为:
class Resources < ProjectDatabase
 #在进行数据查询时,程序会自动把表名变为复数,如果数据库内的表并不是复数形式 可以在这里设置表名
  # 这样的话 在你使用的时候就不会去查询复数,而是你在这里定义的名字
  #set_table_name "resources"
end

注意,重点在于这个类所继承的是我们上一步刚刚建立的模型类(ProjectDatabase).

完成了,你可以正常使用了,

例如:
def get_resources_by_id
	@resource = Resources.find_by_id(1)
end
