class Time
  def rfc3339
    utc.strftime('%Y-%m-%dT%H:%M:%SZ')
  end
end
