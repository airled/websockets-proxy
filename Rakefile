task :start do
  system('bundle exec thin -R config/config_http.ru -C config/thin_http.yml start')
  system('bundle exec thin -R config/config_ws.ru -C config/thin_ws.yml start')
  puts "Started"
end

task :stop do
  servers = Dir.glob('./tmp/pids/thin*')
  if servers.empty?
    puts 'Could not find pidfile(s). Check if the server is running'
  else
    servers.map do |server|
      pid = File.open("./#{server}") { |file| file.read }
      system("kill #{pid}")
      puts "Thin (pid #{pid}) stopped"
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
