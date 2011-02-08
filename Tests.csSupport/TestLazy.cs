using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Xunit;
using PSIS;
using System.Diagnostics;

namespace Tests.csSupport
{
    public class TestLazy
    {
        [Fact]
        public void Test()
        {
            int enumerated = 0;
            var lst = Enumerable.Range(1, 10).Select(ii => { enumerated++; return ii; });
            lst.ToArray();
            var expected = enumerated;
            lst.Count();
            Assert.Equal(2 * expected, enumerated);
        }

        [Fact]
        public void TPopTrade()
        {
            try
            {
                var res = PSIS.PSS.PopulateTrades();
                Debug.WriteLine(res);
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex);
                Assert.True(false);
            }
        }
    }
}
