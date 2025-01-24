require 'csv'

class MySqliteRequest
    def initialize
      @require_type = ""
      @table_name = ""
      @tables_name = []
      @col_name = []
      @where_column = {}
      @value = {}
    end
  
    def self.from(table_name)
        @table_name = table_name
        return self.new
    end
    
    def from(table_name)
      @table_name = table_name
      return self
    end
    
    def where(p1, p2)
      @where_column[p1] = p2
      return self
    end

    def self.where(p1, p2)
        @where_column[p1] = p2
        return self.new
      end

    def select(*p1)
        @col_name = p1
        @require_type = "select"
        return self
    end

    def self.select(*p1)
        @col_name = p1
        @require_type = "select"
        return self.new
    end

    def update(p1)
        @table_name = p1
        @require_type = "update"
        return self
    end

    def self.update(p1)
        @table_name = p1
        @require_type = "update"
        return self.new
    end

    def insert(table_name)
        @table_name = table_name
        @require_type = "insert"
        return self
    end

    def join(*tables_names)
        @tables_names = tables_names
        return self
    end

    def self.join(*tables_names)
        @tables_names = tables_names
        return self.new
    end

    def delete()
        @require_type = "delete"
        return self
    end

    def self.delete()
        @require_type = "delete"
        return self.new
    end

    def self.insert(table_name)
        @table_name = table_name
        @require_type = "insert"
        return self.new
    end

    def values(p1)
        @value = p1 
        return self
    end

    def self.values(p1)
        @value = p1
        return self.new
    end
    
    def print_item(item)
        ret = []
        if @col_name[0] == "*"
            p item
            item
        else 
            temp = {}
            @col_name = @col_name.flatten
            @col_name.each do |i|
                temp[i] = item[i]
            end
            p temp
            temp
        end
    end

    def print_row(item)
        str = ""
        i = 0
        item.each do |key, val|
            if val.to_s.include?","
                if i < item.length - 1
                    str += "\"#{val}\","
                else
                    str += "\"#{val}\""
                end
            else
                if i < item.length - 1
                    str += "#{val},"
                else
                    str += "#{val}"
                end
            end 
            i += 1
        end
        File.write(@table_name, "\n#{str}", mode: 'a')
        # return item
    end

    def selection()
        hash_name = CSV.read(@table_name, headers: true).map(&:to_h)
        ret = []

        hash_name.each do |item|
            if @where_column.empty?
                ret << print_item(item)
            else 
                @where_column.each do |key, value|
                    if item[key] == value
                        ret << print_item(item)
                        break
                    end
                end
            end
        end
        return ret
    end

    def insertion()
        return print_row(@value)
    end

    def updating
        hash_name = CSV.read(@table_name, headers: true).map(&:to_h)
        str = ""
        ret = []
        ind = 0
        File.write(@table_name, "#{hash_name[0].keys.join(",")}", mode: 'w')
        if @where_column.empty?()
            hash_name.each do |item|
                item[@value.keys[0]] = @value[@value.keys[0]]
                print_row(item)
                ret << item
            end
        else
            hash_name.each do |item|
                @where_column.each do |key, value|
                    if item[key] == value  
                        @value.each do |k, v|
                            item[k] = v
                        end
                    end
                end
                print_row(item)
                ret << item
            end
        end
        ret
    end

    def deleting
        hash_name = CSV.read(@table_name, headers: true).map(&:to_h)
        ret = []
        File.write(@table_name, "#{hash_name[0].keys.join(",")}", mode: 'w')
        if @where_column.empty?()
            File.write(@table_name, "", mode: 'a')
        else
            hash_name.each do |item|
                flag = 0
                @where_column.each do |key, value|
                    if item[key] == value
                        flag = 1                
                    end
                end
                if flag == 0
                   ret << print_row(item)
                end
            end
        end
        ret
    end

    def run
        case @require_type
        when "select"
            selection()
        when "insert"
            insertion()
        when "update"
            updating()
        when "delete"
            deleting()
        end
    end
end