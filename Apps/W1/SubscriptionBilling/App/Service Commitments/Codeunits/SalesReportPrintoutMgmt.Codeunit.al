namespace Microsoft.SubscriptionBilling;

using System.Text;
using System.Reflection;
using Microsoft.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Item;
using Microsoft.Finance.Currency;
codeunit 8073 "Sales Report Printout Mgmt."
{
    Access = Internal;
    SingleInstance = true;

    var
        ReportFormatting: Codeunit "Report Formatting";
        RecurringServicesTotalLbl: Label 'Recurring Services (*)';
        RecurringServicesPerLineLbl: Label 'Recurring Services*';
        ServicePriceLbl: Label 'Service Price';
        ServiceDiscountPercLbl: Label 'Service Discount %';
        TotalTextTok: Label 'TotalText', Locked = true;

    [InternalEvent(false, false)]
    local procedure OnBeforeFormatSalesLineExcludeLineInTotals(var SalesLine: Record "Sales Line"; var IncludeLineInTotals: Boolean; var IsHandled: Boolean)
    begin
    end;

    internal procedure ExcludeItemFromTotals(var SalesLine: Record "Sales Line"; var TotalSubTotal: Decimal; var TotalInvDiscAmount: Decimal; var TotalAmount: Decimal; var TotalAmountVAT: Decimal; var TotalAmountInclVAT: Decimal)
    var
        Item: Record Item;
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
        ContractsItemManagement: Codeunit "Contracts Item Management";
        IsHandled: Boolean;
        IncludeLineInTotals: Boolean;
    begin
        IncludeLineInTotals := true;
        IsHandled := false;
        OnBeforeFormatSalesLineExcludeLineInTotals(SalesLine, IncludeLineInTotals, IsHandled);
        if IsHandled then
            exit;
        if ContractRenewalMgt.IsContractRenewal(SalesLine) then
            IncludeLineInTotals := false;
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        if not Item.Get(SalesLine."No.") then
            exit;

        if ContractsItemManagement.IsServiceCommitmentItem(Item."No.") then
            IncludeLineInTotals := false;
        if not IncludeLineInTotals then
            ReduceTotalsForSalesLine(SalesLine, TotalSubTotal, TotalInvDiscAmount, TotalAmount, TotalAmountVAT, TotalAmountInclVAT);
    end;

    local procedure ReduceTotalsForSalesLine(var SalesLine: Record "Sales Line"; var TotalSubTotal: Decimal; var TotalInvDiscAmount: Decimal; var TotalAmount: Decimal; var TotalAmountVAT: Decimal; var TotalAmountInclVAT: Decimal)
    begin
        TotalSubTotal -= SalesLine.Amount;
        TotalInvDiscAmount += SalesLine."Inv. Discount Amount";
        TotalAmount -= SalesLine.Amount;
        TotalAmountVAT -= (SalesLine."Amount Including VAT" - SalesLine.Amount);
        TotalAmountInclVAT -= SalesLine."Amount Including VAT";
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Order Conf.", OnLineOnAfterGetRecordOnBeforeCalcVATAmountLines, '', false, false)]
    local procedure SalesOrderOnBeforeCalcVATAmountLines(var SalesLine: Record "Sales Line")
    begin
        SetFilterForVatCalculationOnSalesLine(SalesLine);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Order Conf.", OnHeaderOnAfterGetRecordOnAfterUpdateVATOnLines, '', false, false)]
    local procedure SalesOrderOnAfterUpdateVATOnLines(var SalesLine: Record "Sales Line")
    begin
        ResetFilterForVatCalculationOnSalesLine(SalesLine);
    end;

    procedure FillServiceCommitmentsGroups(var SalesHeader: Record "Sales Header"; var ServCommGroupPerPeriod: Record "Name/Value Buffer"; var ServCommGroup: Record "Name/Value Buffer")
    begin
        FillServiceCommitmentsGroupPerPeriod(SalesHeader, ServCommGroupPerPeriod);
        if ServCommGroupPerPeriod.FindSet() then begin
            repeat
                ServCommGroup.SetRange("Value Long", ServCommGroupPerPeriod."Value Long");
                if ServCommGroup.IsEmpty then begin
                    ServCommGroup.Reset();
                    ReportFormatting.AddValueToBuffer(ServCommGroup, '', '', ServCommGroupPerPeriod."Value Long");
                end else
                    ServCommGroup.Reset();
            until ServCommGroupPerPeriod.Next() = 0;
            ServCommGroup.Reset();
        end;
    end;

    procedure FillServiceCommitmentsGroupPerPeriod(var SalesHeader: Record "Sales Header"; var GroupPerPeriod: Record "Name/Value Buffer")
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
        TempSalesServiceCommitmentBuff: Record "Sales Service Commitment Buff." temporary;
        FormatDocument: Codeunit "Format Document";
        TotalText: Text[50];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        UniqueRhythmDictionary: Dictionary of [Code[20], Text];
        IsHandled: Boolean;
    begin
        FormatDocument.SetTotalLabels(SalesHeader.GetCurrencySymbol(), TotalText, TotalInclVATText, TotalExclVATText);
        SalesServiceCommitment.CalcVATAmountLines(SalesHeader, TempSalesServiceCommitmentBuff, UniqueRhythmDictionary);
        OnBeforeFillServiceCommitmentsGroupPerPeriod(SalesHeader, TempSalesServiceCommitmentBuff, GroupPerPeriod, UniqueRhythmDictionary, TotalText, TotalInclVATText, TotalExclVATText, IsHandled);
        if not IsHandled then
            FillServiceCommitmentsGroupPerPeriod(TempSalesServiceCommitmentBuff, GroupPerPeriod, UniqueRhythmDictionary, SalesHeader."Currency Code", TotalInclVATText, TotalExclVATText);
    end;

    procedure FillServiceCommitmentsForLine(var SalesHeader: Record "Sales Header"; var SalesLineServiceCommitments: Record "Sales Line"; var SalesLineServiceCommitmentsCaption: Record "Name/Value Buffer")
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
        ShowDiscount: Boolean;
    begin
        SalesServiceCommitment.SetRange("Document Type", SalesHeader."Document Type");
        SalesServiceCommitment.SetRange("Document No.", SalesHeader."No.");
        SalesServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        SalesServiceCommitment.SetRange("Invoicing via", SalesServiceCommitment."Invoicing via"::Contract);
        if SalesServiceCommitment.FindSet() then begin
            repeat
                SalesLineServiceCommitments.Init();
                SalesLineServiceCommitments."Document Type" := SalesServiceCommitment."Document Type";
                SalesLineServiceCommitments."Document No." := Format(SalesServiceCommitment."Document Line No.");
                SalesLineServiceCommitments."Line No." := SalesServiceCommitment."Line No.";
                SalesLineServiceCommitments.Description := SalesServiceCommitment.Description;
                SalesLineServiceCommitments."Line Discount %" := -Round(SalesServiceCommitment."Discount %", 0.1);
                SalesLineServiceCommitments."Unit Price" := SalesServiceCommitment.Price;
                SalesLineServiceCommitments.Insert(false);
                if SalesServiceCommitment."Discount %" <> 0 then
                    ShowDiscount := true;
            until SalesServiceCommitment.Next() = 0;
            // Adds captions for Line Details
            ReportFormatting.AddValueToBuffer(SalesLineServiceCommitmentsCaption, TotalTextTok, RecurringServicesTotalLbl);
            ReportFormatting.AddValueToBuffer(SalesLineServiceCommitmentsCaption, SalesLineServiceCommitments.FieldName(Description), RecurringServicesPerLineLbl);
            if ShowDiscount then
                ReportFormatting.AddValueToBuffer(SalesLineServiceCommitmentsCaption, SalesLineServiceCommitments.FieldName("Line Discount %"), ServiceDiscountPercLbl);
            ReportFormatting.AddValueToBuffer(SalesLineServiceCommitmentsCaption, SalesLineServiceCommitments.FieldName("Unit Price"), ServicePriceLbl);
        end;
    end;

    local procedure SetFilterForVatCalculationOnSalesLine(var Line: Record "Sales Line")
    var
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
        ContractsItemManagement: Codeunit "Contracts Item Management";
    begin
        if Line.FindSet() then
            repeat
                Line.Mark(true);
                if ContractRenewalMgt.IsContractRenewal(Line) then
                    Line.Mark(false)
                else
                    if Line.Type = Enum::"Sales Line Type"::Item then
                        if ContractsItemManagement.IsServiceCommitmentItem(Line."No.") then
                            Line.Mark(false);
            until Line.Next() = 0;
        Line.MarkedOnly(true);
    end;

    local procedure ResetFilterForVatCalculationOnSalesLine(var Line: Record "Sales Line")
    begin
        Line.MarkedOnly(false);
    end;

    local procedure FillServiceCommitmentsGroupPerPeriod(var TempSalesServiceCommitmentBuff: Record "Sales Service Commitment Buff." temporary; var GroupPerPeriod: Record "Name/Value Buffer"; var UniqueRhythmDictionary: Dictionary of [Code[20], Text]; CurrencyCode: Code[10]; TotalInclVATText: Text[50]; TotalExclVATText: Text[50])
    var
        Currency: Record Currency;
        AutoFormat: Codeunit "Auto Format";
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
        ReportFormatting: Codeunit "Report Formatting";
        RhythmIdentifier: Code[20];
        AutoFormatType: Enum "Auto Format";
        BillingRhythmLbl: Label 'Per %1', Comment = '%1 = Billing Rhythm Text';
        PlaceholderLbl: Label '%1', Comment = '%1 = Billing Rhythm Text', Locked = true;
        VATTextLbl: Label 'VAT Amount';
        BillingRhythmPlaceholderTxt: Text;
        FormatTotal: Text[50];
        FormatDecimal: Text[50];
    begin
        Currency.Initialize(CurrencyCode);
        foreach RhythmIdentifier in UniqueRhythmDictionary.Keys() do begin
            TempSalesServiceCommitmentBuff.Reset();
            TempSalesServiceCommitmentBuff.SetRange("Rhythm Identifier", RhythmIdentifier);
            TempSalesServiceCommitmentBuff.CalcSums("VAT Base");
            BillingRhythmPlaceholderTxt := BillingRhythmLbl;
            if RhythmIdentifier = ContractRenewalMgt.GetContractRenewalIdentifierLabel() then
                BillingRhythmPlaceholderTxt := PlaceholderLbl;
            // Set VAT Header with Total
            FormatTotal := Format(TempSalesServiceCommitmentBuff."VAT Base", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, Currency.Code));
            ReportFormatting.AddValueToBuffer(GroupPerPeriod, TotalExclVATText, FormatTotal, StrSubstNo(BillingRhythmPlaceholderTxt, UniqueRhythmDictionary.Get(RhythmIdentifier)));
            // Set Body with VAT entries
            if TempSalesServiceCommitmentBuff.FindSet() then
                repeat
                    FormatDecimal := Format(TempSalesServiceCommitmentBuff."VAT Amount", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, Currency.Code));
                    ReportFormatting.AddValueToBuffer(GroupPerPeriod, VATTextLbl + ' [' + Format(TempSalesServiceCommitmentBuff."VAT %") + '%]', FormatDecimal, StrSubstNo(BillingRhythmPlaceholderTxt, UniqueRhythmDictionary.Get(RhythmIdentifier)));
                until TempSalesServiceCommitmentBuff.Next() = 0;
            // Set VAT Footer with Total
            TempSalesServiceCommitmentBuff.CalcSums("Amount Including VAT");
            FormatTotal := Format(TempSalesServiceCommitmentBuff."Amount Including VAT", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, Currency.Code));
            ReportFormatting.AddValueToBuffer(GroupPerPeriod, TotalInclVATText, FormatTotal, StrSubstNo(BillingRhythmPlaceholderTxt, UniqueRhythmDictionary.Get(RhythmIdentifier)));
        end;
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeFillServiceCommitmentsGroupPerPeriod(SalesHeader: Record "Sales Header"; var TempSalesServiceCommitmentBuff: Record "Sales Service Commitment Buff." temporary; var GroupPerPeriod: Record "Name/Value Buffer"; var UniqueRhythmDictionary: Dictionary of [Code[20], Text]; TotalText: Text[50]; TotalInclVATText: Text[50]; TotalExclVATText: Text[50]; var IsHandled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Format Document", OnAfterSetSalesLine, '', false, false)]
    local procedure SalesLineAddMarkToFormattedLineAmount(var SalesLine: Record "Sales Line"; var FormattedLineAmount: Text)
    begin
        if CheckAppendAsteriskToFormattedLineAmount(SalesLine) then
            AppendAsteriskToText(FormattedLineAmount);
    end;

    local procedure CheckAppendAsteriskToFormattedLineAmount(SourceRecord: Variant): Boolean
    begin
        exit(IsServiceCommitmentItem(SourceRecord));
    end;

    local procedure IsServiceCommitmentItem(SourceRecord: Variant): Boolean
    var
        SalesLine: Record "Sales Line";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        SourceRecordNotDefinedForProcessingErr: Label 'Table %1 %2 has not been defined for processing.';
    begin
        DataTypeManagement.GetRecordRef(SourceRecord, RecRef);
        case RecRef.Number of
            Database::"Sales Line":
                begin
                    RecRef.SetTable(SalesLine);
                    exit(SalesLine.IsServiceCommitmentItem());
                end;
            else
                Error(SourceRecordNotDefinedForProcessingErr, RecRef.Number, RecRef.Caption());
        end;
    end;

    local procedure AppendAsteriskToText(var TextToAppendAsterisk: Text)
    begin
        if DelChr(TextToAppendAsterisk) = '' then
            exit;
        TextToAppendAsterisk += '*';
    end;
}