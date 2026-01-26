// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Foundation.Reporting;

enumextension 6784 "WHT Report Selection Usage Ext" extends "Report Selection Usage"
{
    value(6784; "Withholding Tax Certificate")
    {
        Caption = 'Withholding Tax Certificate';
    }
    value(6785; "P. Withholding Tax Invoice")
    {
        Caption = 'Purchase Withholding Tax Invoice';
    }
    value(6786; "P. Withholding Tax Credit Memo")
    {
        Caption = 'Purchase Withholding Tax Credit Memo';
    }
}