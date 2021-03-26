page 18558 Parties
{
    Caption = 'Parties';
    PageType = List;
    SourceTable = Party;
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the party.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Parties name. This name will appear on all documents for the party.';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Parties address. This address will appear on all documents for the party.';
                }
            }
        }
    }
}