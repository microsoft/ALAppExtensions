// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

pageextension 31266 "VAT Reports Configuration CZL" extends "VAT Reports Configuration"
{
    layout
    {
        addlast(Group)
        {
            field("VAT Statement Template"; Rec."VAT Statement Template")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT Statement Template.';
            }
            field("VAT Statement Name"; Rec."VAT Statement Name")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT Statement Name.';
            }
        }
    }
}