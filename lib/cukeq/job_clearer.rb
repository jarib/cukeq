
module CukeQ

  #
  # TODO: must be a better way
  #

  class JobClearer < Slave

    def poll
      EM.next_tick {
        job = @broker.queue_for(:jobs).pop
        log(self.class, :ignoring, job)
        poll
      }
    end

  end # JobClearer
end # CukeQ