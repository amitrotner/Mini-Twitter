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
    public class PostingTweetTests
    {
        private readonly TestContext _sut;

        public PostingTweetTests(TestContext sut)
        {
            _sut = sut;
        }


        // Posting should fail since no such user exists
        [Fact]
        public async Task InvalidTweetAuthor()
        {
            var data = new
            {
                UserName = "test_user2",
                Tweet = "1234",
                ProfilePicPath = "",
                Imagepath = ""
            };

            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/PostTweet", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }

        // Posting should succeed since it's a valid tweet
        [Fact]
        public async Task PostingValidTweet()
        {
            var data = new
            {
                UserName = "test_user",
                Tweet = "1234",
                ProfilePicPath = "",
                Imagepath = ""
            };

            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/PostTweet", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }
    }
}
