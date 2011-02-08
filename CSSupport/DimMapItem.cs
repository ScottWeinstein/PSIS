using System;
using System.Linq;
using System.Collections.Generic;

namespace PSIS
{
    public class DimMapItem
    {
        public DimMapItem(string name,string dimTableName, string schemaName, string keyName, IEnumerable<string> alternateKeys)
        {
            TableNameDB = schemaName + "." + dimTableName;
            TableNameEntity = schemaName + "_" + dimTableName;
            KeyName = keyName;
            Ak = alternateKeys;
            Name = name;
        }

        public string TableNameEntity { get; set; }
        public string Name { get; set; }
        public string TableNameDB { get; set; }
        public string KeyName { get; set; }
        public IEnumerable<string> Ak { get; set; }
    }
}
