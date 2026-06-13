.class public com/example/app/widget/ErrorView;
.super Ljava/lang/Object;
.source "ErrorView.java"

.field public errorCode:I
.field public errorMessage:Ljava/lang/String;
.field public retryCallback:Ljava/lang/Runnable;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getErrorCode()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/ErrorView;->errorCode:I
    return-object v0
.end method

.method public setErrorCode(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/ErrorView;->errorCode:I
    return-void
.end method

.method public getErrorMessage()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/ErrorView;->errorMessage:Ljava/lang/String;
    return-object v0
.end method

.method public setErrorMessage(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/ErrorView;->errorMessage:Ljava/lang/String;
    return-void
.end method

.method public getRetryCallback()Ljava/lang/Runnable;
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/ErrorView;->retryCallback:Ljava/lang/Runnable;
    return-object v0
.end method

.method public setRetryCallback(Ljava/lang/Runnable;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/ErrorView;->retryCallback:Ljava/lang/Runnable;
    return-void
.end method
