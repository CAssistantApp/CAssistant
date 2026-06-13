.class public com/example/app/model/ApiResponse;
.super Ljava/lang/Object;
.source "ApiResponse.java"

.field public code:I
.field public message:Ljava/lang/String;
.field public data:Ljava/lang/Object;
.field public timestamp:J
.field public pageInfo:LPageInfo;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getCode()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/ApiResponse;->code:I
    return-object v0
.end method

.method public setCode(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/ApiResponse;->code:I
    return-void
.end method

.method public getMessage()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/ApiResponse;->message:Ljava/lang/String;
    return-object v0
.end method

.method public setMessage(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/ApiResponse;->message:Ljava/lang/String;
    return-void
.end method

.method public getData()Ljava/lang/Object;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/ApiResponse;->data:Ljava/lang/Object;
    return-object v0
.end method

.method public setData(Ljava/lang/Object;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/ApiResponse;->data:Ljava/lang/Object;
    return-void
.end method

.method public getTimestamp()J
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/ApiResponse;->timestamp:J
    return-object v0
.end method

.method public setTimestamp(J)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/ApiResponse;->timestamp:J
    return-void
.end method

.method public getPageInfo()LPageInfo;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/ApiResponse;->pageInfo:LPageInfo;
    return-object v0
.end method

.method public setPageInfo(LPageInfo;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/ApiResponse;->pageInfo:LPageInfo;
    return-void
.end method
