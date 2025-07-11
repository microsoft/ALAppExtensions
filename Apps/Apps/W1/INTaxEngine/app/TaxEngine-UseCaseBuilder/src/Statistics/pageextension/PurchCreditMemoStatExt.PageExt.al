// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.UseCaseBuilder;

using Microsoft.Purchases.Document;

pageextension 20288 "Purch Credit Memo Stat Ext" extends "Purchase Statistics"
{
    layout
    {
        addafter(General)
        {
            part("Tax Summary"; "Tax Component Summary")
            {
                ApplicationArea = Basic, Suite;
            }

        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure UpdateComponentRecords()
    var
        PurchLine: Record "Purchase Line";
        PurchLineID: List of [RecordID];
    begin
        PurchLine.LoadFields("Document Type", "Document No.");
        PurchLine.SetRange("Document Type", "Document Type");
        PurchLine.SetRange("Document No.", "No.");
        if PurchLine.FindSet() then
            repeat
                PurchLineID.Add(PurchLine.RecordId());
            until PurchLine.Next() = 0;

        CurrPage."Tax Summary".Page.UpdateTaxComponent(PurchLineID);
        RecordsCalculated := true;
    end;

    local procedure FormatLine()
    begin
        if not RecordsCalculated then
            UpdateComponentRecords();
    end;

    var
        RecordsCalculated: Boolean;
}
