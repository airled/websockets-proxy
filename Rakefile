task :start do
  system('bundle exec thin -R config/config_http.ru -C config/thin_http.yml start && bundle exec thin -R config/config_ws.ru -C config/thin_ws.yml start && echo "Servers started"')
end

task :stop do
  servers = Dir.glob('./tmp/pids/thin*')
  if servers.empty?
    puts 'Could not find pidfile(s). Check if the server is running'
  else
    servers.map do |server|
      pid = File.open("./#{server}") { |file| file.read }
      system("kill -9 #{pid} && echo 'Thin (pid #{pid}) stopped'")
    end
  end
end

task :restart do
  Rake::Task['stop'].invoke
  Rake::Task['start'].invoke
end

task :deploy do
  system 'mina stop && mina deploy && mina start'
end

task :plugin do
  system 'cd ./firefox-plugin && jpm run -b /usr/bin/firefox'
end

task :p => :plugin do
end
