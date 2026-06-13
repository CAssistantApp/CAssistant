.class public com/example/app/model/LogEntry;
.super Ljava/lang/Object;
.source "LogEntry.java"

.field public level:I
.field public tag:Ljava/lang/String;
.field public message:Ljava/lang/String;
.field public timestamp:J
.field public threadName:Ljava/lang/String;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getLevel()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/LogEntry;->level:I
    return-object v0
.end method

.method public setLevel(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/LogEntry;->level:I
    return-void
.end method

.method public getTag()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/LogEntry;->tag:Ljava/lang/String;
    return-object v0
.end method

.method public setTag(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/LogEntry;->tag:Ljava/lang/String;
    return-void
.end method

.method public getMessage()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/LogEntry;->message:Ljava/lang/String;
    return-object v0
.end method

.method public setMessage(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/LogEntry;->message:Ljava/lang/String;
    return-void
.end method

.method public getTimestamp()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/LogEntry;->timestamp:J
    return-object v0
.end method

.method public setTimestamp(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/LogEntry;->timestamp:J
    return-void
.end method

.method public getThreadName()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/LogEntry;->threadName:Ljava/lang/String;
    return-object v0
.end method

.method public setThreadName(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/LogEntry;->threadName:Ljava/lang/String;
    return-void
.end method
