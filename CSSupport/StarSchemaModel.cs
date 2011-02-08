using System;
using System.Linq;
using System.Collections.Generic;

namespace PSIS
{
    /// <summary>
    /// <remarks>Limitations: Assumes all dim tables are in same schema
    /// </remarks>
    /// </summary>
    public class StarSchemaModel
    {

        private DataSchemaContext _dc;

        public string SrcViewTableName { get; private set; }
        public string SrcViewSchemaName { get; private set; }

        public string DestFactSchema { get; private set; }
        public string DestFactTableName { get; private set; }
        public string FactTableNameDB { get; private set; }
        public string FactTableNameEntity { get; private set; }
        public string SourceViewEntity { get; set; }

        public IEnumerable<ColumnInfo> FactMapping { get; private set; }
        public IEnumerable<DimMapItem> DimColMap { get; private set; }

        public StarSchemaModel(string connectionString, string sourceView, string factDestination)
        {
            _dc = new DataSchemaContext(connectionString);
            string[] sourceViewSplit = sourceView.Split('.');
            SrcViewTableName = sourceViewSplit[1];
            SrcViewSchemaName = sourceViewSplit[0];

            var factdestSplit = factDestination.Split('.');
            DestFactSchema = factdestSplit[0];
            DestFactTableName = factdestSplit[1];
            FactTableNameDB = factDestination;
            FactTableNameEntity = CapitalizeWord(DestFactSchema) + "_" + DestFactTableName;
            SourceViewEntity = CapitalizeWord(SrcViewSchemaName) + "_" + SrcViewTableName;

            // get all cols from DB
            var dbCols = _dc.Columns
                .Where(col=> col.TABLE_CATALOG == _dc.Connection.Database)
                .ToArray();

            FactMapping = from col in dbCols
                              where col.TABLE_NAME == SrcViewTableName
                                    && col.TABLE_SCHEMA == SrcViewSchemaName
                                    && col.COLUMN_NAME.StartsWith("FACT_")
                              select new ColumnInfo(col);
                              

            if (!FactMapping.Any())
            {
                //                throw new ArgumentException(sourceView);
            }


            var factDestCols = from col in dbCols
                               where col.TABLE_NAME == DestFactTableName
                                     && col.TABLE_SCHEMA == DestFactSchema
                               select col.COLUMN_NAME;
                                


            var MissingFactDestCols = from fsc in FactMapping
                                      join destc in factDestCols on fsc.DestinationName equals destc into match
                                      from destc in match.DefaultIfEmpty()
                                      where destc == null
                                      select new { Src = fsc, Dest = destc };

            if (MissingFactDestCols.Any())
            {
                throw new ArgumentException("Cols mising from fact");
            }

            var q = from col in dbCols
                    where col.TABLE_NAME == SrcViewTableName
                            && col.TABLE_SCHEMA == SrcViewSchemaName
                            && !col.COLUMN_NAME.StartsWith("FACT_")
                            && !col.COLUMN_NAME.StartsWith("IGNORE_")
                    group col by col.COLUMN_NAME.Split('_')[0] into c
                    select c;

            DimColMap = q.Select(cg =>
                {
                    var ak = cg.Select(col => col.COLUMN_NAME.Split('_')[1]);
                    var dimTableName = "Dim" + cg.Key;
                    var keyName = cg.Key + "Key";


                    var dimAkAssert = from col in dbCols
                                        where col.TABLE_NAME == dimTableName
                                        && col.TABLE_SCHEMA == DestFactSchema
                                      from c in ak
                                      where c == col.COLUMN_NAME
                                      select 1;
                    if (dimAkAssert.Count() != ak.Count())
                    {
                        throw new Exception("Col count in dims don't match");
                    }
                    var factKeyAssert = from col in dbCols
                                        where col.TABLE_NAME == DestFactTableName
                                        && col.TABLE_SCHEMA == DestFactSchema
                                        && col.COLUMN_NAME == keyName
                                        select 1;
                    if (!factKeyAssert.Any())
                    {
                        throw new ArgumentException(String.Format("Missing Dim Key '{0}' on fact table '{1}'", keyName, DestFactTableName));
                    }

                    var dimKeyAssert = from col in dbCols
                                       where col.TABLE_NAME == dimTableName
                                       && col.TABLE_SCHEMA == DestFactSchema
                                       && col.COLUMN_NAME == keyName
                                       select 1;
                    if (!dimKeyAssert.Any())
                    {
                        throw new ArgumentException(String.Format("Missing Dim Key '{0}' on Dim table '{1}'", keyName, dimTableName));
                    }
                    return new DimMapItem(cg.Key,dimTableName,DestFactSchema, keyName, ak);
                }).ToArray();

        }

        public static string CapitalizeWord(string word)
        {
            return System.Globalization.CultureInfo.CurrentCulture.TextInfo.ToTitleCase(word);
        }

    }
}
