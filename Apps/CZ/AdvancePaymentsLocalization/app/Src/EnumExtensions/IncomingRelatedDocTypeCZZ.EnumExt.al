// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.EServices.EDocument;

enumextension 31009 "Incoming Related Doc. Type CZZ" extends "Incoming Related Document Type"
{
    value(31001; "Purchase Advance CZZ")
    {
        Caption = 'Purchase Advance';
    }
    value(31002; "Sales Advance CZZ")
    {
        Caption = 'Sales Advance';
    }
}
