// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 18324 "GST Journal Batch"
{
    Caption = 'GST Journal Batch';
    DataCaptionFields = Name, Description;
    LookupPageID = "GST Journal Batches";

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            TableRelation = "GST Journal Template";
            DataClassification = CustomerContent;
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Reason Code" <> xRec."Reason Code" then begin
                    ModifyLines(FieldNo("Reason Code"));
                    Modify();
                end;
            end;
        }
        field(5; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Bal. Account No." := '';
            end;
        }
        field(6; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = if ("Bal. Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Bal. Account Type" = const(Customer)) Customer
            else
            if ("Bal. Account Type" = const(Vendor)) Vendor
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Bal. Account Type" = "Bal. Account Type"::"G/L Account" then
                    CheckGLAcc("Bal. Account No.");
            end;
        }
        field(7; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No. Series" <> '' then begin
                    GSTJournalTemplate.Get("Journal Template Name");
                    if "No. Series" = "Posting No. Series" then
                        Validate("Posting No. Series", '');
                end;
            end;
        }
        field(8; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Posting No. Series" = "No. Series") and ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(PostingNoSeriesErr, "Posting No. Series"));
                ModifyLines(FieldNo("Posting No. Series"));
                Modify();
            end;
        }
        field(9; "Template Type"; Enum "GST Adjustment Journal Type")
        {
            CalcFormula = Lookup("GST Journal Template".Type where(Name = field("Journal Template Name")));
            Caption = 'Template Type';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Location Code" <> xRec."Location Code" then begin
                    ModifyLinesVouchers(FieldNo("Location Code"));
                    Modify();
                end;
            end;
        }
        field(12; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GSTJournalLine.SetRange("Journal Template Name", Name);
                GSTJournalLine.ModifyAll("Source Code", "Source Code");
                Modify();
            end;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", Name)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        GSTJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GSTJournalLine.SetRange("Journal Batch Name", Name);
        GSTJournalLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        LockTable();
        GSTJournalTemplate.Get("Journal Template Name");
    end;

    var
        GSTJournalTemplate: Record "GST Journal Template";
        GSTJournalLine: Record "GST Journal Line";
        PostingNoSeriesErr: Label 'Must not be %1.', Comment = '%1  = Posting No Series';

    procedure SetupNewBatch()
    begin
        GSTJournalTemplate.Get("Journal Template Name");
        "Bal. Account Type" := GSTJournalTemplate."Bal. Account Type";
        "Bal. Account No." := GSTJournalTemplate."Bal. Account No.";
        "No. Series" := GSTJournalTemplate."No. Series";
        "Posting No. Series" := GSTJournalTemplate."Posting No. Series";
        "Reason Code" := GSTJournalTemplate."Reason Code";
        "Template Type" := GSTJournalTemplate.Type;
    end;

    local procedure CheckGLAcc(AccNo: Code[20])
    var
        GLAcc: Record "G/L Account";
    begin
        if AccNo <> '' then begin
            GLAcc.Get(AccNo);
            GLAcc.CheckGLAcc();
            GLAcc.TestField("Direct Posting", true);
        end;
    end;

    procedure ModifyLines(i: Integer)
    begin
        GSTJournalLine.LockTable();
        GSTJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GSTJournalLine.SetRange("Journal Batch Name", Name);
        if GSTJournalLine.FindSet() then
            repeat
                case i of
                    FieldNo("Reason Code"):
                        GSTJournalLine.Validate("Reason Code", "Reason Code");
                    FieldNo("Posting No. Series"):
                        GSTJournalLine.Validate("Posting No. Series", "Posting No. Series");
                end;
                GSTJournalLine.Modify(true);
            until GSTJournalLine.Next() = 0;
    end;

    procedure ModifyLinesVouchers(CurrFieldNo: Integer)
    begin
        GSTJournalLine.LockTable();
        GSTJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GSTJournalLine.SetRange("Journal Batch Name", Name);
        if GSTJournalLine.FindFirst() then
            case CurrFieldNo of
                FieldNo("Location Code"):
                    GSTJournalLine.ModifyAll("Location Code", "Location Code");
                FieldNo("Posting No. Series"):
                    GSTJournalLine.ModifyAll("Posting No. Series", "Posting No. Series");
            end;
    end;
}

