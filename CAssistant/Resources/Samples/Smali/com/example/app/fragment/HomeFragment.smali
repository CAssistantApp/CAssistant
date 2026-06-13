.class public com/example/app/fragment/HomeFragment;
.super Landroidx/fragment/app/Fragment;
.source "HomeFragment.java"

.field private mRootView:Landroid/view/View;
.field private mIsDataLoaded:Z
.field private mRefreshLayout:Landroidx/swiperefreshlayout/widget/SwipeRefreshLayout;
.field private mRecyclerView:Landroidx/recyclerview/widget/RecyclerView;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Landroidx/fragment/app/Fragment;-><init>()V
    return-void
.end method

.method public onCreateView(Landroid/view/LayoutInflater;Landroid/view/ViewGroup;Landroid/os/Bundle;)Landroid/view/View;
    .registers 6
    const v0, 0x7f0d0042
    const/4 v1, 0x0
    invoke-virtual {p1, v0, p2, v1}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;Z)Landroid/view/View;
    move-result-object v0
    iput-object v0, p0, com/example/app/fragment/HomeFragment->mRootView:Landroid/view/View;
    invoke-direct {p0}, com/example/app/fragment/HomeFragment->initViews()V
    return-object v0
.end method

.method public onViewCreated(Landroid/view/View;Landroid/os/Bundle;)V
    .registers 5
    invoke-super {p0, p1, p2}, Landroidx/fragment/app/Fragment;->onViewCreated(Landroid/view/View;Landroid/os/Bundle;)V
    iget-boolean v0, p0, com/example/app/fragment/HomeFragment->mIsDataLoaded:Z
    if-nez v0, :cond_a
    invoke-direct {p0}, com/example/app/fragment/HomeFragment->fetchData()V
    :cond_a
    return-void
.end method

.method private initViews()V
    .registers 3
    iget-object v0, p0, com/example/app/fragment/HomeFragment->mRootView:Landroid/view/View;
    const v1, 0x7f0901a3
    invoke-virtual {v0, v1}, Landroid/view/View;->findViewById(I)Landroid/view/View;
    move-result-object v0
    check-cast v0, Landroidx/recyclerview/widget/RecyclerView;
    iput-object v0, p0, com/example/app/fragment/HomeFragment->mRecyclerView:Landroidx/recyclerview/widget/RecyclerView;
    new-instance v1, Landroidx/recyclerview/widget/LinearLayoutManager;
    invoke-virtual {p0}, com/example/app/fragment/HomeFragment->getContext()Landroid/content/Context;
    move-result-object v2
    invoke-direct {v1, v2}, Landroidx/recyclerview/widget/LinearLayoutManager;-><init>(Landroid/content/Context;)V
    invoke-virtual {v0, v1}, Landroidx/recyclerview/widget/RecyclerView;->setLayoutManager(Landroidx/recyclerview/widget/RecyclerView$LayoutManager;)V
    return-void
.end method

.method private fetchData()V
    .registers 4
    new-instance v0, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v1
    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    new-instance v1, com/example/app/fragment/HomeFragment$1;
    invoke-direct {v1, p0}, com/example/app/fragment/HomeFragment$1;-><init>(Lcom/example/app/fragment/HomeFragment;)V
    const-wide/16 v2, 0xc8
    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    return-void
.end method

.method public onDestroyView()V
    .registers 2
    const/4 v0, 0x0
    iput-object v0, p0, com/example/app/fragment/HomeFragment->mRootView:Landroid/view/View;
    iput-object v0, p0, com/example/app/fragment/HomeFragment->mRecyclerView:Landroidx/recyclerview/widget/RecyclerView;
    invoke-super {p0}, Landroidx/fragment/app/Fragment;->onDestroyView()V
    return-void
.end method
