using System;
using System.Collections.Generic;

namespace MiniTwitterDotNetAPI.Models
{
    public partial class TweetsTbl
    {
        public long Id { get; set; }
        public string UserName { get; set; }
        public string ProfilePicPath { get; set; }
        public string Tweet { get; set; }
        public string Imagepath { get; set; }
        public int? CommentsCount { get; set; }
        public int? LikesCount { get; set; }
        public int? SharesCount { get; set; }
    }
}
