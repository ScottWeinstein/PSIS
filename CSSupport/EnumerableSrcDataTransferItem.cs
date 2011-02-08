using System;
using System.Collections;
using System.Linq;
using System.Collections.Generic;
using System.Diagnostics;
using System.Data.SqlClient;

namespace PSIS
{
    public class EnumerableSrcDataTransferItem : IDataTransferItem
    {
        private IEnumerable _source;
        private Type _type;
        public EnumerableSrcDataTransferItem(IEnumerable source, Type t, string desCS, string destinationTable)
        {
            _type = t;
            _source = source;
            DestinationTable = DestinationTable;
            DestConnectionString = desCS;
            DestTimeout = 15 * 60;
        }

        public string DestConnectionString { get; set; }
        public string DestinationTable { get; set; }
        public int DestTimeout { get; set; }

        public DataTransferResult RunDataTransfer(Hashtable sqlParams)
        {
            var swatch = Stopwatch.StartNew();
            DataTransferResult status = new DataTransferResult(this);

            try
            {
                PSIS.SSRuntime.SubmitChangesInBulk(_source,_type, DestConnectionString, DestinationTable, SqlBulkCopyOptions.Default, DestTimeout);
            }
            catch (Exception ex)
            {
                status.Error = ex;
            }
            status.Elapsed = swatch.Elapsed;
            return status;

        }
    }
}
