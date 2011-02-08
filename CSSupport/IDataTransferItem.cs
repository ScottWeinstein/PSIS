using System;
using System.Collections;

namespace PSIS
{
    public interface IDataTransferItem
    {
        string DestConnectionString { get; set; }
        string DestinationTable { get; set; }
        int DestTimeout { get; set; }
        DataTransferResult RunDataTransfer(Hashtable sqlParams);
    }
}
