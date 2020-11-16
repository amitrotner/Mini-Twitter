using FluentAssertions;
using IntergrationsTests.fixtures;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Helpers;
using Xunit;

namespace IntergrationsTests.Scenarios
{
    [Collection("MiniTwitterCollection")]
    public class SearchTests
    {
        private readonly TestContext _sut;

        public SearchTests(TestContext sut)
        {
            _sut = sut;
        }

        // Should find only test_user
        [Fact]
        public async Task InvalidUserFeed()
        {

            var response = await _sut.Client.GetAsync("/api/SearchUsers?searchfield=test");
            var body = await response.Content.ReadAsStringAsync();
            response.StatusCode.Should().Be(HttpStatusCode.OK);

            var expected = "[{\"UserName\":\"test_user\",\"ProfilePicPath\":\"https://banner2.cleanpng.com/20180620/fqa/kisspng-computer-icons-user-profile-avatar-icon-5b2aab30517c02.1531259015295229923338.jpg\"}]";

            body.Should().Be(expected);
        }
    }
}
