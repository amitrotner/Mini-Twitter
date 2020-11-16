using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniTwitterDotNetAPI.Models;

namespace MiniTwitterDotNetAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PostTweetController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] TweetsTbl value)
        {
            // new id is number of rows + 1
            long id;
            try
            {
                id = await dbContext.TweetsTbl.MaxAsync(tweet => tweet.Id) + 1;
            }
            catch (Exception)
            {
                id = 1;
            }

            UsersTbl user;
            try
            {
                user = await dbContext.UsersTbl.Where(u => u.UserName.Equals(value.UserName)).FirstAsync();
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status400BadRequest, ex.Message);
            }
            
            TweetsTbl tweet = new TweetsTbl();
            tweet.Id = id;
            tweet.UserName = value.UserName;
            tweet.ProfilePicPath = user.ProfilePicPath;
            tweet.Tweet = value.Tweet;
            tweet.Imagepath = value.Imagepath;
            tweet.CommentsCount = 0;
            tweet.LikesCount = 0;
            tweet.SharesCount = 0;

            //add to DB
            try
            {
                await dbContext.AddAsync(tweet);
                await dbContext.SaveChangesAsync();
                return StatusCode(StatusCodes.Status200OK, "Tweet Posted");
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status400BadRequest, ex.Message);
            }
        }
    }
}