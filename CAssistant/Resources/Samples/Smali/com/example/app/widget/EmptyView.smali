.class public com/example/app/widget/EmptyView;
.super Ljava/lang/Object;
.source "EmptyView.java"

.field public iconRes:I
.field public message:Ljava/lang/String;
.field public actionText:Ljava/lang/String;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getIconRes()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/EmptyView;->iconRes:I
    return-object v0
.end method

.method public setIconRes(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/EmptyView;->iconRes:I
    return-void
.end method

.method public getMessage()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/EmptyView;->message:Ljava/lang/String;
    return-object v0
.end method

.method public setMessage(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/EmptyView;->message:Ljava/lang/String;
    return-void
.end method

.method public getActionText()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/EmptyView;->actionText:Ljava/lang/String;
    return-object v0
.end method

.method public setActionText(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/EmptyView;->actionText:Ljava/lang/String;
    return-void
.end method
