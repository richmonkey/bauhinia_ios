platform :ios, '8.0'
target 'Message' do
    pod 'gobelieve', :git => 'git@github.com:GoBelieveIO/im_ios.git'
    pod 'JSBadgeView'
    pod 'leveldb-library', '~> 1.18.2'
    pod 'ZBarSDK'
    pod 'React', :path => '../node_modules/react-native', :subspecs => [
      'Core',
      'RCTText',
      'RCTWebSocket', # needed for debugging
      'RCTActionSheet',
      'RCTImage',
      'RCTNetwork',
      'RCTVibration',
      'RCTGeolocation',
    ]
end