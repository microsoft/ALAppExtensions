#pragma warning disable AA0247
page 11028 "Elec. VAT Decl. Overview"
{
    Caption = 'Elec. VAT Decl. Overview';
    Editable = false;
    PageType = List;
    SourceTable = "Elec. VAT Decl. Buffer";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';
                field(Code; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT code to report.';
                }

                field(Amount; Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount to report.';
                }

            }
        }
    }
}
