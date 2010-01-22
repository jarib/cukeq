
module CukeQ
  
  #
  # TODO: must be a better way
  # 
  
  class JobClearer < Slave
    
    def subscribe
      # ignore all jobs, clearing the jobs queue
      @broker.subscribe(:jobs, 0.01) do |job| 
        EM.stop unless job # end of queue
        log(self.class, :ignoring, job) 
      end
    end
    
  end # JobClearer
end # CukeQ