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

namespace MiniTwitterDotNetAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LoginController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();
        [HttpPost]
        public async Task<IActionResult> Post([FromBody] UsersTbl value)
        {
            // check if the User exists in the DB
            if (await dbContext.UsersTbl.AnyAsync(User => User.UserName.Equals(value.UserName)))
            {
                UsersTbl user = await dbContext.UsersTbl.Where(u => u.UserName.Equals(value.UserName)).FirstAsync();

                //calculate hash password and compare to DB
                var client_post_hash_password = Convert.ToBase64String(Common.SaltHashPassword(
                    Encoding.ASCII.GetBytes(value.Password),
                    Convert.FromBase64String(user.Salt)));

                if (client_post_hash_password.Equals(user.Password))
                    return StatusCode(StatusCodes.Status200OK, user.UserName);
                else
                    return StatusCode(StatusCodes.Status400BadRequest, "Wrong Password");
            }
            else
            {
                return StatusCode(StatusCodes.Status400BadRequest, "User does not exist in DB");
            }
        }
    }
}
