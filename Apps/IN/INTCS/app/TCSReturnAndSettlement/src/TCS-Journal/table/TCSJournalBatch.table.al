// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Bank.BankAccount;

table 18869 "TCS Journal Batch"
{
    Caption = 'TCS Journal Batch';
    DataCaptionFields = Name, Description;
    LookupPageId = "TCS Journal Batches";
    DrillDownPageId = "TCS Journal Batches";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            NotBlank = true;
            TableRelation = "TCS Journal Template";
            DataClassification = CustomerContent;
        }
        field(2; Name; Code[10])
        {
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Bal. Account Type"; Enum "Bal. Account Type")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Bal. Account No." := '';
            end;
        }
        field(5; "Bal. Account No."; Code[20])
        {
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
        field(6; "No. Series"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                TCSJnlTemplate: Record "TCS Journal Template";
            begin
                if "No. Series" <> '' then begin
                    TCSJnlTemplate.Get("Journal Template Name");
                    if "No. Series" = "Posting No. Series" then
                        Validate("Posting No. Series", '');
                end;
            end;
        }
        field(7; "Posting No. Series"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                ValueErr: Label 'must not be %1', Comment = '%1=The value.';
            begin
                if ("Posting No. Series" = "No. Series") and ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(ValueErr, "Posting No. Series"));
                ModifyLines(FieldNo("Posting No. Series"));
                Modify();
            end;
        }
        field(8; "Location Code"; Code[10])
        {
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
    var
        TCSJournalLine: Record "TCS Journal Line";
    begin
        TCSJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        TCSJournalLine.SetRange("Journal Batch Name", Name);
        TCSJournalLine.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        TCSJournalTemplate: Record "TCS Journal Template";
    begin
        LockTable();
        TCSJournalTemplate.Get("Journal Template Name");
    end;

    procedure SetupNewBatch()
    var
        TCSJournalTemplate: Record "TCS Journal Template";
    begin
        TCSJournalTemplate.Get("Journal Template Name");
        "Bal. Account Type" := TCSJournalTemplate."Bal. Account Type";
        "Bal. Account No." := TCSJournalTemplate."Bal. Account No.";
        "No. Series" := TCSJournalTemplate."No. Series";
        "Posting No. Series" := TCSJournalTemplate."Posting No. Series";
    end;

    procedure ModifyLines(i: Integer)
    var
        TCSJournalLine: Record "TCS Journal Line";
    begin
        TCSJournalLine.LockTable();
        TCSJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        TCSJournalLine.SetRange("Journal Batch Name", Name);
        if TCSJournalLine.FindSet() then
            repeat
                case i of
                    FieldNo("Posting No. Series"):
                        TCSJournalLine.Validate("Posting No. Series", "Posting No. Series");
                end;
                TCSJournalLine.Modify(true);
            until TCSJournalLine.Next() = 0;
    end;

    procedure ModifyLinesVouchers(CurrFieldNo: Integer)
    var
        TCSJournalLine: Record "TCS Journal Line";
    begin
        TCSJournalLine.LockTable();
        TCSJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        TCSJournalLine.SetRange("Journal Batch Name", Name);
        if TCSJournalLine.FindFirst() then
            case CurrFieldNo of
                FieldNo("Location Code"):
                    TCSJournalLine.ModifyAll("Location Code", "Location Code");
                FieldNo("Posting No. Series"):
                    TCSJournalLine.ModifyAll("Posting No. Series", "Posting No. Series");
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
