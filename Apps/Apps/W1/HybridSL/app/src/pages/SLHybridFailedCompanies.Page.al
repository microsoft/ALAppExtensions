// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;

page 47024 "SL Hybrid Failed Companies"
{
    ApplicationArea = All;
    Caption = 'Companies that failed data transformation.';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Hybrid Company Status";

    layout
    {
        area(Content)
        {
            repeater(Companies)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the company that has failed the cloud migration.';
                }
                field(Status; Rec."Upgrade Status")
                {
                    ApplicationArea = All;
                    Caption = 'Upgrade Status';
                    Editable = false;
                    ToolTip = 'Specifies the name of the ocmpany that has failed the cloud migration.';

                    trigger OnDrillDown()
                    var
                        SLMigrationErrorOverview: Record "SL Migration Error Overview";
                    begin
                        SLMigrationErrorOverview.SetRange("Company Name", Rec.Name);
                        Page.Run(Page::"SL Migration Error Overview", SLMigrationErrorOverview);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                Caption = 'Show Errors';
                Image = ViewJob;
                ToolTip = 'View errors for the selected company.';

                trigger OnAction()
                var
                    SLMigrationErrorOverview: Record "SL Migration Error Overview";
                begin
                    SLMigrationErrorOverview.SetRange("Company Name", Rec.Name);
                    Page.Run(Page::"SL Migration Error Overview", SLMigrationErrorOverview);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ActionName_Promoted; ActionName)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Upgrade Status", Rec."Upgrade Status"::Failed);
    end;
}
