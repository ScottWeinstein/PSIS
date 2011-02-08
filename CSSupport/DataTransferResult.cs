using System;

namespace PSIS
{
    public class DataTransferResult
    {
        internal IDataTransferItem WorkItem { get; set; }
        public DataTransferResult(IDataTransferItem sidt)
        {
            WorkItem = sidt;
            
        }
        public string DestTable
        {
            get
            {
                return WorkItem.DestinationTable;
            }
        }
        public long RowCount { get; set; }
        public TimeSpan Elapsed { get; set; }
        public Exception Error { get; set; }
    }
}
