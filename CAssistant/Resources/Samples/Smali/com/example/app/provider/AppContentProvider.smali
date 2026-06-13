.class public com/example/app/provider/AppContentProvider;
.super Landroid/content/ContentProvider;
.source "AppContentProvider.java"

.field private mDbHelper:LDatabaseHelper;
.field private static final URI_MATCHER:Landroid/content/UriMatcher;
.field private static final TABLE_USERS:I = 0x1
.field private static final TABLE_USERS_ID:I = 0x2
.field private static final TABLE_POSTS:I = 0x3
.field private static final TABLE_POSTS_ID:I = 0x4

.method static constructor <clinit>()V
    .registers 4
    new-instance v0, Landroid/content/UriMatcher;
    const/4 v1, -0x1
    invoke-direct {v0, v1}, Landroid/content/UriMatcher;-><init>(I)V
    sput-object v0, Lcom/example/app/provider/AppContentProvider;->URI_MATCHER:Landroid/content/UriMatcher;
    const-string v1, "com.example.provider"
    const-string v2, "users"
    const/4 v3, 0x1
    invoke-virtual {v0, v1, v2, v3}, Landroid/content/UriMatcher;->addURI(Ljava/lang/String;Ljava/lang/String;I)V
    const-string v2, "users/#"
    const/4 v3, 0x2
    invoke-virtual {v0, v1, v2, v3}, Landroid/content/UriMatcher;->addURI(Ljava/lang/String;Ljava/lang/String;I)V
    const-string v2, "posts"
    const/4 v3, 0x3
    invoke-virtual {v0, v1, v2, v3}, Landroid/content/UriMatcher;->addURI(Ljava/lang/String;Ljava/lang/String;I)V
    const-string v2, "posts/#"
    const/4 v3, 0x4
    invoke-virtual {v0, v1, v2, v3}, Landroid/content/UriMatcher;->addURI(Ljava/lang/String;Ljava/lang/String;I)V
    return-void
.end method

.method public onCreate()Z
    .registers 3
    invoke-virtual {p0}, Lcom/example/app/provider/AppContentProvider;->getContext()Landroid/content/Context;
    move-result-object v0
    invoke-static {v0}, LDatabaseHelper;->getInstance(Landroid/content/Context;)LDatabaseHelper;
    move-result-object v0
    iput-object v0, p0, com/example/app/provider/AppContentProvider->mDbHelper:LDatabaseHelper;
    const/4 v0, 0x1
    return v0
.end method

.method public query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    .registers 16
    iget-object v0, p0, com/example/app/provider/AppContentProvider->mDbHelper:LDatabaseHelper;
    invoke-virtual {v0}, LDatabaseHelper;->getReadableDatabase()Landroid/database/sqlite/SQLiteDatabase;
    move-result-object v0
    sget-object v1, Lcom/example/app/provider/AppContentProvider;->URI_MATCHER:Landroid/content/UriMatcher;
    invoke-virtual {v1, p1}, Landroid/content/UriMatcher;->match(Landroid/net/Uri;)I
    move-result v1
    packed-switch v1, :pswitch_data_20
    new-instance v0, Ljava/lang/IllegalArgumentException;
    invoke-direct {v0}, Ljava/lang/IllegalArgumentException;-><init>()V
    throw v0
    :pswitch_12
    invoke-virtual {p1}, Landroid/net/Uri;->getLastPathSegment()Ljava/lang/String;
    move-result-object v2
    const/4 v3, 0x0
    const/4 v6, 0x0
    const/4 v7, 0x0
    const/4 v8, 0x0
    const/4 v9, 0x0
    const-string v1, "users"
    move-object v4, p3
    move-object v5, p4
    :goto_20
    invoke-virtual/range {v0 .. v9}, Landroid/database/sqlite/SQLiteDatabase;->query(...)
    return-object
.end method

.method public insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;
    .registers 8
    iget-object v0, p0, com/example/app/provider/AppContentProvider->mDbHelper:LDatabaseHelper;
    invoke-virtual {v0}, LDatabaseHelper;->getWritableDatabase()Landroid/database/sqlite/SQLiteDatabase;
    move-result-object v0
    sget-object v1, Lcom/example/app/provider/AppContentProvider;->URI_MATCHER:Landroid/content/UriMatcher;
    invoke-virtual {v1, p1}, Landroid/content/UriMatcher;->match(Landroid/net/Uri;)I
    move-result v1
    const-string v2, "users"
    const/4 v3, 0x0
    invoke-virtual {v0, v2, v3, p2}, Landroid/database/sqlite/SQLiteDatabase;->insert(Ljava/lang/String;Ljava/lang/String;Landroid/content/ContentValues;)J
    move-result-wide v0
    invoke-virtual {p0}, Lcom/example/app/provider/AppContentProvider;->getContext()Landroid/content/Context;
    move-result-object v2
    invoke-virtual {v2}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v2
    invoke-virtual {v2, p1, v3}, Landroid/content/ContentResolver;->notifyChange(Landroid/net/Uri;Landroid/database/ContentObserver;)V
    invoke-static {p1, v0, v1}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;
    move-result-object v2
    return-object v2
.end method

.method public update(Landroid/net/Uri;Landroid/content/ContentValues;Ljava/lang/String;[Ljava/lang/String;)I
    .registers 9
    iget-object v0, p0, com/example/app/provider/AppContentProvider->mDbHelper:LDatabaseHelper;
    invoke-virtual {v0}, LDatabaseHelper;->getWritableDatabase()Landroid/database/sqlite/SQLiteDatabase;
    move-result-object v0
    const-string v1, "users"
    invoke-virtual {v0, v1, p2, p3, p4}, Landroid/database/sqlite/SQLiteDatabase;->update(Ljava/lang/String;Landroid/content/ContentValues;Ljava/lang/String;[Ljava/lang/String;)I
    move-result v2
    invoke-virtual {p0}, Lcom/example/app/provider/AppContentProvider;->getContext()Landroid/content/Context;
    move-result-object v1
    invoke-virtual {v1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v1
    const/4 v3, 0x0
    invoke-virtual {v1, p1, v3}, Landroid/content/ContentResolver;->notifyChange(Landroid/net/Uri;Landroid/database/ContentObserver;)V
    return v2
.end method

.method public delete(Landroid/net/Uri;Ljava/lang/String;[Ljava/lang/String;)I
    .registers 8
    iget-object v0, p0, com/example/app/provider/AppContentProvider->mDbHelper:LDatabaseHelper;
    invoke-virtual {v0}, LDatabaseHelper;->getWritableDatabase()Landroid/database/sqlite/SQLiteDatabase;
    move-result-object v0
    const-string v1, "users"
    invoke-virtual {v0, v1, p2, p3}, Landroid/database/sqlite/SQLiteDatabase;->delete(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)I
    move-result v2
    invoke-virtual {p0}, Lcom/example/app/provider/AppContentProvider;->getContext()Landroid/content/Context;
    move-result-object v1
    invoke-virtual {v1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v1
    const/4 v3, 0x0
    invoke-virtual {v1, p1, v3}, Landroid/content/ContentResolver;->notifyChange(Landroid/net/Uri;Landroid/database/ContentObserver;)V
    return v2
.end method

.method public getType(Landroid/net/Uri;)Ljava/lang/String;
    .registers 4
    const-string v0, "vnd.android.cursor.dir/vnd.com.example.users"
    return-object v0
.end method
