// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13651 "OIOUBL-PostedSalesCreditMemos" extends "Posted Sales Credit Memos"
{
    actions
    {
        addbefore(IncomingDoc)
        {
            separator(Seperator) { }

            action(CreateEletronicSalesCreditMemo)
            {
                Caption = 'Create Electronic Sales Credit Memo';
                Tooltip = 'Create an electronic version of the current document.';
                ApplicationArea = Basic, Suite;
                Promoted = True;
                Image = ElectronicDoc;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                begin
                    SalesCrMemoHeader := Rec;
                    SalesCrMemoHeader.SETRECFILTER();

                    REPORT.RUNMODAL(REPORT::"OIOUBL-Create Elec. Cr. Memos", TRUE, FALSE, SalesCrMemoHeader);
                end;
            }
        }
    }
}