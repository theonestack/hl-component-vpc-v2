def ip_lookup(name,ip_blocks)
  if name == 'stack'
    return [ FnGetAtt(:VPC, :CidrBlock) ]
  elsif ip_blocks.has_key?(name)
    return ip_blocks[name].map do |ip|
      name == 'stack' ? FnGetAtt(:VPC, :CidrBlock) : ip
    end
  else
    return []
  end
end

def is_cidr?(cidr)
  cidr =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$/
end
  