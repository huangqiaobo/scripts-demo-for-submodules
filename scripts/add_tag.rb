#!/usr/bin/ruby

class Tag
    attr_accessor :tag_front, :tag_end, :params
    def initialize(tag_front, tag_end)
        @tag_front = tag_front
        @tag_end = tag_end
    end

    def info()
        return "#{tag_front}#{tag_end}"
    end

    def isAlpha()
        return tag_front.include? "alpha"
    end

    def isBeta()
        return tag_front.include? "beta"
    end

    def isRelease()
        return !(isAlpha() || isBeta())
    end

    def hasEnd() 
        return !(tag_end == nil || tag_end == "")
    end

    def increment_major()
        arr = tag_front.split("-")
        version_arr = arr.first.split(".")
        version_arr[0] = version_arr[0].to_i + 1
        tag_front_new = version_arr * "."
        if arr.length == 2
            tag_front_new = tag_front_new + "-#{arr.last}"            
        elsif arr.length > 2
            puts "error tag #{self.info()}"
            exit 1
        end
        return Tag.new(tag_front_new, tag_end)
    end

    def increment_minor()
        arr = tag_front.split("-")
        version_arr = arr.first.split(".")
        version_arr[1] = version_arr[1].to_i + 1
        tag_front_new = version_arr * "."
        if arr.length == 2
            tag_front_new = tag_front_new + "-#{arr.last}"            
        elsif arr.length > 2
            puts "error tag #{self.info()}"
            exit 1
        end
        return Tag.new(tag_front_new, tag_end)
    end

    def increment_patch()
        arr = tag_front.split("-")
        version_arr = arr.first.split(".")
        version_arr[2] = version_arr[2].to_i + 1
        tag_front_new = version_arr * "."
        if arr.length == 2
            tag_front_new = tag_front_new + "-#{arr.last}"            
        elsif arr.length > 2
            puts "error tag #{self.info()}"
            exit 1
        end
        return Tag.new(tag_front_new, tag_end)
    end

    def rest_patch()
        arr = tag_front.split("-")
        version_arr = arr.first.split(".")
        version_arr[2] = 0
        tag_front_new = version_arr * "."
        if arr.length == 2
            tag_front_new = tag_front_new + "-#{arr.last}"            
        elsif arr.length > 2
            puts "error tag #{self.info()}"
            exit 1
        end
        return Tag.new(tag_front_new, tag_end)
    end

    def gen_alpha()
        if self.isAlpha()
            puts "#{self.info()}， 当前为alpha版本"
            return self
        end
        if self.isBeta()
            tag_front_new = tag_front.gsub("beta", "alpha")
            tag = Tag.new(tag_front_new, "")
            tag = tag.increment_minor()
            tag = tag.rest_patch()
            return tag
        end

        if self.isRelease()
            tag = self.increment_minor()
            tag = tag.rest_patch()
            tag_front_new = tag.tag_front + "-alpha"
            return Tag.new(tag_front_new, "")
        end

        puts "error tag: #{self.info()}, 无法转换为alpha版本"
        return nil
    end

    def gen_beta()
        if self.isAlpha()
            tag_front_new = tag_front.gsub("alpha", "beta")
            return Tag.new(tag_front_new, "")
        end
        if self.isBeta()
            puts "#{self.info()}， 当前为beta版本"
            return self
        end
        if self.isRelease()
            tag = self.increment_patch()
            tag_front_new = tag.tag_front + "-beta"
            return Tag.new(tag_front_new, "")
        end
        puts "error tag: #{self.info()}"
        return nil
    end

    def gen_release()
        if self.isRelease()
            tag = self.increment_patch()
            return Tag.new(tag.tag_front, "")
        end
        if self.isAlpha()
            tag_front_new = tag_front.gsub("-alpha", "")
            return Tag.new(tag_front_new, "")
        end
        if self.isBeta()
            tag_front_new = tag_front.gsub("-beta", "")
            return Tag.new(tag_front_new, "")
        end
        puts "error tag: #{self.info()}"
        return nil
    end
end

def add_describe_tag(tag)
    exist_tags = `git tag --list`
    arr = exist_tags.split("\n")
    if arr.include? tag
        p "#{tag} existed"
        return
    end
    message = 'add describe tag: ' + tag
    p message
    p `git tag -a #{tag} -m "#{message}"`
    git_push = "git push #{$remote_url}"
    git_push_with_tag = "#{git_push} --tags"
    p git_push_with_tag
    p `#{git_push_with_tag}`
end

def add_tag(tag)
    exist_tags = `git tag --list`
    arr = exist_tags.split("\n")
    if arr.include? tag
        p "#{tag} existed"
        return
    end
    p 'add tag: ' + tag
    p `git tag #{tag}`
    git_push = "git push #{$remote_url}"
    git_push_with_tag = "#{git_push} --tags"
    p git_push_with_tag
    p `#{git_push_with_tag}`
end

def add_alpha_tag()
    describe = `git describe`.chomp
    pre_tag = `git describe --abbrev=0`.chomp
    last_str = describe.gsub(pre_tag, "")
    tag = Tag.new(pre_tag, last_str)
    preisAlpha = tag.isAlpha()
    tag = tag.gen_alpha()
    if tag != nil
        if preisAlpha
            add_tag(tag.info())
        else
            add_describe_tag(tag.info())
        end
    end
end

def add_beta_tag()
    describe = `git describe`.chomp
    pre_tag = `git describe --abbrev=0`.chomp
    last_str = describe.gsub(pre_tag, "")
    tag = Tag.new(pre_tag, last_str)
    preisBeta = tag.isBeta()
    tag = tag.gen_beta()
    if tag != nil
        if preisBeta
            add_tag(tag.info())
        else
            add_describe_tag(tag.info())
        end
    end
end

def add_release_tag()
    describe = `git describe`.chomp
    pre_tag = `git describe --abbrev=0`.chomp
    last_str = describe.gsub(pre_tag, "")
    tag = Tag.new(pre_tag, last_str)
    tag = tag.gen_release()
    add_describe_tag(tag.info())
end