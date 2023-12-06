// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Sales.Document;

tableextension 11769 "Sales Header CZP" extends "Sales Header"
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
                    CheckCashDocumentActionCZP();
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
                if "Cash Document Action CZP" <> "Cash Document Action CZP"::" " then begin
                    TestField("Cash Desk Code CZP");
                    CheckCashDocumentActionCZP();
                end;
            end;
        }
    }

    procedure CheckCashDocumentActionCZP()
    var
        EETManagementCZP: Codeunit "EET Management CZP";
    begin
        EETManagementCZP.CheckCashDocumentAction("Cash Desk Code CZP", "Cash Document Action CZP");
    end;
}
