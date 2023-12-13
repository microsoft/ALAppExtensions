// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

pageextension 11758 "VAT Statement Templates CZL" extends "VAT Statement Templates"
{
    layout
    {
        addlast(Control1)
        {
            field("XML Format CZL"; Rec."XML Format CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the XML format for VAT statement reporting.';
            }
            field("Allow Comments/Attachments CZL"; Rec."Allow Comments/Attachments CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the possibillity to allow or not allow comments or attachments insert.';
            }
            field("VAT Statement Report ID CZL"; Rec."VAT Statement Report ID")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the VAT statement report that is printed when you click print on the VAT statement.';
                Visible = false;
            }
        }
    }
    actions
    {
        addlast("Te&mplate")
        {
            action("VAT Attribute Codes CZL")
            {
                ApplicationArea = VAT;
                Caption = 'VAT Attribute Codes';
                Image = List;
                RunObject = page "VAT Attribute Codes CZL";
                RunPageLink = "VAT Statement Template Name" = field(Name);
                ToolTip = 'Specifies a set of VAT attributes to use in this VAT Statement Template.';
            }
        }
    }
}
