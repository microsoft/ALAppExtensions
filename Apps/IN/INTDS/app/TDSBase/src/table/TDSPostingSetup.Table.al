// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.GeneralLedger.Account;

table 18691 "TDS Posting Setup"
{
    Caption = 'TDS Posting Setup';
    DrillDownPageId = "TDS Posting Setup";
    LookupPageId = "TDS Posting Setup";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "TDS Section"; Code[10])
        {
            Caption = 'TDS Section';
            TableRelation = "TDS Section";
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "TDS Account"; Code[20])
        {
            Caption = 'TDS Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAcc("TDS Account", true);
            end;
        }
        field(5; "TDS Receivable Account"; Code[20])
        {
            Caption = 'TDS Receivable Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAcc("TDS Receivable Account", true);
            end;
        }
    }

    keys
    {
        key(PK; "TDS Section", "Effective Date")
        {
            Clustered = true;
        }
    }

    local procedure CheckGLAcc(AccNo: Code[20]; CheckDirectPosting: Boolean)
    var
        GLAccount: Record "G/L Account";
    begin
        if AccNo <> '' then begin
            GLAccount.Get(AccNo);
            GLAccount.CheckGLAcc();
            if CheckDirectPosting then
                GLAccount.TestField("Direct Posting", true);
        end;
    end;
}
