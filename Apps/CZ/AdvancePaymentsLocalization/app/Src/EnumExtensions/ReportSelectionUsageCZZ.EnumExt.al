// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Foundation.Reporting;

enumextension 31005 "Report Selection Usage CZZ" extends "Report Selection Usage"
{
    value(31010; "Sales Advance Letter CZZ")
    {
        Caption = 'Sales Advance Letter';
    }
    value(31011; "Sales Advance VAT Document CZZ")
    {
        Caption = 'Sales Advance VAT Document';
    }
    value(31020; "Purchase Advance Letter CZZ")
    {
        Caption = 'Purchase Advance Letter';
    }
    value(31021; "Purchase Advance VAT Document CZZ")
    {
        Caption = 'Purchase Advance VAT Document';
    }
}
