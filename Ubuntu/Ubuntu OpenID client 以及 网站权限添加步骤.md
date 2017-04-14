OpenID client 以及 网站权限添加步骤

OpenID client (基于 Devise 用户管理系统)
1. 添加gem(考虑到该项目更新较慢 获取到本地放到 vendor/plugin 路径下)
	gem 'devise_openid_authenticatable',:path => "vendor/plugin/devise_openid_authenticatable"

2. 安装 Gem
	$ bundle install

3. 找到 models/user.rb 添加
	devise :openid_authenticatable

4. 添加数据库字段 

    create_table :users do |t|
	  t.string :identity_url
	end

	add_index :users, :identity_url, :unique => true


5. 找到 models/user.rb 添加 方法

  # 该方法用来定制你想要获取的必须返回参数
  def self.openid_required_fields
    ["email","roles","oauthtoken"]
  end
  
  #该方法用来制定选填参数
  def self.openid_optional_fields
    ["fullname","nickname","gender"]
  end

#该方法是在获取到需要的参数后 自己的处理操作。
	def openid_fields=(fields)
	    fields.each do |key, value|
	      # Some AX providers can return multiple values per key
	      if value.is_a? Array
	      	value = value.first
	      end
	      case key.to_s
	      when "fullname"
	        self.update_attributes({:username => value}) unless self.username.to_s  == value
	        # self.username = value
	      when "nickname"
	        # self.nickname
	      when "email"
	         self.update_attributes({:email => value}) unless self.email.to_s  == value
	        # self.email = value
	      when "gender"
	        self.gender = value
	      when "roles"
	        pv = JSON.parse(value)
	        pv.each do |role,permission|
	          new_role = self.add_role role
	          permission.each do |p|
	            RolesPermission.find_or_create_by(:role_id =>new_role.id.to_s, :action_name => p)
	          end
	        end
	      when "oauthtoken"
	        self.update_attributes({:authentication_token => value}) unless self.authentication_token.to_s  == value
	      else
	      logger.error "Unknown OpenID field: #{key}"
	    end
	end

6. 修改 views 页面

<% form_for resource_name, resource, :url => session_path(resource_name) do |f| -%>
  <p><%= f.label :identity_url %></p>
  <p><%= f.text_field :identity_url %></p>

  <% if devise_mapping.rememberable? -%>
    <p><%= f.check_box :remember_me %> <%= f.label :remember_me %></p>
  <% end -%>

  <p><%= f.submit "Sign in" %></p>
<% end -%>

以上 OpenIDClient 添加完成

添加ACL

1. 添加GEM

gem 'cancancan', '~> 1.13', '>= 1.13.1'
gem 'rolify', '~> 4.1', '>= 4.1.1'
gem 'grape-cancan', '~> 0.0.2'

2. 执行
  $ rails g cancan:ability
  $ rails g rolify Role User
  $ rails g model roles_permissions  role_id:integer action_name:string description:string
  $ rake db:migrate

3. 修改 models/ability.rb
	添加以下方法，动态查询用户权限
	user ||= User.new # guest user (not logged in)
      roles = user.roles
      roles.each do |role|
        if user.has_role?(role.name)
          role.roles_permissions.each do |rrp|
              can(rrp.action_name.to_sym,:all)
          end
        end
      end
4. 添加关联
	找到 models/role.rb
	添加数据库一对多关联 roles ----> roles_permissions

	has_many :roles_permissions,:class_name => "RolesPermission"


	找到 models/roles_permission.rb

	belongs_to :roles,:class_name => "Role"

5. 修改 API 
找到 grape/base.rb 文件，添加 login 方法

#添加获取 token 接口
      resource :login do
        post do
          req_params = JSON::parse(params.to_json)
          request = req_params["request"]
          login = request["login"]
          pwd = request["password"]

          nuser = User.where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
          unless nuser.blank?
              url = "http://localhost:3000/api/v1/cms/UsersManagementPage"
              data = {:username=>nuser.username,:pwd => pwd}
              body = http_put(url, data)
              body = JSON::parse(body)
              status = body["status"]
              if status == 200
                @body = body["token"]
                nuser.authentication_token = @body unless @body.blank?
                nuser.save
                {:status => 200, :user => {:single_access_token => nuser.authentication_token}}
              else
                {:status => 401}
              end
          else
            {:status=>404}
          end
        end
      end

找到 grape/base_helper.rb 文件，添加方法

	def warden
      env['warden'].params[:single_access_token] = env["HTTP_SINGLE_ACCESS_TOKEN"]
      env['warden']
    end
  
    def current_user
      # puts "====>#{env["HTTP_USER_ACCESS_TOKEN"].nil? ? nil : User.find_by(:authentication_token => env["HTTP_SINGLE_ACCESS_TOKEN"])}"
      @current_user ||= env["HTTP_SINGLE_ACCESS_TOKEN"].nil? ? nil : User.find_by(:authentication_token => env["HTTP_SINGLE_ACCESS_TOKEN"])
    end
    
    def http_put(url,params = {})
      uri = URI.parse(url)
      res = Net::HTTP::Put.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      res.body = params.to_json
      response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(res) }
      response.body
    end

找到 grape/api_v1.rb 文件, 添加方法
	 
	 #用户验证
	  before do
        error!("401 Unauthorized", 401) unless current_user
      end

      before do
        authorize_route! if current_user
      end

      rescue_from CanCan::AccessDenied do |exception|
        error!('Unauthorized', 401, 'X-Error-Detail' => 'Unauthorized')
      end

   接下来就可以在 每一个 接口上面定义需要的权限 比如：
   resource :get_info do
	   post authorize: [:update, User] do
	   end
   end



关于自动更新用户权限

1. 在 grape/api_cms.rb 文件内添加接口

	resource :roles_management do
       put do
         request = params.to_hash
         role_name = request["role_name"]
         role_perssion = request["role_perssion"]
         role_perssion_des = request["role_perssion_des"]
         @user = User.find_by(:email=>"douchunrong@gmail.com", :username => "douchunrong") unless role_name.blank?
         if @user
           role = @user.add_role( role_name )
           role.roles_permissions << RolesPermission.new(:action_name =>role_perssion, :description => role_perssion_des )
         end
         {:status => 200}
       end
     end

2. 项目 humble_openid_server 
添加该地址连接
详细参考 config/realtime_update_role.yml 文件
格式： 任意与上文不重复的名字: IP 或者域名地址


关于如何登录获取 signin_access_token 并通过权限获取信息

1. openid 注册
2. 登录 develop
3. 创建APP
4. 获取login token (此处用户名密码是 OpenID 的用户名密码)
	curl -l -v -H "Content-type: application/json" -X POST -d '{"request":{"login":"douchunrong","password":"111111"}}' http://localhost:3002/api/login
5. 获取信息
curl -l -v -H "Content-type: application/json" -H "single_access_token:Un_35HwwUdLQ5GACZSTH" -X POST -d '{"request":{"app_id":"M2ye7byYqIKyQ8ElxEBM8haM1449126007"}}' http://localhost:3002/api/v1/get_app_info
