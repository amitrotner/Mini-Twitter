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
    public class ShareTweetController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();

        // Share a tweet by tweet_id
        [HttpPost]
        public async Task<IActionResult> Post([FromQuery]long tweet_id)
        {
            try
            {
                TweetsTbl tweet = await dbContext.TweetsTbl.Where(t => t.Id == tweet_id).FirstAsync();
                tweet.SharesCount++;
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status404NotFound);
            }

            try
            {
                await dbContext.SaveChangesAsync();
                return StatusCode(StatusCodes.Status200OK, "Tweet Shared");
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status400BadRequest, ex.Message);
            }
        }
    }
}
