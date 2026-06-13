.class public com/example/app/widget/BannerView;
.super Ljava/lang/Object;
.source "BannerView.java"

.field public imageUrl:Ljava/lang/String;
.field public linkUrl:Ljava/lang/String;
.field public title:Ljava/lang/String;
.field public duration:I

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getImageUrl()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/BannerView;->imageUrl:Ljava/lang/String;
    return-object v0
.end method

.method public setImageUrl(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/BannerView;->imageUrl:Ljava/lang/String;
    return-void
.end method

.method public getLinkUrl()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/BannerView;->linkUrl:Ljava/lang/String;
    return-object v0
.end method

.method public setLinkUrl(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/BannerView;->linkUrl:Ljava/lang/String;
    return-void
.end method

.method public getTitle()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/BannerView;->title:Ljava/lang/String;
    return-object v0
.end method

.method public setTitle(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/BannerView;->title:Ljava/lang/String;
    return-void
.end method

.method public getDuration()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/BannerView;->duration:I
    return-object v0
.end method

.method public setDuration(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/BannerView;->duration:I
    return-void
.end method
