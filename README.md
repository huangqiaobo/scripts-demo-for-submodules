## 脚本仅供参考，请自行随意修改使用
### 修改所有脚本中涉及到的JOSpecs，修改为自己的私有podspec库
### 主项目
PodScripts文件夹整个放在Podfile同一目录下。

修改 submodule.rb 文件的 SubmodulePath，使指向子模块 repo 存放的目录。

在Podfile文件中添加
```ruby
require_relative './PodScripts/submodule.rb'
```
之后就可以在Podfile中使用submodule方法
```ruby
submodule 'MobileiOSBase', '~> 0.6.0', CooHom::Mode::Release
```
 CooHom::Mode的值：Dev, Alpha, Beta, Release
 
 在主项目gitlab-ci.yml中的使用
 
 ```shell
 ruby ./PodScripts/check_profile_valid.rb Podfile develop
 ```
 
 ### 子模块
 pod_version.rb文件和scripts文件夹放入子模块的podspec的同级目录下
 
 在子模块gitlab-ci.yml中的使用
 
 ```shell
 #打alpha的tag
 ruby pod_version.rb tag develop git@gitlab.qunhequnhe.com:i18n/mobile/mobile-ios-base.git
 #tag触发上传podspec
 ruby pod_version.rb update MobileiOSBase.podspec
 ```
 
 #### 脚本代码写的比较随意，逻辑也比较简单，仅供参考，发现bug请自行修改。
