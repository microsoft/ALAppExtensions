// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Setup;

enumextension 31008 "Custom Report Sel. Sales CZZ" extends "Custom Report Selection Sales"
{
    value(31010; "Advance Letter CZZ")
    {
        Caption = 'Advance Letter';
    }
    value(31011; "Advance VAT Document CZZ")
    {
        Caption = 'Advance VAT Document';
    }
}
