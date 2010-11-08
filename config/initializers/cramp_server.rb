Cramp::Websocket.backend = :thin
logger = ActiveSupport::BufferedLogger.new(File.join(File.dirname(__FILE__),"..","..","log","cramp.log"))
logger.level = ActiveSupport::BufferedLogger::DEBUG
logger.auto_flushing = true
Cramp.logger = logger