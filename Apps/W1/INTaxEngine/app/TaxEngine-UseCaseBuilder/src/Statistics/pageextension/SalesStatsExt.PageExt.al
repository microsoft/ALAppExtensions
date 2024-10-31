// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.UseCaseBuilder;

using Microsoft.Sales.Document;

pageextension 20290 "Sales Stats Ext" extends "Sales Statistics"
{
    layout
    {
        addafter(General)
        {
            group(TaxSummary)
            {
                Caption = 'Tax Summary';
                part("Tax Compoent Summary"; "Tax Component Summary")
                {
                    ApplicationArea = Basic, Suite;
                }
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
        CurrentSalesLine: Record "Sales Line";
        DocumentType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        RecordIDList: List of [RecordID];
    begin
        if (DocumentType <> "Document Type") or (DocumentNo <> "No.") then begin
            Clear(RecordIDList);
            CurrentSalesLine.LoadFields("Document Type", "Document No.");
            CurrentSalesLine.SetRange("Document Type", "Document Type");
            CurrentSalesLine.SetRange("Document No.", "No.");
            if CurrentSalesLine.FindSet() then
                repeat
                    RecordIDList.Add(CurrentSalesLine.RecordId());
                until CurrentSalesLine.Next() = 0;
        end;

        DocumentType := "Document Type";
        DocumentNo := "No.";
        CurrPage."Tax Compoent Summary".Page.UpdateTaxComponent(RecordIDList);
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
