.class public com/example/app/model/Post;
.super Ljava/lang/Object;
.source "Post.java"

.field public id:J
.field public title:Ljava/lang/String;
.field public content:Ljava/lang/String;
.field public imageUrl:Ljava/lang/String;
.field public category:Ljava/lang/String;
.field public tags:Ljava/lang/String;
.field public viewCount:I
.field public likeCount:I
.field public commentCount:I

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getId()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Post;->id:J
    return-object v0
.end method

.method public setId(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Post;->id:J
    return-void
.end method

.method public getTitle()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Post;->title:Ljava/lang/String;
    return-object v0
.end method

.method public setTitle(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Post;->title:Ljava/lang/String;
    return-void
.end method

.method public getContent()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Post;->content:Ljava/lang/String;
    return-object v0
.end method

.method public setContent(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Post;->content:Ljava/lang/String;
    return-void
.end method

.method public getImageUrl()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Post;->imageUrl:Ljava/lang/String;
    return-object v0
.end method

.method public setImageUrl(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Post;->imageUrl:Ljava/lang/String;
    return-void
.end method

.method public getCategory()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Post;->category:Ljava/lang/String;
    return-object v0
.end method

.method public setCategory(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Post;->category:Ljava/lang/String;
    return-void
.end method

.method public getTags()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Post;->tags:Ljava/lang/String;
    return-object v0
.end method

.method public setTags(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Post;->tags:Ljava/lang/String;
    return-void
.end method

.method public getViewCount()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Post;->viewCount:I
    return-object v0
.end method

.method public setViewCount(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Post;->viewCount:I
    return-void
.end method

.method public getLikeCount()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Post;->likeCount:I
    return-object v0
.end method

.method public setLikeCount(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Post;->likeCount:I
    return-void
.end method

.method public getCommentCount()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/Post;->commentCount:I
    return-object v0
.end method

.method public setCommentCount(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/Post;->commentCount:I
    return-void
.end method
