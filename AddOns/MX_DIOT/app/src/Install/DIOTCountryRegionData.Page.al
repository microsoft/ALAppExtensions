page 27033 "DIOT Country/Region Data"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "DIOT Country/Region Data";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Country/Region Code';
                    ToolTip = 'Specifies the DIOT specific country/region code.';
                }
                field(Nationality; Nationality)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Nationality';
                    ToolTip = 'Specifies the DIOT specific nationality.';
                }
                field("BC Country/Region Code"; "BC Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'BC Country Code';
                    ToolTip = 'Specifies the Business Central country/region code.';
                }
            }
        }
    }
}