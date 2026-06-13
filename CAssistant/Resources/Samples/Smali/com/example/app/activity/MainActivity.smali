.class public com/example/app/activity/MainActivity;
.super Landroid/app/Activity;
.source "MainActivity.java"

# instance fields
.field private mContext:Landroid/content/Context;
.field private mHandler:Landroid/os/Handler;
.field private mViewModel:Landroidx/lifecycle/ViewModel;
.field private mAdapter:Landroid/widget/BaseAdapter;
.field private mDataList:Ljava/util/List;
.field private mIsLoading:Z
.field private mCurrentPage:I
.field private mTotalPages:I
.field private mSearchQuery:Ljava/lang/String;
.field private mSharedPrefs:Landroid/content/SharedPreferences;

# direct methods
.method public constructor <init>()V
    .registers 3
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    const/4 v0, 0x0
    iput v0, p0, com/example/app/activity/MainActivity->mCurrentPage:I
    const/4 v0, 0x1
    iput v0, p0, com/example/app/activity/MainActivity->mTotalPages:I
    const/4 v0, 0x0
    iput-object v0, p0, com/example/app/activity/MainActivity->mDataList:Ljava/util/List;
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .registers 5
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V
    const v0, 0x7f0a001c
    invoke-virtual {p0, v0}, com/example/app/activity/MainActivity->setContentView(I)V
    invoke-direct {p0}, com/example/app/activity/MainActivity->initViews()V
    invoke-direct {p0}, com/example/app/activity/MainActivity->loadData()V
    invoke-direct {p0}, com/example/app/activity/MainActivity->setupObservers()V
    return-void
.end method

.method protected onResume()V
    .registers 2
    invoke-super {p0}, Landroid/app/Activity;->onResume()V
    invoke-direct {p0}, com/example/app/activity/MainActivity->refreshData()V
    return-void
.end method

.method protected onPause()V
    .registers 1
    invoke-super {p0}, Landroid/app/Activity;->onPause()V
    return-void
.end method

.method protected onDestroy()V
    .registers 2
    invoke-direct {p0}, com/example/app/activity/MainActivity->cleanupResources()V
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V
    return-void
.end method

.method private initViews()V
    .registers 4
    const v0, 0x7f0900ab
    invoke-virtual {p0, v0}, com/example/app/activity/MainActivity->findViewById(I)Landroid/view/View;
    move-result-object v0
    check-cast v0, Landroidx/recyclerview/widget/RecyclerView;
    new-instance v1, Landroidx/recyclerview/widget/LinearLayoutManager;
    invoke-direct {v1, p0}, Landroidx/recyclerview/widget/LinearLayoutManager;-><init>(Landroid/content/Context;)V
    invoke-virtual {v0, v1}, Landroidx/recyclerview/widget/RecyclerView;->setLayoutManager(Landroidx/recyclerview/widget/RecyclerView$LayoutManager;)V
    const v1, 0x7f09005d
    invoke-virtual {p0, v1}, com/example/app/activity/MainActivity->findViewById(I)Landroid/view/View;
    move-result-object v1
    check-cast v1, Landroid/widget/ProgressBar;
    const v2, 0x7f0900f2
    invoke-virtual {p0, v2}, com/example/app/activity/MainActivity->findViewById(I)Landroid/view/View;
    move-result-object v2
    check-cast v2, Landroid/widget/TextView;
    const-string v3, "加载中..."
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    return-void
.end method

