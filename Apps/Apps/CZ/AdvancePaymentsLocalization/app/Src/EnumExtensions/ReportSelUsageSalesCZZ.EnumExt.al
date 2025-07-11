// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Setup;

enumextension 31006 "Report Sel. Usage Sales CZZ" extends "Report Selection Usage Sales"
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
