module EventMachine

  #
  # http://github.com/eventmachine/eventmachine/issues#issue/15
  #

  def self.system3(cmd, *args, &cb)
    cb ||= args.pop if args.last.is_a? Proc
    init = args.pop if args.last.is_a? Proc

    # merge remaining arguments into the command
    cmd = ([cmd] + args.map{|a|a.to_s.dump}).join(' ')

    new_stderr = $stderr.dup

    rd, wr = IO::pipe

    result_count = 0

    err_result = nil
    std_result = nil
    stderr_connection = nil

    err_proc = proc {|output, status|
      stderr_connection = nil
      err_result = output
      result_count+=1
      if result_count == 2
        cb[std_result, err_result, status]
      end
    }

    std_proc = proc {|output, status|
      stderr_connection.close_connection if stderr_connection
      rd.close
      std_result = output
      result_count += 1
      if result_count == 2
        cb[std_result, err_result, status]
      end
    }

    $stderr.reopen(wr)
    signature = EM.popen(cmd, SystemCmd, std_proc) do |c|
      init[c] if init
    end.signature
    stderr_connection = EM.attach(rd, SystemCmd, err_proc)
    $stderr.reopen(new_stderr)
    wr.close

    return EventMachine.get_subprocess_pid(signature)
  end unless EventMachine.respond_to?(:system3)
end