.method private loadData()V
    .registers 5
    const/4 v0, 0x1
    iput-boolean v0, p0, com/example/app/activity/MainActivity->mIsLoading:Z
    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    new-instance v1, Ljava/util/HashMap;
    invoke-direct {v1}, Ljava/util/HashMap;-><init>()V
    const-string v2, "page"
    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v3
    invoke-virtual {v1, v2, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    const-string v2, "pageSize"
    const/16 v3, 0x14
    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v3
    invoke-virtual {v1, v2, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    const-string v2, "token"
    const-string v3, "Bearer xxxxxxxx"
    invoke-virtual {v1, v2, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    invoke-direct {p0, v1}, com/example/app/activity/MainActivity->fetchDataFromNetwork(Ljava/util/Map;)V
    return-void
.end method

.method private fetchDataFromNetwork(Ljava/util/Map;)V
    .registers 7
    new-instance v0, Lokhttp3/OkHttpClient;
    invoke-direct {v0}, Lokhttp3/OkHttpClient;-><init>()V
    new-instance v1, Lokhttp3/Request$Builder;
    invoke-direct {v1}, Lokhttp3/Request$Builder;-><init>()V
    const-string v2, "https://api.example.com/v1/data"
    invoke-virtual {v1, v2}, Lokhttp3/Request$Builder;->url(Ljava/lang/String;)Lokhttp3/Request$Builder;
    move-result-object v1
    invoke-virtual {v1}, Lokhttp3/Request$Builder;->build()Lokhttp3/Request;
    move-result-object v1
    invoke-virtual {v0, v1}, Lokhttp3/OkHttpClient;->newCall(Lokhttp3/Request;)Lokhttp3/Call;
    move-result-object v2
    new-instance v3, com/example/app/activity/MainActivity$1;
    invoke-direct {v3, p0}, com/example/app/activity/MainActivity$1;-><init>(Lcom/example/app/activity/MainActivity;)V
    invoke-virtual {v2, v3}, Lokhttp3/Call;->enqueue(Lokhttp3/Callback;)V
    return-void
.end method

.method private setupObservers()V
    .registers 4
    invoke-virtual {p0}, com/example/app/activity/MainActivity->getViewModelStore()Landroidx/lifecycle/ViewModelStore;
    move-result-object v0
    new-instance v1, Landroidx/lifecycle/ViewModelProvider;
    invoke-direct {v1, v0}, Landroidx/lifecycle/ViewModelProvider;-><init>(Landroidx/lifecycle/ViewModelStoreOwner;)V
    const-class v2, LDataViewModel;
    invoke-virtual {v1, v2}, Landroidx/lifecycle/ViewModelProvider;->get(Ljava/lang/Class;)Landroidx/lifecycle/ViewModel;
    move-result-object v1
    check-cast v1, LDataViewModel;
    iput-object v1, p0, com/example/app/activity/MainActivity->mViewModel:Landroidx/lifecycle/ViewModel;
    invoke-virtual {v1}, LDataViewModel;->getLiveData()Landroidx/lifecycle/LiveData;
    move-result-object v2
    new-instance v3, com/example/app/activity/MainActivity$2;
    invoke-direct {v3, p0}, com/example/app/activity/MainActivity$2;-><init>(Lcom/example/app/activity/MainActivity;)V
    invoke-virtual {v2, p0, v3}, Landroidx/lifecycle/LiveData;->observe(Landroidx/lifecycle/LifecycleOwner;Landroidx/lifecycle/Observer;)V
    return-void
.end method

.method private refreshData()V
    .registers 4
    invoke-direct {p0}, com/example/app/activity/MainActivity->getNetworkInfo()Landroid/net/NetworkInfo;
    move-result-object v0
    if-eqz v0, :cond_12
    invoke-virtual {v0}, Landroid/net/NetworkInfo;->isConnected()Z
    move-result v1
    if-nez v1, :cond_12
    const-string v1, "网络不可用"
    invoke-direct {p0, v1}, com/example/app/activity/MainActivity->showError(Ljava/lang/String;)V
    return-void
    :cond_12
    invoke-direct {p0}, com/example/app/activity/MainActivity->loadData()V
    return-void
.end method

.method private getNetworkInfo()Landroid/net/NetworkInfo;
    .registers 4
    invoke-virtual {p0}, com/example/app/activity/MainActivity->getApplicationContext()Landroid/content/Context;
    move-result-object v0
    const-string v1, "connectivity"
    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/net/ConnectivityManager;
    invoke-virtual {v0}, Landroid/net/ConnectivityManager;->getActiveNetworkInfo()Landroid/net/NetworkInfo;
    move-result-object v1
    return-object v1
.end method

.method private showError(Ljava/lang/String;)V
    .registers 4
    new-instance v0, Landroid/widget/Toast;
    invoke-virtual {p0}, com/example/app/activity/MainActivity->getApplicationContext()Landroid/content/Context;
    move-result-object v1
    invoke-direct {v0, v1}, Landroid/widget/Toast;-><init>(Landroid/content/Context;)V
    invoke-virtual {v0, p1}, Landroid/widget/Toast;->setText(Ljava/lang/CharSequence;)V
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/widget/Toast;->setDuration(I)V
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V
    return-void
.end method

.method private cleanupResources()V
    .registers 3
    const/4 v0, 0x0
    iput-object v0, p0, com/example/app/activity/MainActivity->mAdapter:Landroid/widget/BaseAdapter;
    iput-object v0, p0, com/example/app/activity/MainActivity->mHandler:Landroid/os/Handler;
    iput-object v0, p0, com/example/app/activity/MainActivity->mContext:Landroid/content/Context;
    return-void
.end method

.method public onBackPressed()V
    .registers 4
    invoke-virtual {p0}, com/example/app/activity/MainActivity->getSupportFragmentManager()Landroidx/fragment/app/FragmentManager;
    move-result-object v0
    invoke-virtual {v0}, Landroidx/fragment/app/FragmentManager;->getBackStackEntryCount()I
    move-result v1
    if-lez v1, :cond_f
    invoke-virtual {v0}, Landroidx/fragment/app/FragmentManager;->popBackStack()V
    return-void
    :cond_f
    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V
    return-void
.end method
