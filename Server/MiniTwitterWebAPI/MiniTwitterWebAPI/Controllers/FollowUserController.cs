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
    public class FollowUserController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();

        // Follow or unfollow a user
        [HttpPost]
        public async Task<IActionResult> Post([FromQuery] String follower, String followee)
        {

            // Follow this user
            if (!await dbContext.FollowingTbl.AnyAsync(follow => follow.FollowerId.Equals(follower) && follow.FolloweeId.Equals(followee)))
            {
                FollowingTbl follow = new FollowingTbl();

                try
                {
                    follow.Id = await dbContext.FollowingTbl.MaxAsync(follow => follow.Id) + 1;
                }
                catch (Exception)
                {
                    follow.Id = 1;
                }
                follow.FollowerId = follower;
                follow.FolloweeId = followee;

                try
                {
                    await dbContext.AddAsync(follow);
                    await dbContext.SaveChangesAsync();
                    return StatusCode(StatusCodes.Status200OK, follower + " is now following " + followee);
                }
                catch (Exception ex)
                {
                    return StatusCode(StatusCodes.Status400BadRequest, ex.Message);
                }
            }

            // Else unfollow this user
            else
            {
                FollowingTbl follow = dbContext.FollowingTbl.Where(follow => follow.FollowerId.Equals(follower) && follow.FolloweeId.Equals(followee)).First();
                try
                {
                    dbContext.Remove(follow);
                    await dbContext.SaveChangesAsync();
                    return StatusCode(StatusCodes.Status200OK, follower + " is now not following " + followee);
                }
                catch (Exception ex)
                {
                    return StatusCode(StatusCodes.Status400BadRequest, ex.Message);
                }

            }
        }

        [HttpGet]
        // Returns if user likes the tweet
        public async Task<bool> Get([FromQuery] String follower, String followee)
        {
            return await dbContext.FollowingTbl.AnyAsync(follow => follow.FollowerId.Equals(follower) && follow.FolloweeId.Equals(followee));
        }
    }
}
