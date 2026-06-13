.class public com/example/app/model/DataItem;
.super Ljava/lang/Object;
.source "DataItem.java"

.field public id:J
.field public title:Ljava/lang/String;
.field public description:Ljava/lang/String;
.field public imageUrl:Ljava/lang/String;
.field public link:Ljava/lang/String;
.field public priority:I
.field public isNew:Z

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getId()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/DataItem;->id:J
    return-object v0
.end method

.method public setId(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/DataItem;->id:J
    return-void
.end method

.method public getTitle()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/DataItem;->title:Ljava/lang/String;
    return-object v0
.end method

.method public setTitle(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/DataItem;->title:Ljava/lang/String;
    return-void
.end method

.method public getDescription()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/DataItem;->description:Ljava/lang/String;
    return-object v0
.end method

.method public setDescription(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/DataItem;->description:Ljava/lang/String;
    return-void
.end method

.method public getImageUrl()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/DataItem;->imageUrl:Ljava/lang/String;
    return-object v0
.end method

.method public setImageUrl(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/DataItem;->imageUrl:Ljava/lang/String;
    return-void
.end method

.method public getLink()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/DataItem;->link:Ljava/lang/String;
    return-object v0
.end method

.method public setLink(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/DataItem;->link:Ljava/lang/String;
    return-void
.end method

.method public getPriority()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/DataItem;->priority:I
    return-object v0
.end method

.method public setPriority(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/DataItem;->priority:I
    return-void
.end method

.method public getIsNew()Z
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/DataItem;->isNew:Z
    return-object v0
.end method

.method public setIsNew(Z)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/DataItem;->isNew:Z
    return-void
.end method
