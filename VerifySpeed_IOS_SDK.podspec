Pod::Spec.new do |spec|
  spec.name         = 'VerifySpeed_IOS_SDK'
  spec.version      = '1.0.16'
  spec.summary      = 'A brief description of VerifySpeed_IOS_SDK.'
  spec.description  = 'A more detailed description of VerifySpeed_IOS_SDK.'
  spec.homepage     = 'https://github.com/verifyspeed/VerifySpeed_IOS_SDK.git'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'VerifySpeed' => 'verifyspeeed@gmail.com' }
  spec.source       = { :git => 'https://github.com/verifyspeed/VerifySpeed_IOS_SDK.git', :tag => spec.version.to_s }

  spec.ios.deployment_target      = '12.0'

  # Specify the source files
  # spec.source_files = 'VerifySpeed_IOS_SDK.xcframework/**/*.{h,m,swift}'
  # spec.exclude_files = 'VerifySpeed_IOS_SDK.xcframework/ios-arm64/**/*.{swiftdoc,swiftinterface,abi.json}'
  # Add libphonenumber dependency
  # spec.dependency 'libPhoneNumber-iOS', '~> 1.2'

  # Specify the vendored framework
  spec.vendored_frameworks = 'VerifySpeed_IOS.xcframework'
end