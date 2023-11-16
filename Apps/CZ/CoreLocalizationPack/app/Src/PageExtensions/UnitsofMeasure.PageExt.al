// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.UOM;

pageextension 31098 "Units of Measure CZL" extends "Units of Measure"
{
    layout
    {
        addafter(Description)
        {
            field("Tariff Number UOM Code CZL"; Rec."Tariff Number UOM Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the name of units of measure for revers charge reporting.';
                Visible = false;
            }
        }
    }
}
