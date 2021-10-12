#if not CLEAN19
#pragma warning disable AL0432
codeunit 11782 "Tariff No. Handler CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Event subscribers optimized.';
    ObsoleteTag = '18.0';

    [Obsolete('Not used: moved to "Sales Posting Handler CZL" codeunit.', '18.0')]
    procedure CheckTariffNo(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        TariffNumber: Record "Tariff Number";
        CommodityCZL: Record "Commodity CZL";
        CommoditySetupCZL: Record "Commodity Setup CZL";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        TempInventoryBuffer: Record "Inventory Buffer" temporary;
        TempInventoryBuffer1: Record "Inventory Buffer" temporary;
        TempInventoryBuffer2: Record "Inventory Buffer" temporary;
        CurrencyExchangeRate2: Record "Currency Exchange Rate";
        ConfirmManagement: Codeunit "Confirm Management";
        AmountToCheckLimit: Decimal;
        LineAmount: Decimal;
        QtyToInvoice: Decimal;
        ItemNoText: Text;
        ItemUnitOfMeasureForVATNotExistErr: Label 'Unit of Measure %1 not exist for Item No. %2.', Comment = '%1 = Unit of Measure Code, %2 = Item No.';
        CommoditySetupForVATNotExistErr: Label 'Commodity Setup %1 for date %2 not exist.', Comment = '%1 = Commodity Code, %2 = Date';
        VATPostingSetupPostMismashErr: Label 'For commodity %1 and limit %2 not allowed VAT type %3 posting.\\Item List:\%4.', Comment = '%1 = Commodity Code, %2 = Commodity Limit Amount LCY, %3 = VAT Calculation Type, %4 = Item No.';
        VATPostingSetupPostMismashQst: Label 'The amount of the invoice is below the limit for Reverse VAT (%5).\\Item List:\%4\\Really post VAT type %3 for Deliverable Code %1 and limit %2?', Comment = '%1 = Commodity Code, %2 = Commodity Limit Amount LCY, %3 = VAT Calculation Type, %4 = List of Item No., %5 = AmountToCheckLimit';
    begin
        CommoditySetupCZL.SetFilter("Valid From", '..%1', SalesHeader."VAT Date CZL");
        CommoditySetupCZL.SetFilter("Valid To", '%1|%2..', 0D, SalesHeader."VAT Date CZL");

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet(false, false) then
            repeat
                QtyToInvoice := GetQtyToInvoice(SalesLine, SalesHeader.Ship);

                if VATPostingSetup.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group") and
                   (QtyToInvoice <> 0)
                then
                    if VATPostingSetup."Reverse Charge Check CZL" = ReverseChargeCheckCZL::"Limit Check" then begin
                        SalesLine.TestField("Tariff No. CZL");
                        TariffNumber.Get(SalesLine."Tariff No. CZL");

                        if not TariffNumber."Allow Empty UoM Code CZL" then
                            if SalesLine.Type = SalesLine.Type::Item then begin
                                ItemUnitofMeasure.SetRange("Item No.", SalesLine."No.");
                                ItemUnitofMeasure.SetRange(Code, TariffNumber."VAT Stat. UoM Code CZL");
                                if ItemUnitofMeasure.IsEmpty() then
                                    Error(ItemUnitOfMeasureForVATNotExistErr, TariffNumber."VAT Stat. UoM Code CZL", SalesLine."No.");
                            end else
                                if TariffNumber."VAT Stat. UoM Code CZL" <> '' then
                                    SalesLine.TestField("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");

                        if (TariffNumber."Statement Code CZL" <> '') and SalesHeader.Invoice then begin
                            TariffNumber.TestField("Statement Limit Code CZL");
                            CommodityCZL.Get(TariffNumber."Statement Limit Code CZL");
                        end else
                            Clear(CommodityCZL);

                        if CommodityCZL.Code <> '' then begin
                            CommoditySetupCZL.SetRange("Commodity Code", CommodityCZL.Code);
                            if not CommoditySetupCZL.FindLast() then
                                Error(CommoditySetupForVATNotExistErr, CommodityCZL.Code, SalesHeader."VAT Date CZL");

                            if not TempInventoryBuffer.Get(CommodityCZL.Code, Format(SalesLine."VAT Calculation Type", 0, '<Number>')) then begin
                                TempInventoryBuffer.Init();
                                TempInventoryBuffer."Item No." := CommodityCZL.Code;
                                TempInventoryBuffer."Variant Code" := Format(SalesLine."VAT Calculation Type", 0, '<Number>');
                                TempInventoryBuffer.Insert();
                                TempInventoryBuffer1.Init();
                                TempInventoryBuffer1."Item No." := CommodityCZL.Code;
                                TempInventoryBuffer1."Variant Code" := Format(SalesLine."VAT Calculation Type", 0, '<Number>');
                                TempInventoryBuffer1.Insert();
                            end;

                            LineAmount := SalesLine."Line Amount";
                            if SalesHeader."Currency Code" <> '' then
                                LineAmount :=
                                  CurrencyExchangeRate2.ExchangeAmtFCYToLCY(
                                    SalesHeader."Posting Date", SalesHeader."Currency Code",
                                    LineAmount, SalesHeader."Currency Factor");

                            TempInventoryBuffer.Quantity += LineAmount;
                            TempInventoryBuffer.Modify();
                            TempInventoryBuffer1.Get(CommodityCZL.Code, Format(SalesLine."VAT Calculation Type", 0, '<Number>'));
                            TempInventoryBuffer1.Quantity += LineAmount;
                            TempInventoryBuffer1.Modify();

                            if not TempInventoryBuffer2.Get(CommodityCZL.Code, Format(SalesLine."VAT Calculation Type", 0, '<Number>'), 0, '', '', SalesLine."No.") then begin
                                TempInventoryBuffer2.Init();
                                TempInventoryBuffer2."Item No." := CommodityCZL.Code;
                                TempInventoryBuffer2."Variant Code" := Format(SalesLine."VAT Calculation Type", 0, '<Number>');
                                TempInventoryBuffer2."Lot No." := SalesLine."No.";
                                TempInventoryBuffer2.Insert();
                            end;
                        end;
                    end;
            until SalesLine.Next() = 0;

        if not SalesHeader.Invoice then
            exit;

        if TempInventoryBuffer.FindSet() then
            repeat
                CommoditySetupCZL.SetRange("Commodity Code", TempInventoryBuffer."Item No.");
                CommoditySetupCZL.FindLast();

                TempInventoryBuffer.SetRange("Item No.", TempInventoryBuffer."Item No.");
                Clear(AmountToCheckLimit);
                Clear(ItemNoText);
                if TempInventoryBuffer.Count > 1 then
                    repeat
                        AmountToCheckLimit += TempInventoryBuffer.Quantity;
                        ItemNoText := GetListItemNo(TempInventoryBuffer2, TempInventoryBuffer);
                    until TempInventoryBuffer.Next() = 0
                else begin
                    AmountToCheckLimit := TempInventoryBuffer.Quantity;
                    ItemNoText := GetListItemNo(TempInventoryBuffer2, TempInventoryBuffer);
                end;

                TempInventoryBuffer.SetRange("Item No.");

                if AmountToCheckLimit < CommoditySetupCZL."Commodity Limit Amount LCY" then begin
                    // Normal
                    if TempInventoryBuffer1.Get(TempInventoryBuffer."Item No.", Format(SalesLine."VAT Calculation Type"::"Reverse Charge VAT", 0, '<Number>')) then
                        if not ConfirmManagement.GetResponseOrDefault(StrSubStno(VATPostingSetupPostMismashQst,
                             CommoditySetupCZL."Commodity Code", CommoditySetupCZL."Commodity Limit Amount LCY",
                             SalesLine."VAT Calculation Type"::"Reverse Charge VAT", ItemNoText, AmountToCheckLimit), false)
                        then
                            Error('');
                end else
                    // Reverse
                    if TempInventoryBuffer1.Get(TempInventoryBuffer."Item No.", Format(SalesLine."VAT Calculation Type"::"Normal VAT", 0, '<Number>')) then
                        Error(VATPostingSetupPostMismashErr, CommoditySetupCZL."Commodity Code", CommoditySetupCZL."Commodity Limit Amount LCY",
                          SalesLine."VAT Calculation Type"::"Normal VAT", ItemNoText);

            until TempInventoryBuffer.Next() = 0;
    end;

    [Obsolete('Not used: moved to "Purchase Posting Handler CZL" codeunit.', '18.0')]
    procedure CheckTariffNo(PurchHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
        TariffNumber: Record "Tariff Number";
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchHeader."No.");
        if PurchaseLine.FindSet(false, false) then
            repeat
                if VATPostingSetup.Get(PurchaseLine."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group") then
                    if VATPostingSetup."Reverse Charge Check CZL" = ReverseChargeCheckCZL::"Limit Check" then
                        if not ((PurchaseLine.Type = PurchaseLine.Type::"G/L Account") and
                                (VATPostingSetup."Purch. Ded. VAT Base Adj. Acc." = PurchaseLine."No."))
                        then begin
                            PurchaseLine.TestField("Tariff No. CZL");
                            if TariffNumber.Get(PurchaseLine."Tariff No. CZL") then
                                if TariffNumber."VAT Stat. UoM Code CZL" <> '' then
                                    PurchaseLine.TestField("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");
                        end;
            until PurchaseLine.Next() = 0;
    end;

    [Obsolete('Optimized: moved to "Sales Posting Handler CZL" codeunit.', '18.0')]
    local procedure GetListItemNo(var TempInvtBuf2: Record "Inventory Buffer" temporary; TempInvtBuf: Record "Inventory Buffer" temporary): Text
    var
        ItemNoText: Text;
    begin
        ItemNoText := '';

        TempInvtBuf2.SetRange("Item No.", TempInvtBuf."Item No.");
        TempInvtBuf2.SetRange("Variant Code", TempInvtBuf."Variant Code");
        if TempInvtBuf2.FindSet() then
            repeat
                if (StrLen(ItemNoText) + StrLen(TempInvtBuf2."Lot No.") + 2) < MaxStrLen(ItemNoText) then
                    if ItemNoText <> '' then
                        ItemNoText := ItemNoText + ', ' + TempInvtBuf2."Lot No."
                    else
                        ItemNoText := TempInvtBuf2."Lot No.";
            until TempInvtBuf2.Next() = 0;

        exit(ItemNoText);
    end;

    [Obsolete('Not used: moved to "Service Posting Handler CZL" codeunit.', '18.0')]
    procedure CheckTariffNo(ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
        VATPostingSetup: Record "VAT Posting Setup";
        TariffNumber: Record "Tariff Number";
    begin
        ServiceLine.Reset();
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        if ServiceLine.FindSet(false, false) then
            repeat
                if VATPostingSetup.Get(ServiceLine."VAT Bus. Posting Group", ServiceLine."VAT Prod. Posting Group") then
                    if VATPostingSetup."Reverse Charge Check CZL" = ReverseChargeCheckCZL::"Limit Check" then begin
                        ServiceLine.TestField("Tariff No. CZL");
                        if TariffNumber.Get(ServiceLine."Tariff No. CZL") then
                            if TariffNumber."VAT Stat. UoM Code CZL" <> '' then
                                ServiceLine.TestField("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");
                    end;
            until ServiceLine.Next() = 0;
    end;

    [Obsolete('Optimized: moved to "Sales Posting Handler CZL" codeunit.', '18.0')]
    local procedure GetQtyToInvoice(SalesLine: Record "Sales Line"; Ship: Boolean): Decimal
    var
        AllowedQtyToInvoice: Decimal;
    begin
        AllowedQtyToInvoice := SalesLine."Qty. Shipped Not Invoiced";
        if Ship then
            AllowedQtyToInvoice := AllowedQtyToInvoice + SalesLine."Qty. to Ship";
        if SalesLine."Qty. to Invoice" > AllowedQtyToInvoice then
            exit(AllowedQtyToInvoice);
        exit(SalesLine."Qty. to Invoice");
    end;

    var
        ReverseChargeCheckCZL: Enum "Reverse Charge Check CZL";
}
#endif