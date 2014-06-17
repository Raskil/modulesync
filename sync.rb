#!/usr/bin/env ruby

require 'erb'
require 'git'

# git pull all repos
# read config params
# render templates
# rsync rendered templates to repos
# git commit
# git push

MODULE_DIR = 'moduleroot/'
modules = [ 'puppetlabs-mysql' ]

class ForgeModuleFile
  def initialize(rvms=[])
    @rvms = rvms
  end
end

def build(from_erb_template)
  erb_obj = ERB.new(File.read(from_erb_template), nil, '-')
  erb_obj.filename = from_erb_template.chomp('.erb')
  erb_obj.def_method(ForgeModuleFile, 'render()')
  erb_obj
end

def render(template, options = {})
  ForgeModuleFile.new(options[:rvms]).render()
end

def sync(template, to_file)
  File.open(to_file, 'w') do |file|
    file.write(template)
  end
end

def update_repo(name, files, message)
  repo = Git.open('../' + name)
  repo.branch('master').checkout
  repo.pull
  repo.add(files)
  repo.commit(message)
  # TODO: repo.push
end

erb = build(MODULE_DIR + '.travis.yml')
template = render(erb, { :rvms => ['1.8.7', '1.9.3', '2.0.0', '2.1.0'] })
sync(template, '../' + modules[0] + '/' + '.travis.yml')
update_repo(modules[0], ['.travis.yml'], 'testing updating .travis.yml')
