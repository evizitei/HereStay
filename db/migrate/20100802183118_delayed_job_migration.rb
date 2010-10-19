class DelayedJobMigration < ActiveRecord::Migration
  def self.up
      create_table :delayed_jobs, :force => true do |t|
        t.integer  :priority, :default => 0      # jobs can jump to the front of
        t.integer  :attempts, :default => 0      # retries, but still fail eventually
        t.text     :handler                      # YAML object dump
        t.text     :last_error                   # last failure
        t.datetime :run_at                       # schedule for later
        t.datetime :locked_at                    # set when client working this job
        t.datetime :failed_at                    # set when all retries have failed
        t.text     :locked_by                    # who is working on this object
        t.timestamps
      end
    end
    
    def self.down
      drop_table :delayed_jobs
    end
end
