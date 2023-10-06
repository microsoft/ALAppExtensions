// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

using System.Text;

tableextension 13639 "OIOUBL-Issued Reminder Line" extends "Issued Reminder Line"
{
    fields
    {
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
        }
    }
    keys
    {
    }

    procedure GetDescription(CurrencyCode: Code[10]): Text[1024];
    var
        AutoFormat: Codeunit "Auto Format";
        DescriptionTxt: Label '%1: %2; ', Locked = true;
    begin
        case Type of
            Type::" ":
                exit(Description + CrLf());
            Type::"G/L Account":
                exit(
                  STRSUBSTNO(DescriptionTxt, FIELDCAPTION(Description), Description) +
                  STRSUBSTNO(DescriptionTxt, FIELDCAPTION(Amount), FORMAT(Amount, 0, AutoFormat.ResolveAutoFormat(1, CurrencyCode))) +
                  CrLf());
            Type::"Customer Ledger Entry":
                exit(
                  STRSUBSTNO(DescriptionTxt, FIELDCAPTION("Document Date"), FORMAT("Document Date")) +
                  STRSUBSTNO(DescriptionTxt, FIELDCAPTION("Document Type"), FORMAT("Document Type")) +
                  STRSUBSTNO(DescriptionTxt, FIELDCAPTION("Document No."), FORMAT("Document No.")) +
                  STRSUBSTNO(DescriptionTxt, FIELDCAPTION("Due Date"), FORMAT("Due Date")) +
                  STRSUBSTNO(DescriptionTxt, FIELDCAPTION("Original Amount"),
                  FORMAT("Original Amount", 0, AutoFormat.ResolveAutoFormat(1, CurrencyCode))) +
                  STRSUBSTNO(DescriptionTxt, FIELDCAPTION("Remaining Amount"),
                  FORMAT("Remaining Amount", 0, AutoFormat.ResolveAutoFormat(1, CurrencyCode))) +
                  CrLf());
        end;
    end;

    local procedure CrLf() CrLf: Text[2];
    begin
        CrLf[1] := 13;
        CrLf[2] := 10;
    end;
}
