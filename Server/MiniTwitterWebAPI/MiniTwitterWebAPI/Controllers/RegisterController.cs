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
    public class RegisterController : ControllerBase
    {
        MiniTwitterContext dbContext = new MiniTwitterContext();

        [HttpPost]
        public async Task<IActionResult> Post([FromBody]UsersTbl value)
        {
            // check if the User exists in the DB
            if (!await dbContext.UsersTbl.AnyAsync(User => User.UserName.Equals(value.UserName))) {
                if (!await dbContext.UsersTbl.AnyAsync(User => User.Email.Equals(value.Email)))
                {
                    UsersTbl user = new UsersTbl();
                    user.UserName = value.UserName;
                    user.Email = value.Email;
                    // Generate salt and hash password with salt
                    user.Salt = Convert.ToBase64String(Common.GetRandomSalt(16));
                    user.Password = Convert.ToBase64String(Common.SaltHashPassword(
                        Encoding.ASCII.GetBytes(value.Password),
                        Convert.FromBase64String(user.Salt)));

                    user.ProfilePicPath = value.ProfilePicPath;
                    user.Bio = value.Bio;
                    //add to DB
                    try
                    {
                        await dbContext.AddAsync(user);
                        await dbContext.SaveChangesAsync();
                        return StatusCode(StatusCodes.Status200OK, "Registered Successfully");
                    }
                    catch (Exception ex)
                    {
                        return StatusCode(StatusCodes.Status400BadRequest, ex.Message);
                    }
                }
                else
                {
                    return StatusCode(StatusCodes.Status409Conflict, "Email already exists in DB");
                }
            }
            else
            {
                return StatusCode(StatusCodes.Status409Conflict, "Username already exists in DB");
            }
        }
    }
}
