using System;
using System.Collections;
using System.Linq;
using System.Collections.Generic;

namespace PSIS
{
    public class ColumnInfo
    {
        //CHARACTER_MAXIMUM_LENGTH
        //DataType
        //ISNullable
        //
        public ColumnInfo(Column col)
        {
            var colNamesplit = col.COLUMN_NAME.Split('_');
            SourceName = col.COLUMN_NAME;
            DestinationName = colNamesplit[1];
        }
        public string SourceName { get; set; }
        public string DestinationName { get; set; }


        private static string ConvertSQLToClrDataType(string dataType, int maxLen, bool IsNullable)
        {
            switch (dataType)
            {
                case "int":
                    return typeof(int).FullName;
                case "datetime":
                    return typeof(DateTime).FullName;
                case "decimal":
                case "numeric":
                case "money":
                case "smallmoney":
                    return typeof(decimal).FullName;
                case "float":
                    return typeof(double).FullName;
                case "smallint":
                    return typeof(Int16).FullName;
                case "nvarchar":
                case "varchar":
                    if (maxLen > 1)
                        return typeof(string).FullName;
                    else
                        return typeof(char).FullName;
                case "bit":
                    return typeof(bool).FullName;
                default:
                    throw new Exception(String.Format("Undefined SQL dataType {0}", dataType));
            }
        }
 

    }
}
