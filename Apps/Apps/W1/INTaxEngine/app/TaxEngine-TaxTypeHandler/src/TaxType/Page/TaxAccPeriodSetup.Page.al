// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

page 20246 "Tax Acc. Period Setup"
{
    PageType = List;
    SourceTable = "Tax Acc. Period Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code of the Accounting period.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the description of the Accounting period.';
                }
            }
        }
    }
}
