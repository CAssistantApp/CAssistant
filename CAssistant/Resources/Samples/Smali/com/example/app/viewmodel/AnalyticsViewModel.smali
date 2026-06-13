.class public com/example/app/viewmodel/AnalyticsViewModel;
.super Landroidx/lifecycle/ViewModel;
.source "AnalyticsViewModel.java"

.field private mLiveData:Landroidx/lifecycle/MutableLiveData;
    .annotation system Ldalvik/annotation/Signature;
        value = {"Landroidx/lifecycle/MutableLiveData", "<", "Ljava/util/List", "<", "LDataItem;", ">;>;"}
    .end annotation
.end field

.field private mIsLoading:Landroidx/lifecycle/MutableLiveData;
    .annotation system Ldalvik/annotation/Signature;
        value = {"Landroidx/lifecycle/MutableLiveData", "<", "Ljava/lang/Boolean;", ">;"}
    .end annotation
.end field

.field private mErrorMessage:Landroidx/lifecycle/MutableLiveData;
    .annotation system Ldalvik/annotation/Signature;
        value = {"Landroidx/lifecycle/MutableLiveData", "<", "Ljava/lang/String;", ">;"}
    .end annotation
.end field

.field private mRepository:LDataRepository;
.field private mCurrentPage:I
.field private mTotalItems:I

.method public constructor <init>()V
    .registers 3
    invoke-direct {p0}, Landroidx/lifecycle/ViewModel;-><init>()V
    new-instance v0, Landroidx/lifecycle/MutableLiveData;
    invoke-direct {v0}, Landroidx/lifecycle/MutableLiveData;-><init>()V
    iput-object v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mLiveData:Landroidx/lifecycle/MutableLiveData;
    new-instance v0, Landroidx/lifecycle/MutableLiveData;
    invoke-direct {v0}, Landroidx/lifecycle/MutableLiveData;-><init>()V
    iput-object v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mIsLoading:Landroidx/lifecycle/MutableLiveData;
    new-instance v0, LDataRepository;
    invoke-direct {v0}, LDataRepository;-><init>()V
    iput-object v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mRepository:LDataRepository;
    const/4 v0, 0x1
    iput v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mCurrentPage:I
    return-void
.end method

.method public getLiveData()Landroidx/lifecycle/LiveData;
    .registers 2
    iget-object v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mLiveData:Landroidx/lifecycle/MutableLiveData;
    return-object v0
.end method

.method public getIsLoading()Landroidx/lifecycle/LiveData;
    .registers 2
    iget-object v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mIsLoading:Landroidx/lifecycle/MutableLiveData;
    return-object v0
.end method

.method public loadData()V
    .registers 4
    iget-object v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mIsLoading:Landroidx/lifecycle/MutableLiveData;
    sget-object v1, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;
    invoke-virtual {v0, v1}, Landroidx/lifecycle/MutableLiveData;->setValue(Ljava/lang/Object;)V
    new-instance v0, Ljava/lang/Thread;
    new-instance v1, com/example/app/viewmodel/AnalyticsViewModel$1;
    invoke-direct {v1, p0}, com/example/app/viewmodel/AnalyticsViewModel$1;-><init>(Lcom/example/app/viewmodel/AnalyticsViewModel;)V
    invoke-direct {v0, v1}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V
    invoke-virtual {v0}, Ljava/lang/Thread;->start()V
    return-void
.end method

.method public refreshData()V
    .registers 3
    const/4 v0, 0x1
    iput v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mCurrentPage:I
    const/4 v0, 0x0
    iput v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mTotalItems:I
    invoke-virtual {p0}, com/example/app/viewmodel/AnalyticsViewModel->loadData()V
    return-void
.end method

.method public loadMoreData()V
    .registers 3
    iget v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mTotalItems:I
    iget-object v1, p0, com/example/app/viewmodel/AnalyticsViewModel->mLiveData:Landroidx/lifecycle/MutableLiveData;
    invoke-virtual {v1}, Landroidx/lifecycle/MutableLiveData;->getValue()Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Ljava/util/List;
    if-eqz v1, :cond_18
    invoke-interface {v1}, Ljava/util/List;->size()I
    move-result v1
    if-ge v1, v0, :cond_18
    iget v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mCurrentPage:I
    add-int/lit8 v0, v0, 0x1
    iput v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mCurrentPage:I
    invoke-virtual {p0}, com/example/app/viewmodel/AnalyticsViewModel->loadData()V
    :cond_18
    return-void
.end method

.method public filterData(Ljava/lang/String;)V
    .registers 8
    iget-object v0, p0, com/example/app/viewmodel/AnalyticsViewModel->mLiveData:Landroidx/lifecycle/MutableLiveData;
    invoke-virtual {v0}, Landroidx/lifecycle/MutableLiveData;->getValue()Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/util/List;
    if-nez v0, :cond_9
    return-void
    :cond_9
    new-instance v1, Ljava/util/ArrayList;
    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v2
    :cond_10
    :goto_10
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z
    move-result v3
    if-eqz v3, :cond_2e
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v3
    check-cast v3, LDataItem;
    invoke-virtual {v3}, LDataItem;->getTitle()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v4, p1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v4
    if-eqz v4, :cond_10
    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    goto :goto_10
    :cond_2e
    iget-object v2, p0, com/example/app/viewmodel/AnalyticsViewModel->mLiveData:Landroidx/lifecycle/MutableLiveData;
    invoke-virtual {v2, v1}, Landroidx/lifecycle/MutableLiveData;->setValue(Ljava/lang/Object;)V
    return-void
.end method
