
# Be sure to run `pod lib lint DFVideoPlayer.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DFVideoPlayer"
  s.version          = "0.1.1"
  s.summary          = "powerful video player wrapped around Vitaimo like weico"
  s.description      = <<-DESC
												Powerful video player wrapped around Vitamio
												* Support MMS / RTSP / RTP / SDP / HTTP ...
												* Support MPEG-4 / H.264 / H.265 / RMVB ...
                       DESC
  s.homepage         = "https://github.com/zhudongfang/DFVideoPlayer"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'https://www.vitamio.org/License'
  s.author           = { "zhudongfang" => "dongfang.zhu@inbox.com" }
  s.source           = { :git => "https://github.com/zhudongfang/DFVideoPlayer.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*' 
	s.resource_bundles = {
    'DFVideoPlayer' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/classes/**/*.h'

	# 以下依赖库放到这里活着subspec都ok
  s.frameworks = 'UIKit','AVFoundation','AudioToolbox','CoreGraphics','CoreMedia','Foundation','MediaPlayer','OpenGlES','QuartzCore'
	s.libraries = 'bz2','z','stdc++','iconv'
	
	s.subspec 'Vitamio' do |vitamio|
		vitamio.preserve_paths = 'Pod/Vendor/Vitamio/include/Vitamio/*.h'
		vitamio.source_files = 'Pod/Vendor/Vitamio/include/Vitamio/*'
		vitamio.vendored_libraries = 'Pod/Vendor/Vitamio/libffmpeg.a','Pod/Vendor/Vitamio/libopenssl.a','Pod/Vendor/Vitamio/libVitamio.a'
		vitamio.xcconfig = {'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/{s.name}/Pod/Vendor/Vitamio/include/**' }
		# 如何导入静态库，请看http://stackoverflow.com/questions/19481125/add-static-library-to-podspec/19609714#19609714
	end

end
