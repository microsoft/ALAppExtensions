// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.NoSeries;
using System.Utilities;

codeunit 31237 "FA History Management CZF"
{
    Permissions = tabledata "Fixed Asset" = m,
                  tabledata "FA History Entry CZF" = im;

    var
        FASetup: Record "FA Setup";
        FADepreciationBook: Record "FA Depreciation Book";
        NoSeriesManagement: Codeunit NoSeriesManagement;

    procedure CreateFAHistoryEntry(FAHistoryTypeCZF: Enum "FA History Type CZF"; var FixedAsset: Record "Fixed Asset"; var xFixedAsset: Record "Fixed Asset")
    var
        CreateFAHistoryCZF: Page "Create FA History CZF";
        OldValue, NewValue : Code[20];
        IsHandled: Boolean;
        PostingDate: Date;
        DocumentNo: Code[20];
        FADisposedErr: Label 'Selected Fixed Asset %1 is disposed and FA Location/Responsible Employee cannot be assigned to it.', Comment = '%1 = Fixed Asset No.';
    begin
        IsHandled := false;
        OnBeforeInsertFAHistoryEntry(FixedAsset, xFixedAsset, FAHistoryTypeCZF, IsHandled);
        if IsHandled then
            exit;

        if FixedAsset.Inactive then
            Error(FADisposedErr, FixedAsset."No.");
        FASetup.Get();
        FASetup.TestField("Default Depr. Book");
        FADepreciationBook.SetRange("FA No.", FixedAsset."No.");
        FADepreciationBook.SetRange("Depreciation Book Code", FASetup."Default Depr. Book");
        if FADepreciationBook.FindLast() then
            if FADepreciationBook."Disposal Date" > 0D then
                Error(FADisposedErr, FixedAsset."No.");

        if GuiAllowed() then begin
            OnBeforeShowInsertFAHistoryPage(PostingDate, DocumentNo);
            if (PostingDate = 0D) or (DocumentNo = '') then begin
                FASetup.TestField("Fixed Asset History Nos. CZF");
                CreateFAHistoryCZF.SetValues(WorkDate(), NoSeriesManagement.GetNextNo(FASetup."Fixed Asset History Nos. CZF", WorkDate(), true));
                Commit();
                if CreateFAHistoryCZF.RunModal() = Action::OK then begin
                    CreateFAHistoryCZF.GetValues(PostingDate, DocumentNo);
                    case FAHistoryTypeCZF of
                        FAHistoryTypeCZF::"FA Location":
                            begin
                                OldValue := xFixedAsset."FA Location Code";
                                NewValue := FixedAsset."FA Location Code";
                            end;
                        FAHistoryTypeCZF::"Responsible Employee":
                            begin
                                OldValue := xFixedAsset."Responsible Employee";
                                NewValue := FixedAsset."Responsible Employee";
                            end;
                    end;
                    PrintAssignmentAndDiscard(InsertEntry(FAHistoryTypeCZF, FixedAsset."No.", OldValue, NewValue, 0, false, PostingDate, DocumentNo));
                end else
                    case FAHistoryTypeCZF of
                        FAHistoryTypeCZF::"FA Location":
                            FixedAsset."FA Location Code" := xFixedAsset."FA Location Code";
                        FAHistoryTypeCZF::"Responsible Employee":
                            FixedAsset."Responsible Employee" := xFixedAsset."Responsible Employee";
                    end;
            end;
        end;
    end;

    procedure InsertFAHistoryEntry(FAHistoryTypeCZF: Enum "FA History Type CZF"; FANo: Code[20]; PostingDate: Date; DocumentNo: Code[20])
    var
        FixedAsset: Record "Fixed Asset";
        OldValue: Code[20];
    begin
        FixedAsset.Get(FANo);
        case FAHistoryTypeCZF of
            FAHistoryTypeCZF::"FA Location":
                begin
                    OldValue := FixedAsset."FA Location Code";
                    FixedAsset."FA Location Code" := '';
                end;
            FAHistoryTypeCZF::"Responsible Employee":
                begin
                    OldValue := FixedAsset."Responsible Employee";
                    FixedAsset."Responsible Employee" := '';
                end;
        end;
        FixedAsset.Modify();
        InsertEntry(FAHistoryTypeCZF, FANo, OldValue, '', 0, true, PostingDate, DocumentNo);
    end;

    procedure UpdateFAHistoryEntry(FAHistoryTypeCZF: Enum "FA History Type CZF"; FANo: Code[20]; PostingDate: Date; DocumentNo: Code[20])
    var
        FixedAsset: Record "Fixed Asset";
        FAHistoryEntryCZF: Record "FA History Entry CZF";
    begin
        FAHistoryEntryCZF.Reset();
        FAHistoryEntryCZF.SetRange(Disposal, true);
        FAHistoryEntryCZF.SetRange("FA No.", FANo);
        FAHistoryEntryCZF.SetRange("Closed by Entry No.", 0);
        FAHistoryEntryCZF.SetRange(Type, FAHistoryTypeCZF);
        if not FAHistoryEntryCZF.FindLast() then
            exit;

        FixedAsset.Get(FANo);
        case FAHistoryTypeCZF of
            FAHistoryTypeCZF::"FA Location":
                FixedAsset."FA Location Code" := CopyStr(FAHistoryEntryCZF."Old Value", 1, MaxStrLen(FixedAsset."FA Location Code"));
            FAHistoryTypeCZF::"Responsible Employee":
                FixedAsset."Responsible Employee" := FAHistoryEntryCZF."Old Value";
        end;
        FAHistoryEntryCZF."Closed by Entry No." := InsertEntry(FAHistoryTypeCZF, FANo, '', FAHistoryEntryCZF."Old Value", 0, false, PostingDate, DocumentNo);
        FAHistoryEntryCZF.Modify();
        FixedAsset.Modify();
    end;

    local procedure InsertEntry(FAHistoryTypeCZF: Enum "FA History Type CZF"; FANo: Code[20]; OldValue: Code[20]; NewValue: Code[20]; ClosedByEntryNo: Integer; Disp: Boolean; PostingDate: Date; DocumentNo: Code[20]): Integer
    var
        FAHistoryEntryCZF: Record "FA History Entry CZF";
    begin
        FAHistoryEntryCZF.Init();
        FAHistoryEntryCZF.Type := FAHistoryTypeCZF;
        FAHistoryEntryCZF."FA No." := FANo;
        FAHistoryEntryCZF."Old Value" := OldValue;
        FAHistoryEntryCZF."New Value" := NewValue;
        FAHistoryEntryCZF."Posting Date" := PostingDate;
        FAHistoryEntryCZF."Document No." := DocumentNo;
        FAHistoryEntryCZF."Closed by Entry No." := ClosedByEntryNo;
        FAHistoryEntryCZF.Disposal := Disp;

        OnBeforeFAHistoryEntryInsert(FAHistoryEntryCZF);
        FAHistoryEntryCZF.Insert(true);
        exit(FAHistoryEntryCZF."Entry No.");
    end;

    procedure InitializeFAHistory(FixedAsset: Record "Fixed Asset"; PostingDate: Date; DocumentNo: Code[20])
    var
        FAHistoryEntryCZF: Record "FA History Entry CZF";
        Disposed: Boolean;
    begin
        if (FixedAsset."FA Location Code" = '') and (FixedAsset."Responsible Employee" = '') then
            exit;
        FAHistoryEntryCZF.SetCurrentKey("FA No.");
        FAHistoryEntryCZF.SetRange("FA No.", FixedAsset."No.");
        if not FAHistoryEntryCZF.IsEmpty() then
            exit;

        FASetup.Get();
        FASetup.TestField("Default Depr. Book");
        FADepreciationBook.SetRange("FA No.", FixedAsset."No.");
        FADepreciationBook.SetRange("Depreciation Book Code", FASetup."Default Depr. Book");
        if FADepreciationBook.FindLast() then
            Disposed := FADepreciationBook."Disposal Date" > 0D;

        if FixedAsset."FA Location Code" <> '' then
            InsertEntry(FAHistoryEntryCZF.Type::"FA Location", FixedAsset."No.", '', FixedAsset."FA Location Code", 0, Disposed, PostingDate, DocumentNo);
        if FixedAsset."Responsible Employee" <> '' then
            InsertEntry(FAHistoryEntryCZF.Type::"Responsible Employee", FixedAsset."No.", '', FixedAsset."Responsible Employee", 0, Disposed, PostingDate, DocumentNo);
    end;

    local procedure PrintAssignmentAndDiscard(FAHistoryEntryNo: Integer)
    var
        FAHistoryEntryCZF: Record "FA History Entry CZF";
        ConfirmManagement: Codeunit "Confirm Management";
        PrintAssignmentDiscardReportQst: Label 'Do you want to print FA Assignment/Discard report?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(PrintAssignmentDiscardReportQst, true) then
            exit;
        FAHistoryEntryCZF.Get(FAHistoryEntryNo);
        FAHistoryEntryCZF.SetRecFilter();
        Report.Run(Report::"FA Assignment/Discard CZF", false, false, FAHistoryEntryCZF);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFAHistoryEntryInsert(var FAHistoryEntryCZF: Record "FA History Entry CZF")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertFAHistoryEntry(var FixedAsset: Record "Fixed Asset"; var xFixedAsset: Record "Fixed Asset"; FAHistoryTypeCZF: Enum "FA History Type CZF"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowInsertFAHistoryPage(var PostingDate: Date; var DocumentNo: Code[20])
    begin
    end;
}
