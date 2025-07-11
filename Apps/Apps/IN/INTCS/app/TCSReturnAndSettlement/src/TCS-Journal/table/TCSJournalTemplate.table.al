// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Foundation.AuditCodes;
using System.Reflection;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Bank.BankAccount;

table 18871 "TCS Journal Template"
{
    Caption = 'TCS Journal Template';
    LookupPageId = "TCS Journal Template List";
    DrillDownPageId = "TCS Journal Template List";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; Name; Code[10])
        {
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Source Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Source Code";

            trigger OnValidate()
            var
                TCSJnlLine: Record "TCS Journal Line";
            begin
                TCSJnlLine.SetRange("Journal Template Name", Name);
                TCSJnlLine.ModifyAll("Source Code", "Source Code");
                Modify();
            end;
        }
        field(4; "Form ID"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Form Name"; Text[80])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Page),
                                                                           "Object ID" = field("Form ID")));
        }
        field(6; "Bal. Account Type"; Enum "Bal. Account Type")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Bal. Account No." := '';
            end;
        }
        field(7; "Bal. Account No."; Code[20])
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
        field(8; "No. Series"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if "No. Series" <> '' then
                    if "No. Series" = "Posting No. Series" then
                        "Posting No. Series" := '';
            end;
        }
        field(9; "Posting No. Series"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                ValueErr: Label 'must not be %1', Comment = '%1=The value';
            begin
                if ("Posting No. Series" = "No. Series") and ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(ValueErr, "Posting No. Series"));
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
        TCSJournalBatch: Record "TCS Journal Batch";
        TCSJournalLine: Record "TCS Journal Line";
    begin
        TCSJournalLine.SetRange("Journal Template Name", Name);
        TCSJournalLine.DeleteAll(true);
        TCSJournalBatch.SetRange("Journal Template Name", Name);
        TCSJournalBatch.DeleteAll();
    end;

    trigger OnInsert()
    begin
        Validate("Form ID", Page::"TCS Adjustment Journal");
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
