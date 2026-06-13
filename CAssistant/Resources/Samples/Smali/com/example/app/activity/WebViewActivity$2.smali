.class public synthetic Lcom/example/app/activity/WebViewActivity$2;
.super Ljava/lang/Object;
.source "WebViewActivity.java"
.implements Landroidx/lifecycle/Observer;

.method public onChanged(Ljava/lang/Object;)V
    .registers 5
    check-cast p1, Ljava/util/List;
    if-eqz p1, :cond_10
    invoke-interface {p1}, Ljava/util/List;->isEmpty()Z
    move-result v0
    if-nez v0, :cond_10
    invoke-interface {p1}, Ljava/util/List;->size()I
    :cond_10
    return-void
.end method

.method constructor <init>(Lcom/example/app/activity/WebViewActivity;)V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method
