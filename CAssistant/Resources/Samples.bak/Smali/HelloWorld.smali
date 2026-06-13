.class public LHelloWorld;
.super Ljava/lang/Object;
.source "HelloWorld.java"

# direct methods
.method public constructor <init>()V
    .registers 1

    .prologue
    .line 3
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

# virtual methods
.method public static main([Ljava/lang/String;)V
    .registers 3

    .prologue
    .line 6
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;

    const-string v1, "Hello, World!"

    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V

    .line 7
    return-void
.end method

.method public getGreeting()Ljava/lang/String;
    .registers 2

    .prologue
    .line 10
    const-string v0, "Hello from CAssistant!"

    return-object v0
.end method
