codeunit 11743 "Sales Header Handler CZL"
{
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var SalesHeader: Record "Sales Header")
    begin
        SalesReceivablesSetup.Get();
        case SalesReceivablesSetup."Default VAT Date CZL" of
            SalesReceivablesSetup."Default VAT Date CZL"::"Posting Date":
                SalesHeader."VAT Date CZL" := SalesHeader."Posting Date";
            SalesReceivablesSetup."Default VAT Date CZL"::"Document Date":
                SalesHeader."VAT Date CZL" := SalesHeader."Document Date";
            SalesReceivablesSetup."Default VAT Date CZL"::Blank:
                SalesHeader."VAT Date CZL" := 0D;
        end;

        if SalesHeader.IsCreditDocType() then
            SalesHeader."Credit Memo Type CZL" := SalesHeader."Credit Memo Type CZL"::"Corrective Tax Document";
        SalesHeader.Validate("Credit Memo Type CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforePostingDateValidate(var Rec: Record "Sales Header")
    begin
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."Default VAT Date CZL" = SalesReceivablesSetup."Default VAT Date CZL"::"Posting Date" then
            Rec.Validate("VAT Date CZL", Rec."Posting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Document Date', false, false)]
    local procedure UpdateVatDateOnBeforeDocumentDateValidate(var Rec: Record "Sales Header")
    begin
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."Default VAT Date CZL" = SalesReceivablesSetup."Default VAT Date CZL"::"Document Date" then
            Rec.Validate("VAT Date CZL", Rec."Document Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnUpdateBillToCustOnAfterSalesQuote', '', false, false)]
    local procedure UpdateRegNoOnUpdateBillToCustOnAfterSalesQuote(var SalesHeader: Record "Sales Header"; Contact: Record Contact)
    begin
        SalesHeader."Registration No. CZL" := Contact."Registration No. CZL";
        SalesHeader."Tax Registration No. CZL" := Contact."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterSetFieldsBilltoCustomer', '', false, false)]
    local procedure UpdateBankInfoAndRegNosOnAfterSetFieldsBilltoCustomer(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    var
        CompanyInformation: Record "Company Information";
        ResponsibilityCenter: Record "Responsibility Center";
    begin
        if not SalesHeader.IsCreditDocType() then begin
            if SalesHeader."Responsibility Center" = '' then begin
                CompanyInformation.Get();
                SalesHeader.Validate("Bank Account Code CZL", CompanyInformation."Default Bank Account Code CZL");
            end else begin
                ResponsibilityCenter.Get(SalesHeader."Responsibility Center");
                SalesHeader.Validate("Bank Account Code CZL", ResponsibilityCenter."Default Bank Account Code CZL");
            end;
        end else
            SalesHeader.Validate("Bank Account Code CZL", Customer."Preferred Bank Account Code");
        SalesHeader."Registration No. CZL" := Customer."Registration No. CZL";
        SalesHeader."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopySellToCustomerAddressFieldsFromCustomer', '', false, false)]
    local procedure UpdateOnAfterCopySellToCustomerAddressFieldsFromCustomer(var SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer)
    begin
        SalesHeader."Registration No. CZL" := SellToCustomer."Registration No. CZL";
        SalesHeader."Tax Registration No. CZL" := SellToCustomer."Tax Registration No. CZL";
        SalesHeader."Transaction Type" := SellToCustomer."Transaction Type CZL";
        SalesHeader."Transaction Specification" := SellToCustomer."Transaction Specification CZL";
        SalesHeader."Transport Method" := SellToCustomer."Transport Method CZL";
        if SalesHeader.IsCreditDocType() then
            SalesHeader.Validate("Shipment Method Code", SellToCustomer."Shipment Method Code");
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

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Currency Factor', false, false)]
    local procedure UpdateVATCurrencyfactorCZLOnBeforeCurrencyFactorValidate(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if (Rec."Currency Factor" <> xRec."Currency Factor") and (Rec.IsCurrentFieldNoDiffZero(CurrFieldNo) or (xRec."Currency Factor" = 0)) then begin
            Rec.UpdateSalesLinesByFieldNo(Rec.FieldNo("Currency Factor"), false);
            Rec.UpdateVATCurrencyFactorCZL();
            Rec.CopyRecCurrencyFactortoxRecCurrencyFactor(Rec, xRec); // Elimination of double run function (synchro)
        end;
    end;
#pragma warning restore AL0432

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterUpdateCurrencyFactor', '', false, false)]
    local procedure OnAfterUpdateCurrencyFactor(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.UpdateVATCurrencyFactorCZL()
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Customer Posting Group', false, false)]
    local procedure CheckPostingGroupChangeOnBeforeCustomerPostingGroupValidate(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        PostingGroupManagementCZL: Codeunit "Posting Group Management CZL";
    begin
        if CurrFieldNo = Rec.FieldNo("Customer Posting Group") then
            PostingGroupManagementCZL.CheckPostingGroupChange(Rec."Customer Posting Group", xRec."Customer Posting Group", Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitFromSalesHeader', '', false, false)]
    local procedure UpdateBankAccountOnAfterInitFromSalesHeader(var SalesHeader: Record "Sales Header"; SourceSalesHeader: Record "Sales Header")
    begin
        SalesHeader."Bank Account Code CZL" := SourceSalesHeader."Bank Account Code CZL";
        SalesHeader."Bank Name CZL" := SourceSalesHeader."Bank Name CZL";
        SalesHeader."Bank Account No. CZL" := SourceSalesHeader."Bank Account No. CZL";
        SalesHeader."Bank Branch No. CZL" := SourceSalesHeader."Bank Branch No. CZL";
        SalesHeader."IBAN CZL" := SourceSalesHeader."IBAN CZL";
        SalesHeader."SWIFT Code CZL" := SourceSalesHeader."SWIFT Code CZL";
        SalesHeader."Transit No. CZL" := SourceSalesHeader."Transit No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnUpdateSalesLineByChangedFieldName', '', false, false)]
    local procedure UpdateSalesLineByChangedFieldName(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ChangedFieldName: Text[100]; ChangedFieldNo: Integer)
    begin
        case ChangedFieldNo of
            SalesHeader.FieldNo("Physical Transfer CZL"):
                if (SalesLine.Type = SalesLine.Type::Item) and (SalesLine."No." <> '') then
                    SalesLine."Physical Transfer CZL" := SalesHeader."Physical Transfer CZL";
        end;
    end;
}
