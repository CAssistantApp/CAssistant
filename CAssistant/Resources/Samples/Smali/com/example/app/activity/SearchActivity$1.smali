.class public synthetic Lcom/example/app/activity/SearchActivity$1;
.super Ljava/lang/Object;
.source "SearchActivity.java"

.implements Lokhttp3/Callback;

.method public onFailure(Lokhttp3/Call;Ljava/io/IOException;)V
    .registers 3
    return-void
.end method

.method public onResponse(Lokhttp3/Call;Lokhttp3/Response;)V
    .registers 5
    invoke-virtual {p2}, Lokhttp3/Response;->body()Lokhttp3/ResponseBody;
    move-result-object v0
    if-eqz v0, :cond_b
    invoke-virtual {v0}, Lokhttp3/ResponseBody;->string()Ljava/lang/String;
    :cond_b
    return-void
.end method

.method constructor <init>(Lcom/example/app/activity/SearchActivity;)V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method
