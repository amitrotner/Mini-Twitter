using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniTwitterDotNetAPI.Models;
using MiniTwitterDotNetAPI.Utils;
using Newtonsoft.Json;

namespace MiniTwitterWebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdminController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();
        [HttpPost]
        public async Task<IActionResult> Post([FromBody] AdminTbl value)
        {
            // check if the User exists in the DB
            if (await dbContext.AdminTbl.AnyAsync(User => User.UserName.Equals(value.UserName)))
            {
                AdminTbl admin = await dbContext.AdminTbl.Where(admin => admin.UserName.Equals(value.UserName)).FirstAsync();

                //calculate hash password and compare to DB
                var client_post_hash_password = Convert.ToBase64String(Common.SaltHashPassword(
                    Encoding.ASCII.GetBytes(value.Password),
                    Convert.FromBase64String(admin.Salt)));

                if (client_post_hash_password.Equals(admin.Password))
                    return StatusCode(StatusCodes.Status200OK, JsonConvert.SerializeObject(admin.UserName));
                else
                    return StatusCode(StatusCodes.Status400BadRequest, JsonConvert.SerializeObject("Wrong Credentials"));
            }
            else
            {
                return StatusCode(StatusCodes.Status400BadRequest, JsonConvert.SerializeObject("Wrong Credentials"));
            }
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            try
            {
                // Get details of all users

                var users = await dbContext.UsersTbl.Where(user => user.UserName.Equals(user.UserName)).Select(user => new { user.UserName, user.Email, user.ProfilePicPath}).ToListAsync();

                return StatusCode(StatusCodes.Status200OK, JsonConvert.SerializeObject(users));
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status404NotFound, JsonConvert.SerializeObject("Couldn't retrieve users details"));
            }
        }
    }
}
