// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.UseCaseBuilder;

using Microsoft.Purchases.History;

pageextension 20284 "Posted Purch. Inv. Stats Ext" extends "Purchase Invoice Statistics"
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
        PurchInvLine: Record "Purch. Inv. Line";
        DocumentNo: Code[20];
        RecordIDList: List of [RecordID];
    begin

        if DocumentNo <> "No." then begin
            Clear(RecordIDList);
            PurchInvLine.LoadFields("Document No.");
            PurchInvLine.SetRange("Document No.", "No.");
            if PurchInvLine.FindSet() then
                repeat
                    RecordIDList.Add(PurchInvLine.RecordId());
                until PurchInvLine.Next() = 0;
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
