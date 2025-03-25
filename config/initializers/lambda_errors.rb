module LambdaErrors
  class InvocationError < StandardError; end
  class TimeoutError < StandardError; end
  class ValidationError < StandardError; end
end
