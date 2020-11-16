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
    public class UserBioTests
    {
        private readonly TestContext _sut;

        public UserBioTests(TestContext sut)
        {
            _sut = sut;
        }


        // Should fail since this user doesn't exist
        [Fact]
        public async Task NoSuchUser()
        {
            var response = await _sut.Client.GetAsync("/api/UserBio?username=test_user2");
            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }

        // Should retrieve profile pic
        [Fact]
        public async Task ValidUserBio()
        {
            var response = await _sut.Client.GetAsync("/api/UserBio?username=test_user");
            var body = response.Content.ReadAsStreamAsync();
            response.StatusCode.Should().Be(HttpStatusCode.OK);

        }

        // Should fail since this user doesn't exist
        [Fact]
        public async Task NoSuchUser2()
        {
            var json = JsonConvert.SerializeObject("New Bio");
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/UserBio?username=test_user2", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }


        // Should change profile pic
        [Fact]
        public async Task ValidUserBioChange()
        {
            var json = JsonConvert.SerializeObject("New Bio");
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/UserBio?username=test_user", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }
    }
}
