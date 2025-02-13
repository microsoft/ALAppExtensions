page 6100 "E-Invoice Lines"
{
    ApplicationArea = Basic, Suite;
    Caption = 'E-Invoice Lines';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "E-Invoice Line";

    layout
    {
        area(Content)
        {
            repeater(EInvoiceLines)
            {
                field("No."; Rec."No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                }
            }
        }
    }
}