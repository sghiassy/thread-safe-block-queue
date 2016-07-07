#
# Be sure to run `pod lib lint thread-safe-block-queue.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'thread-safe-block-queue'
  s.version          = '0.1.4'
  s.summary          = 'An opinionted thread-safe FIFO queue designed for blocks'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This class is an opinionted thread-safe FIFO queue designed for blocks. It takes in blocks and queues them until it is messaged to purge and run all blocks. After the purge event, this data-structure will no longer queue future blocks and will instead run any block given to immediatly.
                       DESC

  s.homepage         = 'https://github.com/sghiassy/thread-safe-block-queue'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Shaheen Ghiassy' => 'shaheen.ghiassy@gmail.com' }
  s.source           = { :git => 'https://github.com/sghiassy/thread-safe-block-queue.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/shaheenghiassy'

  s.ios.deployment_target = '8.0'

  s.source_files = 'thread-safe-block-queue/Classes/**/*'

  # s.resource_bundles = {
  #   'thread-safe-block-queue' => ['thread-safe-block-queue/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
