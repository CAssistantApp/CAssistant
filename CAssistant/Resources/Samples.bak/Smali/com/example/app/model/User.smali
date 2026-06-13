.class public com/example/app/model/User;
.super Ljava/lang/Object;
.source "User.java"

.field public id:J
.field public username:Ljava/lang/String;
.field public email:Ljava/lang/String;
.field public avatarUrl:Ljava/lang/String;
.field public bio:Ljava/lang/String;
.field public role:Ljava/lang/String;
.field public level:I
.field public createdAt:J

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getId()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/User;->id:J
    return-object v0
.end method

.method public setId(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/User;->id:J
    return-void
.end method

.method public getUsername()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/User;->username:Ljava/lang/String;
    return-object v0
.end method

.method public setUsername(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/User;->username:Ljava/lang/String;
    return-void
.end method

.method public getEmail()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/User;->email:Ljava/lang/String;
    return-object v0
.end method

.method public setEmail(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/User;->email:Ljava/lang/String;
    return-void
.end method

.method public getAvatarUrl()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/User;->avatarUrl:Ljava/lang/String;
    return-object v0
.end method

.method public setAvatarUrl(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/User;->avatarUrl:Ljava/lang/String;
    return-void
.end method

.method public getBio()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/User;->bio:Ljava/lang/String;
    return-object v0
.end method

.method public setBio(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/User;->bio:Ljava/lang/String;
    return-void
.end method

.method public getRole()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/User;->role:Ljava/lang/String;
    return-object v0
.end method

.method public setRole(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/User;->role:Ljava/lang/String;
    return-void
.end method

.method public getLevel()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/User;->level:I
    return-object v0
.end method

.method public setLevel(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/User;->level:I
    return-void
.end method

.method public getCreatedAt()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/User;->createdAt:J
    return-object v0
.end method

.method public setCreatedAt(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/User;->createdAt:J
    return-void
.end method
