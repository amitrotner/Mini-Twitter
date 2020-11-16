using FluentAssertions;
using IntergrationsTests.fixtures;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace IntergrationsTests.Scenarios
{
    [Collection("MiniTwitterCollection")]
    public class UserTweetFeedTests
    {
        private readonly TestContext _sut;

        public UserTweetFeedTests(TestContext sut)
        {
            _sut = sut;
        }


        // Retrieving feed should fail since no such user exists
        [Fact]
        public async Task InvalidUserFeed()
        {
           
            var response = await _sut.Client.GetAsync("/api/UserTweetsStream?username=test_user2");

            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }

        // Retrieving feed should succeed since there is such user
        [Fact]
        public async Task ValidTweetsFeed()
        {
            var response = await _sut.Client.GetAsync("/api/UserTweetsStream?UserName=test_user");

            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }
    }
}
