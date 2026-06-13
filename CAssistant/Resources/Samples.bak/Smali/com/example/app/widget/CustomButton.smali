.class public com/example/app/widget/CustomButton;
.super Ljava/lang/Object;
.source "CustomButton.java"

.field public text:Ljava/lang/String;
.field public color:I
.field public size:F
.field public isEnabled:Z

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getText()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/CustomButton;->text:Ljava/lang/String;
    return-object v0
.end method

.method public setText(Ljava/lang/String;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/CustomButton;->text:Ljava/lang/String;
    return-void
.end method

.method public getColor()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/CustomButton;->color:I
    return-object v0
.end method

.method public setColor(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/CustomButton;->color:I
    return-void
.end method

.method public getSize()F
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/CustomButton;->size:F
    return-object v0
.end method

.method public setSize(F)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/CustomButton;->size:F
    return-void
.end method

.method public getIsEnabled()Z
    .registers 2
    iget-object v0, p0, Lcom/example/app/widget/CustomButton;->isEnabled:Z
    return-object v0
.end method

.method public setIsEnabled(Z)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/widget/CustomButton;->isEnabled:Z
    return-void
.end method
