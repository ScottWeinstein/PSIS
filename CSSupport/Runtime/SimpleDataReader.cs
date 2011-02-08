namespace PSIS
{

    using System;
    using System.Data;


    //via Marc Gravell
    public abstract class SimpleDataReader : IDataReader
    {
        string[] columnNames;
        Type[] columnTypes;
        object[] values;

        protected SimpleDataReader()
        {
        }
        protected SimpleDataReader(string[] names, Type[] types)
        {
            Init(names, types);
        }
        protected void Init(string[] names, Type[] types)
        {
	        if (names == null) throw new ArgumentNullException("names");
            if (types == null) throw new ArgumentNullException("types");
            if (names.Length != types.Length) throw new ArgumentException("Names / types lengths must match");
            columnNames = (string[])names.Clone();
            columnTypes = (Type[])types.Clone();
            values = new object[names.Length];
        }
        
        protected void SetValues(params object[] values)
        {
            if (values == null) throw new ArgumentNullException("values");
            if (values.Length != this.values.Length) throw new ArgumentException("Values length is invalid");
            values.CopyTo(this.values, 0);
        }

        void IDisposable.Dispose() { Close(); }

        abstract protected void DoClose();

        public void Close()
        {
            try
            {
                DoClose();
            }
            finally
            {
                IsClosed = true;
            }
        }
        public bool IsClosed { get; private set; }
        public int RecordsAffected { get { return -1; } }



        public int Depth
        {
            get { return 0; }
        }


        public DataTable GetSchemaTable()
        {
            return null;
        }


        public bool NextResult()
        {
            Close();
            return false;
        }
        public bool Read()
        {
            return DoRead();
        }
        protected abstract bool DoRead();



        public int FieldCount
        {
            get { return columnNames.Length; }
        }


        public bool GetBoolean(int i)
        {
            return Convert.ToBoolean(GetValue(i));
        }


        public byte GetByte(int i)
        {
            return Convert.ToByte(GetValue(i));
        }


        public long GetBytes(int i, long fieldOffset, byte[] buffer, int bufferoffset, int length)
        {
            byte[] data = (byte[])GetValue(i);
            int max = data.Length + 1 - (int)fieldOffset;
            if (length > max) length = max;
            if (length > 0)
            {
                Buffer.BlockCopy(data, (int)fieldOffset, buffer, bufferoffset, length);
                return length;
            }
            return 0;
        }


        public char GetChar(int i)
        {
            return Convert.ToChar(GetValue(i));
        }


        public long GetChars(int i, long fieldoffset, char[] buffer, int bufferoffset, int length)
        {
            string data = GetString(i);
            int max = data.Length + 1 - (int)fieldoffset;
            if (length > max) length = max;
            if (length > 0)
            {
                data.CopyTo((int)fieldoffset, buffer, bufferoffset, length);
                return length;
            }
            return 0;
        }


        public IDataReader GetData(int i)
        {
            throw new NotSupportedException();
        }


        public string GetDataTypeName(int i)
        {
            return GetFieldType(i).Name;
        }


        public DateTime GetDateTime(int i)
        {
            return Convert.ToDateTime(GetValue(i));
        }


        public decimal GetDecimal(int i)
        {
            return Convert.ToDecimal(GetValue(i));
        }


        public double GetDouble(int i)
        {
            return Convert.ToDouble(GetValue(i));
        }


        public Type GetFieldType(int i)
        {
            return columnTypes[i];
        }


        public float GetFloat(int i)
        {
            return Convert.ToSingle(GetValue(i));
        }


        public Guid GetGuid(int i)
        {
            object obj = GetValue(i);
            byte[] binary = obj as byte[];
            if (binary != null)
            {
                return new Guid(binary);
            }
            else
            {
                return new Guid(Convert.ToString(obj));
            }
        }


        public short GetInt16(int i)
        {
            return Convert.ToInt16(GetValue(i));
        }


        public int GetInt32(int i)
        {
            return Convert.ToInt32(GetValue(i));
        }


        public long GetInt64(int i)
        {
            return Convert.ToInt64(GetValue(i));
        }


        public string GetName(int i)
        {
            return columnNames[i];
        }


        public int GetOrdinal(string name)
        {
            for (int i = 0; i < columnNames.Length; i++)
            {
                if (StringComparer.InvariantCultureIgnoreCase.Equals(name, columnNames[i]))
                    return i;
            }
            return -1;
        }


        public string GetString(int i)
        {
            return Convert.ToString(GetValue(i));
        }


        public object GetValue(int i)
        {
            return values[i];
        }


        public int GetValues(object[] values)
        {
            if (values == null) throw new ArgumentNullException("values");
            int fields = values.Length < FieldCount ? values.Length : FieldCount;
            Array.Copy(this.values, values, fields);
            return fields;
        }


        public bool IsDBNull(int i)
        {
            object obj = GetValue(i);
            return obj == null || obj is DBNull;
        }


        public object this[string name]
        {
            get { return this[GetOrdinal(name)]; }
        }


        public object this[int i]
        {
            get { return GetValue(i); }
        }
    }
}
