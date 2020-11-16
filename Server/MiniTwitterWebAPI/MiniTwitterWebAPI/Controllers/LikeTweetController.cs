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
    public class LikeTweetController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();

        // Likes or unlikes a tweet by tweet_id
        [HttpPost]
        public async Task<IActionResult> Post([FromQuery] String username, long tweet_id)
        {
            UsersTbl user;
            TweetsTbl tweet;

            try
            {
                user = await dbContext.UsersTbl.Where(u => u.UserName.Equals(username)).FirstAsync();
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status404NotFound, ex.Message);
            }

            try
            {
                tweet = await dbContext.TweetsTbl.Where(t => t.Id == tweet_id).FirstAsync();
            }
            catch (Exception ex) 
            {
                return StatusCode(StatusCodes.Status404NotFound, ex.Message);
            }

            // User likes tweet
            if (!await dbContext.TweetsLikes.AnyAsync(like => (like.UserName.Equals(username) && like.TweetId == tweet_id)))
            {

                tweet.LikesCount++;
                TweetsLikes new_like = new TweetsLikes();
                try
                {
                    new_like.Id = await dbContext.TweetsLikes.MaxAsync(like => like.Id) + 1;
                }
                catch (Exception)
                {
                    new_like.Id = 1;
                }

                new_like.TweetId = tweet_id;
                new_like. UserName = username;

                try
                {
                    await dbContext.AddAsync(new_like);
                    await dbContext.SaveChangesAsync();
                    return StatusCode(StatusCodes.Status200OK, "Tweet Liked!");
                }
                catch (Exception ex)
                {
                    return StatusCode(StatusCodes.Status400BadRequest, ex.Message);
                }
            }

            // Else user unlikes tweet
            else
            {
                tweet.LikesCount--;
                TweetsLikes like = await dbContext.TweetsLikes.Where(like => (like.UserName.Equals(username) && like.TweetId == tweet_id)).FirstAsync();
                try
                {
                    dbContext.Remove(like);
                    await dbContext.SaveChangesAsync();
                    return StatusCode(StatusCodes.Status200OK, "Tweet Unliked");
                }
                catch (Exception ex)
                {
                    return StatusCode(StatusCodes.Status400BadRequest, ex.Message);
                }

            }
        }

        [HttpGet]
        // Returns if user likes the tweet
        public async Task<bool> Get([FromQuery] String username, long tweet_id)
        {
            return await dbContext.TweetsLikes.AnyAsync(like => (like.UserName.Equals(username) && like.TweetId == tweet_id));
        }
    }
}
