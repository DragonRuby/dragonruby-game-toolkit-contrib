def try_assert_or_schedule args, assert
  if $result[:complete]
    log_info "Request completed! Verifying."
    if $result[:http_response_code] != 200
      log_info "The request yielded a result of #{$result[:http_response_code]} instead of 200."
      exit
    end
    log_info ":try_assert_or_schedule succeeded!"
  else
    args.gtk.schedule_callback Kernel.tick_count + 10 do
      try_assert_or_schedule args, assert
    end
  end
end

def test_http args, assert
  $result = $gtk.http_get 'http://dragonruby.org'
  try_assert_or_schedule args, assert
end

$gtk.reset 100
$gtk.log_level = :off
