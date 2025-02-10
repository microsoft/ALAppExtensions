codeunit 11502 "Create Purchase Document NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdateInvoiceHeaderAmounts();
        UpdatePurchaseLine();
    end;

    local procedure UpdateInvoiceHeaderAmounts()
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.SetFilter("Document Type", '%1|%2', PurchHeader."Document Type"::Invoice, PurchHeader."Document Type"::"Credit Memo");
        PurchHeader.SetFilter("No.", '<>%1', '');
        if PurchHeader.FindSet() then
            repeat
                PurchHeader.CalcFields("Amount Including VAT", Amount);
                PurchHeader.Validate("Doc. Amount Incl. VAT", PurchHeader."Amount Including VAT");
                PurchHeader.Validate("Doc. Amount VAT", PurchHeader."Amount Including VAT" - PurchHeader.Amount);
                PurchHeader.Modify(true);
            until PurchHeader.Next() = 0;
    end;

    local procedure UpdatePurchaseLine()
    var
        PurchaseLine: Record "Purchase Line";
        Resource: Record Resource;
    begin
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Resource);
        if PurchaseLine.FindSet() then
            repeat
                Resource.Get(PurchaseLine."No.");
                PurchaseLine.Validate("Direct Unit Cost", Resource."Direct Unit Cost");
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;
    end;
}