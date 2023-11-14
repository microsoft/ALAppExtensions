// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Purchases.Document;

tableextension 11772 "Purchase Header CZP" extends "Purchase Header"
{
    fields
    {
        field(11740; "Cash Desk Code CZP"; Code[20])
        {
            Caption = 'Cash Desk Code';
            TableRelation = "Cash Desk CZP";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CashDeskCZP: Record "Cash Desk CZP";
            begin
                if "Bal. Account No." <> '' then
                    TestField("Cash Desk Code CZP", '');
                if "Cash Desk Code CZP" <> '' then begin
                    TestField("Bal. Account No.", '');
                    CashDeskCZP.Get("Cash Desk Code CZP");
                    CashDeskCZP.TestField(Blocked, false);
                    TestField("Currency Code", CashDeskCZP."Currency Code");
                end else
                    "Cash Document Action CZP" := "Cash Document Action CZP"::" ";
            end;
        }
        field(11741; "Cash Document Action CZP"; Enum "Cash Document Action CZP")
        {
            Caption = 'Cash Document Action';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Cash Document Action CZP" <> "Cash Document Action CZP"::" " then
                    TestField("Cash Desk Code CZP");
            end;
        }
    }
}
