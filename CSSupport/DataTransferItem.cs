using System;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Data;
using System.Text.RegularExpressions;
using System.Collections;
using System.Data.Common;

namespace PSIS
{
    public class DataTransferItem : IDataTransferItem
    {

        public DataTransferItem(TransferSource transferSource,
                                    string sourceConnectionString,
                                    string destConnectionString,
                                    string sqlQuery,
                                    string destinationTable)
        {
            DestTimeout = SourceTimeout = 15 * 60;

            TransferSource = transferSource;
            SourceConnectionString = sourceConnectionString;
            DestConnectionString = destConnectionString;
            SqlQuery = sqlQuery;
            DestinationTable = destinationTable;
        }

        public DataTransferResult RunDataTransfer(Hashtable sqlParams)
        {
            var swatch = Stopwatch.StartNew();
            DataTransferResult status = new DataTransferResult(this);

            try
            {
                using (IDbConnection srcConn = CreateConnection())
                using (IDbCommand srcCmd = CreateSourceCommand(srcConn, SqlQuery, sqlParams))
                {
                   srcConn.Open();
                   status.RowCount = PSIS.SSRuntime.SubmitChangesInBulk(srcCmd.ExecuteReader(), DestConnectionString, DestinationTable, SqlBulkCopyOptions.Default, DestTimeout);
                }
            }
            catch (Exception ex)
            {
                status.Error = ex;
            }
            status.Elapsed = swatch.Elapsed;
            return status;
        }


        public IDbConnection CreateConnection()
        {
            var conn = DBFactory.CreateConnection();
            conn.ConnectionString = SourceConnectionString;
            return conn;
        }
        

        private DbProviderFactory DBFactory
        {
            get
            {
                switch (TransferSource)
                {
                    case TransferSource.Odbc:
                        return DbProviderFactories.GetFactory("System.Data.Odbc");
                    case TransferSource.OleDb:
                        return DbProviderFactories.GetFactory("System.Data.OleDb");
                    case TransferSource.OracleClient:
                        return DbProviderFactories.GetFactory("System.Data.OracleClient");
                    case TransferSource.SqlClient:
                        return DbProviderFactories.GetFactory("System.Data.SqlClient");
                    case TransferSource.SqlServerCe:
                        return DbProviderFactories.GetFactory("System.Data.SqlServerCe.3.5");
                    case TransferSource.IEnumerable:
                        return null;
                    default:
                        throw new Exception("");
                }
            }
        }
        
        private IDbCommand CreateSourceCommand(IDbConnection srcConn, string sourceSQL, Hashtable sqlParams)
        {
            IDbCommand cmd = srcConn.CreateCommand();
            cmd.CommandTimeout = SourceTimeout;

            var regex = new Regex(@"[ = > <(]@(\w+)", RegexOptions.Multiline);
            var matches = regex.Matches(sourceSQL);

            foreach (Match match in matches)
            {
                string pName = match.Groups[1].Value;
                IDbDataParameter param = cmd.CreateParameter();
                param.ParameterName = match.Groups[0].Value;

                if (!sqlParams.Contains(pName))
                {
                    throw new ArgumentException(string.Format("Parameter '{0}' not found in sql query {1}", pName, sourceSQL));
                }
                param.Value = sqlParams[pName];
                cmd.Parameters.Add(param);
            }
            cmd.CommandText = sourceSQL;
            return cmd;
        }

        public TransferSource TransferSource { get; set; }
        public string SourceConnectionString { get; set; }
        public string DestConnectionString { get; set; }
        public string SqlQuery { get; set; }
        public string DestinationTable { get; set; }
        public int SourceTimeout { get; set; }
        public int DestTimeout { get; set; }

    }
}
