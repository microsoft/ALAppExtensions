// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

page 18281 "GST Reconcilation List"
{
    Caption = 'GST Reconcilation List';
    CardPageID = "GST Reconciliation";
    PageType = List;
    SourceTable = "GST Reconcilation";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("GSTIN No."; Rec."GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GSTIN for which GST reconciliation is created.';
                }
                field(Month; Rec.Month)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the month for which GST reconciliation is created.';
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the year for which GST reconciliation is created.';
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the document number for the journal entry .';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which GST reconciliation entries will be posted.';
                }
            }
        }
    }
}

