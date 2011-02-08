using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Xunit;
using PSIS;

namespace Tests.csSupport
{
    public class TestSSModel
    {
        private string DSTCS = "Data Source=.;Integrated Security=True;Initial Catalog=DestSQLDatabase";

        [Fact]
        public void TestValidModel()
        {
            var mdl = new StarSchemaModel(DSTCS, "staging.TradesDWView", "DW.FactTrades");
        }

        [Fact]
        public void TestInvalidModelExtraSrcCol()
        {
            Assert.Throws<ArgumentException>(() => new StarSchemaModel(DSTCS, "staging.TradesDWViewInvalidExtraCol", "DW.FactTrades"));
        }

        [Fact]
        public void TestInvalidModelMissingSrcCol()
        {
            Assert.Throws<Exception>(() => new StarSchemaModel(DSTCS, "staging.TradesDWViewInvalidMissingCol", "DW.FactTrades"));
        }

    }
}
