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
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Reflection;

table 18323 "GST Journal Template"
{
    Caption = 'GST Journal Template';
    LookupPageID = "GST Journal Template List";

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
        field(3; "Page ID"; Integer)
        {
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Page ID" = 0 then
                    Validate(Type);
            end;
        }
        field(4; Type; Enum "GST Adjustment Journal Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SourceCodeSetup.Get();
                case Type of
                    Type::"GST Adjustment Journal":
                        begin
                            "Source Code" := SourceCodeSetup."GST Adjustment Journal";
                            "Page ID" := Page::"GST Adjustment Journal";
                        end;
                end;
            end;
        }
        field(5; "Source Code"; Code[10])
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
        field(6; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(7; "Page Name"; Text[80])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Page), "Object ID" = field("Page ID")));
            Caption = 'Page Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Bal. Account No." := '';
            end;
        }
        field(9; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = if ("Bal. Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Bal. Account Type" = const(Customer)) "Customer"
            else
            if ("Bal. Account Type" = const(Vendor)) "Vendor"
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Bal. Account Type" = "Bal. Account Type"::"G/L Account" then
                    CheckGLAcc("Bal. Account No.");
            end;
        }
        field(10; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;

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
            TableRelation = "No. Series";
            DataClassification = CustomerContent;

            trigger OnValidate()
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
        fieldgroup(DropDown; Name, Description, "Bal. Account No.")
        {
        }
    }

    trigger OnDelete()
    begin
        GSTJournalLine.SetRange("Journal Template Name", Name);
        GSTJournalLine.DeleteAll(true);
        GSTJournalBatch.SetRange("Journal Template Name", Name);
        GSTJournalBatch.DeleteAll();
    end;

    trigger OnInsert()
    begin
        Validate("Page ID");
    end;

    var
        GSTJournalBatch: Record "GST Journal Batch";
        GSTJournalLine: Record "GST Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        PostingNoSeriesErr: Label 'Must not be %1.', Comment = '%1  = Posting No Series';

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
}

