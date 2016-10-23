#
# Be sure to run `pod lib lint HActionButton.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HActionButton'
  s.version          = '2.1.0'
  s.summary          = 'Action button with customizable items, position and animation.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = "An customizable action button subclassing UIView where the mainButton, itemButton, and animation can all be customized. Besides flexibility of customization, default settings and built-in functions also provide great usability of the pod."

  s.homepage         = 'https://github.com/popodidi/HActionButton'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chang, Hao' => 'popodidi@livemail.tw' }
  s.source           = { :git => 'https://github.com/popodidi/HActionButton.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'HActionButton/Classes/**/*'
end
