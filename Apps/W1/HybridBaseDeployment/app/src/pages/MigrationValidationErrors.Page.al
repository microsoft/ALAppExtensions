namespace Microsoft.DataMigration;

page 40065 "Migration Validation Errors"
{
    ApplicationArea = All;
    Caption = 'Migration Validation Errors';
    PageType = List;
    SourceTable = "Migration Validation Error";
    UsageCategory = Lists;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Company Name"; Rec."Company Name")
                {
                }
                field("Entity Type"; Rec."Entity Type")
                {
                }
                field(Context; Rec."Entity Display Name")
                {
                }
                field("Test Description"; Rec."Test Description")
                {
                }
                field(Expected; Rec.Expected)
                {
                }
                field(Actual; Rec.Actual)
                {
                }
                field("Is Warning"; Rec."Is Warning")
                {
                }
                field("Migration Type"; Rec."Migration Type")
                {
                    Visible = false;
                }
                field("Validation Suite Id"; Rec."Validation Suite Id")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(CompanyMigrationStatus_Promoted; CompanyMigrationStatus)
            {
            }
        }
        area(Navigation)
        {
            action(CompanyMigrationStatus)
            {
                ApplicationArea = All;
                Caption = 'Company Migration Status';
                Image = Navigate;
                ToolTip = 'Open the Company Migration Status page.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Hybrid Companies List");
                end;
            }
        }
    }
}