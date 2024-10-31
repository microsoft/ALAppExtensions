// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.UseCaseBuilder;

using Microsoft.Sales.Document;

pageextension 20289 "Sales Order Statistics Ext" extends "Sales Order Statistics"
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
        SalesLine: Record "Sales Line";
        SalesLineID: List of [RecordID];
    begin
        SalesLine.LoadFields("Document Type", "Document No.");
        SalesLine.SetRange("Document Type", "Document Type");
        SalesLine.SetRange("Document No.", "No.");
        if SalesLine.FindSet() then
            repeat
                SalesLineID.Add(SalesLine.RecordId());
            until SalesLine.Next() = 0;

        CurrPage."Tax Summary".Page.UpdateTaxComponent(SalesLineID);
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
