page 18872 "TCS Journal Template List"
{
    Caption = 'TCS Journal Template List';
    Editable = false;
    PageType = List;
    SourceTable = "TCS Journal Template";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the journal template you are creating.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a brief description of the journal template you are creating.';
                }
            }
        }
    }
}