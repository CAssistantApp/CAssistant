.class public com/example/app/model/FileInfo;
.super Ljava/lang/Object;
.source "FileInfo.java"

.field public id:J
.field public fileName:Ljava/lang/String;
.field public fileSize:J
.field public mimeType:Ljava/lang/String;
.field public url:Ljava/lang/String;
.field public thumbnailUrl:Ljava/lang/String;
.field public uploadTime:J

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getId()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/FileInfo;->id:J
    return-object v0
.end method

.method public setId(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/FileInfo;->id:J
    return-void
.end method

.method public getFileName()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/FileInfo;->fileName:Ljava/lang/String;
    return-object v0
.end method

.method public setFileName(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/FileInfo;->fileName:Ljava/lang/String;
    return-void
.end method

.method public getFileSize()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/FileInfo;->fileSize:J
    return-object v0
.end method

.method public setFileSize(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/FileInfo;->fileSize:J
    return-void
.end method

.method public getMimeType()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/FileInfo;->mimeType:Ljava/lang/String;
    return-object v0
.end method

.method public setMimeType(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/FileInfo;->mimeType:Ljava/lang/String;
    return-void
.end method

.method public getUrl()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/FileInfo;->url:Ljava/lang/String;
    return-object v0
.end method

.method public setUrl(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/FileInfo;->url:Ljava/lang/String;
    return-void
.end method

.method public getThumbnailUrl()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/FileInfo;->thumbnailUrl:Ljava/lang/String;
    return-object v0
.end method

.method public setThumbnailUrl(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/FileInfo;->thumbnailUrl:Ljava/lang/String;
    return-void
.end method

.method public getUploadTime()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/FileInfo;->uploadTime:J
    return-object v0
.end method

.method public setUploadTime(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/FileInfo;->uploadTime:J
    return-void
.end method
