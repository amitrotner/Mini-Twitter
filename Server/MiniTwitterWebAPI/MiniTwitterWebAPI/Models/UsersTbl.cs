using System;
using System.Collections.Generic;

namespace MiniTwitterDotNetAPI.Models
{
    public partial class UsersTbl
    {
        public string UserName { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string Salt { get; set; }
        public string ProfilePicPath { get; set; }
        public string Bio { get; set; }
    }
}
