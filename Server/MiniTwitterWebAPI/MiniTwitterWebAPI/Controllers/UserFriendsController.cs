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
    public class UserFriendsController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();

        [HttpGet]
        //Get the number of followers and followees by username
        public async Task<IActionResult> Get([FromQuery] String username)
        {
            try
            {
                int numberOfFollowers = await dbContext.FollowingTbl.CountAsync(follow => follow.FolloweeId.Equals(username));
                int numberOfFollowees = await dbContext.FollowingTbl.CountAsync(follow => follow.FollowerId.Equals(username));

                var map = new Dictionary<string, int>();
                map.Add("followers", numberOfFollowers);
                map.Add("followees", numberOfFollowees);

                return StatusCode(StatusCodes.Status200OK, JsonConvert.SerializeObject(map));
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status404NotFound, "Couldn't retrieve friends");
            }
        }

        [HttpPost]
        //Get all the followers/followees of username
        public async Task<IActionResult> Post([FromQuery] String username, String select)
        {
            IQueryable<String> friendsList;
            try
            {
                if (select == "followees")
                {
                    // Get all the followees of username
                    friendsList = dbContext.FollowingTbl.Where(follow => follow.FollowerId.Equals(username)).Select(follow => follow.FolloweeId);
                }
                else
                {
                    // Get all the followers of username
                    friendsList = dbContext.FollowingTbl.Where(follow => follow.FolloweeId.Equals(username)).Select(follow => follow.FollowerId);
                }

                return StatusCode(StatusCodes.Status200OK, JsonConvert.SerializeObject(friendsList));
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status404NotFound, "Couldn't retrieve friends");
            }
        }
    }
}
