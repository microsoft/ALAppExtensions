namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
using Microsoft.Finance.Currency;

codeunit 8062 "Billing Proposal"
{
    Access = Internal;

    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        CreateBillingDocuments: Codeunit "Create Billing Documents";
        DateFormulaManagement: Codeunit "Date Formula Management";
        SessionStore: Codeunit "Session Store";
        CreateBillingDocumentPage: Page "Create Billing Document";
        LastContractNo: Code[20];
        LastPartnerNo: Code[20];
        BillingToChangeNotAllowedErr: Label 'A change of Billing to field from %1 to %2 for %3 and %4 is not allowed because the service has already been calculated up to %5.';
        NoBillingDateErr: Label 'Please enter the Billing Date.';
        BillingToChangeNotAllowedDocNoExistsErr: Label 'Billing to field is not allowed to change because an unposted invoice or credit memo exists.';
        CreditMemoPreventsProposalCreationLbl: Label 'The credit memos listed here must be posted or deleted before further billing lines can be created.';
        BillingLineWithoutInvoiceExistsQst: Label 'Billing lines without invoice exists. Contract line with existing billing line will not be considered when creating an invoice from the contract. Do you want to continue?';
        BillingLineWithUnpostedSalesInvoiceExistsQst: Label 'Billing line with unposted Sales Invoice exists. New invoices cannot be created until the current invoice is posted. Do you want to open the invoice?';
        BillingLineWithUnpostedPurchaseInvoiceExistsQst: Label 'Billing line with unposted Purchase Invoice exists. New invoices cannot be created until the current invoice is posted. Do you want to open the invoice?';
        SalesCreditMemoExistsForBillingLineQst: Label 'There is a sales credit memo that needs to be posted before an invoice can be created. Do you want to open the credit memo?';
        PurchaseCreditMemoExistsForBillingLineQst: Label 'There is a purchase credit memo that needs to be posted before an invoice can be created. Do you want to open the credit memo?';
        BillingLinesForAllContractLinesExistsErr: Label 'There are billing lines for all contract lines. For contract lines with billing lines, the invoice must be created in recurring billing.';
        BillingPeriodStart, BillingPeriodEnd : Date;

    internal procedure InitTempTable(var TempBillingLine: Record "Billing Line" temporary; GroupBy: Enum "Contract Billing Grouping")
    var
        BillingLine: Record "Billing Line";
        TempBillingLine2: Record "Billing Line" temporary;
        TempGroupBillingLine: Record "Billing Line" temporary;
        NextEntryNo: Integer;
    begin
        TempBillingLine2.CopyFilters(TempBillingLine);
        BillingLine.CopyFilters(TempBillingLine);
        TempBillingLine.Reset();
        TempBillingLine.DeleteAll(false);

        SetKeysForGrouping(BillingLine, TempBillingLine, GroupBy);

        if BillingLine.FindSet() then
            repeat
                UpdateGroupingLine(TempGroupBillingLine, BillingLine, GroupBy);
                TempBillingLine := BillingLine;
                TempBillingLine.Indent := 1;
                TempBillingLine.Insert(false);
            until BillingLine.Next() = 0;
        if TempGroupBillingLine.FindSet() then
            repeat
                TempBillingLine := TempGroupBillingLine;
                NextEntryNo -= 1;
                TempBillingLine."Entry No." := NextEntryNo;
                TempBillingLine.Insert(false);
            until TempGroupBillingLine.Next() = 0;

        TempBillingLine.CopyFilters(TempBillingLine2);
        OnAfterInitTempTable(TempBillingLine, GroupBy);
    end;

    local procedure SetKeysForGrouping(var BillingLine: Record "Billing Line"; var TempBillingLine: Record "Billing Line" temporary; GroupBy: Enum "Contract Billing Grouping")
    begin
        case GroupBy of
            GroupBy::Contract:
                begin
                    BillingLine.SetCurrentKey("Contract No.", "Contract Line No.", "Billing from");
                    TempBillingLine.SetCurrentKey("Contract No.", "Contract Line No.", "Billing from");
                    LastContractNo := '';
                end;
            GroupBy::"Contract Partner":
                begin
                    BillingLine.SetCurrentKey("Partner No.", "Contract No.", "Contract Line No.", "Billing from");
                    TempBillingLine.SetCurrentKey("Partner No.", "Contract No.", "Contract Line No.", "Billing from");
                    LastPartnerNo := '';
                end;
            GroupBy::None:
                TempBillingLine.SetCurrentKey("Partner No.", "Contract No.", "Contract Line No.", "Billing from");
        end;
    end;

    local procedure UpdateGroupingLine(var TempGroupBillingLine: Record "Billing Line" temporary; BillingLine: Record "Billing Line"; GroupBy: Enum "Contract Billing Grouping")
    begin
        if GroupingLineShouldBeInserted(BillingLine, GroupBy) then begin
            TempGroupBillingLine.Init();
            TempGroupBillingLine."User ID" := BillingLine."User ID";
            TempGroupBillingLine."Entry No." := BillingLine."Entry No.";
            TempGroupBillingLine.Partner := BillingLine.Partner;
            TempGroupBillingLine."Partner No." := BillingLine."Partner No.";
            if GroupBy = GroupBy::Contract then
                TempGroupBillingLine."Contract No." := BillingLine."Contract No.";
            TempGroupBillingLine."Service Amount" := GetServiceAmount(BillingLine, GroupBy);
            TempGroupBillingLine.Indent := 0;
            if BillingLine."Update Required" then
                TempGroupBillingLine."Update Required" := BillingLine."Update Required";
            TempGroupBillingLine.Insert(false);
        end;

        if GroupBy = GroupBy::Contract then begin
            if (BillingLine."Billing from" < TempGroupBillingLine."Billing from") or (TempGroupBillingLine."Billing from" = 0D) then begin
                TempGroupBillingLine."Billing from" := BillingLine."Billing from";
                TempGroupBillingLine.Modify(false);
            end;
            if BillingLine."Billing to" > TempGroupBillingLine."Billing to" then begin
                TempGroupBillingLine."Billing to" := BillingLine."Billing to";
                TempGroupBillingLine.Modify(false);
            end;
        end;
    end;

    local procedure GetServiceAmount(BillingLine: Record "Billing Line"; GroupBy: Enum "Contract Billing Grouping"): Decimal
    var
        ContractBillingLine2: Record "Billing Line";
    begin
        if GroupBy = GroupBy::None then
            exit;

        case GroupBy of
            GroupBy::Contract:
                ContractBillingLine2.SetRange("Contract No.", BillingLine."Contract No.");
            GroupBy::"Contract Partner":
                ContractBillingLine2.SetRange("Partner No.", BillingLine."Partner No.");
        end;
        ContractBillingLine2.CalcSums("Service Amount");
        exit(ContractBillingLine2."Service Amount");
    end;

    local procedure GroupingLineShouldBeInserted(BillingLine: Record "Billing Line"; GroupBy: Enum "Contract Billing Grouping") InsertLine: Boolean
    begin
        case GroupBy of
            GroupBy::Contract:
                begin
                    InsertLine := LastContractNo <> BillingLine."Contract No.";
                    if InsertLine then
                        LastContractNo := BillingLine."Contract No.";
                end;
            GroupBy::"Contract Partner":
                begin
                    InsertLine := LastPartnerNo <> BillingLine."Partner No.";
                    if InsertLine then
                        LastPartnerNo := BillingLine."Partner No.";
                end;
        end;
    end;

    internal procedure CreateBillingProposal(BillingTemplateCode: Code[20]; BillingDate: Date; BillingToDate: Date)
    var
        BillingTemplate: Record "Billing Template";
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        FilterText: Text;
        BillingRhythmFilterText: Text;
    begin
        SalesHeader.Reset();
        BillingTemplate.Get(BillingTemplateCode);
        if BillingDate = 0D then
            Error(NoBillingDateErr);

        if not DeleteUpdateRequiredBillingLines(BillingTemplateCode) then
            exit;

        if BillingTemplate.Filter.HasValue() then
            FilterText := BillingTemplate.ReadFilter(BillingTemplate.FieldNo(Filter));

        case BillingTemplate.Partner of
            "Service Partner"::Customer:
                begin
                    if FilterText <> '' then
                        CustomerContract.SetView(FilterText);
                    BillingRhythmFilterText := CustomerContract.GetFilter("Billing Rhythm Filter");
                    if CustomerContract.FindSet() then
                        repeat
                            ProcessContractServiceCommitments(BillingTemplate, CustomerContract."No.", '', BillingDate, BillingToDate, BillingRhythmFilterText);
                        until CustomerContract.Next() = 0;
                end;
            "Service Partner"::Vendor:
                begin
                    if FilterText <> '' then
                        VendorContract.SetView(FilterText);
                    BillingRhythmFilterText := VendorContract.GetFilter("Billing Rhythm Filter");
                    if VendorContract.FindSet() then
                        repeat
                            ProcessContractServiceCommitments(BillingTemplate, VendorContract."No.", '', BillingDate, BillingToDate, BillingRhythmFilterText);
                        until VendorContract.Next() = 0;
                end;
        end;

        case BillingTemplate.Partner of
            Enum::"Service Partner"::Customer:
                begin
                    SalesHeader.MarkedOnly(true);
                    if SalesHeader.Count <> 0 then begin
                        Page.Run(Page::"Sales Credit Memos", SalesHeader);
                        Message(CreditMemoPreventsProposalCreationLbl);
                    end;
                end;
            Enum::"Service Partner"::Vendor:
                begin
                    PurchaseHeader.MarkedOnly(true);
                    if PurchaseHeader.Count <> 0 then begin
                        Page.Run(Page::"Purchase Credit Memos", PurchaseHeader);
                        Message(CreditMemoPreventsProposalCreationLbl);
                    end;
                end;
        end;
    end;

    local procedure ProcessContractServiceCommitments(BillingTemplate: Record "Billing Template"; ContractNo: Code[20]; ContractLineFilter: Text; BillingDate: Date; BillingToDate: Date; BillingRhythmFilterText: Text)
    var
        ServiceCommitment: Record "Service Commitment";
        BillingLine: Record "Billing Line";
    begin
        ServiceCommitment.SetRange(Partner, BillingTemplate.Partner);
        ServiceCommitment.SetRange("Contract No.", ContractNo);
        if ContractLineFilter <> '' then begin
            ServiceCommitment.SetRange("Usage Based Billing", true);
            ServiceCommitment.SetFilter("Contract Line No.", ContractLineFilter);
        end;
        ServiceCommitment.SetFilter("Next Billing Date", '<=%1&<>%2', BillingDate, 0D);
        if BillingRhythmFilterText <> '' then
            ServiceCommitment.SetFilter("Billing Rhythm", BillingRhythmFilterText);
        OnBeforeProcessContractServiceCommitments(ServiceCommitment, BillingDate, BillingToDate, BillingRhythmFilterText, BillingTemplate);
        if ServiceCommitment.FindSet() then
            repeat
                ProcessServiceCommitment(ServiceCommitment, BillingLine, BillingTemplate, BillingDate, BillingToDate);
            until ServiceCommitment.Next() = 0;
        OnAfterProcessContractServiceCommitments(ServiceCommitment, BillingDate, BillingToDate, BillingRhythmFilterText);
        if BillingTemplate.IsPartnerCustomer() then
            RecalculateHarmonizedBillingFieldsBasedOnNextBillingDate(BillingLine, ContractNo);
    end;

    internal procedure ProcessServiceCommitment(var ServiceCommitment: Record "Service Commitment"; var BillingLine: Record "Billing Line"; BillingTemplate: Record "Billing Template"; var BillingDate: Date; var BillingToDate: Date)
    var
        UsageDataBilling: Record "Usage Data Billing";
        SkipServiceCommitment: Boolean;
    begin
        SkipServiceCommitment := false;
        FilterBillingLinesOnServiceCommitment(BillingLine, ServiceCommitment);
        case true of
            (ServiceCommitment."Service End Date" <> 0D) and (ServiceCommitment."Next Billing Date" > ServiceCommitment."Service End Date"):
                SkipServiceCommitment := true;
            BillingLine.FindFirst() and ((BillingLine."Document No." <> '') or (BillingTemplate.Code = '')):
                begin
                    SkipServiceCommitment := true;
                    case BillingLine.Partner of
                        Enum::"Service Partner"::Customer:
                            if SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", BillingLine."Document No.") then
                                SalesHeader.Mark(true);
                        Enum::"Service Partner"::Vendor:
                            if PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", BillingLine."Document No.") then
                                PurchaseHeader.Mark(true);
                    end;
                end;
            ServiceCommitment."Usage Based Billing":
                begin
                    UsageDataBilling.Reset();
                    UsageDataBilling.SetCurrentKey("Usage Data Import Entry No.", "Service Commitment Entry No.", Partner, "Document Type", "Charge End Date", "Charge End Time");
                    UsageDataBilling.FilterOnServiceCommitment(ServiceCommitment);
                    UsageDataBilling.SetRange("Document Type", "Usage Based Billing Doc. Type"::None);
                    SkipServiceCommitment := UsageDataBilling.IsEmpty();
                end;
            else
                OnCheckSkipServiceCommitmentOnElse(ServiceCommitment, SkipServiceCommitment);
        end;

        if not SkipServiceCommitment then begin
            CalculateBillingPeriod(ServiceCommitment, BillingDate, BillingToDate);
            if FindBillingLine(BillingLine, ServiceCommitment, BillingPeriodStart, CalculateNextBillingToDateForServiceCommitment(ServiceCommitment, BillingPeriodStart)) then
                UpdateBillingLine(BillingLine, ServiceCommitment, BillingTemplate, BillingPeriodStart)
            else begin
                BillingLine.InitNewBillingLine();
                UpdateBillingLine(BillingLine, ServiceCommitment, BillingTemplate, BillingPeriodStart);
            end;
        end;
    end;

    local procedure FilterBillingLinesOnServiceCommitment(var BillingLine: Record "Billing Line"; ServiceCommitment: Record "Service Commitment")
    begin
        BillingLine.Reset();
        BillingLine.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
    end;

    local procedure FindBillingLine(var BillingLine: Record "Billing Line"; ServiceCommitment: Record "Service Commitment"; BillingFromDate: Date; BillingToDate: Date): Boolean
    begin
        FilterBillingLinesOnServiceCommitment(BillingLine, ServiceCommitment);
        BillingLine.SetRange("Billing from", BillingFromDate);
        BillingLine.SetRange("Billing to", BillingToDate);
        exit(BillingLine.FindFirst())
    end;

    local procedure DeleteUpdateRequiredBillingLines(BillingTemplateCode: Code[20]): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetRange("Billing Template Code", BillingTemplateCode);
        BillingLine.SetRange("Update Required", true);
        if BillingLine.FindSet() then
            repeat
                DeleteBillingLinesForServiceObject(BillingLine);
            until BillingLine.Next() = 0;
        exit(true);
    end;

    local procedure UpdateBillingLine(var BillingLine: Record "Billing Line"; var ServiceCommitment: Record "Service Commitment"; BillingTemplate: Record "Billing Template"; BillingFrom: Date)
    var
        BillingLine2: Record "Billing Line";
        NewBillingToDate, NewBillingToDate2, NewBillingFromDate2 : Date;
        ServiceCommitmentNotEnded: Boolean;
    begin
        BillingLine."Billing from" := BillingFrom;
        if BillingLine."Billing from" > BillingPeriodEnd then
            exit;

        NewBillingToDate := CalculateNextBillingToDateForServiceCommitment(ServiceCommitment, BillingLine."Billing from");
        if NewBillingToDate >= BillingPeriodEnd then
            BillingLine."Billing to" := BillingPeriodEnd
        else
            BillingLine."Billing to" := NewBillingToDate;

        UpdateBillingLineFromServiceCommitment(BillingLine, ServiceCommitment);
        CalculateBillingLineUnitPriceAndServiceAmounts(BillingLine, ServiceCommitment);
        BillingLine."Billing Template Code" := BillingTemplate.Code;

        OnBeforeInsertBillingLineUpdateBillingLine(BillingLine, ServiceCommitment);
        if not BillingLine.Insert(false) then
            BillingLine.Modify(false);

        OnBeforeUpdateNextBillingDateInUpdateBillingLine(ServiceCommitment);
        ServiceCommitment.UpdateNextBillingDate(BillingLine."Billing to");
        ServiceCommitment.Modify(false);

        NewBillingFromDate2 := CalculateNextToDate(ServiceCommitment, ServiceCommitment."Billing Rhythm", BillingLine."Billing from") + 1;
        NewBillingToDate2 := CalculateNextBillingToDateForServiceCommitment(ServiceCommitment, NewBillingFromDate2);
        if NewBillingToDate2 >= BillingPeriodEnd then
            NewBillingToDate2 := BillingPeriodEnd;

        ServiceCommitmentNotEnded := ServiceCommitment."Service End Date" = 0D;
        if not ServiceCommitmentNotEnded then
            ServiceCommitmentNotEnded := NewBillingFromDate2 < ServiceCommitment."Service End Date";

        if (NewBillingToDate <= BillingPeriodEnd) and ServiceCommitmentNotEnded then begin
            if not FindBillingLine(BillingLine2, ServiceCommitment, NewBillingFromDate2, NewBillingToDate2) then
                BillingLine2.InitNewBillingLine();
            UpdateBillingLine(BillingLine2, ServiceCommitment, BillingTemplate, NewBillingFromDate2);//recursion
        end;
    end;

    local procedure CalculateBillingLineUnitPriceAndServiceAmounts(var BillingLine: Record "Billing Line"; ServiceCommitment: Record "Service Commitment")
    var
        Currency: Record Currency;
    begin
        Currency.Initialize(ServiceCommitment."Currency Code");

        BillingLine."Unit Price" := CalculateBillingLineUnitPrice(BillingLine, ServiceCommitment);
        if not ServiceCommitment."Usage Based Billing" then
            BillingLine."Unit Price" := Round(BillingLine."Unit Price", Currency."Unit-Amount Rounding Precision");

        BillingLine."Service Amount" := CalculateBillingLineServiceAmount(BillingLine);
        if not ServiceCommitment."Usage Based Billing" then
            BillingLine."Service Amount" := Round(BillingLine."Service Amount", Currency."Amount Rounding Precision");
    end;

    local procedure CalculateBillingLineUnitPrice(BillingLine: Record "Billing Line"; ServiceCommitment: Record "Service Commitment") UnitPrice: Decimal
    var
        PeriodFormula: DateFormula;
        BillingPeriodRatio: Decimal;
        PeriodPrice: Decimal;
        DayPrice: Decimal;
        FollowUpDays: Integer;
        Periods: Integer;
        FollowUpPeriodDays: Integer;
    begin
        BillingPeriodRatio := GetBillingPeriodRatio(BillingLine."Billing Rhythm", ServiceCommitment."Billing Base Period");
        if BillingPeriodRatio > 1 then begin
            PeriodPrice := ServiceCommitment.Price;
            PeriodFormula := ServiceCommitment."Billing Base Period";
        end else begin
            PeriodPrice := ServiceCommitment.Price * BillingPeriodRatio;
            PeriodFormula := ServiceCommitment."Billing Rhythm";
        end;
        CalculatePeriodCountAndDaysCount(ServiceCommitment, PeriodFormula, BillingLine."Billing from", BillingLine."Billing to", Periods, FollowUpDays, FollowUpPeriodDays);
        if FollowUpPeriodDays <> 0 then
            DayPrice := PeriodPrice / FollowUpPeriodDays;
        UnitPrice := PeriodPrice * Periods + DayPrice * FollowUpDays;
    end;

    internal procedure CalculateBillingLineServiceAmount(var BillingLine: Record "Billing Line") ServiceAmount: Decimal
    begin
        BillingLine.TestField("Service Obj. Quantity Decimal");
        ServiceAmount := BillingLine."Unit Price" * BillingLine."Service Obj. Quantity Decimal" * (1 - BillingLine."Discount %" / 100);
    end;

    local procedure CalculatePeriodCountAndDaysCount(ServiceCommitment: Record "Service Commitment"; PeriodFormula: DateFormula; StartDate: Date; EndDate: Date; var Periods: Integer; var FollowUpDays: Integer; var FollowUpPeriodDays: Integer)
    var
        LastDayInPreviousPeriod: Date;
        LastDayInNextPeriod: Date;
        FollowUpDaysExist: Boolean;
        PeriodFormulaInteger: Integer;
        Letter: Char;
    begin
        Periods := 0;
        FollowUpDays := 0;
        FollowUpPeriodDays := 0;
        FollowUpDaysExist := true;

        LastDayInNextPeriod := StartDate - 1;
        DateFormulaManagement.FindDateFormulaType(PeriodFormula, PeriodFormulaInteger, Letter);
        repeat
            Evaluate(PeriodFormula, '<' + Format((Periods + 1) * PeriodFormulaInteger) + Letter + '>');
            LastDayInPreviousPeriod := LastDayInNextPeriod;
            LastDayInNextPeriod := CalculateNextToDate(ServiceCommitment, PeriodFormula, StartDate);
            if LastDayInNextPeriod <= EndDate then
                Periods += 1;
            FollowUpDaysExist := LastDayInNextPeriod <> EndDate;
        until LastDayInNextPeriod >= EndDate;
        if FollowUpDaysExist then begin
            FollowUpDays := EndDate - LastDayInPreviousPeriod;
            FollowUpPeriodDays := LastDayInNextPeriod - LastDayInPreviousPeriod;
        end;
    end;

    local procedure GetBillingPeriodRatio(BillingRhythm: DateFormula; BillingBaseRhytm: DateFormula) BillingPeriodRatio: Decimal
    var
        BillingPeriodCount: Integer;
        BillingBasePeriodCount: Integer;
    begin
        if (Format(BillingRhythm) = '') or (Format(BillingBaseRhytm) = '') then
            exit(0);
        DateFormulaManagement.FindDateFormulaTypeForComparison(BillingRhythm, BillingPeriodCount);
        DateFormulaManagement.FindDateFormulaTypeForComparison(BillingBaseRhytm, BillingBasePeriodCount);
        BillingPeriodRatio := BillingPeriodCount / BillingBasePeriodCount;
    end;

    local procedure UpdateBillingLineFromServiceCommitment(var BillingLine: Record "Billing Line"; ServiceCommitment: Record "Service Commitment")
    var
        ServiceObject: Record "Service Object";
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
    begin
        BillingLine."Service Object No." := ServiceCommitment."Service Object No.";
        BillingLine."Service Commitment Entry No." := ServiceCommitment."Entry No.";
        BillingLine."Service Commitment Description" := ServiceCommitment.Description;
        BillingLine."Service Start Date" := ServiceCommitment."Service Start Date";
        BillingLine."Service End Date" := ServiceCommitment."Service End Date";
        BillingLine."Billing Rhythm" := ServiceCommitment."Billing Rhythm";
        BillingLine.Partner := ServiceCommitment.Partner;
        case ServiceCommitment.Partner of
            ServiceCommitment.Partner::Customer:
                begin
                    CustomerContract.Get(ServiceCommitment."Contract No.");
                    BillingLine."Partner No." := CustomerContract."Sell-to Customer No.";
                    BillingLine."Detail Overview" := CustomerContract."Detail Overview";
                    BillingLine."Currency Code" := CustomerContract."Currency Code";
                end;
            ServiceCommitment.Partner::Vendor:
                begin
                    VendorContract.Get(ServiceCommitment."Contract No.");
                    BillingLine."Partner No." := VendorContract."Pay-to Vendor No.";
                    BillingLine."Currency Code" := VendorContract."Currency Code";
                end;
        end;
        BillingLine."Contract No." := ServiceCommitment."Contract No.";
        BillingLine."Contract Line No." := ServiceCommitment."Contract Line No.";
        BillingLine."Discount %" := ServiceCommitment."Discount %";
        BillingLine.Discount := ServiceCommitment.Discount;
        ServiceObject.Get(ServiceCommitment."Service Object No.");
        BillingLine."Service Obj. Quantity Decimal" := BillingLine.GetSign() * ServiceObject."Quantity Decimal";
        OnAfterUpdateBillingLineFromServiceCommitment(BillingLine, ServiceCommitment);
    end;

    local procedure CalculateBillingPeriod(ServiceCommitment: Record "Service Commitment"; BillingDate: Date; BillToDate: Date)
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        BillingPeriodEnd := 0D;
        BillingPeriodStart := ServiceCommitment."Next Billing Date";
        if BillToDate <> 0D then begin
            BillingPeriodEnd := BillToDate;
            exit;
        end;
        if ServiceCommitment."Usage Based Billing" then begin
            UsageDataBilling.SetCurrentKey("Charge End Date");
            UsageDataBilling.SetAscending("Charge End Date", true);
            UsageDataBilling.SetRange("Service Object No.", ServiceCommitment."Service Object No.");
            UsageDataBilling.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
            UsageDataBilling.SetRange(Partner, ServiceCommitment.Partner);
            UsageDataBilling.SetRange("Document Type", "Usage Based Billing Doc. Type"::None);
            if UsageDataBilling.FindFirst() then
                BillingPeriodStart := UsageDataBilling."Charge Start Date";
            if UsageDataBilling.FindLast() then
                BillingPeriodEnd := CalcDate('<-1D>', UsageDataBilling."Charge End Date");
            exit;
        end;

        BillingPeriodEnd := CalculateNextBillingToDateForServiceCommitment(ServiceCommitment, BillingPeriodStart);
        while (BillingPeriodEnd < BillingDate) and
              ((BillingPeriodEnd < ServiceCommitment."Service End Date") or (ServiceCommitment."Service End Date" = 0D))
        do
            BillingPeriodEnd := CalculateNextBillingToDateForServiceCommitment(ServiceCommitment, BillingPeriodEnd + 1);

        CalculateCustomerContractHarmonizedBillingPeriodEnd(ServiceCommitment);
    end;

    local procedure CalculateCustomerContractHarmonizedBillingPeriodEnd(ServiceCommitment: Record "Service Commitment")
    var
        CustomerContract: Record "Customer Contract";
    begin
        if ServiceCommitment.IsPartnerVendor() then
            exit;
        CustomerContract.Get(ServiceCommitment."Contract No.");
        if CustomerContract.IsContractTypeSetAsHarmonizedBilling() then
            if ((BillingPeriodEnd > CustomerContract."Next Billing To") and (CustomerContract."Next Billing From" <> 0D)) then
                BillingPeriodEnd := CustomerContract."Next Billing To" - 1;
    end;

    internal procedure CalculateNextBillingToDateForServiceCommitment(ServiceCommitment: Record "Service Commitment"; BillingFromDate: Date) NextBillingToDate: Date
    var
        CustomerContract: Record "Customer Contract";
    begin
        ServiceCommitment.TestField("Billing Rhythm");
        NextBillingToDate := CalculateNextToDate(ServiceCommitment, ServiceCommitment."Billing Rhythm", BillingFromDate);
        if (NextBillingToDate >= ServiceCommitment."Service End Date") and (ServiceCommitment."Service End Date" <> 0D) then
            NextBillingToDate := ServiceCommitment."Service End Date";
        if ServiceCommitment.IsPartnerVendor() then
            exit;
        CustomerContract.Get(ServiceCommitment."Contract No.");
        if CustomerContract.IsContractTypeSetAsHarmonizedBilling() then
            HarmonizeNextBillingTo(CustomerContract."Next Billing To", NextBillingToDate, BillingFromDate);
        OnAfterCalculateNextBillingToDateForServiceCommitment(NextBillingToDate, ServiceCommitment, BillingFromDate);
    end;

    internal procedure CalculateNextToDate(ServiceCommitment: Record "Service Commitment"; PeriodFormula: DateFormula; FromDate: Date) NextToDate: Date
    var
        DistanceToEndOfMonth: Integer;
        LastDateInLastMonth: Date;
    begin
        case ServiceCommitment."Period Calculation" of
            ServiceCommitment."Period Calculation"::"Align to Start of Month":
                NextToDate := CalcDate(PeriodFormula, FromDate) - 1;
            ServiceCommitment."Period Calculation"::"Align to End of Month":
                begin
                    DistanceToEndOfMonth := CalcDate('<CM>', ServiceCommitment."Service Start Date") - ServiceCommitment."Service Start Date";
                    if DistanceToEndOfMonth > 2 then
                        NextToDate := CalcDate(PeriodFormula, FromDate) - 1
                    else begin
                        LastDateInLastMonth := CalcDate(PeriodFormula, FromDate);
                        LastDateInLastMonth := CalcDate('<CM>', LastDateInLastMonth);
                        NextToDate := LastDateInLastMonth - DistanceToEndOfMonth - 1;
                    end;
                end;
        end;
    end;

    internal procedure DeleteBillingProposal(BillingTemplateCode: Code[20])
    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        ClearBillingProposalOptionsTxt: Label 'All billing proposals, Only current billing template proposal';
        ClearBillingProposalQst: Label 'Which billing proposal(s) should be deleted?';
        StrMenuResponse: Integer;
    begin
        StrMenuResponse := Dialog.StrMenu(ClearBillingProposalOptionsTxt, 1, ClearBillingProposalQst);
        BillingTemplate.Get(BillingTemplateCode);
        case StrMenuResponse of
            0:
                Error('');
            1:
                begin
                    BillingLine.SetCurrentKey("Service Object No.", "Service Commitment Entry No.", "Billing to");
                    BillingLine.SetAscending("Billing to", false);
                    BillingLine.SetRange("Partner", BillingTemplate.Partner);
                    if BillingLine.FindSet() then
                        repeat
                            BillingLine.Delete(true);
                        until BillingLine.Next() = 0;
                end;
            2:
                begin
                    BillingLine.SetCurrentKey("Service Object No.", "Service Commitment Entry No.", "Billing to");
                    BillingLine.SetAscending("Billing to", false);
                    BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
                    if BillingLine.FindSet() then
                        repeat
                            BillingLine.Delete(true);
                        until BillingLine.Next() = 0;
                end;
        end;
    end;

    internal procedure DeleteBillingLines(var BillingLine: Record "Billing Line")
    begin
        BillingLine.SetCurrentKey("Service Object No.", "Service Commitment Entry No.", "Billing to");
        BillingLine.SetAscending("Billing to", false);
        if BillingLine.FindSet() then
            repeat
                BillingLine.Delete(true)
            until BillingLine.Next() = 0;
    end;

    local procedure DeleteBillingLinesForServiceObject(var BillingLine: Record "Billing Line")
    var
        BillingLine2: Record "Billing Line";
    begin
        BillingLine2.SetCurrentKey("Service Object No.", "Service Commitment Entry No.", "Billing to");
        BillingLine2.SetRange("Service Object No.", BillingLine."Service Object No.");
        BillingLine2.SetRange("Service Commitment Entry No.", BillingLine."Service Commitment Entry No.");
        BillingLine2.SetAscending("Billing to", false);
        if BillingLine2.FindSet() then
            repeat
                BillingLine2.Delete(true)
            until BillingLine2.Next() = 0;
    end;

    local procedure HarmonizeNextBillingTo(CustomerContractNextBillingTo: Date; var NextBillingToDate: Date; BillingFromDate: Date)
    begin
        if CustomerContractNextBillingTo = 0D then
            exit;
        if NextBillingToDate < CustomerContractNextBillingTo then
            exit;
        if ((CustomerContractNextBillingTo >= BillingFromDate) and (CustomerContractNextBillingTo <= NextBillingToDate)) then
            NextBillingToDate := CustomerContractNextBillingTo
    end;

    local procedure BillingLinesForCustomerContractCreated(var BillingLine: Record "Billing Line"; CustomerContractNo: Code[20]): Boolean
    begin
        BillingLine.Reset();
        BillingLine.SetRange("Contract No.", CustomerContractNo);
        exit(not BillingLine.IsEmpty());
    end;

    local procedure RecalculateHarmonizedBillingFieldsBasedOnNextBillingDate(var BillingLines: Record "Billing Line"; CustomerContractNo: Code[20])
    var
        CustomerContract: Record "Customer Contract";
    begin
        if not BillingLinesForCustomerContractCreated(BillingLines, CustomerContractNo) then
            exit;
        if CustomerContractNo = '' then
            exit;
        CustomerContract.Get(CustomerContractNo);
        CustomerContract.RecalculateHarmonizedBillingFieldsBasedOnNextBillingDate(0);
    end;

    internal procedure UpdateBillingToDate(var BillingLine: Record "Billing Line"; NewBillingToDate: Date)
    var
        ServiceCommitment: Record "Service Commitment";
        BillingTemplate: Record "Billing Template";
    begin
        if BillingLine.FindSet() then
            repeat
                if BillingLine."Document No." <> '' then
                    Error(BillingToChangeNotAllowedDocNoExistsErr);
                ServiceCommitment.Get(BillingLine."Service Commitment Entry No.");
                OnAfterServiceCommitmentGetInUpdateBillingToDate(ServiceCommitment);
                if CalcDate('<+1D>', BillingLine."Billing to") = ServiceCommitment."Next Billing Date" then begin
                    BillingTemplate.Get(BillingLine."Billing Template Code");
                    ServiceCommitment.UpdateNextBillingDate(BillingLine."Billing from" - 1);
                    CalculateBillingPeriod(ServiceCommitment, 0D, NewBillingToDate);
                    UpdateBillingLine(BillingLine, ServiceCommitment, BillingTemplate, BillingPeriodStart);
                end else
                    Error(BillingToChangeNotAllowedErr, Format(BillingLine."Billing to"), Format(NewBillingToDate), BillingLine."Contract No.", BillingLine."Service Object No.", Format(CalcDate('<-1D>', ServiceCommitment."Next Billing Date")));
            until BillingLine.Next() = 0;
    end;

    internal procedure CreateBillingProposalFromContract(ContractNo: Code[20]; BillingRhytmFilter: Text; ServicePartner: Enum "Service Partner")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCreateBillingProposalFromContract(ContractNo, BillingRhytmFilter, ServicePartner, IsHandled);
        if IsHandled then
            exit;

        if not BillingProposalCanBeCreatedForContract(ContractNo, ServicePartner) then
            exit;
        CreateBillingDocumentPage.SetContractData(ServicePartner, ContractNo, BillingRhytmFilter);
        CreateBillingDocumentPage.RunModal();
    end;

    local procedure ErrorIfBillingLinesForAllContractLinesExist(ContractNo: Code[20]; ServicePartner: Enum "Service Partner"): Boolean
    var
        ContractLineWithoutBillingLineExists: Boolean;
    begin
        case ServicePartner of
            "Service Partner"::Customer:
                ContractLineWithoutBillingLineExists := CheckIfBillingLineForCustomerContractLineDoesNotExist(ContractNo);
            "Service Partner"::Vendor:
                ContractLineWithoutBillingLineExists := CheckIfBillingLineForVendorContractLineDoesNotExist(ContractNo);
        end;
        if ContractLineWithoutBillingLineExists then
            exit;
        Error(BillingLinesForAllContractLinesExistsErr);
    end;

    local procedure CheckIfBillingLineWithUnpostedDocumentExists(var BillingLine: Record "Billing Line"; ContractNo: Code[20]; ServicePartner: Enum "Service Partner"; BillingDocumentType: Enum "Rec. Billing Document Type"): Boolean
    begin
        BillingLine.FilterBillingLineOnContract(ServicePartner, ContractNo);
        BillingLine.SetRange("Document Type", BillingDocumentType);
        BillingLine.SetFilter("Document No.", '<>%1', '');
        exit(not BillingLine.IsEmpty());
    end;

    internal procedure CreateBillingProposalForContract(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineFilter: Text; BillingRhythmFilter: Text; BillingDate: Date; BillingToDate: Date)
    var
        TempBillingTemplate: Record "Billing Template" temporary;
    begin
        CreateTempBillingTemplate(TempBillingTemplate, ServicePartner);
        ProcessContractServiceCommitments(TempBillingTemplate, ContractNo, '', BillingDate, BillingToDate, BillingRhythmFilter);
    end;

    internal procedure CreateBillingProposalForPurchaseHeader(ServicePartner: Enum "Service Partner"; var TempServiceCommitment: Record "Service Commitment" temporary; BillingDate: Date; BillingToDate: Date)
    var
        DummyPurchaseLine: Record "Purchase Line";
    begin
        CreateBillingProposalForPurchaseLine(ServicePartner, TempServiceCommitment, BillingDate, BillingToDate, DummyPurchaseLine);
    end;

    internal procedure CreateBillingProposalForPurchaseLine(ServicePartner: Enum "Service Partner"; var TempServiceCommitment: Record "Service Commitment" temporary; BillingDate: Date; BillingToDate: Date; var PurchaseLine: Record "Purchase Line")
    var
        TempBillingTemplate: Record "Billing Template" temporary;
        ServiceCommitment: Record "Service Commitment";
        BillingLine: Record "Billing Line";
    begin
        CreateTempBillingTemplate(TempBillingTemplate, ServicePartner);
        if TempServiceCommitment.FindSet() then
            repeat
                ProcessServiceCommitment(TempServiceCommitment, BillingLine, TempBillingTemplate, BillingDate, BillingToDate);
                if PurchaseLine."Document No." <> '' then
                    SyncPurchaseLineAndBillingLine(BillingLine, PurchaseLine);
                if ServiceCommitment.Get(TempServiceCommitment."Entry No.") then begin
                    ServiceCommitment."Next Billing Date" := TempServiceCommitment."Next Billing Date";
                    ServiceCommitment.Modify();
                end;
            until TempServiceCommitment.Next() = 0;
        AddRecurringBillingFlagToExistingPurchaseHeader(PurchaseLine."Document Type", PurchaseLine."Document No.");
    end;

    internal procedure CreatePurchaseLines(PurchaseHeader: Record "Purchase Header")
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetRange("Billing Template Code", '');
        if BillingLine.IsEmpty() then
            exit;
        CreateBillingDocuments.SetPurchaseHeaderFromExistingPurchaseDocument(PurchaseHeader."Document Type", PurchaseHeader."No.");
        CreateBillingDocuments.SetSkipRequestPageSelection(true);
        CreateBillingDocuments.SetHideProcessingFinishedMessage();
        CreateBillingDocuments.Run(BillingLine);
    end;

    local procedure SyncPurchaseLineAndBillingLine(var BillingLine: Record "Billing Line"; var PurchaseLine: Record "Purchase Line")
    begin
        if PurchaseLine."Document No." = '' then
            exit;
        BillingLine."Document Type" := BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchaseLine."Document Type");
        BillingLine."Document No." := PurchaseLine."Document No.";
        BillingLine."Document Line No." := PurchaseLine."Line No.";
        BillingLine.Modify();

        PurchaseLine."Recurring Billing from" := BillingLine."Billing from";
        PurchaseLine."Recurring Billing to" := BillingLine."Billing to";
        PurchaseLine.Modify(false);
    end;

    local procedure AddRecurringBillingFlagToExistingPurchaseHeader(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20])
    begin
        if DocumentNo = '' then
            exit;
        SessionStore.SetBooleanKey('SkipContractPurchaseHeaderModifyCheck', true);
        PurchaseHeader.Get(DocumentType, DocumentNo);
        PurchaseHeader.SetRecurringBilling();
        SessionStore.RemoveBooleanKey('SkipContractPurchaseHeaderModifyCheck');
    end;

    local procedure BillingProposalCanBeCreatedForContract(ContractNo: Code[20]; ServicePartner: Enum "Service Partner"): Boolean
    var
        BillingLine: Record "Billing Line";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if CheckIfBillingLineWithUnpostedDocumentExists(BillingLine, ContractNo, ServicePartner, "Rec. Billing Document Type"::"Credit Memo") then begin
            if ConfirmManagement.GetResponse(GetCreditMemoExistsForBillingLineQst(ServicePartner), true) then begin
                BillingLine.FindFirst();
                BillingLine.OpenDocumentCard();
            end;
            exit(false);
        end;
        if CheckIfBillingLineWithUnpostedDocumentExists(BillingLine, ContractNo, ServicePartner, "Rec. Billing Document Type"::Invoice) then begin
            if ConfirmManagement.GetResponse(GetBillingLineWithUnpostedInvoiceExistsQst(ServicePartner), true) then begin
                BillingLine.FindFirst();
                BillingLine.OpenDocumentCard();
            end;
            exit(false);
        end;
        ErrorIfBillingLinesForAllContractLinesExist(ContractNo, ServicePartner);
        if CheckIfBillingLineForContractExists(ContractNo, ServicePartner) then
            if not ConfirmManagement.GetResponse(BillingLineWithoutInvoiceExistsQst, true) then
                exit(false);
        exit(true);
    end;

    local procedure CreateTempBillingTemplate(var TempBillingTemplate: Record "Billing Template" temporary; ServicePartner: Enum "Service Partner")
    begin
        TempBillingTemplate.Init();
        TempBillingTemplate.Partner := ServicePartner;
        TempBillingTemplate.Insert(false);
    end;

    internal procedure CreateBillingDocument(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; DocumentDate: Date; PostingDate: Date; PostDocument: Boolean; OpenDocument: Boolean): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetRange("Billing Template Code", '');
        if BillingLine.IsEmpty() then
            exit(false);
        CreateBillingDocuments.SetBillingGroupingPerContract(ServicePartner);
        CreateBillingDocuments.SetDocumentDataFromRequestPage(DocumentDate, PostingDate, PostDocument, true);
        CreateBillingDocuments.SetSkipRequestPageSelection(true);
        CreateBillingDocuments.Run(BillingLine);
        Commit(); // Commit before RunModal
        if OpenDocument then
            FindBillingLineAndOpenDocumentCard(ContractNo);
        exit(true);
    end;

    local procedure FindBillingLineAndOpenDocumentCard(ContractNo: Code[20])
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetRange("Billing Template Code", '');
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.FindLast();
        BillingLine.OpenDocumentCard()
    end;

    local procedure GetCreditMemoExistsForBillingLineQst(ServicePartner: Enum "Service Partner"): Text
    begin
        case ServicePartner of
            "Service Partner"::Customer:
                exit(SalesCreditMemoExistsForBillingLineQst);
            "Service Partner"::Vendor:
                exit(PurchaseCreditMemoExistsForBillingLineQst);
        end;
    end;

    local procedure GetBillingLineWithUnpostedInvoiceExistsQst(ServicePartner: Enum "Service Partner"): Text
    begin
        case ServicePartner of
            "Service Partner"::Customer:
                exit(BillingLineWithUnpostedSalesInvoiceExistsQst);
            "Service Partner"::Vendor:
                exit(BillingLineWithUnpostedPurchaseInvoiceExistsQst);
        end;
    end;

    local procedure CheckIfBillingLineForCustomerContractLineDoesNotExist(ContractNo: Code[20]): Boolean
    var
        CustomerContractLine: Record "Customer Contract Line";
        BillingLine: Record "Billing Line";
    begin
        CustomerContractLine.SetRange("Contract No.", ContractNo);
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::"Service Commitment");
        if CustomerContractLine.FindSet() then
            repeat
                BillingLine.FilterBillingLineOnContractLine("Service Partner"::Customer, ContractNo, CustomerContractLine."Line No.");
                if BillingLine.IsEmpty then
                    exit(true);
            until CustomerContractLine.Next() = 0;
    end;

    local procedure CheckIfBillingLineForVendorContractLineDoesNotExist(ContractNo: Code[20]): Boolean
    var
        VendorContractLine: Record "Vendor Contract Line";
        BillingLine: Record "Billing Line";
    begin
        VendorContractLine.SetRange("Contract No.", ContractNo);
        VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::"Service Commitment");
        if VendorContractLine.FindSet() then
            repeat
                BillingLine.FilterBillingLineOnContractLine("Service Partner"::Vendor, ContractNo, VendorContractLine."Line No.");
                if BillingLine.IsEmpty then
                    exit(true);
            until VendorContractLine.Next() = 0;
    end;

    local procedure CheckIfBillingLineForContractExists(ContractNo: Code[20]; ServicePartner: Enum "Service Partner"): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnContract(ServicePartner, ContractNo);
        exit(not BillingLine.IsEmpty());
    end;

    internal procedure DeleteBillingDocuments()
    var
        DeleteBillingDocumentQst: Label 'Which contract billing documents should be deleted?';
        DeleteBillingDocumentOptionsTxt: Label 'All Documents,All Sales Invoices,All Sales Credit Memos,All Purchase Invoices,All Purchase Credit Memos';
    begin
        DeleteBillingDocuments(Dialog.StrMenu(DeleteBillingDocumentOptionsTxt, 1, DeleteBillingDocumentQst), true);
    end;

    internal procedure DeleteBillingDocuments(Selection: Option " ","All Documents","All Sales Invoices","All Sales Credit Memos","All Purchase Invoices","All Purchase Credit Memos"; ShowDialog: Boolean)
    var
        Window: Dialog;
        ProgressTxt: Label 'Deleting Billing Documents ...';
    begin
        if Selection = Selection::" " then
            exit;
        if ShowDialog and GuiAllowed() then
            Window.Open(ProgressTxt);
        DeleteSalesBillingDocuments(
            Selection in [Selection::"All Documents", Selection::"All Sales Invoices"],
            Selection in [Selection::"All Documents", Selection::"All Sales Credit Memos"]);
        DeletePurchaseBillingDocuments(
            Selection in [Selection::"All Documents", Selection::"All Purchase Invoices"],
            Selection in [Selection::"All Documents", Selection::"All Purchase Credit Memos"]);
        if ShowDialog and GuiAllowed() then
            Window.Close();
    end;

    local procedure DeleteSalesBillingDocuments(DeleteSalesInvoices: Boolean; DeleteSalesCreditMemos: Boolean)
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Recurring Billing", true);
        if DeleteSalesCreditMemos then begin
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
            if not SalesHeader.IsEmpty() then
                SalesHeader.DeleteAll(true);
        end;
        if DeleteSalesInvoices then begin
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
            if not SalesHeader.IsEmpty() then
                SalesHeader.DeleteAll(true);
        end;
    end;

    local procedure DeletePurchaseBillingDocuments(DeletePurchaseInvoices: Boolean; DeletePurchaseCreditMemos: Boolean)
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Recurring Billing", true);
        if DeletePurchaseCreditMemos then begin
            PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
            if not PurchaseHeader.IsEmpty() then
                PurchaseHeader.DeleteAll(true);
        end;
        if DeletePurchaseInvoices then begin
            PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
            if not PurchaseHeader.IsEmpty() then
                PurchaseHeader.DeleteAll(true);
        end;
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateBillingLineFromServiceCommitment(var BillingLine: Record "Billing Line"; ServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeProcessContractServiceCommitments(var ServiceCommitment: Record "Service Commitment"; BillingDate: Date; BillingToDate: Date; BillingRhythmFilterText: Text; BillingTemplate: Record "Billing Template")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterProcessContractServiceCommitments(var ServiceCommitment: Record "Service Commitment"; BillingDate: Date; BillingToDate: Date; BillingRhythmFilterText: Text)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateBillingProposalFromContract(ContractNo: Code[20]; BillingRhytmFilter: Text; ServicePartner: Enum "Service Partner"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCalculateNextBillingToDateForServiceCommitment(var NextBillingToDate: Date; ServiceCommitment: Record "Service Commitment"; BillingFromDate: Date)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInsertBillingLineUpdateBillingLine(var BillingLine: Record "Billing Line"; ServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInitTempTable(var TempBillingLine: Record "Billing Line" temporary; GroupBy: Enum "Contract Billing Grouping")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeUpdateNextBillingDateInUpdateBillingLine(var ServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterServiceCommitmentGetInUpdateBillingToDate(var ServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCheckSkipServiceCommitmentOnElse(ServiceCommitment: Record "Service Commitment"; var SkipServiceCommitment: Boolean)
    begin
    end;
}