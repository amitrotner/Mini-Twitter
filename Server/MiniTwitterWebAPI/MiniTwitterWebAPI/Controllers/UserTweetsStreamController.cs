using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniTwitterDotNetAPI.Models;
using Newtonsoft.Json;

namespace MiniTwitterDotNetAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserTweetsStreamController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();

        // Get every tweet only the user tweeted. This will be shown in user profile, but not in feed.
        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] String username)
        {
            // First check if username exists in DB
            if (!await dbContext.UsersTbl.AnyAsync(User => User.UserName.Equals(username)))
                return StatusCode(StatusCodes.Status404NotFound, "No Such User");

            //var tweets;
            try
            {
                //Get all tweets by the user or by users the user follow. Order by descending order since we would like new tweets to be first in feed.
                var tweets = await dbContext.TweetsTbl.Where(tweet => tweet.UserName.Equals(username)).OrderByDescending(tweet => tweet.Id).ToListAsync();

                return StatusCode(StatusCodes.Status200OK, JsonConvert.SerializeObject(tweets));
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status404NotFound, "Couldn't retrieve feed");
            }
        }
    }
}
