page 2400 "XS Sync Change"
{
    Caption = 'Sync Change';
    PageType = List;
    SourceTable = "Sync Change";
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                field("External Id"; "External Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Internal ID"; format("Internal ID"))
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Direction; Direction)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Change Type"; "Change Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("NAV Entity ID"; "XS NAV Entity ID")
                {
                    ApplicationArea = Basic, Suite;
                }

                field("Current No. of sync attempts"; "Current No. of sync attempts")
                {
                    ApplicationArea = Basic, Suite;
                }

                field("Error message"; "Error message")
                {
                    ApplicationArea = Basic, Suite;
                    trigger OnDrillDown()
                    begin
                        Message("Error message");
                    end;
                }
            }
        }
    }
}