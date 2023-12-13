// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.CashFlow.Reports;
using Microsoft.CashFlow.Setup;

reportextension 31006 "Cash Flow Date List CZZ" extends "Cash Flow Date List CZL"
{
    dataset
    {
        modify(EditionPeriod)
        {
            trigger OnAfterAfterGetRecord()
            begin
                SalesAdvanceValue := CashFlow.CalcSourceTypeAmount(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ");
                PurchaseAdvanceValue := CashFlow.CalcSourceTypeAmount(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ");
            end;
        }
    }
}
