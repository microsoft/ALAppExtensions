page 6100 "E-Invoice Lines"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "E-Invoice Line";

    layout
    {
        area(Content)
        {
            repeater(EInvoiceLines)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies what is being purchased.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Describes what is being purchased.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity of what you''re buying. The number is based on the unit chosen in the Unit of Measure Code field.';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ToolTip = 'Specifies the price of one unit of what you are buying.';
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
                }
            }
        }
    }
}