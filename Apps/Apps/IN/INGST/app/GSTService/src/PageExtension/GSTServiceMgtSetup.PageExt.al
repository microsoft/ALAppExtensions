// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Setup;

pageextension 18457 "GST Service Mgt Setup" extends "Service Mgt. Setup"
{
    layout
    {
        addafter("Base Calendar Code")
        {
            field("GST Dependency Type"; Rec."GST Dependency Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST calculation dependency mentioned in service management setup.';
            }
        }
    }
}
