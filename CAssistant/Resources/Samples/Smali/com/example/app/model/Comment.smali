.class public com/example/app/model/Comment;
.super Ljava/lang/Object;
.source "Comment.java"

.field public id:J
.field public postId:J
.field public userId:J
.field public content:Ljava/lang/String;
.field public parentId:J
.field public createdAt:J

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getId()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Comment;->id:J
    return-object v0
.end method

.method public setId(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Comment;->id:J
    return-void
.end method

.method public getPostId()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Comment;->postId:J
    return-object v0
.end method

.method public setPostId(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Comment;->postId:J
    return-void
.end method

.method public getUserId()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Comment;->userId:J
    return-object v0
.end method

.method public setUserId(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Comment;->userId:J
    return-void
.end method

.method public getContent()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Comment;->content:Ljava/lang/String;
    return-object v0
.end method

.method public setContent(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Comment;->content:Ljava/lang/String;
    return-void
.end method

.method public getParentId()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Comment;->parentId:J
    return-object v0
.end method

.method public setParentId(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Comment;->parentId:J
    return-void
.end method

.method public getCreatedAt()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Comment;->createdAt:J
    return-object v0
.end method

.method public setCreatedAt(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Comment;->createdAt:J
    return-void
.end method
