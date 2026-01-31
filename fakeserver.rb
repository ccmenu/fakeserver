require 'sinatra'
require 'haml'

if ARGV[1] == '--ssl'
  require './sinatra_ssl'
  set :ssl_certificate, "server.crt"
  set :ssl_key, "server.key"
end

Project = Struct.new(:activity, :status, :build_num, :build_time)

configure do
  set :project, Project.new(:Sleeping, :Success, 1, DateTime.now.to_s)
end

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="API"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['dev', 'rosebud']
  end

  def is_building()
    settings.project.activity != :Sleeping
  end
end

get '/' do
  redirect "/control"
end

get '/control' do
  haml :control
end

post '/control/build' do
  settings.project.activity = :Building
  settings.project.build_num += 1
  settings.project.build_time = Time.now.iso8601
  redirect "/control"
end

post '/control/success' do
  settings.project.status = :Success
  settings.project.activity = :Sleeping
  redirect "/control"
end

post '/control/failure' do
  settings.project.status = :Failure
  settings.project.activity = :Sleeping
  redirect "/control"
end

get '/cctray.xml' do
  content_type :xml
  haml :cctray
end

get '/protected/cctray.xml' do
  protected!
  content_type :xml
  haml :cctray
end

get '/weird/cctray.xml' do
  halt 500, 'oops!'
end

get '/weird/cc.xml' do
  sleep 2
  redirect "/cctray.xml"
end

get '/slow/cctray.xml' do
  sleep 5
  content_type :xml
  haml :cctray
end

get '/empty/cctray.xml' do
  haml :empty
end

get '/dashboard/build/detail/connectfour' do
  haml :project
end


__END__

@@ control
!!! 5
%html{:style => "font-family: sans-serif"}
  %h1 Fake CI Server
  %hr
  %h2 Project: connectfour
  %table
    %tr
      %td Activitiy:
      %td= settings.project.activity
    %tr
      %td Status:
      %td= settings.project.status
    %tr
      %td Build number:
      %td= settings.project.build_num
    %tr
      %td Build time:
      %td= settings.project.build_time
  %p
  %form{:name => "input", :action => "control/build", :method => "post", :style => "display: inline"}
    %input{:type => "submit", :value => "Start build", :disabled => is_building() }
  %form{:name => "input", :action => "control/success", :method => "post", :style => "display: inline"}
    %input{:type => "submit", :value => "Success", :disabled => !is_building() }
  %form{:name => "input", :action => "control/failure", :method => "post", :style => "display: inline"}
    %input{:type => "submit", :value => "Failure", :disabled => !is_building() }

@@ cctray
!!! XML
%Projects
  %Project{:name => 'Other Project', :webUrl => 'http://localhost:4567/dashboard/build/detail/other-project',
    :activity => :Sleeping, :lastBuildStatus => :Success,
    :lastBuildLabel => "build.1234", :lastBuildTime => "2007-07-18T18:44:48"}
  %Project{:name => 'connectfour', :webUrl => 'http://localhost:4567/dashboard/build/detail/connectfour',
    :activity => settings.project.activity, :lastBuildStatus => settings.project.status,
    :lastBuildLabel => "build.#{settings.project.build_num}", :lastBuildTime => settings.project.build_time}
  %Project{:name => 'Some pipeline with a long name :: Project with a really long name', :webUrl => 'http://localhost:4567/dashboard/build/detail/dummy',
    :activity => :Sleeping, :lastBuildStatus => :Unknown,
    :lastBuildLabel => "build.99", :lastBuildTime => "2007-07-18T18:44:48"}

@@ empty
!!! XML

@@ project
!!! 5
%html
  %h1 Connect Four
  %p This is the project page on the build server.


