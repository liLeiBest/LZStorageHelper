
Pod::Spec.new do |s|
  s.name             = 'LZStorageHelper'
  s.version          = '0.1.0'
  s.summary          = 'A short description of LZStorageHelper.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/liLeiBest'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lilei' => 'lilei_hapy@163.com' }
  s.source           = { :git => 'https://github.com/liLeiBest/LZStorageHelper.git', :tag => s.version.to_s }

  s.ios.deployment_target   = '8.0'
  s.default_subspec         = 'UserDefaults', 'File'
  s.source_files		    = 'LZStorageHelper/Classes/LZStorageHelper.h'
  s.public_header_files     = 'LZStorageHelper/Classes/LZStorageHelper.h'
  
  # 数据库 SQL
  s.subspec 'DatabaseSQL' do |databaseSQL|
	  databaseSQL.source_files			= 'LZStorageHelper/Classes/Database/SQL/*.{h,m}'
	  databaseSQL.public_header_files 	= 'LZStorageHelper/Classes/Database/SQL/*.h'
	  databaseSQL.dependency 'FMDB'
  end
  
  # 用户偏好
  s.subspec 'UserDefaults' do |userDefaults|
	  userDefaults.source_files		 	= 'LZStorageHelper/Classes/UserDefaults/*.{h,m}'
	  userDefaults.public_header_files 	= 'LZStorageHelper/Classes/UserDefaults/*.h'
  end
  
  #文件
  s.subspec 'File' do |file|
	  file.source_files			= 'LZStorageHelper/Classes/File/*.{h,m}'
	  file.public_header_files 	= 'LZStorageHelper/Classes/File/*.h'
  end
  
  #归档
  
  pch_AF = <<-EOS
  #if DEBUG
  #define LZStorageLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
  #else
  #define LZStorageLog(fmt, ...)
  #endif
  EOS
  s.prefix_header_contents = pch_AF
  
end
