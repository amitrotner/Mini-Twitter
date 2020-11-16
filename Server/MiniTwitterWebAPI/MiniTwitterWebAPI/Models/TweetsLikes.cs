using System;
using System.Collections.Generic;

namespace MiniTwitterDotNetAPI.Models
{
    public partial class TweetsLikes
    {
        public long Id { get; set; }
        public string UserName { get; set; }
        public long? TweetId { get; set; }
    }
}
