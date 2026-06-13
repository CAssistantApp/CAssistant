.class public com/example/app/model/Notification;
.super Ljava/lang/Object;
.source "Notification.java"

.field public id:J
.field public type:Ljava/lang/String;
.field public title:Ljava/lang/String;
.field public content:Ljava/lang/String;
.field public isRead:Z
.field public createdAt:J

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getId()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Notification;->id:J
    return-object v0
.end method

.method public setId(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Notification;->id:J
    return-void
.end method

.method public getType()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Notification;->type:Ljava/lang/String;
    return-object v0
.end method

.method public setType(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Notification;->type:Ljava/lang/String;
    return-void
.end method

.method public getTitle()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Notification;->title:Ljava/lang/String;
    return-object v0
.end method

.method public setTitle(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Notification;->title:Ljava/lang/String;
    return-void
.end method

.method public getContent()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Notification;->content:Ljava/lang/String;
    return-object v0
.end method

.method public setContent(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Notification;->content:Ljava/lang/String;
    return-void
.end method

.method public getIsRead()Z
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Notification;->isRead:Z
    return-object v0
.end method

.method public setIsRead(Z)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Notification;->isRead:Z
    return-void
.end method

.method public getCreatedAt()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Notification;->createdAt:J
    return-object v0
.end method

.method public setCreatedAt(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Notification;->createdAt:J
    return-void
.end method
