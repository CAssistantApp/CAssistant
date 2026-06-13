.class public com/example/app/model/PageInfo;
.super Ljava/lang/Object;
.source "PageInfo.java"

.field public currentPage:I
.field public pageSize:I
.field public totalItems:I
.field public totalPages:I
.field public hasMore:Z

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method


.method public getCurrentPage()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/PageInfo;->currentPage:I
    return-object v0
.end method

.method public setCurrentPage(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/PageInfo;->currentPage:I
    return-void
.end method

.method public getPageSize()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/PageInfo;->pageSize:I
    return-object v0
.end method

.method public setPageSize(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/PageInfo;->pageSize:I
    return-void
.end method

.method public getTotalItems()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/PageInfo;->totalItems:I
    return-object v0
.end method

.method public setTotalItems(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/PageInfo;->totalItems:I
    return-void
.end method

.method public getTotalPages()I
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/PageInfo;->totalPages:I
    return-object v0
.end method

.method public setTotalPages(I)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/PageInfo;->totalPages:I
    return-void
.end method

.method public getHasMore()Z
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/PageInfo;->hasMore:Z
    return-object v0
.end method

.method public setHasMore(Z)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/model/PageInfo;->hasMore:Z
    return-void
.end method
