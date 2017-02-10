#!/opt/puppetlabs/puppet/bin/ruby
require 'benchmark'
require 'net/https'
require 'puppet'

Puppet.initialize_settings
messages = String.new

if ARGV[0].nil?
  puts "Must supply hostname of the PuppetDB Server"
  exit 1
end

conn = connection = Net::HTTP.new(ARGV[0], 8081)

conn.use_ssl = true
conn.ssl_version = :TLSv1
conn.read_timeout = 120
conn.verify_mode = OpenSSL::SSL::VERIFY_PEER

conn.ca_file = Puppet[:cacert]
conn.cert = OpenSSL::X509::Certificate.new(File.read(Puppet[:hostcert]))
conn.key = OpenSSL::PKey::RSA.new(File.read(Puppet[:hostprivkey]))

req = Net::HTTP::Get.new("/pdb/query/v4/fact-names", "Accept" => 'application/json')

messages << "[#{Time.now} -- #{Process.pid}] - Starting Heartbeat Check\n"

result = nil
bmtime = Benchmark.measure { result = conn.request(req) }

if result.code == "200"
messages << "[#{Time.now} -- #{Process.pid}] - Alive (#{bmtime.real}s)\n"
else
messages << "[#{Time.now} -- #{Process.pid}] - Dead  (#{bmtime.real}s)\n"
end

open('/var/log/puppetlabs/pdb-heartbeat.log', 'a') { |f|
    f << messages
}

