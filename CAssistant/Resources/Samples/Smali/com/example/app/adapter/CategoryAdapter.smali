.class public com/example/app/adapter/CategoryAdapter;
.super Landroidx/recyclerview/widget/RecyclerView$Adapter;
.source "CategoryAdapter.java"
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Landroidx/recyclerview/widget/RecyclerView$Adapter",
        "<",
        "com/example/app/adapter/CategoryAdapter$ViewHolder",
        ">;"
    }
.end annotation

.field private mDataList:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "LDataItem;",
            ">;"
        }
    .end annotation
.end field

.field private mContext:Landroid/content/Context;
.field private mOnItemClickListener:Landroid/view/View$OnClickListener;
.field private mSelectedPosition:I

.method public constructor <init>(Landroid/content/Context;Ljava/util/List;)V
    .registers 6
    invoke-direct {p0}, Landroidx/recyclerview/widget/RecyclerView$Adapter;-><init>()V
    iput-object p1, p0, com/example/app/adapter/CategoryAdapter->mContext:Landroid/content/Context;
    iput-object p2, p0, com/example/app/adapter/CategoryAdapter->mDataList:Ljava/util/List;
    const/4 v0, -0x1
    iput v0, p0, com/example/app/adapter/CategoryAdapter->mSelectedPosition:I
    return-void
.end method

.method public onCreateViewHolder(Landroid/view/ViewGroup;I)Lcom/example/app/adapter/CategoryAdapter$ViewHolder;
    .registers 7
    invoke-virtual {p1}, Landroid/view/ViewGroup;->getContext()Landroid/content/Context;
    move-result-object v0
    invoke-static {v0}, Landroid/view/LayoutInflater;->from(Landroid/content/Context;)Landroid/view/LayoutInflater;
    move-result-object v0
    const v1, 0x7f0d00a5
    const/4 v2, 0x0
    invoke-virtual {v0, v1, p1, v2}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;Z)Landroid/view/View;
    move-result-object v1
    new-instance v2, com/example/app/adapter/CategoryAdapter$ViewHolder;
    invoke-direct {v2, p0, v1}, com/example/app/adapter/CategoryAdapter$ViewHolder;-><init>(Lcom/example/app/adapter/CategoryAdapter;Landroid/view/View;)V
    return-object v2
.end method

.method public onBindViewHolder(Lcom/example/app/adapter/CategoryAdapter$ViewHolder;I)V
    .registers 7
    iget-object v0, p0, com/example/app/adapter/CategoryAdapter->mDataList:Ljava/util/List;
    invoke-interface {v0, p2}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, LDataItem;
    iget-object v1, p1, com/example/app/adapter/CategoryAdapter$ViewHolder;->titleTextView:Landroid/widget/TextView;
    invoke-virtual {v0}, LDataItem;->getTitle()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    iget-object v1, p1, com/example/app/adapter/CategoryAdapter$ViewHolder;->descTextView:Landroid/widget/TextView;
    invoke-virtual {v0}, LDataItem;->getDescription()Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    iget v1, p0, com/example/app/adapter/CategoryAdapter->mSelectedPosition:I
    if-ne p2, v1, :cond_21
    iget-object v1, p1, com/example/app/adapter/CategoryAdapter$ViewHolder;->itemView:Landroid/view/View;
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/view/View;->setSelected(Z)V
    :goto_1e
    return-void
    :cond_21
    iget-object v1, p1, com/example/app/adapter/CategoryAdapter$ViewHolder;->itemView:Landroid/view/View;
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/view/View;->setSelected(Z)V
    goto :goto_1e
.end method

.method public getItemCount()I
    .registers 2
    iget-object v0, p0, com/example/app/adapter/CategoryAdapter->mDataList:Ljava/util/List;
    if-nez v0, :cond_6
    const/4 v0, 0x0
    return v0
    :cond_6
    invoke-interface {v0}, Ljava/util/List;->size()I
    move-result v0
    return v0
.end method

.method public updateData(Ljava/util/List;)V
    .registers 3
    iput-object p1, p0, com/example/app/adapter/CategoryAdapter->mDataList:Ljava/util/List;
    invoke-virtual {p0}, com/example/app/adapter/CategoryAdapter->notifyDataSetChanged()V
    return-void
.end method

.method public getItemAtPosition(I)LDataItem;
    .registers 3
    iget-object v0, p0, com/example/app/adapter/CategoryAdapter->mDataList:Ljava/util/List;
    if-eqz v0, :cond_d
    invoke-interface {v0}, Ljava/util/List;->size()I
    move-result v0
    if-ge p1, v0, :cond_d
    iget-object v0, p0, com/example/app/adapter/CategoryAdapter->mDataList:Ljava/util/List;
    invoke-interface {v0, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, LDataItem;
    return-object v0
    :cond_d
    const/4 v0, 0x0
    return-object v0
.end method
