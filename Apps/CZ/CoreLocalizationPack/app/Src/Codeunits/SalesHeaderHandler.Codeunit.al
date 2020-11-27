#pragma warning disable AL0432
codeunit 11743 "Sales Header Handler CZL"
{
    var
        SalesSetup: Record "Sales & Receivables Setup";

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var SalesHeader: Record "Sales Header")
    begin
        SalesSetup.Get();
        case SalesSetup."Default VAT Date CZL" of
            SalesSetup."Default VAT Date CZL"::"Posting Date":
                SalesHeader."VAT Date CZL" := SalesHeader."Posting Date";
            SalesSetup."Default VAT Date CZL"::"Document Date":
                SalesHeader."VAT Date CZL" := SalesHeader."Document Date";
            SalesSetup."Default VAT Date CZL"::Blank:
                SalesHeader."VAT Date CZL" := 0D;
        end;

        if SalesHeader.IsCreditDocType() then
            SalesHeader."Credit Memo Type CZL" := SalesHeader."Credit Memo Type CZL"::"Corrective Tax Document";
        SalesHeader.Validate("Credit Memo Type CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforePostingDateValidate(var Rec: Record "Sales Header")
    begin
        SalesSetup.Get();
        if SalesSetup."Default VAT Date CZL" = SalesSetup."Default VAT Date CZL"::"Posting Date" then
            Rec.Validate("VAT Date CZL", Rec."Posting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Document Date', false, false)]
    local procedure UpdateVatDateOnBeforeDocumentDateValidate(var Rec: Record "Sales Header")
    begin
        SalesSetup.Get();
        if SalesSetup."Default VAT Date CZL" = SalesSetup."Default VAT Date CZL"::"Document Date" then
            Rec.Validate("VAT Date CZL", Rec."Document Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnUpdateBillToCustOnAfterSalesQuote', '', false, false)]
    local procedure UpdateRegNoOnUpdateBillToCustOnAfterSalesQuote(var SalesHeader: Record "Sales Header"; Contact: Record Contact)
    begin
        SalesHeader."Registration No. CZL" := Contact."Registration No. CZL";
        SalesHeader."Tax Registration No. CZL" := Contact."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopySellToCustomerAddressFieldsFromCustomer', '', false, false)]
    local procedure UpdateRegNoOnAfterCopySellToCustomerAddressFieldsFromCustomer(var SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer)
    begin
        SalesHeader."Registration No. CZL" := SellToCustomer."Registration No. CZL";
        SalesHeader."Tax Registration No. CZL" := SellToCustomer."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterSetFieldsBilltoCustomer', '', false, false)]
    local procedure UpdateRegNoOnAfterSetFieldsBilltoCustomer(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        SalesHeader."Registration No. CZL" := Customer."Registration No. CZL";
        SalesHeader."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'EU 3-Party Trade', false, false)]
    local procedure UpdateEU3PartyIntermedRoleOnBeforeEU3PartyTradeValidate(var Rec: Record "Sales Header")
    begin
        if not Rec."EU 3-Party Trade" then
            Rec."EU 3-Party Intermed. Role CZL" := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Currency Code', false, false)]
    local procedure UpdateVatCurrencyCodeCZLOnBeforeCurrencyCodeValidate(var Rec: Record "Sales Header")
    begin
        Rec.Validate("VAT Currency Code CZL", Rec."Currency Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Currency Factor', false, false)]
    local procedure UpdateVATCurrencyfactorCZLOnBeforeCurrencyFactorValidate(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if (Rec."Currency Factor" <> xRec."Currency Factor") and (Rec.IsCurrentFieldNoDiffZero(CurrFieldNo) or (xRec."Currency Factor" = 0)) then begin
            Rec.UpdateSalesLinesByFieldNo(Rec.FieldNo("Currency Factor"), false);
            Rec.UpdateVATCurrencyFactorCZL();
            Rec.CopyRecCurrencyFactortoxRecCurrencyFactor(Rec, xRec); // Elimination of double run function (synchro)
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterUpdateCurrencyFactor', '', false, false)]
    local procedure OnAfterUpdateCurrencyFactor(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.UpdateVATCurrencyFactorCZL()
    end;
}
