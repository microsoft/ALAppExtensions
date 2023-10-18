// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using Microsoft.Foundation.AuditCodes;
using System.Reflection;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Bank.BankAccount;

table 18748 "TDS Journal Template"
{
    Caption = 'Tax Journal Template';
    Extensible = true;
    Access = Public;
    LookupPageId = "TDS Journal Template List";
    DrillDownPageId = "TDS Journal Template List";

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Form ID"; Integer)
        {
            Caption = 'Form ID';
            DataClassification = CustomerContent;
        }
        field(5; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";

            trigger OnValidate()
            var
                TDSJnlLine: Record "TDS Journal Line";
            begin
                TDSJnlLine.SetRange("Journal Template Name", Name);
                TDSJnlLine.ModifyAll("Source Code", "Source Code");
                Modify();
            end;
        }
        field(6; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(7; "Form Name"; Text[80])
        {
            Caption = 'Form Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Page),
                                                                           "Object ID" = field("Form ID")));
        }
        field(8; "Bal. Account Type"; enum "TDS Bal. Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Bal. Account Type';

            trigger OnValidate()
            begin
                "Bal. Account No." := '';
            end;
        }
        field(9; "Bal. Account No."; Code[20])
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
        field(10; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if "No. Series" <> '' then
                    if "No. Series" = "Posting No. Series" then
                        "Posting No. Series" := '';
            end;
        }
        field(11; "Posting No. Series"; Code[10])
        {
            Caption = 'Posting No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                PostingNoSeriesErr: Label 'must not be %1', Comment = '%1 = Posting No.Series';
            begin
                if ("Posting No. Series" = "No. Series") and ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(PostingNoSeriesErr, "Posting No. Series"));
            end;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, Description)
        {
        }
    }

    trigger OnDelete()
    var
        TDSJournalBatch: Record "TDS Journal Batch";
        TDSJournalLine: Record "TDS Journal Line";
    begin
        TDSJournalLine.SetRange("Journal Template Name", Name);
        TDSJournalLine.DeleteAll(true);
        TDSJournalBatch.SetRange("Journal Template Name", Name);
        TDSJournalBatch.DeleteAll();
    end;

    trigger OnInsert()
    begin
        Validate("Form ID");
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
