// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Setup;

enumextension 31007 "Report Sel. Usage Purchase CZZ" extends "Report Selection Usage Purchase"
{
    value(31020; "Advance Letter CZZ")
    {
        Caption = 'Advance Letter';
    }
    value(31021; "Advance VAT Document CZZ")
    {
        Caption = 'Advance VAT Document';
    }
}
