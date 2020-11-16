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
    public class ProfilePicController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();
        [HttpGet]
        //Get profile pic by user
        public async Task<IActionResult> Get([FromQuery] String username)
        {
            try
            {
                UsersTbl user = await dbContext.UsersTbl.Where(u => u.UserName.Equals(username)).FirstAsync();
                return StatusCode(StatusCodes.Status200OK, user.ProfilePicPath);
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status404NotFound, "Couldn't retrieve Profile pic path");
            }
        }

        [HttpPost]
        //Set profile pic of user to path
        public async Task<IActionResult> Post([FromQuery] String username, [FromBody] String path)
        {
            // First check if username exists in DB
            if (!await dbContext.UsersTbl.AnyAsync(User => User.UserName.Equals(username)))
                return StatusCode(StatusCodes.Status404NotFound, "No Such User");

            try
            {
                //Change user profile pic in users table
                UsersTbl user = await dbContext.UsersTbl.Where(u => u.UserName.Equals(username)).FirstAsync();
                user.ProfilePicPath = path;

                //Change user profile pic in tweets table
                await dbContext.TweetsTbl.Where(tweet => tweet.UserName.Equals(username)).ForEachAsync(tweet => tweet.ProfilePicPath = path);

                await dbContext.SaveChangesAsync();
                return StatusCode(StatusCodes.Status200OK, "Profile pic path changed");
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status404NotFound, ex.Message);
            }
        }
    }
}
