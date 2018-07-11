Pod::Spec.new do |s|
  s.name         = 'HYToast'
  s.summary      = 'A toast with three style.'
  s.version      = '2.2.1'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { 'huxiaoyang' => 'yohuyang@gmail.com' }
  s.homepage     = 'https://github.com/huxiaoyang/HYToast'
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.source       = { :git => 'https://github.com/huxiaoyang/HYToast.git', :tag => s.version.to_s }

  s.requires_arc = true
 
  s.subspec 'All' do |ss|
      ss.dependency 'HYToast/Notification'
      ss.dependency 'HYToast/Status'
    end

    s.subspec 'Notification' do |ss|
      ss.source_files = 'HYToast/HYNotificationToast/*.{h,m}'
    end

    s.subspec 'Status' do |ss|
      ss.source_files = 'HYToast/HYStatusToast/*.{h,m}'
    end

end
