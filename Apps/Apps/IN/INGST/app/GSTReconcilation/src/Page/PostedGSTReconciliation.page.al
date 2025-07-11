// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

page 18286 "Posted GST Reconciliation"
{
    Caption = 'Posted GST Reconciliation';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Posted GST Reconciliation";
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
                    ToolTip = 'Specifies the GSTIN for which reconciliation is posted.';
                }
                field("State Code"; Rec."State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code the GSTIN belongs to.';
                }
                field("Reconciliation Month"; Rec."Reconciliation Month")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the month for which GST reconciliation is posted.';
                }
                field("Reconciliation Year"; Rec."Reconciliation Year")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the year for which GST reconciliation is posted.';
                }
                field("GST Component"; Rec."GST Component")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Component for which reconciliation is posted.';
                }
                field("GST Amount"; Rec."GST Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST amount which was reconciled in the posted reconciliation.';
                }
                field("GST Prev. Period B/F Amount"; Rec."GST Prev. Period B/F Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if any balance brought forward from previous period.';
                }
                field("GST Amount Utilized"; Rec."GST Amount Utilized")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount utilized for GST on the current reconciliation.';
                }
                field("GST Prev. Period C/F Amount"; Rec."GST Prev. Period C/F Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if any balance brought forward from previous period.';
                }
            }
        }
    }
}
