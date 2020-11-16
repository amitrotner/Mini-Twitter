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
    public class RegisterTests
    {
        private readonly TestContext _sut;

        public RegisterTests(TestContext sut)
        {
            _sut = sut;
        }


        // Registration should pass
        [Fact]
        public async Task RegisterReturnsOK()
        {
            var data = new
            {
                UserName = "test_user",
                Password = "1234",
                Email = "test@example.com",
                ProfilePicPath = "https://banner2.cleanpng.com/20180620/fqa/kisspng-computer-icons-user-profile-avatar-icon-5b2aab30517c02.1531259015295229923338.jpg",
                Bio = ""
            };

            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/register", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }


        // Registration should fail - amit already exist in DB
        [Fact]
        public async Task RegisterUserAlreadyExist()
        {
            var data = new
            {
                UserName = "amit",
                Password = "1234",
                Email = "test@example.com",
                ProfilePicPath = "https://banner2.cleanpng.com/20180620/fqa/kisspng-computer-icons-user-profile-avatar-icon-5b2aab30517c02.1531259015295229923338.jpg",
                Bio = ""
            };

            var json = JsonConvert.SerializeObject(data);
            var stringContent = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            var response = await _sut.Client.PostAsync("/api/register", stringContent);

            response.StatusCode.Should().Be(HttpStatusCode.Conflict);
        }
    }
}
