.class public com/example/app/database/AnalyticsDatabase;
.super Landroid/database/sqlite/SQLiteOpenHelper;
.source "AnalyticsDatabase.java"

.field private static final DATABASE_NAME:Ljava/lang/String; = "analyticsdatabase.db"
.field private static final DATABASE_VERSION:I = 0x3
.field private static INSTANCE:Lcom/example/app/database/AnalyticsDatabase;

.method private constructor <init>(Landroid/content/Context;)V
    .registers 5
    sget-object v0, Lcom/example/app/database/AnalyticsDatabase;->DATABASE_NAME:Ljava/lang/String;
    const/4 v1, 0x0
    sget v2, Lcom/example/app/database/AnalyticsDatabase;->DATABASE_VERSION:I
    invoke-direct {p0, p1, v0, v1, v2}, Landroid/database/sqlite/SQLiteOpenHelper;-><init>(Landroid/content/Context;Ljava/lang/String;Landroid/database/sqlite/SQLiteDatabase$CursorFactory;I)V
    return-void
.end method

.method public static getInstance(Landroid/content/Context;)Lcom/example/app/database/AnalyticsDatabase;
    .registers 3
    sget-object v0, Lcom/example/app/database/AnalyticsDatabase;->INSTANCE:Lcom/example/app/database/AnalyticsDatabase;
    if-nez v0, :cond_13
    const-class v0, Lcom/example/app/database/AnalyticsDatabase;
    monitor-enter v0
    :try_start_7
    sget-object v1, Lcom/example/app/database/AnalyticsDatabase;->INSTANCE:Lcom/example/app/database/AnalyticsDatabase;
    if-nez v1, :cond_11
    new-instance v1, Lcom/example/app/database/AnalyticsDatabase;
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;
    move-result-object v2
    invoke-direct {v1, v2}, Lcom/example/app/database/AnalyticsDatabase;-><init>(Landroid/content/Context;)V
    sput-object v1, Lcom/example/app/database/AnalyticsDatabase;->INSTANCE:Lcom/example/app/database/AnalyticsDatabase;
    :cond_11
    monitor-exit v0
    goto :goto_13
    :catch_10
    move-exception v1
    monitor-exit v0
    throw v1
    :cond_13
    :goto_13
    sget-object v0, Lcom/example/app/database/AnalyticsDatabase;->INSTANCE:Lcom/example/app/database/AnalyticsDatabase;
    return-object v0
.end method

.method public onCreate(Landroid/database/sqlite/SQLiteDatabase;)V
    .registers 5
    const-string v0, "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, email TEXT, avatar_url TEXT, created_at INTEGER, updated_at INTEGER, last_login INTEGER, status INTEGER DEFAULT 1, role TEXT DEFAULT 'user')"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "CREATE TABLE IF NOT EXISTS posts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT NOT NULL, content TEXT, image_url TEXT, category TEXT, tags TEXT, view_count INTEGER DEFAULT 0, like_count INTEGER DEFAULT 0, comment_count INTEGER DEFAULT 0, is_pinned INTEGER DEFAULT 0, is_deleted INTEGER DEFAULT 0, created_at INTEGER, updated_at INTEGER, FOREIGN KEY (user_id) REFERENCES users(id))"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "CREATE TABLE IF NOT EXISTS comments (id INTEGER PRIMARY KEY AUTOINCREMENT, post_id INTEGER, user_id INTEGER, content TEXT NOT NULL, parent_id INTEGER DEFAULT 0, is_deleted INTEGER DEFAULT 0, created_at INTEGER, FOREIGN KEY (post_id) REFERENCES posts(id), FOREIGN KEY (user_id) REFERENCES users(id))"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT, updated_at INTEGER)"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "CREATE TABLE IF NOT EXISTS cache (url TEXT PRIMARY KEY, response TEXT, headers TEXT, expires_at INTEGER, created_at INTEGER)"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "CREATE INDEX idx_posts_user_id ON posts(user_id)"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "CREATE INDEX idx_posts_category ON posts(category)"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "CREATE INDEX idx_comments_post_id ON comments(post_id)"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "CREATE INDEX idx_cache_expires ON cache(expires_at)"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    return-void
.end method

.method public onUpgrade(Landroid/database/sqlite/SQLiteDatabase;II)V
    .registers 7
    const-string v0, "DROP TABLE IF EXISTS users"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "DROP TABLE IF EXISTS posts"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "DROP TABLE IF EXISTS comments"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "DROP TABLE IF EXISTS settings"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    const-string v0, "DROP TABLE IF EXISTS cache"
    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V
    invoke-virtual {p0, p1}, Lcom/example/app/database/AnalyticsDatabase;->onCreate(Landroid/database/sqlite/SQLiteDatabase;)V
    return-void
.end method

.method public insertUser(Landroid/content/ContentValues;)J
    .registers 6
    invoke-virtual {p0}, Lcom/example/app/database/AnalyticsDatabase;->getWritableDatabase()Landroid/database/sqlite/SQLiteDatabase;
    move-result-object v0
    const-string v1, "users"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2, p1}, Landroid/database/sqlite/SQLiteDatabase;->insert(Ljava/lang/String;Ljava/lang/String;Landroid/content/ContentValues;)J
    move-result-wide v0
    return-wide v0
.end method

.method public queryUser(Ljava/lang/String;[Ljava/lang/String;)Landroid/database/Cursor;
    .registers 12
    invoke-virtual {p0}, Lcom/example/app/database/AnalyticsDatabase;->getReadableDatabase()Landroid/database/sqlite/SQLiteDatabase;
    move-result-object v0
    const-string v1, "users"
    const/4 v2, 0x0
    const/4 v5, 0x0
    const/4 v6, 0x0
    const/4 v7, 0x0
    const/4 v8, 0x0
    move-object v3, p1
    move-object v4, p2
    invoke-virtual/range {v0 .. v8}, Landroid/database/sqlite/SQLiteDatabase;->query(Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    move-result-object v0
    return-object v0
.end method

.method public deleteExpiredCache(J)V
    .registers 9
    invoke-virtual {p0}, Lcom/example/app/database/AnalyticsDatabase;->getWritableDatabase()Landroid/database/sqlite/SQLiteDatabase;
    move-result-object v0
    const-string v1, "cache"
    const-string v2, "expires_at < ?"
    const/4 v3, 0x1
    new-array v3, v3, [Ljava/lang/String;
    invoke-static {p1, p2}, Ljava/lang/String;->valueOf(J)Ljava/lang/String;
    move-result-object v4
    const/4 v5, 0x0
    aput-object v4, v3, v5
    invoke-virtual {v0, v1, v2, v3}, Landroid/database/sqlite/SQLiteDatabase;->delete(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)I
    return-void
.end method
