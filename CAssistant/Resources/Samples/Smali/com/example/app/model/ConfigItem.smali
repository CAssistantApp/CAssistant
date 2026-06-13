.class public com/example/app/model/ConfigItem;
.super Ljava/lang/Object;
.source "ConfigItem.java"

.field public key:Ljava/lang/String;
.field public value:Ljava/lang/String;
.field public type:Ljava/lang/String;
.field public isPublic:Z
.field public updatedAt:J

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getKey()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/ConfigItem;->key:Ljava/lang/String;
    return-object v0
.end method

.method public setKey(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/ConfigItem;->key:Ljava/lang/String;
    return-void
.end method

.method public getValue()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/ConfigItem;->value:Ljava/lang/String;
    return-object v0
.end method

.method public setValue(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/ConfigItem;->value:Ljava/lang/String;
    return-void
.end method

.method public getType()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/ConfigItem;->type:Ljava/lang/String;
    return-object v0
.end method

.method public setType(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/ConfigItem;->type:Ljava/lang/String;
    return-void
.end method

.method public getIsPublic()Z
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/ConfigItem;->isPublic:Z
    return-object v0
.end method

.method public setIsPublic(Z)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/ConfigItem;->isPublic:Z
    return-void
.end method

.method public getUpdatedAt()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/ConfigItem;->updatedAt:J
    return-object v0
.end method

.method public setUpdatedAt(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/ConfigItem;->updatedAt:J
    return-void
.end method
