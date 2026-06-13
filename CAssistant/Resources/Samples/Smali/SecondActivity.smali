.class public LSecondActivity;
.super Landroid/app/Activity;
.source "SecondActivity.java"


# direct methods
.method public constructor <init>()V
    .registers 1

    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .registers 3
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V
    const v0, 0x7f030001
    invoke-virtual {p0, v0}, LSecondActivity;->setContentView(I)V
    return-void
.end method
