def pad(str, pad_chr, pad_len)
	if str.length < pad_len
		(pad_chr * (pad_len - str.length)) + str
	else
		str
	end
end

def list_bin(file, with_addr = false)
	bf = File.open(file, 'rb')

	while !bf.eof?
		if with_addr
			addr = bf.pos
			print "#{pad(addr.to_s, '0', 3)} (0x#{addr.to_s(16)}): "
		end
		byte = bf.read(1).ord
		print pad(byte.to_s(2), "0", 8) 
		puts " (#{pad(byte.to_s(16), "0", 2)})"
	end

	bf.close
end

list_bin('car_parking.cim', true)