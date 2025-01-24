require './my_sqlite_request.rb'
require 'csv'

def main_func(p1)
    request = MySqliteRequest.new
    if p1.include?"VALUES"
        string_value = p1.split('VALUES')[1].strip
    end
    p1 = p1.split(" ")
    @data_name = ""
    i = 0
    while (i < p1.length)
        if p1[i] == "SELECT"
            if p1[i+1].include?","
                tmp = p1[i+1].split(",")
            else
                tmp = p1[i+1]
            end
            request = request.select(tmp)
        end
        if p1[i] == "FROM"
            request = request.from(p1[i+1])
        end
        if p1[i] == "WHERE"
            tmp = p1.join(" ").split("WHERE").last.split("=").map(&:strip)
            request = request.where(tmp[0], tmp[1].gsub(/^'|'$/, ''))
        end
        if p1[i] == "INSERT" && p1[i + 1] == "INTO"
            i += 2
            @data_name = p1[i]
            request = request.insert(p1[i])  
        end
        if p1[i] == "UPDATE"
            request = request.update(p1[i + 1])
        end
        if p1[i] == "DELETE"
            request = request.delete()
        end
        if p1[i] == "VALUES"
            i += 1
            contents = File.read(@data_name).split("\n")[0]
            contents << "\n"
            contents << string_value.gsub(/[()]/, '')
            hash_name = CSV.parse(contents, headers: true).map(&:to_h)
            request = request.values(hash_name[0])
        end
        if p1[i] == "SET"
            i += 1
            temp = ""
            ind = i 
            while p1[ind] != "WHERE"
                temp << p1[ind]
                temp << " "
                ind += 1
            end
            hash = {}
            temp.scan(/(\w+)\s*=\s*'([^']+)'/) do |key, value|
                hash[key] = value
            end
            request = request.values(hash)
        end
        i += 1
    end
    request.run
end

print "my_sqlite_cli>".chomp
while str = $stdin.gets.chomp
    str = str
    if str.include?("quit")
        return
    end
    main_func(str)
    print "my_sqlite_cli>".chomp
end