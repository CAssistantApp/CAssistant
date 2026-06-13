.class public com/example/app/widget/LoadingView;
.super Ljava/lang/Object;
.source "LoadingView.java"

.field public isLoading:Z
.field public message:Ljava/lang/String;
.field public color:I

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getIsLoading()Z
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/LoadingView;->isLoading:Z
    return-object v0
.end method

.method public setIsLoading(Z)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/LoadingView;->isLoading:Z
    return-void
.end method

.method public getMessage()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/LoadingView;->message:Ljava/lang/String;
    return-object v0
.end method

.method public setMessage(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/LoadingView;->message:Ljava/lang/String;
    return-void
.end method

.method public getColor()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/LoadingView;->color:I
    return-object v0
.end method

.method public setColor(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/LoadingView;->color:I
    return-void
.end method
