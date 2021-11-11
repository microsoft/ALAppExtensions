page 18162 "Service Invoice QR Code"
{
    PageType = CardPart;
    SourceTable = "Service Invoice Header";

    layout
    {
        area(Content)
        {
            field(UpdateTaxInfoLbl; UpdateTaxInfoLbl)
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
                StyleExpr = true;
                Style = Subordinate;
                trigger OnDrillDown()
                var
                    ServiceInvoiceHeader: Record "Service Invoice Header";
                begin
                    ServiceInvoiceHeader.get(Rec."No.");
                    Page.Run(Page::"Service Invoice Dialog", ServiceInvoiceHeader);
                end;
            }
            field("QR Code"; Rec."QR Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the QR Code assigned by e-invoice portal for sales document.';
            }
        }
    }
    var
        UpdateTaxInfoLbl: Label 'Click here to update Information';
}