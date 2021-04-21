page 31194 "Acc. Schedule Line List CZL"
{
    Caption = 'Acc. Schedule Line List';
    Editable = false;
    PageType = List;
    SourceTable = "Acc. Schedule Line";
    SourceTableView = sorting("Schedule Name", "Line No.") where("Row Correction CZL" = const(''));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Schedule Name"; Rec."Schedule Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account schedule name.';
                    Visible = false;
                }
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a number for the account schedule line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies text that will appear on the account schedule line.';
                }
                field("Totaling Type"; Rec."Totaling Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the totaling type for the account schedule line. The type determines which accounts within the totaling interval you specify in the Totaling field will be totaled.';
                }
                field(Totaling; Rec.Totaling)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies totaling for acc. schedule line';
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;
}