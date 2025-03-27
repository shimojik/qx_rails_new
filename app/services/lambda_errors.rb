module LambdaErrors
  class BaseError < StandardError; end
  class InvocationError < BaseError; end
  class TimeoutError < BaseError; end
  class ValidationError < BaseError; end
end
