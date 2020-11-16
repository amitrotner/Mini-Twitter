using System;
using System.Collections.Generic;

namespace MiniTwitterDotNetAPI.Models
{
    public partial class AdminTbl
    {
        public string UserName { get; set; }
        public string Password { get; set; }
        public string Salt { get; set; }

    }
}
