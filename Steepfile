D = Steep::Diagnostic

target :lib do
  check "lib"
  signature "sig"

  repo_path ".gem_rbs_collection"
  library "erb", "net-http", "nokogiri", "set", "time", "uri"

  configure_code_diagnostics(D::Ruby.all_error)
end
