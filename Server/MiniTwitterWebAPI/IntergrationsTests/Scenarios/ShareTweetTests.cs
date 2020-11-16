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
    public class ShareTweetTests
    {
        private readonly TestContext _sut;

        public ShareTweetTests(TestContext sut)
        {
            _sut = sut;
        }

        // Sharing should fail since there it isn't a valid tweet id
        [Fact]
        public async Task InvalidTweetId()
        {
            var data = new { };
            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/ShareTweet?tweet_id=9999", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }

        // Sharing should succeed since it is a valid request
        [Fact]
        public async Task ValidShare()
        {
            var data = new { };
            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/ShareTweet?tweet_id=2", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }

    }
}
