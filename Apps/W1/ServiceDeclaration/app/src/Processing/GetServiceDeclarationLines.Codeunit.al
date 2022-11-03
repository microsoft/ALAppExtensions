codeunit 5013 "Get Service Declaration Lines"
{
    TableNo = "Service Declaration Header";

    trigger OnRun()
    var
        ServiceDeclarationLine: Record "Service Declaration Line";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        ServiceDeclarationLine.SetRange("Service Declaration No.", Rec."No.");
        if not ServiceDeclarationLine.IsEmpty() then
            if not ConfirmManagement.GetResponseOrDefault(RecreateLinesQst, false) then
                exit;

        AddLines(Rec);
    end;

    var
        RecreateLinesQst: Label 'The service declaration lines have already been suggested. Do you want to remove the existing lines and suggest again?';

    local procedure AddLines(ServiceDeclarationHeader: Record "Service Declaration Header")
    var
        ValueEntry: Record "Value Entry";
        ServiceDeclarationLine: Record "Service Declaration Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
    begin
        ServiceDeclarationLine.SetRange("Service Declaration No.", ServiceDeclarationHeader."No.");
        ServiceDeclarationLine.DeleteAll(true);

        ValueEntry.SetCurrentKey("Item Ledger Entry Type", "Posting Date", "Applicable For Serv. Decl.");
        ValueEntry.SetFilter(
          "Item Ledger Entry Type", '%1|%2', ValueEntry."Item Ledger Entry Type"::Sale, ValueEntry."Item Ledger Entry Type"::Purchase);
        ValueEntry.SetRange("Posting Date", ServiceDeclarationHeader."Starting Date", ServiceDeclarationHeader."Ending Date");
        ValueEntry.SetRange("Applicable For Serv. Decl.", true);
        if not ValueEntry.FindSet() then
            exit;

        ServiceDeclarationLine.Init();
        ServiceDeclarationLine."Service Declaration No." := ServiceDeclarationHeader."No.";
        repeat
            ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
            ServiceDeclarationLine."Line No." += 10000;
            ServiceDeclarationLine."Posting Date" := ItemLedgerEntry."Posting Date";
            ServiceDeclarationLine."Document Type" := ValueEntry."Document Type";
            ServiceDeclarationLine."Document No." := ValueEntry."Document No.";
            ServiceDeclarationLine."Item Charge No." := ValueEntry."Item Charge No.";
            ServiceDeclarationLine.Description := ItemLedgerEntry.Description;

            ServiceDeclarationLine."Service Transaction Code" := ValueEntry."Service Transaction Type Code";
            ServiceDeclarationLine."Country/Region Code" := ItemLedgerEntry."Country/Region Code";
            ServiceDeclarationLine."Sales Amount (LCY)" := ValueEntry."Sales Amount (Actual)";
            ServiceDeclarationLine."Purchase Amount (LCY)" := ValueEntry."Purchase Amount (Actual)";
            GetCurrencyInfoFromValueEntry(CurrencyCode, CurrencyFactor, ValueEntry);
            if CurrencyCode = '' then begin
                GeneralLedgerSetup.Get();
                ServiceDeclarationLine."Currency Code" := GeneralLedgerSetup."LCY Code";
            end else begin
                Currency.Get(CurrencyCode);
                ServiceDeclarationLine."Currency Code" := CurrencyCode;
                ValueEntry."Sales Amount (Actual)" :=
                  Round(
                    CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                      ValueEntry."Posting Date", CurrencyCode, ValueEntry."Sales Amount (Actual)", CurrencyFactor),
                    Currency."Amount Rounding Precision");
                ValueEntry."Purchase Amount (Actual)" :=
                  Round(
                    CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                      ValueEntry."Posting Date", CurrencyCode, ValueEntry."Purchase Amount (Actual)", CurrencyFactor),
                    Currency."Amount Rounding Precision");
            end;
            ServiceDeclarationLine."VAT Registration No." := GetVATRegistrationNoFromItemLedgEntry(ItemLedgerEntry);
            ServiceDeclarationLine."Sales Amount" := ValueEntry."Sales Amount (Actual)";
            ServiceDeclarationLine."Purchase Amount" := ValueEntry."Purchase Amount (Actual)";
            ServiceDeclarationLine.Insert();
        until ValueEntry.Next() = 0;
    end;

    local procedure GetCurrencyInfoFromValueEntry(var CurrencyCode: Code[10]; var CurrencyFactor: Decimal; ValueEntry: Record "Value Entry")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        CurrencyCode := '';
        CurrencyFactor := 0;

        case ValueEntry."Item Ledger Entry Type" of
            ValueEntry."Item Ledger Entry Type"::Sale:
                begin
                    case ValueEntry."Document Type" of
                        ValueEntry."Document Type"::"Sales Invoice":
                            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                        ValueEntry."Document Type"::"Sales Credit Memo":
                            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
                    end;
                    CustLedgerEntry.SetRange("Document No.", ValueEntry."Document No.");
                    CustLedgerEntry.SetRange("Posting Date", ValueEntry."Posting Date");
                    if CustLedgerEntry.FindFirst() then begin
                        CurrencyCode := CustLedgerEntry."Currency Code";
                        CurrencyFactor := CustLedgerEntry."Adjusted Currency Factor";
                        if CurrencyFactor = 0 then
                            CurrencyFactor := CustLedgerEntry."Original Currency Factor";
                        exit;
                    end;
                    if ValueEntry."Source Type" = ValueEntry."Source Type"::Customer then
                        if Customer.Get(ValueEntry."Source No.") then
                            CurrencyCode := Customer."Currency Code";
                    if CurrencyCode <> '' then
                        CurrencyFactor := CurrencyExchangeRate.ExchangeRate(ValueEntry."Posting Date", CurrencyCode);
                end;
            ValueEntry."Item Ledger Entry Type"::Purchase:
                begin
                    case ValueEntry."Document Type" of
                        ValueEntry."Document Type"::"Sales Invoice":
                            VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
                        ValueEntry."Document Type"::"Sales Credit Memo":
                            VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::"Credit Memo");
                    end;
                    VendorLedgerEntry.SetRange("Document No.", ValueEntry."Document No.");
                    VendorLedgerEntry.SetRange("Posting Date", ValueEntry."Posting Date");
                    if VendorLedgerEntry.FindFirst() then begin
                        CurrencyCode := VendorLedgerEntry."Currency Code";
                        CurrencyFactor := VendorLedgerEntry."Adjusted Currency Factor";
                        if CurrencyFactor = 0 then
                            CurrencyFactor := VendorLedgerEntry."Original Currency Factor";
                        exit;
                    end;
                    if ValueEntry."Source Type" = ValueEntry."Source Type"::Vendor then
                        if Vendor.Get(ValueEntry."Source No.") then
                            CurrencyCode := Vendor."Currency Code";
                    if CurrencyCode <> '' then
                        CurrencyFactor := CurrencyExchangeRate.ExchangeRate(ValueEntry."Posting Date", CurrencyCode);
                end;
        end;
    end;

    local procedure GetVATRegistrationNoFromItemLedgEntry(ItemLedgEntry: Record "Item Ledger Entry"): Text[20]
    var
        ServDeclSetup: Record "Service Declaration Setup";
        VATEntry: Record "VAT Entry";
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        ServDeclSetup.Get();
        if not ServDeclSetup."Enable VAT Registration No." then
            exit('');

        VATEntry.SetRange("Document Type", ItemLedgEntry."Document Type");
        VATEntry.SetRange("Document No.", ItemLedgEntry."Document No.");
        VATEntry.SetRange("Posting Date", ItemLedgEntry."Posting Date");
        if VATEntry.FindFirst() and (VATEntry."VAT Registration No." <> '') then
            exit(VATEntry."VAT Registration No.");

        case ItemLedgEntry."Source Type" of
            ItemLedgEntry."Source Type"::Customer:
                if Customer.Get(ItemLedgEntry."Source No.") then
                    exit(Customer."VAT Registration No.");
            ItemLedgEntry."Source Type"::Vendor:
                if Vendor.Get(ItemLedgEntry."Source No.") then
                    exit(Vendor."VAT Registration No.");
        end;
    end;
}

