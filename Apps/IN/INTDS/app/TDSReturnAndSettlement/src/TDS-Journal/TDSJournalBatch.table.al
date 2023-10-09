// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Bank.BankAccount;

table 18746 "TDS Journal Batch"
{
    Caption = 'Tax Journal Batch';
    DataCaptionFields = Name, Description;
    LookupPageId = "TDS Journal Batches";
    DrillDownPageId = "TDS Journal Batches";
    Extensible = true;
    Access = Public;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            TableRelation = "TDS Journal Template";
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
        field(5; "Bal. Account Type"; Enum "TDS Bal. Account Type")
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
            DataClassification = CustomerContent;
            TableRelation = if ("Bal. Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Bal. Account Type" = const(Customer)) Customer
            else
            if ("Bal. Account Type" = const(Vendor)) Vendor
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account";

            trigger OnValidate()
            begin
                if "Bal. Account Type" = "Bal. Account Type"::"G/L Account" then
                    CheckGLAcc("Bal. Account No.");
            end;
        }
        field(7; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if "No. Series" <> '' then begin
                    TDSJournalTemplate.Get("Journal Template Name");
                    if "No. Series" = "Posting No. Series" then
                        Validate("Posting No. Series", '');
                end;
            end;
        }
        field(8; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if ("Posting No. Series" = "No. Series") and ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(PostingNoSeriesErr, "Posting No. Series"));
                ModifyLines(FieldNo("Posting No. Series"));
                Modify();
            end;
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;

            trigger OnValidate()
            begin
                if "Location Code" <> xRec."Location Code" then begin
                    ModifyLinesVouchers(FieldNo("Location Code"));
                    Modify();
                end;
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
        TDSJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        TDSJournalLine.SetRange("Journal Batch Name", Name);
        TDSJournalLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        LockTable();
        TDSJournalTemplate.Get("Journal Template Name");
    end;

    var
        TDSJournalTemplate: Record "TDS Journal Template";
        TDSJournalLine: Record "TDS Journal Line";
        PostingNoSeriesErr: Label 'must not be %1', Comment = '%1 = Posting No. Series ';

    procedure SetupNewBatch()
    begin
        TDSJournalTemplate.Get("Journal Template Name");
        "Bal. Account Type" := TDSJournalTemplate."Bal. Account Type";
        "Bal. Account No." := TDSJournalTemplate."Bal. Account No.";
        "No. Series" := TDSJournalTemplate."No. Series";
        "Posting No. Series" := TDSJournalTemplate."Posting No. Series";
        "Reason Code" := TDSJournalTemplate."Reason Code";
    end;

    procedure ModifyLines(i: Integer)
    begin
        TDSJournalLine.LockTable();
        TDSJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        TDSJournalLine.SetRange("Journal Batch Name", Name);
        if TDSJournalLine.FindSet() then
            repeat
                case i of
                    FieldNo("Reason Code"):
                        TDSJournalLine.Validate("Reason Code", "Reason Code");
                    FieldNo("Posting No. Series"):
                        TDSJournalLine.Validate("Posting No. Series", "Posting No. Series");
                end;
                TDSJournalLine.Modify(true);
            until TDSJournalLine.Next() = 0;
    end;

    procedure ModifyLinesVouchers(CurrFieldNo: Integer)
    begin
        TDSJournalLine.LockTable();
        TDSJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        TDSJournalLine.SetRange("Journal Batch Name", Name);
        if TDSJournalLine.FindFirst() then
            case CurrFieldNo of
                FieldNo("Location Code"):
                    TDSJournalLine.ModifyAll("Location Code", "Location Code");
                FieldNo("Posting No. Series"):
                    TDSJournalLine.ModifyAll("Posting No. Series", "Posting No. Series");
            end;
    end;

    local procedure CheckGLAcc(AccNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if AccNo <> '' then begin
            GLAccount.Get(AccNo);
            GLAccount.CheckGLAcc();
            GLAccount.TestField("Direct Posting", true);
        end;
    end;
}
