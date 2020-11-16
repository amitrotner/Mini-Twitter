using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using MiniTwitterDotNetAPI.Models;
using Newtonsoft.Json;

namespace MiniTwitterDotNetAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TweetStreamController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();

        // Get every tweet by the user or by users the user follow
        [HttpGet]
        public async Task<IActionResult> Get([FromQuery]String username)
        {
            //var tweets;
            try
            {
                // First check if username exists in DB
                if (!await dbContext.UsersTbl.AnyAsync(User => User.UserName.Equals(username)))
                    return StatusCode(StatusCodes.Status404NotFound, "No Such User");

                // Get all the users user is following
                var user_followees = await dbContext.FollowingTbl.Where(follow => follow.FollowerId.Equals(username)).Select(follow => follow.FolloweeId).ToListAsync();

                
               //Get all tweets by the user or by users the user follow. Order by descenging order since we would like new tweets to be first in feed.
                var tweets = await dbContext.TweetsTbl.Where(tweet  => tweet.UserName.Equals(username) || (user_followees.Contains(tweet.UserName))).OrderByDescending(tweet => tweet.Id).ToListAsync();

                return StatusCode(StatusCodes.Status200OK, JsonConvert.SerializeObject(tweets));
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status404NotFound, "Couldn't retrieve feed");
            }
        }
    }
}

