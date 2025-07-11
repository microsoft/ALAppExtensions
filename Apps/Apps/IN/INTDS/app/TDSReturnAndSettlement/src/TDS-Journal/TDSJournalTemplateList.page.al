// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using System.Reflection;

page 18749 "TDS Journal Template List"
{
    Caption = 'TDS Journal Template List';
    Editable = false;
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
                field("Source Code"; Rec."Source Code")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code that defines where the entry was created.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                }
                field("Form ID"; Rec."Form ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    Visible = false;
                    ToolTip = 'Specifies Form ID';
                }
                field("Form Name"; Rec."Form Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Visible = false;
                    ToolTip = 'Specifies Form Name';
                }
            }
        }
    }
}
