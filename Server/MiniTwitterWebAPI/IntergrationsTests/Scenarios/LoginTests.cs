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
    public class LoginTests
    {
        private readonly TestContext _sut;

        public LoginTests(TestContext sut)
        {
            _sut = sut;
        }


        // Login should fail since there is not such user
        [Fact]
        public async Task LoginNoSuchUser()
        {
            var data = new
            {
                UserName = "test_user2",
                Password = "1234",
            };

            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/login", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }


        // Login should fail since the password is incorrect
        [Fact]
        public async Task LoginWrongPassword()
        {
            var data = new
            {
                UserName = "test_user",
                Password = "12345",
            };

            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/login", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }


        // Login should succeed
        [Fact]
        public async Task LoginReturnsOK()
        {
            var data = new
            {
                UserName = "test_user",
                Password = "1234",
            };

            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/login", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }
    }
}
