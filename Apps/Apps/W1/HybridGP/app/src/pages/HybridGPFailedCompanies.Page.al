namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

page 40057 "Hybrid GP Failed Companies"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Hybrid Company Status";
    DeleteAllowed = false;
    InsertAllowed = false;
    Editable = false;
    ModifyAllowed = false;
    Caption = 'Companies failed data trasnformation';

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
                        GPMigrationErrorOverview: Record "GP Migration Error Overview";
                    begin
                        GPMigrationErrorOverview.SetRange("Company Name", Rec.Name);
                        Page.Run(Page::"GP Migration Error Overview", GPMigrationErrorOverview);
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
                Image = ViewJob;
                Caption = 'Show Errors';
                ToolTip = 'View errors for the selected company.';

                trigger OnAction()
                var
                    GPMigrationErrorOverview: Record "GP Migration Error Overview";
                begin
                    GPMigrationErrorOverview.SetRange("Company Name", Rec.Name);
                    Page.Run(Page::"GP Migration Error Overview", GPMigrationErrorOverview);
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