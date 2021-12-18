class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def request_signature(body)
    # https://www.reddit.com/r/TOR/comments/ayy6rl/v3_onion_ed25519_secret_key_question/
  end

  def my_onion
    configatron.my_onion
  end
end
