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
    public class SearchUsersController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();
        // Get every tweet only the user tweeted. This will be shown in user profile, but not in feed.
        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] String searchfield)
        {
            //var tweets;
            try
            {
                //Get all users starting with searchfield
                var users = dbContext.UsersTbl.Where(user => user.UserName.Contains(searchfield)).Select(user => new { user.UserName, user.ProfilePicPath});
                return StatusCode(StatusCodes.Status200OK, JsonConvert.SerializeObject(users));
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status404NotFound, "Couldn't search");
            }
        }
    }
}
