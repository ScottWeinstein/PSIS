namespace PSIS
{

    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
using System.Data;
    using System.Collections;


    public static class SSRuntime
    {
        public static long SubmitChangesInBulk<T>(IEnumerable<T> items, string connectionString, string destTable, SqlBulkCopyOptions opts,int timeout)
        {
            using (var rdr = new LinqObjDataReader<T>(items))
            {
                using (var sbc = new SqlBulkCopy(connectionString, SqlBulkCopyOptions.TableLock | SqlBulkCopyOptions.KeepNulls | opts))
                {
                    long count = 0;
                    sbc.NotifyAfter = 1;
                    sbc.BulkCopyTimeout = timeout;
                    sbc.SqlRowsCopied += (sender, e) => count++;

                    sbc.DestinationTableName = destTable;
                    sbc.WriteToServer(rdr);
                    return count;
                }
            }
        }

        public static long SubmitChangesInBulk(IEnumerable items,Type t, string connectionString, string destTable, SqlBulkCopyOptions opts, int timeout)
        {
            using (var rdr = new LinqObjDataReader(items,t))
            {
                using (var sbc = new SqlBulkCopy(connectionString, SqlBulkCopyOptions.TableLock | SqlBulkCopyOptions.KeepNulls | opts))
                {
                    long count = 0;
                    sbc.NotifyAfter = 1;
                    sbc.BulkCopyTimeout = timeout;
                    sbc.SqlRowsCopied += (sender, e) => count++;

                    sbc.DestinationTableName = destTable;
                    sbc.WriteToServer(rdr);
                    return count;
                }
            }
        }


        public static long SubmitChangesInBulk(IDataReader rdr, string connectionString, string destTable, SqlBulkCopyOptions opts, int timeout)
        {
                using (var sbc = new SqlBulkCopy(connectionString, SqlBulkCopyOptions.TableLock | SqlBulkCopyOptions.KeepNulls |  SqlBulkCopyOptions.KeepIdentity | opts))
                {
                    long count = 0;

                    sbc.BulkCopyTimeout = timeout;
                    sbc.NotifyAfter = 1;
                    sbc.SqlRowsCopied += (sender, e) => count++;

                    MapSourceColsToDestCols(sbc, rdr);
                    sbc.DestinationTableName = destTable;
                    sbc.WriteToServer(rdr);
                    return count;
                }
        }
        private static void MapSourceColsToDestCols(SqlBulkCopy sbc, IDataReader rdr)
        {
            using (DataTable schema = rdr.GetSchemaTable())
            {
                foreach (DataRow row in schema.Rows)
                {
                    string columnName = (string)row["ColumnName"];
                    sbc.ColumnMappings.Add(new SqlBulkCopyColumnMapping(columnName, columnName));
                }
            }
        }



        //public static T Using<T,R>(Func<R> resFactory,Func<R,T> func ) where R:IDisposable
        //{
        //    using (var r = resFactory()) 
        //    {
        //        return func(r);
        //    }
        //}

        public static Func<T> Using<T, R>(Func<R> resFactory, Func<R, T> func) where R : IDisposable
        {
            return () =>
                {
                    R r = default(R);
                    try
                    {
                        r = resFactory();
                        return func(r);
                    }
                    finally
                    {
                        if (r != null)
                            r.Dispose();
                    }
                };
        }



        public static TResult TryCatchThrow<TResult, TException>(Func<TResult> tryFunc, Action<TException> doCatchBlock) where TException : Exception
        {
            try
            {
                return tryFunc();
            }
            catch (Exception ex)
            {
                if (ex is TException)
                {
                    doCatchBlock((TException)ex);
                }
                throw;
            }
        }
    }
}
