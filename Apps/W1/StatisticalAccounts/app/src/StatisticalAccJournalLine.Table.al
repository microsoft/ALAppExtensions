namespace Microsoft.Finance.Analysis.StatisticalAccount;

using Microsoft.Finance.Dimension;
using Microsoft.Foundation.AuditCodes;

table 2631 "Statistical Acc. Journal Line"
{
    Caption = 'Statistical Account Journal';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            Editable = false;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal batch name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(10; "Statistical Account No."; Code[20])
        {
            Caption = 'Statistical Account No.';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account";

            trigger OnValidate()
            var
                StatisticalAccount: Record "Statistical Account";
            begin
                if Rec."Statistical Account No." = '' then
                    exit;

                StatisticalAccount.Get("Statistical Account No.");
                if StatisticalAccount.Blocked then
                    Error(StatisticalAccountIsBlockedErr, Rec."Statistical Account No.", Rec."Line No.");

                AssignDefaultDimensions();
            end;
        }
        field(11; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            ClosingDates = true;
            DataClassification = CustomerContent;
        }
        field(12; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(13; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
#pragma warning disable AA0232
        field(14; "Amount Change"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Statistical Acc. Journal Line".Amount where("Journal Template Name" = field("Journal Template Name"),
                                                                   "Journal Batch Name" = field("Journal Batch Name"),
                                                                   "Statistical Account No." = field("Statistical Account No.")));
            Caption = 'Allocated Amt. (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning restore AA0232
        field(24; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(25; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(50; "Statistical Account Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Statistical Account".Name where("No." = field("Statistical Account No.")));
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            var
                DimensionManagement: Codeunit DimensionManagement;
            begin
                DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Journal Template Name", "Journal Batch Name", "Statistical Account No.")
        {
            SumIndexFields = Amount;
        }
    }

    local procedure AssignDefaultDimensions()
    var
        DefaultDimensionSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimensionSource);
        CreateDimensions(DefaultDimensionSource);
    end;

    local procedure CreateDimensions(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        SourceCodeSetup: Record "Source Code Setup";
        DimensionManagement: Codeunit DimensionManagement;
        OldDimSetID: Integer;
    begin
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        OldDimSetID := "Dimension Set ID";

        "Dimension Set ID" :=
          DimensionManagement.GetRecDefaultDimID(
            Rec, CurrFieldNo, DefaultDimSource, SourceCodeSetup.GetSourceCodeSetupSafe(), "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);

        OnAfterCreateDimensions(Rec, xRec, CurrFieldNo, OldDimSetID, DefaultDimSource);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimensionSource: List of [Dictionary of [Integer, Code[20]]])
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.AddDimSource(DefaultDimensionSource, Database::"Statistical Account", Rec."Statistical Account No.");
    end;

    internal procedure LookupBatchName(var JournalBatchName: Code[10]; var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line")
    var
        StatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
    begin
        Commit();
        if PAGE.RunModal(PAGE::"Statistical Acc. Journal Batch", StatisticalAccJournalBatch) = ACTION::LookupOK then begin
            JournalBatchName := StatisticalAccJournalBatch.Name;
            SetName(JournalBatchName, StatisticalAccJournalLine);
        end;
    end;

    internal procedure SetName(JournalBatchName: Code[10]; var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line")
    begin
        StatisticalAccJournalLine.FilterGroup := 2;
        StatisticalAccJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        StatisticalAccJournalLine.FilterGroup := 0;
        if StatisticalAccJournalLine.FindFirst() then;
    end;

    internal procedure CheckName(JournalBatchName: Code[10]): Boolean
    var
        StatisticalAccJnlBatch: Record "Statistical Acc. Journal Batch";
    begin
        StatisticalAccJnlBatch.SetRange(Name, JournalBatchName);
        exit(not StatisticalAccJnlBatch.IsEmpty());
    end;

    internal procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    internal procedure ShowDimensions()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        "Dimension Set ID" :=
          DimensionManagement.EditDimensionSet(
            Rec, "Dimension Set ID", StrSubstNo(DimensionSetLabelTxt, "Journal Batch Name", "Line No.", "Statistical Account No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    internal procedure SelectJournal(var JournalBatchName: Code[10])
    var
        DefaultStatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
        JnlBatchNameIdentified: Boolean;
    begin
        if JournalBatchName <> '' then
            JnlBatchNameIdentified := Rec.CheckName(JournalBatchName);

        if not JnlBatchNameIdentified then begin
            if not DefaultStatisticalAccJournalBatch.FindFirst() then begin
                DefaultStatisticalAccJournalBatch.CreateDefaultBatch();
                DefaultStatisticalAccJournalBatch.FindFirst();
            end;
            JournalBatchName := DefaultStatisticalAccJournalBatch.Name;
        end;
        Rec.FilterGroup := 2;
        Rec.SetRange("Journal Batch Name", JournalBatchName);
        Rec.FilterGroup := 0;
    end;

    internal procedure SetUpNewLine(PreviousStatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; JournalBatchName: Code[10])
    var
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        StatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
    begin
        Rec."Journal Batch Name" := JournalBatchName;
        StatisticalAccJournalBatch.SetRange(Name, JournalBatchName);
        StatisticalAccJournalBatch.FindFirst();
        if StatisticalAccJournalBatch."Statistical Account No." <> '' then
            Rec.Validate("Statistical Account No.", StatisticalAccJournalBatch."Statistical Account No.");

        StatisticalAccJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if not StatisticalAccJournalLine.IsEmpty() then begin
            "Posting Date" := PreviousStatisticalAccJournalLine."Posting Date";
            "Document No." := PreviousStatisticalAccJournalLine."Document No.";
        end else
            "Posting Date" := WorkDate();
    end;

    internal procedure GetBalance(StatisticalAccountJournalLine: Record "Statistical Acc. Journal Line"; var BalanceAfterPosting: Decimal; var Balance: Decimal)
    var
        StatisticalAccount: Record "Statistical Account";
        ExistingAccJournalLine: Record "Statistical Acc. Journal Line";
    begin
        Clear(Balance);
        Clear(BalanceAfterPosting);

        StatisticalAccount.SetAutoCalcFields(Balance);
        if StatisticalAccount.Get(StatisticalAccountJournalLine."Statistical Account No.") then begin
            Balance := StatisticalAccount.Balance;
            ExistingAccJournalLine.Copy(StatisticalAccountJournalLine);
            ExistingAccJournalLine.SetRange("Statistical Account No.", StatisticalAccount."No.");
            ExistingAccJournalLine.SetAutoCalcFields("Amount Change");
            if ExistingAccJournalLine.FindFirst() then
                BalanceAfterPosting := StatisticalAccount.Balance + ExistingAccJournalLine."Amount Change"
            else
                BalanceAfterPosting := StatisticalAccount.Balance;
        end;
    end;

    internal procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.GetShortcutDimensions(Rec."Dimension Set ID", ShortcutDimCode);
    end;

    var
        DimensionSetLabelTxt: Label '%1 %2 %3', Locked = true;
        StatisticalAccountIsBlockedErr: Label 'Statistical account %1 is blocked. Journal line %2.', Comment = '%1 number of statistical account. %2 number of journal line';

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDimensions(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; xStatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; CurrentFieldNo: Integer; OldDimSetID: Integer; DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;
}