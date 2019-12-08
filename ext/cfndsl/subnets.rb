require 'ipaddr'

def calculate_subnet(multiplyer,vpc_cidr,subnet_mask)
  net = IPAddr.new(vpc_cidr)
  shift = 32 - subnet_mask
  return "#{[((net.to_i >> shift) + multiplyer) << shift].pack('N').unpack('CCCC').join('.')}/#{subnet_mask}"
end