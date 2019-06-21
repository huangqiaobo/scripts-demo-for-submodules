#!/usr/bin/ruby

require 'cocoapods'

eval File.read("./scripts/add_tag.rb")

#ruby pod_version.rb tag develop git@gitlab.qunhequnhe.com:i18n/mobile/mobile-ios-base.git
#ruby pod_version.rb update MobileiOSBase.podspec

cmd = ARGV[0]

if cmd == "tag"
  branch = ARGV[1]
  $remote_url = ARGV[2]
  if branch == "develop"
    add_alpha_tag()
  end
  if branch == "release"
    add_beta_tag()
  end
  if branch == "master"
    add_release_tag()
  end
end

if cmd == "update"
  podspec = ARGV[1]
  describe = `git describe`.chomp
  exist_tags = `git tag --list`
  if exist_tags.include? describe
      puts "#{describe} 存在"
      podspec_content = File.read podspec
      result = eval podspec_content
      version = result.version.to_s
      new_podspec_content = podspec_content.gsub(version.to_s, describe.to_s)
      File.open(podspec, "w") {|file| file.puts new_podspec_content }
      push_specs = "pod repo push JOSpecs #{podspec} --allow-warnings"
      puts push_specs
      exec(push_specs)
  else
    puts "tag #{describe} is missing"
    exit 1
  end
end
