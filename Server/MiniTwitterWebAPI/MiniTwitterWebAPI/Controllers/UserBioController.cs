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
    public class UserBioController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();
        [HttpGet]
        //Get bio of username
        public async Task<IActionResult> Get([FromQuery] String username)
        {
            try
            {
                UsersTbl user = await dbContext.UsersTbl.Where(u => u.UserName.Equals(username)).FirstAsync();
                return StatusCode(StatusCodes.Status200OK, user.Bio);
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status404NotFound, "Couldn't retrieve Bio");
            }
        }

        [HttpPost]
        //Set bio of username
        public async Task<IActionResult> Post([FromQuery] String username, [FromBody] String bio)
        {
            if (!await dbContext.UsersTbl.AnyAsync(User => User.UserName.Equals(username)))
                return StatusCode(StatusCodes.Status404NotFound, "No Such User");

            try
            {
                UsersTbl user = await dbContext.UsersTbl.Where(u => u.UserName.Equals(username)).FirstAsync();
                user.Bio = bio;

                await dbContext.SaveChangesAsync();
                return StatusCode(StatusCodes.Status200OK, "Profile bio changed");
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status404NotFound, ex.Message);
            }
        }
    }
}
