pageextension 13408 "Intrastat Report FI" extends "Intrastat Report"
{
    layout
    {
        modify(Reported)
        {
            Visible = false;
        }
        addafter(Reported)
        {
            field("Arrivals Reported"; Rec."Arrivals Reported")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies if the batch contains a reported receipt and cannot be reported again.';
            }
            field("Dispatches Reported"; Rec."Dispatches Reported")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies if the batch contains a reported shipment and cannot be reported again.';
            }
        }
    }
}