.class public synthetic Lcom/example/app/service/LocationService$1;
.super Ljava/lang/Object;
.source "LocationService.java"

.implements Ljava/lang/Runnable;

.method public run()V
    .registers 5
    :try_start_0
    const-wide/16 v0, 0x3e8
    invoke-static {v0, v1}, Ljava/lang/Thread;->sleep(J)V
    :goto_5
    # loop body
    goto :goto_5
    :catch_end
    return-void
.end method

.method constructor <init>(Lcom/example/app/service/LocationService;)V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method
