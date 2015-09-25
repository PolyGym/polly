; RUN: opt %loadPolly -polly-detect-unprofitable -polly-scops -analyze -polly-delinearize < %s | FileCheck %s
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"

; Derived from the following code:
;
; void foo(long n, long m, long p, double A[n][m]) {
;   for (long i = 0; i < 100; i++)
;     for (long j = 0; j < m; j++)
;       A[i+p][j] = 1.0;
; }

; CHECK:  Assumed Context:
; CHECK:  [m, p] -> {  : p <= 9223372036854775708 }
; CHECK:  p0: %m
; CHECK:  p1: %p
; CHECK:  Statements {
; CHECK:    Stmt_for_j
; CHECK:          Domain :=
; CHECK:              [m, p] -> { Stmt_for_j[i0, i1] :
; CHECK-DAG:             i0 >= 0
; CHECK-DAG:          and
; CHECK-DAG:             i0 <= 99
; CHECK-DAG:          and
; CHECK-DAG:             i1 >= 0
; CHECK-DAG:          and
; CHECK-DAG:             i1 <= -1 + m
; CHECK:              }
; CHECK:          Schedule :=
; CHECK:              [m, p] -> { Stmt_for_j[i0, i1] -> [i0, i1] };
; CHECK:          MustWriteAccess := [Reduction Type: NONE]
; CHECK:              [m, p] -> { Stmt_for_j[i0, i1] -> MemRef_A[p + i0, i1] };
; CHECK:  }

define void @foo(i64 %n, i64 %m, i64 %p, double* %A) {
entry:
  br label %for.i

for.i:
  %i = phi i64 [ 0, %entry ], [ %i.inc, %for.i.inc ]
  %add = add nsw i64 %i, %p
  %tmp = mul nsw i64 %add, %m
  br label %for.j

for.j:
  %j = phi i64 [ 0, %for.i ], [ %j.inc, %for.j ]
  %vlaarrayidx.sum = add i64 %j, %tmp
  %arrayidx = getelementptr inbounds double, double* %A, i64 %vlaarrayidx.sum
  store double 1.0, double* %arrayidx
  %j.inc = add nsw i64 %j, 1
  %j.exitcond = icmp eq i64 %j.inc, %m
  br i1 %j.exitcond, label %for.i.inc, label %for.j

for.i.inc:
  %i.inc = add nsw i64 %i, 1
  %i.exitcond = icmp eq i64 %i.inc, 100
  br i1 %i.exitcond, label %end, label %for.i

end:
  ret void
}
