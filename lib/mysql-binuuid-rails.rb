require 'mysql-binuuid/type'

ActiveRecord::Type.register(:uuid, MySQLBinUUID::Type)

module MySQLBinUUID
end
