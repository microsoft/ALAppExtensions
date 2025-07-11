// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

pageextension 18002 "GST Company Information Ext" extends "Company Information"
{
    layout
    {
        addlast("Tax Information")
        {
            group("GST")
            {
                field("GST Registration No."; Rec."GST Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the company.';
                }
                field("ARN No."; Rec."ARN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ARN number of the company.';
                }
                field("Trading Co."; Rec."Trading Co.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the company is a trading company.';
                }
            }
        }
    }
}
