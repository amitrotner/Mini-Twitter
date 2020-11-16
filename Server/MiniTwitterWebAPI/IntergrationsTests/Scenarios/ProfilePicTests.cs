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
    public class ProfilePicTests
    {
        private readonly TestContext _sut;

        public ProfilePicTests(TestContext sut)
        {
            _sut = sut;
        }


        // Should fail since this user doesn't exist
        [Fact]
        public async Task NoSuchUser()
        {
            var response = await _sut.Client.GetAsync("/api/ProfilePic?username=test_user2");
            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }

        // Should retrieve profile pic
        [Fact]
        public async Task ValidUserProfilePic()
        {
            var response = await _sut.Client.GetAsync("/api/ProfilePic?username=test_user");
            response.StatusCode.Should().Be(HttpStatusCode.OK);

        }

        // Should fail since this user doesn't exist
        [Fact]
        public async Task NoSuchUser2()
        {
            var json = JsonConvert.SerializeObject("https://hips.hearstapps.com/hmg-prod/images/180906-delish-seo-00017-1537277923.jpg?crop=0.817xw%3A0.690xh%3B0.0176xw%2C0.284xh&resize=480%3A270");
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/ProfilePic?username=test_user2", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.NotFound);
        }


        // Should change profile pic
        [Fact]
        public async Task ValidProfilePicChange()
        {
            var json = JsonConvert.SerializeObject("https://hips.hearstapps.com/hmg-prod/images/180906-delish-seo-00017-1537277923.jpg?crop=0.817xw%3A0.690xh%3B0.0176xw%2C0.284xh&resize=480%3A270");
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/ProfilePic?username=test_user", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }
    }
}
