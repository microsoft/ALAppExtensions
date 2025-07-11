// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using System.Reflection;

page 18328 "GST Journal Template List"
{
    Caption = 'GST Journal Template List';
    Editable = false;
    PageType = List;
    SourceTable = "GST Journal Template";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the journal template.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the GST adjustment journal template.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of journal templates which are getting created.';
                    Visible = false;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code that specifies where the entry was created.';
                    Visible = false;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                    Visible = false;
                }
                field("Page ID"; Rec."Page ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the page id for GST adjustment journal.';
                    LookupPageID = Objects;
                    Visible = false;
                }
                field("Page Name"; Rec."Page Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the page name for GST adjustment journal.';
                    DrillDown = false;
                    Visible = false;
                }
            }
        }
    }
}

