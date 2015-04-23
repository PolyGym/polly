; RUN: opt %loadPolly -polly-detect-unprofitable -polly-use-runtime-alias-checks=false -pass-remarks-missed="polly-detect" -polly-detect-track-failures -polly-detect -analyze < %s 2>&1| FileCheck %s

;void f(int A[], int B[]) {
;  for (int i=0; i<42; i++)
;    A[i] = B[i];
;}

; CHECK: remark: ReportAlias-01.c:2:8: The following errors keep this region from being a Scop.
; CHECK: remark: ReportAlias-01.c:3:5: Accesses to the arrays "B", "A" may access the same memory.
; CHECK: remark: ReportAlias-01.c:3:5: Invalid Scop candidate ends here.

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define void @f(i32* %A, i32* %B) {
entry:
  br label %entry.split

entry.split:                                      ; preds = %entry
  tail call void @llvm.dbg.value(metadata i32* %A, i64 0, metadata !13, metadata !MDExpression()), !dbg !14
  tail call void @llvm.dbg.value(metadata i32* %B, i64 0, metadata !15, metadata !MDExpression()), !dbg !16
  tail call void @llvm.dbg.value(metadata i32 0, i64 0, metadata !18, metadata !MDExpression()), !dbg !20
  br label %for.body, !dbg !21

for.body:                                         ; preds = %entry.split, %for.body
  %indvar = phi i64 [ 0, %entry.split ], [ %indvar.next, %for.body ]
  %arrayidx = getelementptr i32, i32* %B, i64 %indvar, !dbg !22
  %arrayidx2 = getelementptr i32, i32* %A, i64 %indvar, !dbg !22
  %0 = load i32, i32* %arrayidx, align 4, !dbg !22
  store i32 %0, i32* %arrayidx2, align 4, !dbg !22
  tail call void @llvm.dbg.value(metadata !{null}, i64 0, metadata !18, metadata !MDExpression()), !dbg !20
  %indvar.next = add i64 %indvar, 1, !dbg !21
  %exitcond = icmp ne i64 %indvar.next, 42, !dbg !21
  br i1 %exitcond, label %for.body, label %for.end, !dbg !21

for.end:                                          ; preds = %for.body
  ret void, !dbg !23
}

declare void @llvm.dbg.declare(metadata, metadata, metadata)
declare void @llvm.dbg.value(metadata, i64, metadata, metadata)

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!10, !11}
!llvm.ident = !{!12}

!0 = !MDCompileUnit(language: DW_LANG_C99, producer: "clang version 3.6.0 ", isOptimized: false, emissionKind: 1, file: !1, enums: !2, retainedTypes: !2, subprograms: !3, globals: !2, imports: !2)
!1 = !MDFile(filename: "ReportAlias-01.c", directory: "test/ScopDetectionDiagnostic/")
!2 = !{}
!3 = !{!4}
!4 = !MDSubprogram(name: "f", line: 1, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 1, file: !1, scope: !5, type: !6, function: void (i32*, i32*)* @f, variables: !2)
!5 = !MDFile(filename: "ReportAlias-01.c", directory: "test/ScopDetectionDiagnostic/")
!6 = !MDSubroutineType(types: !7)
!7 = !{null, !8, !8}
!8 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !9)
!9 = !MDBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!10 = !{i32 2, !"Dwarf Version", i32 4}
!11 = !{i32 2, !"Debug Info Version", i32 3}
!12 = !{!"clang version 3.6.0 "}
!13 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "A", line: 1, arg: 1, scope: !4, file: !5, type: !8)
!14 = !MDLocation(line: 1, column: 12, scope: !4)
!15 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "B", line: 1, arg: 2, scope: !4, file: !5, type: !8)
!16 = !MDLocation(line: 1, column: 21, scope: !4)
!17 = !{i32 0}
!18 = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "i", line: 2, scope: !19, file: !5, type: !9)
!19 = distinct !MDLexicalBlock(line: 2, column: 3, file: !1, scope: !4)
!20 = !MDLocation(line: 2, column: 12, scope: !19)
!21 = !MDLocation(line: 2, column: 8, scope: !19)
!22 = !MDLocation(line: 3, column: 5, scope: !19)
!23 = !MDLocation(line: 4, column: 1, scope: !4)
