// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

using Microsoft.Finance.TaxBase;

pageextension 18553 "Tax Acc. Period Setup" extends "Tax Acc. Period Setup"
{
    actions
    {
        addfirst(Processing)
        {
            action("Accounting Period")
            {
                ApplicationArea = Basic, Suite;
                Image = AccountingPeriods;
                RunObject = page "Tax Accounting Periods";
                RunPageLink = "Tax Type Code" = field(Code);
                ToolTip = 'Specifies the accounting period for the tax type.';
            }
        }
    }
}
