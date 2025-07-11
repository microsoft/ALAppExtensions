// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Archive;

tableextension 10059 "IRS 1099 Purch. Line Arch." extends "Purchase Line Archive"
{
    fields
    {
        field(10030; "1099 Liable"; Boolean)
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the amount is to be a 1099 amount.';
        }
    }
}