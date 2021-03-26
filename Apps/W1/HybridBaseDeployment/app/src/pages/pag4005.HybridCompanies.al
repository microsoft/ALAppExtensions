page 4005 "Hybrid Companies"
{
    SourceTable = "Hybrid Company";
    SourceTableTemporary = false;
    PageType = ListPart;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Caption = 'Select companies to migrate';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(Companies)
            {
                ShowCaption = false;
                field("Replicate"; Rec."Replicate")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migrate';
                    Visible = true;
                    ToolTip = 'Check this box if you want to migrate this company''s data';
                    Width = 5;
                    Editable = true;
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = true;
                    Editable = false;
                    ToolTip = 'Name of the company';
                }
                field("Display Name"; Rec."Display Name")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = true;
                    Editable = false;
                    Width = 10;
                    ToolTip = 'Display Name of the company';
                }
                field("Estimated Size"; Rec."Estimated Size")
                {
                    Caption = 'Estimated Size (GB)';
                    ApplicationArea = Basic, Suite;
                    Visible = DisplayDatabaseSize;
                    Editable = false;
                    ToolTip = 'Estimated size in GB of the company data to migrate';
                }
            }
        }
    }

    var
        DisplayDatabaseSize: Boolean;

    trigger OnAfterGetRecord()
    begin
        DisplayDatabaseSize := DisplayDatabaseSize or (Rec."Estimated Size" > 0);
    end;
}