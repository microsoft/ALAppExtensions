// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.NoSeries;

table 31270 "Compensations Setup CZC"
{
    Caption = 'Compensation Setup';
    DrillDownPageID = "Compensations Setup CZC";
    LookupPageID = "Compensations Setup CZC";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Compensation Nos."; Code[20])
        {
            Caption = 'Compensation Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(15; "Compensation Bal. Account No."; Code[20])
        {
            Caption = 'Compensation Bal. Account No.';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Compensation Bal. Account No.");
            end;
        }
        field(20; "Max. Rounding Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Max. Rounding Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Debit Rounding Account"; Code[20])
        {
            Caption = 'Debit Rounding Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Debit Rounding Account");
            end;
        }
        field(30; "Credit Rounding Account"; Code[20])
        {
            Caption = 'Credit Rounding Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Credit Rounding Account");
            end;
        }
        field(35; "Compensation Proposal Method"; Enum "Compens. Proposal Method CZC")
        {
            Caption = 'Compensation Proposal Method';
            DataClassification = CustomerContent;
        }
        field(40; "Show Empty when not Found"; Boolean)
        {
            Caption = 'Show Empty when not Found';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    local procedure CheckGLAccount(AccNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if AccNo <> '' then begin
            GLAccount.Get(AccNo);
            GLAccount.CheckGLAcc();
        end;
    end;
}
