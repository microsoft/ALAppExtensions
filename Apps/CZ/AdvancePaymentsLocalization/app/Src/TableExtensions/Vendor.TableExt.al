tableextension 31046 "Vendor CZZ" extends Vendor
{
    procedure GetPurchaseAdvancesCountCZZ(): Integer
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", "No.");
        PurchAdvLetterHeaderCZZ.SetFilter(Status, '%1|%2', PurchAdvLetterHeaderCZZ.Status::"To Pay", PurchAdvLetterHeaderCZZ.Status::"To Use");
        exit(PurchAdvLetterHeaderCZZ.Count());
    end;
}