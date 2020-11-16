using System;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace MiniTwitterDotNetAPI.Models
{
    public partial class MiniTwitterContext : DbContext
    {

        public MiniTwitterContext()
        {
        }

        public MiniTwitterContext(DbContextOptions<MiniTwitterContext> options)
            : base(options)
        {
        }

        public virtual DbSet<FollowingTbl> FollowingTbl { get; set; }
        public virtual DbSet<TweetsLikes> TweetsLikes { get; set; }
        public virtual DbSet<TweetsTbl> TweetsTbl { get; set; }
        public virtual DbSet<UsersTbl> UsersTbl { get; set; }
        public virtual DbSet<AdminTbl> AdminTbl { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {

                var connectionString = new SqlConnectionStringBuilder()
                {
                    DataSource = Environment.GetEnvironmentVariable("DB_HOST"),
                    UserID = Environment.GetEnvironmentVariable("DB_USER"),
                    Password = Environment.GetEnvironmentVariable("DB_PASS"),
                    InitialCatalog = Environment.GetEnvironmentVariable("DB_NAME"),
                    Encrypt = false,
                };
                connectionString.Pooling = true;



#warning To protect potentially sensitive information in your connection string, you should move it out of source code. See http://go.microsoft.com/fwlink/?LinkId=723263 for guidance on storing connection strings.
                optionsBuilder.UseSqlServer(connectionString.ConnectionString);
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<FollowingTbl>(entity =>
            {
                entity.Property(e => e.Id).ValueGeneratedNever();

                entity.Property(e => e.FolloweeId).HasMaxLength(50);

                entity.Property(e => e.FollowerId)
                    .IsRequired()
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<TweetsLikes>(entity =>
            {
                entity.Property(e => e.Id).ValueGeneratedNever();

                entity.Property(e => e.UserName)
                    .IsRequired()
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<TweetsTbl>(entity =>
            {
                entity.Property(e => e.Id).ValueGeneratedNever();

                entity.Property(e => e.Imagepath).HasMaxLength(300);

                entity.Property(e => e.ProfilePicPath).HasMaxLength(300);

                entity.Property(e => e.Tweet).HasMaxLength(255);

                entity.Property(e => e.UserName)
                    .IsRequired()
                    .HasMaxLength(50)
                    .IsFixedLength();
            });

            modelBuilder.Entity<UsersTbl>(entity =>
            {
                entity.HasKey(e => e.UserName);

                entity.Property(e => e.UserName).HasMaxLength(50);

                entity.Property(e => e.Bio).HasMaxLength(300);

                entity.Property(e => e.Email)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.Password)
                    .HasMaxLength(250)
                    .IsUnicode(false);

                entity.Property(e => e.ProfilePicPath).HasMaxLength(300);

                entity.Property(e => e.Salt)
                    .HasMaxLength(50)
                    .IsUnicode(false);
            });

            modelBuilder.Entity<AdminTbl>(entity =>
            {
                entity.HasKey(e => e.UserName);

                entity.Property(e => e.UserName).HasMaxLength(50);

                entity.Property(e => e.Password)
                    .HasMaxLength(250)
                    .IsUnicode(false);

                entity.Property(e => e.Salt)
                    .HasMaxLength(50)
                    .IsUnicode(false);
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
