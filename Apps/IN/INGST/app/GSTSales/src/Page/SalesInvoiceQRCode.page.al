page 18142 "Sales Invoice QR Code"
{
    PageType = CardPart;
    SourceTable = "Sales Invoice Header";

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
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                begin
                    SalesInvoiceHeader.get(Rec."No.");
                    Page.Run(Page::"Sales Invoice Dialog", SalesInvoiceHeader);
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