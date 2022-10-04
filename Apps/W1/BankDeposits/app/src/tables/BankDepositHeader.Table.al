table 1690 "Bank Deposit Header"
{
    Caption = 'Bank Deposit Header';
    DataCaptionFields = "No.";
    LookupPageID = "Bank Deposit List";
    Permissions = tabledata "Bank Deposit Header" = rm;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    SalesReceivablesSetup.Get();
                    NoSeriesManagement.TestManual(SalesReceivablesSetup."Bank Deposit Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = "Bank Account";

            trigger OnValidate()
            var
                DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
            begin
                BankAccount.Get("Bank Account No.");
                GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
                GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
                GenJournalLine.ModifyAll("Bal. Account No.", "Bank Account No.", true);

                Validate("Currency Code", BankAccount."Currency Code");
                "Bank Acc. Posting Group" := BankAccount."Bank Acc. Posting Group";
                "Language Code" := BankAccount."Language Code";

                DimensionManagement.AddDimSource(DefaultDimSource, Database::"Bank Account", "Bank Account No.");
                CreateDim(DefaultDimSource);
            end;
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;

            trigger OnValidate()
            var
                LocalGenJournalLine: Record "Gen. Journal Line";
            begin
                UpdateCurrencyFactor();
                if "Currency Code" <> xRec."Currency Code" then begin
                    LocalGenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
                    LocalGenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
                    if LocalGenJournalLine.FindSet(true) then
                        repeat
                            LocalGenJournalLine.Validate("Currency Code", "Currency Code");
                            LocalGenJournalLine.Modify(true);
                        until LocalGenJournalLine.Next() = 0;
                end;
            end;
        }
        field(4; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate()
            var
                LocalGenJournalLine: Record "Gen. Journal Line";
                OrigDocumentDate: Date;
            begin
                TestField("Posting Date");
                UpdateCurrencyFactor();
                if "Document Date" = 0D then
                    "Document Date" := "Posting Date";
                LocalGenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
                LocalGenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
                if LocalGenJournalLine.FindSet(true) then
                    repeat
                        OrigDocumentDate := LocalGenJournalLine."Document Date";
                        LocalGenJournalLine.Validate("Posting Date", "Posting Date");
                        LocalGenJournalLine."Document Date" := OrigDocumentDate;
                        LocalGenJournalLine.Modify(true);
                    until LocalGenJournalLine.Next() = 0;
            end;
        }
        field(6; "Total Deposit Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Total Deposit Amount';
        }
        field(7; "Document Date"; Date)
        {
            Caption = 'Document Date';

            trigger OnValidate()
            begin
                if "Posting Date" = 0D then
                    Validate("Posting Date", "Document Date");
            end;
        }
        field(8; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
                Modify();
            end;
        }
        field(9; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
                Modify();
            end;
        }
        field(10; "Bank Acc. Posting Group"; Code[20])
        {
            Caption = 'Bank Acc. Posting Group';
            TableRelation = "Bank Account Posting Group";
        }
        field(11; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(12; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            Editable = false;
        }
        field(13; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(14; Correction; Boolean)
        {
            Caption = 'Correction';
        }
        field(15; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(16; "Posting Description"; Text[100])
        {
            Caption = 'Posting Description';
        }
        field(17; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            Editable = false;
            TableRelation = "Gen. Journal Template";
        }
        field(18; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            Editable = false;
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(21; Comment; Boolean)
        {
            CalcFormula = Exist("Bank Acc. Comment Line" WHERE("Table Name" = CONST("Bank Deposit Header"),
                                                           "Bank Account No." = FIELD("Bank Account No."),
                                                           "No." = FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning disable AA0232
        field(22; "Total Deposit Lines"; Decimal)
#pragma warning restore
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = - Sum("Gen. Journal Line".Amount WHERE("Journal Template Name" = FIELD("Journal Template Name"),
                                                                 "Journal Batch Name" = FIELD("Journal Batch Name")));
            Caption = 'Total Deposit Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(23; "Post as Lump Sum"; Boolean)
        {
            Caption = 'Post as Lump Sum';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDocDim();
            end;

            trigger OnValidate()
            begin
                DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Bank Account No.")
        {
        }
        key(Key3; "Journal Template Name", "Journal Batch Name")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        LocalGenJournalLine: Record "Gen. Journal Line";
    begin
        LocalGenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        LocalGenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        LocalGenJournalLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        SalesReceivablesSetup.Get();
        InitInsert();
    end;

    trigger OnRename()
    begin
        Error(CannotRenameErr, TableCaption);
    end;

    var
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalBatch: Record "Gen. Journal Batch";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        DimensionManagement: Codeunit DimensionManagement;
        GenJnlManagement: Codeunit GenJnlManagement;
        PostingDescriptionTxt: Label 'Deposit %1 %2', Comment = '%1 - the caption of field No.; %2 - the value of field No.';
        OnlyOneAllowedErr: Label 'Only one %1 is allowed for each %2. Choose Change Batch action if you want to create a new bank deposit.', Comment = '%1 - bank deposit; %2 - general journal batch name';
        CannotRenameErr: Label 'You cannot rename a %1.', Comment = '%1 - bank deposit';
        UpdateDimensionsOnExistingLinesQst: Label 'Do you want to add the bank deposit dimensions to all bank deposit lines?';

    local procedure InitInsert()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnInitInsertOnBeforeInitSeries(xRec, IsHandled);
        if not IsHandled then
            if "No." = '' then begin
                TestNoSeries();
                NoSeriesManagement.InitSeries(GetNoSeriesCode(), xRec."No. Series", "Posting Date", "No.", "No. Series");
            end;

        OnInitInsertOnBeforeInitRecord(xRec);
        InitRecord();
    end;

    [Scope('OnPrem')]
    procedure InitRecord()
    var
        BatchFound: Boolean;
    begin
        BatchFound := LookupGenJournalBatchSilent("Journal Template Name", "Journal Batch Name");
        if not BatchFound then begin
            "Journal Template Name" := GetRangeMax("Journal Template Name");
            "Journal Batch Name" := GetRangeMax("Journal Batch Name");
            GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
            GenJnlManagement.LookupName("Journal Batch Name", GenJournalLine);
        end else begin
            GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
            GenJnlManagement.SetName("Journal Batch Name", GenJournalLine);
        end;
        GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        FilterGroup(2);
        SetRange("Journal Batch Name", "Journal Batch Name");
        FilterGroup(0);
        BankDepositHeader.Copy(Rec);
        BankDepositHeader.Reset();
        BankDepositHeader.SetRange("Journal Template Name", "Journal Template Name");
        BankDepositHeader.SetRange("Journal Batch Name", "Journal Batch Name");
        if BankDepositHeader.FindFirst() then
            Error(OnlyOneAllowedErr, TableCaption, GenJournalBatch.TableCaption);

        if "Posting Date" = 0D then
            Validate("Posting Date", WorkDate());
        "Posting Description" := StrSubstNo(PostingDescriptionTxt, FieldName("No."), "No.");

        GenJournalBatch.Get("Journal Template Name", "Journal Batch Name");
        if (GenJournalBatch."Bal. Account Type" = GenJournalBatch."Bal. Account Type"::"Bank Account") and
           (GenJournalBatch."Bal. Account No." <> '')
        then
            Validate("Bank Account No.", GenJournalBatch."Bal. Account No.");

        "Reason Code" := GenJournalBatch."Reason Code";
        "Post as Lump Sum" := SalesReceivablesSetup."Post Bank Deposits as Lump Sum";

        OnAfterInitRecord(Rec);
    end;

    local procedure LookupGenJournalBatchSilent(var GenJournalTemplateName: Code[10]; var GenJournalBatchName: Code[10]): Boolean
    var
        LocalBankDepositHeader: Record "Bank Deposit Header";
        LocalGenJournalTemplate: Record "Gen. Journal Template";
        LocalGenJournalBatch: Record "Gen. Journal Batch";
    begin
#pragma warning disable AA0210
        LocalGenJournalTemplate.SetRange(Type, LocalGenJournalTemplate.Type::"Bank Deposits");
#pragma warning restore
        if LocalGenJournalTemplate.Count() <> 1 then
            exit(false);

        LocalGenJournalTemplate.FindFirst();
        LocalGenJournalBatch.SetRange("Journal Template Name", LocalGenJournalTemplate.Name);
        if LocalGenJournalBatch.Count() <> 1 then
            exit(false);

        LocalGenJournalBatch.FindFirst();
        LocalBankDepositHeader.SetRange("Journal Template Name", LocalGenJournalTemplate.Name);
        LocalBankDepositHeader.SetRange("Journal Batch Name", LocalGenJournalBatch.Name);
        if not LocalBankDepositHeader.IsEmpty() then
            exit(false);

        GenJournalTemplateName := LocalGenJournalTemplate.Name;
        GenJournalBatchName := LocalGenJournalBatch.Name;
        exit(true);
    end;

    local procedure GetNoSeriesCode(): Code[20]
    var
        NoSeriesCode: Code[20];
        IsHandled: Boolean;
    begin
        SalesReceivablesSetup.Get();
        IsHandled := false;
        OnBeforeGetNoSeriesCode(Rec, SalesReceivablesSetup, NoSeriesCode, IsHandled);
        if IsHandled then
            exit;

        NoSeriesCode := SalesReceivablesSetup."Bank Deposit Nos.";
        OnAfterGetNoSeriesCode(Rec, NoSeriesCode);
        exit(NoSeriesCode);
    end;

    local procedure TestNoSeries()
    var
        IsHandled: Boolean;
    begin
        SalesReceivablesSetup.Get();
        IsHandled := false;
        OnBeforeTestNoSeries(Rec, IsHandled);
        if not IsHandled then
            SalesReceivablesSetup.TestField("Bank Deposit Nos.");

        OnAfterTestNoSeries(Rec);
    end;

    local procedure UpdateCurrencyFactor()
    var
        CurrencyDate: Date;
    begin
        if "Currency Code" <> '' then begin
            if "Posting Date" <> 0D then
                CurrencyDate := "Posting Date"
            else
                CurrencyDate := WorkDate();
            "Currency Factor" := CurrencyExchangeRate.ExchangeRate(CurrencyDate, "Currency Code");
        end else
            "Currency Factor" := 0;
    end;

    local procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimensionManagement.GetDefaultDimID(
            DefaultDimSource, SourceCodeSetup."Bank Deposit",
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    [Scope('OnPrem')]
    procedure AssistEdit(OldBankDepositHeader: Record "Bank Deposit Header"): Boolean
    var
        LocalBankDepositHeader: Record "Bank Deposit Header";
    begin
        LocalBankDepositHeader := Rec;
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Bank Deposit Nos.");
        if NoSeriesManagement.SelectSeries(SalesReceivablesSetup."Bank Deposit Nos.", OldBankDepositHeader."No. Series", LocalBankDepositHeader."No. Series") then begin
            NoSeriesManagement.SetSeries(LocalBankDepositHeader."No.");
            Rec := LocalBankDepositHeader;
            exit(true);
        end;
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure ShowDocDim()
    var
        IsHandled: Boolean;
        OldDimensionSetId: Integer;
    begin
        IsHandled := false;
        OnBeforeShowDocDim(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        OldDimensionSetId := Rec."Dimension Set ID";

        "Dimension Set ID" :=
          DimensionManagement.EditDimensionSet("Dimension Set ID", "Bank Account No." + ' ' + "No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        if OldDimensionSetId <> Rec."Dimension Set ID" then begin
            Rec.Modify();
            PropagateDimensionsToLines();
        end;

        OnAferShowDocDim(Rec);
    end;

    local procedure PropagateDimensionsToLines()
    var
        LocalGenJournalLine: Record "Gen. Journal Line";
        BankDepositPost: Codeunit "Bank Deposit-Post";
        CanUpdateLineDimension: Boolean;
    begin
        LocalGenJournalLine.Reset();
        LocalGenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        LocalGenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        if LocalGenJournalLine.FindSet() then begin
            if GuiAllowed() then
                CanUpdateLineDimension := Confirm(UpdateDimensionsOnExistingLinesQst)
            else
                CanUpdateLineDimension := true;

            if not CanUpdateLineDimension then
                exit;

            repeat
                LocalGenJournalLine.Validate("Dimension Set ID", BankDepositPost.CombineDimensionSetsHeaderPriority(Rec, LocalGenJournalLine));
                LocalGenJournalLine.Modify(true);
            until LocalGenJournalLine.Next() = 0;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetNoSeriesCode(var BankDepositHeader: Record "Bank Deposit Header"; var NoSeriesCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var BankDepositHeader: Record "Bank Deposit Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestNoSeries(var BankDepositHeader: Record "Bank Deposit Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetNoSeriesCode(var BankDepositHeader: Record "Bank Deposit Header"; SalesReceivablesSetup: Record "Sales & Receivables Setup"; var NoSeriesCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(var BankDepositHeader: Record "Bank Deposit Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnInitInsertOnBeforeInitSeries(var BankDepositHeader: Record "Bank Deposit Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnInitInsertOnBeforeInitRecord(var BankDepositHeader: Record "Bank Deposit Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAferShowDocDim(var BankDepositHeader: Record "Bank Deposit Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowDocDim(
        var BankDepositHeader: Record "Bank Deposit Header";
        xBankDepositHeader: Record "Bank Deposit Header";
        var IsHandled: Boolean)
    begin
    end;
}

