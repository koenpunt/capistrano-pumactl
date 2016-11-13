namespace :pumactl do

  ACTIONS = %w(
    halt restart phased-restart start stats
    reload-worker-directory status stop
  )

  task :validate do
    on release_roles(fetch(:pumactl_roles)) do
      puma_config_file = fetch(:pumactl_config_file)
      unless test "[ -f #{puma_config_file} ]"
        warn "puma: #{puma_config_file} is not found"
      end
    end
  end

  ACTIONS.each do |action|
    desc "Execute pumactl #{action}"
    task :"#{action}" do
      on release_roles(fetch(:pumactl_roles)) do
        within release_path do
          execute :pumactl, '--config-file', fetch(:pumactl_config_file), action
        end
      end
    end
  end
end

Capistrano::DSL.stages.each do |stage|
  after stage, :'pumactl:validate'
end

namespace :load do
  task :defaults do
    set :pumactl_config_file, -> { current_path.join('config/puma.rb') }
    # set :pumactl_pidfile,     -> { current_path.join('tmp/pids/puma.pid') }
    # set :pumactl_state_path,  -> { current_path.join('tmp/pids/puma.state') }
    set :pumactl_roles, fetch(:pumactl_roles, :app)
  end
end
