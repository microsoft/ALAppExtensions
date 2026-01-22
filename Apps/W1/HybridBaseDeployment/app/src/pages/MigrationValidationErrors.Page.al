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
                    ToolTip = 'Specifies the value of the Company Name field.';
                }
                field("Entity Type"; Rec."Entity Type")
                {
                    ToolTip = 'Specifies the value of the Entity Type field.';
                }
                field(Context; Rec.Context)
                {
                    ToolTip = 'Specifies the value of the Context field.';
                }
                field("Test Description"; Rec."Test Description")
                {
                    ToolTip = 'Specifies the value of the Test Description field.';
                }
                field(Expected; Rec.Expected)
                {
                    ToolTip = 'Specifies the value of the Expected field.';
                }
                field(Actual; Rec.Actual)
                {
                    ToolTip = 'Specifies the value of the Actual field.';
                }
                field("Is Warning"; Rec."Is Warning")
                {
                    ToolTip = 'Specifies if the failed validation test should be considered just a warning.';
                }
                field("Migration Type"; Rec."Migration Type")
                {
                    ToolTip = 'Specifies the value of the Migration Type field.';
                    Visible = false;
                }
                field("Validator Code"; Rec."Validator Code")
                {
                    ToolTip = 'Specifies the value of the Validator Code field.';
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