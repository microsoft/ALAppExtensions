page 18165 "Service Cr Memo QR Code"
{
    PageType = CardPart;
    SourceTable = "Service Cr.Memo Header";

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
                    ServiceCrMemoHeader: Record "Service Cr.Memo Header";
                begin
                    ServiceCrMemoHeader.get(Rec."No.");
                    Page.Run(Page::"Service Cr Memo Dialog", ServiceCrMemoHeader);
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