codeunit 31090 "EET Management Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EET Management CZP", 'OnBeforeCheckLineWithAppliedDocument', '', false, false)]
    local procedure EETManagementOnBeforeCheckLineWithAppliedDocument(CashDocumentLineCZP: Record "Cash Document Line CZP"; var IsHandled: Boolean)
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        AppliedDocumentAmount: Decimal;
    begin
        if CashDocumentLineCZP."Advance Letter No. CZZ" = '' then
            exit;

        case CashDocumentLineCZP."Document Type" of
            CashDocumentLineCZP."Document Type"::Receipt:
                begin
                    SalesAdvLetterHeaderCZZ.Get(CashDocumentLineCZP."Advance Letter No. CZZ");
                    SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", CashDocumentLineCZP."Account No.");
                    SalesAdvLetterHeaderCZZ.TestField("Currency Code", CashDocumentLineCZP."Currency Code");
                    SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
                    AppliedDocumentAmount := SalesAdvLetterHeaderCZZ."To Pay";
                end;
            CashDocumentLineCZP."Document Type"::Withdrawal:
                begin
                    PurchAdvLetterHeaderCZZ.Get(CashDocumentLineCZP."Advance Letter No. CZZ");
                    PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", CashDocumentLineCZP."Account No.");
                    PurchAdvLetterHeaderCZZ.TestField("Currency Code", CashDocumentLineCZP."Currency Code");
                    AppliedDocumentAmount := PurchAdvLetterHeaderCZZ."To Pay";
                end;
        end;

        if CashDocumentLineCZP."Amount Including VAT" > AppliedDocumentAmount then
            CashDocumentLineCZP.TestField("Amount Including VAT", AppliedDocumentAmount);

        IsHandled := true;
    end;
}