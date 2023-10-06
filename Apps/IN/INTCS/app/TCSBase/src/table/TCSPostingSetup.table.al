// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Finance.GeneralLedger.Account;

table 18813 "TCS Posting Setup"
{
    LookupPageId = "TCS Posting Setup";
    DrillDownPageId = "TCS Posting Setup";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "TCS Nature of Collection"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "TCS Nature Of Collection";
            NotBlank = true;
        }
        field(2; "Effective Date"; Date)
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "TCS Account No."; code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("TCS Account No.", false);
            end;
        }
    }

    keys
    {
        key(PK; "TCS Nature of Collection", "effective date")
        {
            Clustered = true;
        }
    }

    procedure CheckGLAcc(AccNo: Code[20]; CheckDirectPosting: Boolean)
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
