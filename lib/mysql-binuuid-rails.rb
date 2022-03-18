require 'mysql-binuuid/type'
require 'mysql-binuuid/uuid'

ActiveRecord::Type.register(:uuid, MySQLBinUUID::Type)

module MySQLBinUUID
end
