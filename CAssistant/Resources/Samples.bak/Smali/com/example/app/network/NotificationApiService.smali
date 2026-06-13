.class public interface abstract Lcom/example/app/network/NotificationApiService;
.super Ljava/lang/Object;
.source "NotificationApiService.java"
.annotation runtime Lretrofit2/http/FormUrlEncoded;
.end annotation

.method public abstract login(Lretrofit2/http/FieldMap;Ljava/util/Map;)Lretrofit2/Call;
    .param p1
        .annotation runtime Lretrofit2/http/Field;
            value = "username"
        .end annotation
    .end param
    .param p2
        .annotation runtime Lretrofit2/http/Field;
            value = "password"
        .end annotation
    .end param
    .annotation runtime Lretrofit2/http/POST;
        value = "/api/v2/auth/login"
    .end annotation
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ")",
            "Lretrofit2/Call",
            "<",
            "Lretrofit2/Response",
            "<",
            "Lcom/google/gson/JsonObject;",
            ">;>;"
        }
    .end annotation
.end method

.method public abstract getData(Lretrofit2/http/HeaderMap;Ljava/util/Map;Lretrofit2/http/QueryMap;Ljava/util/Map;)Lretrofit2/Call;
    .param p1
        .annotation runtime Lretrofit2/http/Header;
            value = "Authorization"
        .end annotation
    .end param
    .param p3
        .annotation runtime Lretrofit2/http/Query;
            value = "page"
        .end annotation
    .end param
    .annotation runtime Lretrofit2/http/GET;
        value = "/api/v2/data/list"
    .end annotation
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Ljava/util/Map;",
            ")",
            "Lretrofit2/Call",
            "<",
            "Lcom/google/gson/JsonObject;",
            ">;"
        }
    .end annotation
.end method

.method public abstract uploadFile(Lretrofit2/http/Multipart;Lokhttp3/MultipartBody$Part;)Lretrofit2/Call;
    .annotation runtime Lretrofit2/http/Multipart;
    .end annotation
    .annotation runtime Lretrofit2/http/POST;
        value = "/api/v2/upload"
    .end annotation
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lokhttp3/MultipartBody$Part;",
            ")",
            "Lretrofit2/Call",
            "<",
            "Lcom/google/gson/JsonObject;",
            ">;"
        }
    .end annotation
.end method

.method public abstract downloadFile(Lretrofit2/http/Streaming;Lretrofit2/http/Url;Ljava/lang/String;)Lretrofit2/Call;
    .annotation runtime Lretrofit2/http/Streaming;
    .end annotation
    .annotation runtime Lretrofit2/http/GET;
    .end annotation
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            ")",
            "Lretrofit2/Call",
            "<",
            "Lokhttp3/ResponseBody;",
            ">;"
        }
    .end annotation
.end method
