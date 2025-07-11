// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.History;

pageextension 31234 "Posted Sales Invoices CZZ" extends "Posted Sales Invoices"
{
    layout
    {
        addlast(factboxes)
        {
            part(AdvanceUsageFactBoxCZZ; "Advance Usage FactBox CZZ")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if GuiAllowed() then
            CurrPage.AdvanceUsageFactBoxCZZ.Page.SetDocument(Rec);
    end;
}
