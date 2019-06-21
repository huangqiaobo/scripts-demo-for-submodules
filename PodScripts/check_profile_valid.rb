#!/usr/bin/ruby

require 'cocoapods'
require_relative './submodule.rb'

def get_names_for_submodules(submodules)
  if submodules.empty?
    return nil
  end
  names = submodules.map { |submodule|
    version = submodule.version
    submodule.name
  }
  return names
end

def check_profile_valid(podfile, ci_env)
  is_develop = ci_env == "develop"
  is_release = ci_env == "release"
  is_testflight = ci_env == "testflight"

  Pod::Podfile.from_file(podfile)
  local_submodules = CooHom::Submodules.values.select { |submodule| submodule.mode == CooHom::Mode::Dev }
  alpha_submodules = CooHom::Submodules.values.select { |submodule| submodule.mode == CooHom::Mode::Alpha }
  beta_submodules = CooHom::Submodules.values.select { |submodule| submodule.mode == CooHom::Mode::Beta }

  local_names = get_names_for_submodules(local_submodules)

  if is_develop
    puts "local_submodules: #{local_names}"
    return local_names == nil
  end

  alpha_names = get_names_for_submodules(alpha_submodules)

  if is_release
    puts "local_submodules: #{local_names}"
    puts "alpha_submodules: #{alpha_names}"

    return local_names == nil && alpha_names == nil
  end

  beta_names = get_names_for_submodules(beta_submodules)

  if is_testflight
    puts "local_submodules: #{local_names}"
    puts "alpha_submodules: #{alpha_names}"
    puts "beta_submodules: #{beta_names}"
    return local_names == nil && alpha_names == nil && beta_names == nil
  end
  abort("ci_env: #{ci_env} is error")
end

podfile = ARGV[0]
ci_env = ARGV[1]

if check_profile_valid(podfile, ci_env)
  puts "#{podfile} is valid for #{ci_env}"
else
  abort("#{podfile} is invalid for #{ci_env}, recheck the submodules")
end
