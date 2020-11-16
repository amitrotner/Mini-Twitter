using System;
using System.Collections.Generic;

namespace MiniTwitterDotNetAPI.Models
{
    public partial class FollowingTbl
    {
        public long Id { get; set; }
        public string FollowerId { get; set; }
        public string FolloweeId { get; set; }
    }
}
