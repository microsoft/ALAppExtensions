// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using System.Reflection;

page 18750 "TDS Journal Templates"
{
    Caption = 'TDS Journal Templates';
    PageType = List;
    SourceTable = "TDS Journal Template";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the tax journal template.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the tax journal template.';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account where the balancing entry will be posted.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the balancing entry will be posted.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series from which numbers are assigned to new entries or records.';
                }
                field("Posting No. Series"; Rec."Posting No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of number series that will be used to assign number to ledger entries that are posted from Journal using this template.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code that defines where the entry was created.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                }
                field("Form ID"; Rec."Form ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    Visible = false;
                    ToolTip = 'Specifies the Form ID';
                }
                field("Form Name"; Rec."Form Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Visible = false;
                    ToolTiP = 'Specifies the Form Name';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Te&mplate")
            {
                Caption = 'Te&mplate';
                Image = Template;
                ToolTip = 'View or edit multiple journals for a specific template.';

                action(Batches)
                {
                    Caption = 'Batches';
                    ToolTip = 'View or edit multiple journals for a specific template.';
                    ApplicationArea = Basic, Suite;
                    Image = Description;
                    RunObject = Page "TDS Journal Batches";
                    RunPageLink = "Journal Template Name" = field(Name);
                }
            }
        }
    }
}
