.class public com/example/app/manager/PermissionManager;
.super Ljava/lang/Object;
.source "PermissionManager.java"

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static isEmpty(Ljava/lang/String;)Z
    .registers 2
    if-eqz p0, :cond_c
    invoke-virtual {p0}, Ljava/lang/String;->length()I
    move-result v0
    if-nez v0, :cond_a
    goto :goto_c
    :cond_a
    const/4 v0, 0x0
    return v0
    :cond_c
    const/4 v0, 0x1
    return v0
.end method

.method public static md5(Ljava/lang/String;)Ljava/lang/String;
    .registers 8
    :try_start_0
    const-string v0, "MD5"
    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;
    move-result-object v0
    invoke-virtual {p0}, Ljava/lang/String;->getBytes()[B
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/security/MessageDigest;->digest([B)[B
    move-result-object v1
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    array-length v3, v1
    const/4 v4, 0x0
    :goto_11
    if-ge v4, v3, :cond_27
    aget-byte v5, v1, v4
    const-string v6, "%02x"
    const/4 v7, 0x1
    new-array v7, v7, [Ljava/lang/Object;
    invoke-static {v5}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;
    move-result-object v5
    const/4 v8, 0x0
    aput-object v5, v7, v8
    invoke-static {v6, v7}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v2, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    add-int/lit8 v4, v4, 0x1
    goto :goto_11
    :cond_27
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    :try_end_2b
    .catch Ljava/security/NoSuchAlgorithmException; {:try_end_0 .. :try_end_2b} :catch_2c
    return-object v0
    :catch_2c
    move-exception v0
    invoke-virtual {v0}, Ljava/security/NoSuchAlgorithmException;->printStackTrace()V
    const/4 v0, 0x0
    return-object v0
.end method

.method public static base64Encode([B)Ljava/lang/String;
    .registers 2
    invoke-static {p0}, Ljava/util/Base64;->getEncoder()Ljava/util/Base64$Encoder;
    move-result-object v0
    invoke-virtual {v0, p0}, Ljava/util/Base64$Encoder;->encodeToString([B)Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method public static base64Decode(Ljava/lang/String;)[B
    .registers 2
    invoke-static {p0}, Ljava/util/Base64;->getDecoder()Ljava/util/Base64$Decoder;
    move-result-object v0
    invoke-virtual {v0, p0}, Ljava/util/Base64$Decoder;->decode(Ljava/lang/String;)[B
    move-result-object v0
    return-object v0
.end method

.method public static formatTimestamp(J)Ljava/lang/String;
    .registers 6
    new-instance v0, Ljava/text/SimpleDateFormat;
    const-string v1, "yyyy-MM-dd HH:mm:ss"
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;
    move-result-object v2
    invoke-direct {v0, v1, v2}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;Ljava/util/Locale;)V
    const-wide/16 v1, 0x3e8
    mul-long/2addr v1, p0
    new-instance v3, Ljava/util/Date;
    invoke-direct {v3, v1, v2}, Ljava/util/Date;-><init>(J)V
    invoke-virtual {v0, v3}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;
    move-result-object v1
    return-object v1
.end method

.method public static parseJsonToMap(Ljava/lang/String;)Ljava/util/Map;
    .registers 5
    :try_start_0
    new-instance v0, Lorg/json/JSONObject;
    invoke-direct {v0, p0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
    new-instance v1, Ljava/util/HashMap;
    invoke-direct {v1}, Ljava/util/HashMap;-><init>()V
    invoke-virtual {v0}, Lorg/json/JSONObject;->keys()Ljava/util/Iterator;
    move-result-object v2
    :goto_b
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z
    move-result v3
    if-eqz v3, :cond_1f
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Ljava/lang/String;
    invoke-virtual {v0, v3}, Lorg/json/JSONObject;->get(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v4
    invoke-virtual {v1, v3, v4}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    goto :goto_b
    :cond_1f
    :try_end_1f
    .catch Lorg/json/JSONException; {:try_start_0 .. :try_end_1f} :catch_20
    return-object v1
    :catch_20
    move-exception v1
    invoke-virtual {v1}, Lorg/json/JSONException;->printStackTrace()V
    const/4 v1, 0x0
    return-object v1
.end method
