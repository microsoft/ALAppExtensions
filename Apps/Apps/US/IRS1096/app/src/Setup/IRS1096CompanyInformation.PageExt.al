// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

pageextension 10018 "IRS 1096 Company Information" extends "Company Information"
{
    layout
    {
        addafter("Home Page")
        {
            field("EIN Number"; Rec."EIN Number")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies an Employer Identification Number (EIN).';
            }
            field("IRS Contact No."; Rec."IRS Contact No.")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies a name of the person to contact related with IRS.';
            }
        }
    }
}
