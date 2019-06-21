#!/usr/bin/ruby

require 'cocoapods'

module CooHom
    SubmodulePath = "../../"
    Submodules = Hash.new
    module Mode
        Dev = "Dev"
        Alpha = "Alpha"
        Beta = "Beta"
        Release = "Release"
    end

    class Submodule
        attr_accessor :name, :mode, :version, :params
        def initialize(name, version, mode, params=nil)
            @name = name
            @mode = mode
            @version = version
            @params = params
        end

        def path()
            if mode == Mode::Dev
                return "#{SubmodulePath}#{name}"
            end
            return nil
        end

        def info()
            path = path()
            return "#{name}, #{version}, :path => #{path}"
        end

        def submodule_version()
            if version == nil
                puts "version is missing"
                return nil
            end
            if mode == Mode::Dev
                return nil
            end
            if mode == Mode::Alpha
                return "#{version}-alpha"
            end
            if mode == Mode::Beta
                return "#{version}-beta"
            end
            if mode == Mode::Release
                return version
            end
        end
    end
end

def submodule(name, version, mode, params)
    submodule = CooHom::Submodule.new(name, version, mode, params)
    path = submodule.path()
    submodule_version = submodule.submodule_version()
    if path != nil
        params[:path] = path
        pod name, params
    else
        pod name, submodule_version, params
    end
    CooHom::Submodules[:name] = submodule
end
