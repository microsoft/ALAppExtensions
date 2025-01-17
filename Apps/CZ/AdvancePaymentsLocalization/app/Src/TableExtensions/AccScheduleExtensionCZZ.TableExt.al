// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.FinancialReports;

tableextension 31048 "Acc. Schedule Extension CZZ" extends "Acc. Schedule Extension CZL"
{
    fields
    {
        field(60; "Advance Payments CZZ"; Option)
        {
            Caption = 'Advance Payments';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Yes,No';
            OptionMembers = " ",Yes,No;
        }
    }
}
