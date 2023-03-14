tableextension 31045 "Customer CZZ" extends Customer
{
    procedure GetSalesAdvancesCountCZZ(): Integer
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", "No.");
        SalesAdvLetterHeaderCZZ.SetFilter(Status, '%1|%2', SalesAdvLetterHeaderCZZ.Status::"To Pay", SalesAdvLetterHeaderCZZ.Status::"To Use");
        exit(SalesAdvLetterHeaderCZZ.Count());
    end;
}