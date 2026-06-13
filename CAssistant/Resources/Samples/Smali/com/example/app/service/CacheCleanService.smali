.class public com/example/app/service/CacheCleanService;
.super Landroid/app/Service;
.source "CacheCleanService.java"

.field private mBinder:Landroid/os/Binder;
.field private mIsRunning:Z
.field private mHandler:Landroid/os/Handler;
.field private mThread:Ljava/lang/Thread;
.field private mWakeLock:Landroid/os/PowerManager$WakeLock;
.field private mWifiLock:Landroid/net/wifi/WifiManager$WifiLock;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Landroid/app/Service;-><init>()V
    return-void
.end method

.method public onCreate()V
    .registers 6
    invoke-super {p0}, Landroid/app/Service;->onCreate()V
    new-instance v0, Landroid/os/HandlerThread;
    const-string v1, "com/example/app/service/CacheCleanService_Thread"
    const/16 v2, 0xa
    invoke-direct {v0, v1, v2}, Landroid/os/HandlerThread;-><init>(Ljava/lang/String;I)V
    invoke-virtual {v0}, Landroid/os/HandlerThread;->start()V
    new-instance v1, Landroid/os/Handler;
    invoke-virtual {v0}, Landroid/os/HandlerThread;->getLooper()Landroid/os/Looper;
    move-result-object v2
    invoke-direct {v1, v2}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    iput-object v1, p0, com/example/app/service/CacheCleanService->mHandler:Landroid/os/Handler;
    invoke-direct {p0}, com/example/app/service/CacheCleanService->acquireWakeLock()V
    return-void
.end method

.method public onStartCommand(Landroid/content/Intent;II)I
    .registers 8
    invoke-direct {p0, p1}, com/example/app/service/CacheCleanService->handleIntent(Landroid/content/Intent;)V
    const/4 v0, 0x2
    return v0
.end method

.method public onBind(Landroid/content/Intent;)Landroid/os/IBinder;
    .registers 3
    iget-object v0, p0, com/example/app/service/CacheCleanService->mBinder:Landroid/os/Binder;
    if-nez v0, :cond_a
    new-instance v0, com/example/app/service/CacheCleanService$LocalBinder;
    invoke-direct {v0, p0}, com/example/app/service/CacheCleanService$LocalBinder;-><init>(Lcom/example/app/service/CacheCleanService;)V
    iput-object v0, p0, com/example/app/service/CacheCleanService->mBinder:Landroid/os/Binder;
    :cond_a
    iget-object v0, p0, com/example/app/service/CacheCleanService->mBinder:Landroid/os/Binder;
    return-object v0
.end method

.method public onDestroy()V
    .registers 3
    invoke-super {p0}, Landroid/app/Service;->onDestroy()V
    const/4 v0, 0x0
    iput-boolean v0, p0, com/example/app/service/CacheCleanService->mIsRunning:Z
    invoke-direct {p0}, com/example/app/service/CacheCleanService->releaseWakeLock()V
    iget-object v0, p0, com/example/app/service/CacheCleanService->mHandler:Landroid/os/Handler;
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacksAndMessages(Ljava/lang/Object;)V
    return-void
.end method

.method private handleIntent(Landroid/content/Intent;)V
    .registers 8
    if-nez p1, :cond_3
    return-void
    :cond_3
    invoke-virtual {p1}, Landroid/content/Intent;->getAction()Ljava/lang/String;
    move-result-object v0
    const-string v1, "ACTION_START"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :cond_11
    invoke-direct {p0}, com/example/app/service/CacheCleanService->startTask()V
    :cond_11
    const-string v1, "ACTION_STOP"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :cond_1b
    invoke-direct {p0}, com/example/app/service/CacheCleanService->stopTask()V
    :cond_1b
    const-string v1, "ACTION_SYNC"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :cond_25
    invoke-direct {p0}, com/example/app/service/CacheCleanService->syncData()V
    :cond_25
    return-void
.end method

