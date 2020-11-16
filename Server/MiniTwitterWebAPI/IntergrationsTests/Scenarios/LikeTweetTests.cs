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
    public class LikeTweetTests
    {
        private readonly TestContext _sut;

        public LikeTweetTests(TestContext sut)
        {
            _sut = sut;
        }


        // Liking should fail since no such user exists
        [Fact]
        public async Task InvalidTweetLiker()
        {
            var data = new{};
            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/LikeTweet?username=test_user2&tweet_id=2", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }

        // Liking should fail since no such tweet
        [Fact]
        public async Task InvalidTweetId()
        {
            var data = new { };
            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/LikeTweet?username=test_user2&tweet_id=9999", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }

        // Liking should succeed since it is a valid request
        [Fact]
        public async Task ValidLike()
        {
            var data = new { };
            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/LikeTweet?username=test_user&tweet_id=2", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }

    }
}
