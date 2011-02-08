using System;
using System.Collections;
using System.Linq;
using System.Collections.Generic;
using System.Diagnostics;

namespace PSIS
{
    public class DataTransfer
    {
        private List<IDataTransferItem> _items = new List<IDataTransferItem>();

       public void Add(TransferSource transferSource,
                                    string sourceConnectionString,
                                    string destConnectionString,
                                    string sqlQuery,
                                    string destinationTable)
        {
            _items.Add(new DataTransferItem(transferSource, sourceConnectionString, destConnectionString, sqlQuery, destinationTable));
        }

       public void Add(IEnumerable source, Type t,string destConnectionString,string destinationTable)
       {
           _items.Add(new EnumerableSrcDataTransferItem(source,t, destConnectionString, destinationTable));
       }

        public  IEnumerable<DataTransferResult>Run(Hashtable sqlparms)
        {
            return _items
                .AsParallel()
                .Select(dti => dti.RunDataTransfer(sqlparms))
                .ToArray();
        }


    }
}