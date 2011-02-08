namespace PSIS
{

    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Linq.Expressions;
    using System.Collections;


    public class LinqObjDataReader : SimpleDataReader
    {

        private IEnumerator _Enumer;
        private Func<object, object[]> _Converter;
        public LinqObjDataReader(IEnumerable items, Type t)
        {

            if (items == null)
            {
                throw new Exception("Null values not allowed");
            }

            Type ttype = t;
            var properties = ttype.GetProperties();
            var types = properties.Select(pi => pi.PropertyType).ToArray();
            Init(properties.Select(pi => pi.Name).ToArray(), types);


            // create a expression like so
            // Func<T, object[]> func = item => new object[] { (object) item.Property1, (object) item.Property2,.. (object)item.PropertyN };  
            ParameterExpression param = Expression.Parameter(ttype, "item");
            Expression[] initValues = properties
                .Select(pi => Expression.Convert(Expression.Property(param, pi.Name), typeof(object)))
                .ToArray();

            Expression<Func<object, object[]>> conversionExpr = Expression.Lambda<Func<object, object[]>>(
                Expression.NewArrayInit(typeof(object), initValues),
                param);

            _Converter = conversionExpr.Compile();
            _Enumer = items.GetEnumerator();
        }

        protected override void DoClose()
        {
            IDisposable disp = _Enumer as IDisposable;
            if (disp != null)
            {
                disp.Dispose();
            }
        }
        
        protected override bool DoRead()
        {
            var ret = _Enumer.MoveNext();
            if (ret)
            {
                SetValues(_Converter(_Enumer.Current));
            }

            return ret;
        }
    }

    public class LinqObjDataReader<T> : SimpleDataReader
    {

        private IEnumerator<T> _Enumer;
        private Func<T, object[]> _Converter;
        public LinqObjDataReader(IEnumerable<T> items)
        {

            if (items == null)
            {
                throw new Exception("Null values not allowed");
            }

            Type ttype = typeof(T);
            var properties = ttype.GetProperties();
            var types = properties.Select(pi => pi.PropertyType).ToArray();
            Init(properties.Select(pi => pi.Name).ToArray(), types);


            // create a expression like so
            // Func<T, object[]> func = item => new object[] { (object) item.Property1, (object) item.Property2,.. (object)item.PropertyN };  
            ParameterExpression param = Expression.Parameter(ttype, "item");
            Expression[] initValues = properties
                .Select(pi => Expression.Convert(Expression.Property(param, pi.Name), typeof(object)))
                .ToArray();

            Expression<Func<T, object[]>> conversionExpr = Expression.Lambda<Func<T, object[]>>(
                Expression.NewArrayInit(typeof(object), initValues),
                param);

            _Converter = conversionExpr.Compile();
            _Enumer = items.GetEnumerator();
        }

        protected override void DoClose()
        {
            _Enumer.Dispose();
        }

        protected override bool DoRead()
        {
            var ret = _Enumer.MoveNext();
            if (ret)
            {
                SetValues(_Converter(_Enumer.Current));
            }

            return ret;
        }
    }
}