.method private startTask()V
    .registers 7
    iget-boolean v0, p0, com/example/app/service/CacheCleanService->mIsRunning:Z
    if-eqz v0, :cond_5
    return-void
    :cond_5
    const/4 v0, 0x1
    iput-boolean v0, p0, com/example/app/service/CacheCleanService->mIsRunning:Z
    new-instance v0, Ljava/lang/Thread;
    new-instance v1, com/example/app/service/CacheCleanService$1;
    invoke-direct {v1, p0}, com/example/app/service/CacheCleanService$1;-><init>(Lcom/example/app/service/CacheCleanService;)V
    invoke-direct {v0, v1}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V
    iput-object v0, p0, com/example/app/service/CacheCleanService->mThread:Ljava/lang/Thread;
    invoke-virtual {v0}, Ljava/lang/Thread;->start()V
    invoke-direct {p0}, com/example/app/service/CacheCleanService->sendBroadcastStatus(Ljava/lang/String;)V
    return-void
.end method

.method private stopTask()V
    .registers 5
    const/4 v0, 0x0
    iput-boolean v0, p0, com/example/app/service/CacheCleanService->mIsRunning:Z
    iget-object v1, p0, com/example/app/service/CacheCleanService->mThread:Ljava/lang/Thread;
    if-eqz v1, :cond_a
    invoke-virtual {v1}, Ljava/lang/Thread;->interrupt()V
    :cond_a
    const-string v1, "stopped"
    invoke-direct {p0, v1}, com/example/app/service/CacheCleanService->sendBroadcastStatus(Ljava/lang/String;)V
    invoke-virtual {p0}, com/example/app/service/CacheCleanService->stopSelf()V
    return-void
.end method

.method private syncData()V
    .registers 5
    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    invoke-virtual {p0}, com/example/app/service/CacheCleanService->getApplicationContext()Landroid/content/Context;
    move-result-object v1
    invoke-static {v1}, LDatabaseHelper;->getInstance(Landroid/content/Context;)LDatabaseHelper;
    move-result-object v1
    invoke-virtual {v1, v0}, LDatabaseHelper;->markForSync(Ljava/util/List;)V
    new-instance v2, Landroid/content/Intent;
    const-string v3, "SYNC_COMPLETED"
    invoke-direct {v2, v3}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    invoke-static {p0}, Landroidx/localbroadcastmanager/content/LocalBroadcastManager;->getInstance(Landroid/content/Context;)Landroidx/localbroadcastmanager/content/LocalBroadcastManager;
    move-result-object v3
    invoke-virtual {v3, v2}, Landroidx/localbroadcastmanager/content/LocalBroadcastManager;->sendBroadcast(Landroid/content/Intent;)Z
    return-void
.end method

.method private acquireWakeLock()V
    .registers 5
    const-string v0, "power"
    invoke-virtual {p0, v0}, com/example/app/service/CacheCleanService->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/os/PowerManager;
    const/4 v1, 0x1
    const-string v2, "CAssistant:com/example/app/service/CacheCleanService"
    invoke-virtual {v0, v1, v2}, Landroid/os/PowerManager;->newWakeLock(ILjava/lang/String;)Landroid/os/PowerManager$WakeLock;
    move-result-object v0
    iput-object v0, p0, com/example/app/service/CacheCleanService->mWakeLock:Landroid/os/PowerManager$WakeLock;
    invoke-virtual {v0}, Landroid/os/PowerManager$WakeLock;->acquire()V
    return-void
.end method

.method private releaseWakeLock()V
    .registers 3
    iget-object v0, p0, com/example/app/service/CacheCleanService->mWakeLock:Landroid/os/PowerManager$WakeLock;
    if-eqz v0, :cond_e
    invoke-virtual {v0}, Landroid/os/PowerManager$WakeLock;->isHeld()Z
    move-result v1
    if-eqz v1, :cond_e
    iget-object v0, p0, com/example/app/service/CacheCleanService->mWakeLock:Landroid/os/PowerManager$WakeLock;
    invoke-virtual {v0}, Landroid/os/PowerManager$WakeLock;->release()V
    :cond_e
    return-void
.end method

.method private sendBroadcastStatus(Ljava/lang/String;)V
    .registers 5
    new-instance v0, Landroid/content/Intent;
    const-string v1, "SERVICE_STATUS_CHANGED"
    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v1, "status"
    invoke-virtual {v0, v1, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    invoke-static {p0}, Landroidx/localbroadcastmanager/content/LocalBroadcastManager;->getInstance(Landroid/content/Context;)Landroidx/localbroadcastmanager/content/LocalBroadcastManager;
    move-result-object v1
    invoke-virtual {v1, v0}, Landroidx/localbroadcastmanager/content/LocalBroadcastManager;->sendBroadcast(Landroid/content/Intent;)Z
    return-void
.end method
