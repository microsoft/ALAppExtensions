// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.UseCaseBuilder;

using Microsoft.Sales.History;

pageextension 20285 "Posted Sales Cr. Stats Ext" extends "Sales Credit Memo Statistics"
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

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    local procedure UpdateComponentRecords()
    var
        SaleCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentNo: Code[20];
        RecordIDList: List of [RecordID];
    begin
        if DocumentNo <> "No." then begin
            Clear(RecordIDList);
            SaleCrMemoLine.Reset();
            SaleCrMemoLine.SetRange("Document No.", "No.");
            if SaleCrMemoLine.FindSet() then
                repeat
                    RecordIDList.Add(SaleCrMemoLine.RecordId());
                until SaleCrMemoLine.Next() = 0;
        end;

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
