using IntergrationsTests.fixtures;
using System;
using System.Collections.Generic;
using System.Text;
using Xunit;

namespace IntergrationsTests.Fixtures
{
    [CollectionDefinition("MiniTwitterCollection", DisableParallelization = true)]
    public class Collection : ICollectionFixture<TestContext>
    {

    }
}
