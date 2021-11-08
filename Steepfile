D = Steep::Diagnostic

target :lib do
  check "lib"
  signature "sig"

  repo_path "vendor/rbs/gem_rbs_collection/gems"
  library "erb", "net-http", "nokogiri", "set", "time", "uri"

  configure_code_diagnostics(D::Ruby.all_error)
end
