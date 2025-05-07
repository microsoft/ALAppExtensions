namespace Microsoft.SubscriptionBilling;

using System.IO;
using System.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;

codeunit 8060 "Create Billing Documents"
{
    TableNo = "Billing Line";

    trigger OnRun()
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.Copy(Rec);
        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::None);
        if CreateContractInvoice then
            BillingLine.SetRange("Billing Template Code", '');
        CreateBillingDocuments(BillingLine);
    end;

    local procedure CreateBillingDocuments(var BillingLine: Record "Billing Line")
    begin
        OnBeforeCreateBillingDocuments(BillingLine);
        CheckBillingLines(BillingLine);

        if not SkipRequestPageSelection then
            if not RequestPageSelectionConfirmed() then
                exit;

        Window.Open(ProgressTxt);
        Window.Update();
        ProcessBillingLines(BillingLine);
        Window.Close();
        if PostDocuments then
            PostCreatedDocuments();
        if not HideProcessingFinishedMessage then
            ProcessingFinishedMessage();
    end;

    local procedure ProcessBillingLines(var BillingLine: Record "Billing Line")
    begin
        OnBeforeProcessBillingLines(BillingLine);
        CreateTempBillingLines(BillingLine);
        case BillingLine.Partner of
            BillingLine.Partner::Customer:
                case CustomerRecurringBillingGrouping of
                    CustomerRecurringBillingGrouping::Contract:
                        CreateSalesDocumentsPerContract();
                    CustomerRecurringBillingGrouping::"Sell-to Customer No.",
                    CustomerRecurringBillingGrouping::"Bill-to Customer No.":
                        CreateSalesDocumentsPerCustomer();
                end;
            BillingLine.Partner::Vendor:
                case VendorRecurringBillingGrouping of
                    VendorRecurringBillingGrouping::Contract:
                        CreatePurchaseDocumentsPerContract();
                    VendorRecurringBillingGrouping::"Pay-to Vendor No.",
                    VendorRecurringBillingGrouping::"Buy-from Vendor No.":
                        CreatePurchaseDocumentsPerVendor();
                end;
        end;
        OnAfterProcessBillingLines(BillingLine);
    end;

    local procedure CreateSalesDocumentsPerContract()
    var
        CustomerContract: Record "Customer Subscription Contract";
        PreviousContractNo: Code[20];
        DiscountLineExists: Boolean;
    begin
        PreviousContractNo := '';
        TempBillingLine.Reset();
        TempBillingLine.SetCurrentKey("Subscription Contract No.", "Subscription Contract Line No.");
        SetDiscountLineExists(TempBillingLine, DiscountLineExists);
        OnCreateSalesDocumentsPerContractBeforeTempBillingLineFindSet(TempBillingLine);
        if TempBillingLine.FindSet(true) then
            repeat
                if TempBillingLine."Subscription Contract No." <> PreviousContractNo then begin
                    TestPreviousDocumentTotalInvoiceAmount(true, DiscountLineExists, PreviousContractNo);
                    CustomerContract.Get(TempBillingLine."Subscription Contract No.");
                    CreateSalesHeaderFromContract(CustomerContract);
                    InsertContractDescriptionSalesLines(TempBillingLine);
                    PreviousContractNo := TempBillingLine."Subscription Contract No.";
                    ContractsProcessedCount += 1;
                    Window.Update(1, CustomerContract."Sell-to Customer No.");
                    Window.Update(2, PreviousContractNo);
                end;
                InsertSalesLineFromTempBillingLine();
            until TempBillingLine.Next() = 0;
        TestPreviousDocumentTotalInvoiceAmount(true, DiscountLineExists, PreviousContractNo);
    end;

    local procedure CreatePurchaseDocumentsPerContract()
    var
        VendorContract: Record "Vendor Subscription Contract";
        PreviousContractNo: Code[20];
        DiscountLineExists: Boolean;
    begin
        PreviousContractNo := '';
        TempBillingLine.Reset();
        TempBillingLine.SetCurrentKey("Subscription Contract No.", "Subscription Header No.", "Subscription Line Entry No.");
        SetDiscountLineExists(TempBillingLine, DiscountLineExists);
        OnCreatePurchaseDocumentsPerContractBeforeTempBillingLineFindSet(TempBillingLine);
        if TempBillingLine.FindSet() then
            repeat
                if TempBillingLine."Subscription Contract No." <> PreviousContractNo then begin
                    TestPreviousDocumentTotalInvoiceAmount(false, DiscountLineExists, PreviousContractNo);
                    VendorContract.Get(TempBillingLine."Subscription Contract No.");
                    CreatePurchaseHeaderFromContract(VendorContract);
                    InsertContractDescriptionPurchaseLines(TempBillingLine);
                    PreviousContractNo := TempBillingLine."Subscription Contract No.";
                    ContractsProcessedCount += 1;
                    Window.Update(1, VendorContract."Pay-to Vendor No.");
                    Window.Update(2, PreviousContractNo);
                end;
                InsertPurchaseLineFromTempBillingLine();
            until TempBillingLine.Next() = 0;
        TestPreviousDocumentTotalInvoiceAmount(false, DiscountLineExists, PreviousContractNo);
    end;

    local procedure CreateSalesDocumentsPerCustomer()
    var
        PreviousCustomerNo: Code[20];
        PreviousContractNo: Code[20];
        PreviousCurrencyCode: Code[20];
        LastDetailOverview: Enum "Contract Detail Overview";
        DiscountLineExists: Boolean;
    begin
        PreviousCustomerNo := '';
        PreviousContractNo := '';
        PreviousCurrencyCode := '';
        TempBillingLine.Reset();
        TempBillingLine.SetCurrentKey("Partner No.", "Currency Code", "Detail Overview", "Subscription Contract No.", "Subscription Header No.", "Subscription Line Entry No.");
        SetDiscountLineExists(TempBillingLine, DiscountLineExists);
        OnCreateSalesDocumentsPerCustomerBeforeTempBillingLineFindSet(TempBillingLine);
        if TempBillingLine.FindSet() then
            repeat
                if IsNewSalesHeaderNeeded(PreviousCustomerNo, LastDetailOverview, PreviousCurrencyCode, PreviousContractNo) then begin
                    TestPreviousDocumentTotalInvoiceAmount(true, DiscountLineExists, PreviousContractNo);
                    CreateSalesHeaderForCustomerNo(TempBillingLine."Partner No.");
                    SalesHeader."Sub. Contract Detail Overview" := TempBillingLine."Detail Overview";
                    SalesHeader.Modify(false);
                    PreviousCustomerNo := TempBillingLine."Partner No.";
                    LastDetailOverview := TempBillingLine."Detail Overview";
                    PreviousCurrencyCode := TempBillingLine."Currency Code";
                    Window.Update(1, PreviousCustomerNo);
                    FirstContractDescriptionLineInserted := false;
                end;
                if TempBillingLine."Subscription Contract No." <> PreviousContractNo then begin
                    InsertContractDescriptionSalesLines(TempBillingLine);
                    if PreviousContractNo <> '' then begin
                        TranslationHelper.SetGlobalLanguageByCode(SalesHeader."Language Code");
                        SalesHeader."Posting Description" := MultipleLbl + ' ' + CustomerContractsLbl;
                        TranslationHelper.RestoreGlobalLanguage();
                        SalesHeader.Modify(false);
                    end;
                    PreviousContractNo := TempBillingLine."Subscription Contract No.";
                    ContractsProcessedCount += 1;
                    Window.Update(2, PreviousContractNo);
                end;
                InsertSalesLineFromTempBillingLine();
            until TempBillingLine.Next() = 0;
        TestPreviousDocumentTotalInvoiceAmount(true, DiscountLineExists, PreviousContractNo);
    end;

    local procedure CreatePurchaseDocumentsPerVendor()
    var
        PreviousVendorNo: Code[20];
        PreviousContractNo: Code[20];
        PreviousCurrencyCode: Code[20];
        DiscountLineExists: Boolean;
    begin
        PreviousVendorNo := '';
        PreviousContractNo := '';
        PreviousCurrencyCode := '';
        TempBillingLine.Reset();
        TempBillingLine.SetCurrentKey("Partner No.", "Currency Code", "Subscription Contract No.", "Subscription Header No.", "Subscription Line Entry No.");
        SetDiscountLineExists(TempBillingLine, DiscountLineExists);
        OnCreatePurchaseDocumentsPerVendorBeforeTempBillingLineFindSet(TempBillingLine);
        if TempBillingLine.FindSet() then
            repeat
                if (TempBillingLine."Partner No." <> PreviousVendorNo) or
                    (TempBillingLine."Currency Code" <> PreviousCurrencyCode)
                then begin
                    TestPreviousDocumentTotalInvoiceAmount(false, DiscountLineExists, PreviousContractNo);
                    CreatePurchaseHeaderForVendorNo(TempBillingLine."Partner No.");
                    PreviousVendorNo := TempBillingLine."Partner No.";
                    PreviousCurrencyCode := TempBillingLine."Currency Code";
                    Window.Update(1, PreviousVendorNo);
                    FirstContractDescriptionLineInserted := false;
                end;
                if TempBillingLine."Subscription Contract No." <> PreviousContractNo then begin
                    InsertContractDescriptionPurchaseLines(TempBillingLine);
                    if PreviousContractNo <> '' then begin
                        TranslationHelper.SetGlobalLanguageByCode(PurchaseHeader."Language Code");
                        PurchaseHeader."Posting Description" := MultipleLbl + ' ' + VendorContractsLbl;
                        TranslationHelper.RestoreGlobalLanguage();
                        PurchaseHeader.Modify(false);
                    end;
                    PreviousContractNo := TempBillingLine."Subscription Contract No.";
                    ContractsProcessedCount += 1;
                    Window.Update(2, PreviousContractNo);
                end;
                InsertPurchaseLineFromTempBillingLine();
            until TempBillingLine.Next() = 0;
        TestPreviousDocumentTotalInvoiceAmount(false, DiscountLineExists, PreviousContractNo);
    end;

    local procedure InsertSalesLineFromTempBillingLine()
    var
        SalesLine: Record "Sales Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        BillingLine: Record "Billing Line";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        UsageDataBilling: Record "Usage Data Billing";
        UsageBasedDocTypeConv: Codeunit "Usage Based Doc. Type Conv.";
        BillingLineNo: Integer;
    begin
        ServiceObject.Get(TempBillingLine."Subscription Header No.");
        ServiceCommitment.Get(TempBillingLine."Subscription Line Entry No.");
        CustomerContractLine.Get(TempBillingLine."Subscription Contract No.", TempBillingLine."Subscription Contract Line No.");
        OnAfterCustomerContractLineGetInInsertSalesLineFromTempBillingLine(CustomerContractLine, SalesHeader, TempBillingLine);

        SalesLine.InitFromSalesHeader(SalesHeader);
        SessionStore.SetBooleanKey('CreateBillingDocumentsAllowInsertOfInvoicingItemNo', true);
        if (ServiceCommitment."Invoicing Item No." <> '') and
            ((ServiceObject."Source No." <> ServiceCommitment."Invoicing Item No.") or (ServiceObject.Type = ServiceObject.Type::"G/L Account"))
        then begin
            SalesLine.Type := SalesLine.Type::Item;
            SalesLine.Validate("No.", ServiceCommitment."Invoicing Item No.")
        end else begin
            SalesLine.Validate(Type, ServiceObject.GetSalesLineType());
            SalesLine.Validate("No.", ServiceObject."Source No.");
            SalesLine.Validate("Variant Code", ServiceObject."Variant Code");
        end;
        SessionStore.RemoveBooleanKey('CreateBillingDocumentsAllowInsertOfInvoicingItemNo');
        if SalesLine.Type = SalesLine.Type::Item then
            ErrorIfItemUnitOfMeasureCodeDoesNotExist(SalesLine."No.", ServiceObject);
        SalesLine.Validate("Unit of Measure Code", ServiceObject."Unit of Measure");
        SalesLine.Validate(Quantity, TempBillingLine.GetSign() * ServiceObject.Quantity);
        SalesLine.Validate("Unit Price", GetSalesDocumentSign(SalesLine."Document Type") * TempBillingLine."Unit Price");
        SalesLine.Validate("Line Discount %", TempBillingLine."Discount %");
        SalesLine.Validate("Unit Cost (LCY)", TempBillingLine."Unit Cost (LCY)");
        SalesLine."Recurring Billing from" := TempBillingLine."Billing from";
        SalesLine."Recurring Billing to" := TempBillingLine."Billing to";
        SalesLine."Discount" := TempBillingLine.Discount;
        SalesLine.GetCombinedDimensionSetID(SalesLine."Dimension Set ID", ServiceCommitment."Dimension Set ID");
        TranslationHelper.SetGlobalLanguageByCode(SalesHeader."Language Code");
        SalesLine.Description :=
            CopyStr(
                GetAdditionalLineText(ServiceContractSetup.FieldNo("Contract Invoice Description"), SalesLine, ServiceObject, ServiceCommitment),
                1,
                MaxStrLen(SalesLine.Description));
        TranslationHelper.RestoreGlobalLanguage();
        SalesLine."Description 2" := '';

        SetInvoicePriceFromUsageDataBilling(SalesLine, TempBillingLine);
        OnBeforeInsertSalesLineFromContractLine(SalesLine, TempBillingLine);
        SalesLine.Insert(false);

        TranslationHelper.SetGlobalLanguageByCode(SalesHeader."Language Code");
        CreateAdditionalInvoiceLine(ServiceContractSetup.FieldNo("Contract Invoice Add. Line 1"), SalesHeader, SalesLine, ServiceObject, ServiceCommitment);
        CreateAdditionalInvoiceLine(ServiceContractSetup.FieldNo("Contract Invoice Add. Line 2"), SalesHeader, SalesLine, ServiceObject, ServiceCommitment);
        CreateAdditionalInvoiceLine(ServiceContractSetup.FieldNo("Contract Invoice Add. Line 3"), SalesHeader, SalesLine, ServiceObject, ServiceCommitment);
        CreateAdditionalInvoiceLine(ServiceContractSetup.FieldNo("Contract Invoice Add. Line 4"), SalesHeader, SalesLine, ServiceObject, ServiceCommitment);
        CreateAdditionalInvoiceLine(ServiceContractSetup.FieldNo("Contract Invoice Add. Line 5"), SalesHeader, SalesLine, ServiceObject, ServiceCommitment);
        OnAfterCreateAdditionalInvoiceLines(SalesHeader, SalesLine, ServiceObject, ServiceCommitment);
        TranslationHelper.RestoreGlobalLanguage();

        BillingLine.SetRange("Subscription Header No.", TempBillingLine."Subscription Header No.");
        BillingLine.SetRange("Subscription Line Entry No.", TempBillingLine."Subscription Line Entry No.");
        BillingLine.SetRange(Rebilling, TempBillingLine.Rebilling);
        if CreateContractInvoice then
            BillingLine.SetRange("Billing Template Code", '');
        BillingLine.ModifyAll("Document Type", BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), false);
        BillingLine.ModifyAll("Document No.", SalesLine."Document No.", false);
        BillingLine.ModifyAll("Document Line No.", SalesLine."Line No.", false);

        if ServiceCommitment."Usage Based Billing" then begin
            UsageDataBilling.SetRange(Partner, Enum::"Service Partner"::Customer);
            UsageDataBilling.SetRange("Subscription Contract No.", CustomerContractLine."Subscription Contract No.");
            UsageDataBilling.SetRange("Subscription Contract Line No.", CustomerContractLine."Line No.");
            UsageDataBilling.SetRange("Document Type", Enum::"Usage Based Billing Doc. Type"::None);
            UsageDataBilling.SetRange("Document No.", '');
            if UsageDataBilling.FindSet() then
                repeat
                    BillingLineNo := GetBillingLineNo(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"),
                                                        "Service Partner"::Customer, SalesLine."Document No.", CustomerContractLine."Subscription Contract No.", CustomerContractLine."Line No.");
                    UsageDataBilling.SaveDocumentValues(UsageBasedDocTypeConv.ConvertSalesDocTypeToUsageBasedBillingDocType(SalesLine."Document Type"), SalesLine."Document No.",
                                                                               SalesLine."Line No.", BillingLineNo);
                until UsageDataBilling.Next() = 0;
        end;

        OnAfterInsertSalesLineFromBillingLine(CustomerContractLine, SalesLine);
    end;

    local procedure SetInvoicePriceFromUsageDataBilling(var SalesLine: Record "Sales Line"; var BillingLine: Record "Billing Line")
    var
        UsageDataBilling: Record "Usage Data Billing";
        ServiceCommitment: Record "Subscription Line";
        NewSalesLineQuantity: Decimal;
        NewSalesLineAmount: Decimal;
    begin
        if not ServiceCommitment.Get(BillingLine."Subscription Line Entry No.") then
            exit;
        if not ServiceCommitment.IsUsageBasedBillingValid() then
            exit;

        if not ServiceCommitment.IsUsageDataBillingFound(UsageDataBilling, BillingLine."Billing from", BillingLine."Billing to") then
            exit;

        UsageDataBilling.CalcSums(Amount, Quantity);
        NewSalesLineQuantity := SalesLine.Quantity;
        NewSalesLineAmount := UsageDataBilling.Amount;
        UsageDataBilling.FindLast();
        if UsageDataBilling.Rebilling then
            NewSalesLineQuantity := UsageDataBilling.Quantity;

        SalesLine.Validate(Quantity, NewSalesLineQuantity);
        SalesLine.Validate("Unit Price", NewSalesLineAmount / NewSalesLineQuantity);
    end;

    local procedure InsertPurchaseLineFromTempBillingLine()
    var
        PurchaseLine: Record "Purchase Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        BillingLine: Record "Billing Line";
        UsageDataBilling: Record "Usage Data Billing";
        UsageBasedDocTypeConv: Codeunit "Usage Based Doc. Type Conv.";
        BillingLineNo: Integer;
    begin
        ServiceObject.Get(TempBillingLine."Subscription Header No.");
        ServiceCommitment.Get(TempBillingLine."Subscription Line Entry No.");

        InitPurchaseLine(PurchaseLine);
        SessionStore.SetBooleanKey('CreateBillingDocumentsAllowInsertOfInvoicingItemNo', true);
        if (ServiceCommitment."Invoicing Item No." <> '') and
            ((ServiceObject."Source No." <> ServiceCommitment."Invoicing Item No.") or (ServiceObject.Type = ServiceObject.Type::"G/L Account"))
        then begin
            PurchaseLine.Type := PurchaseLine.Type::Item;
            PurchaseLine.Validate("No.", ServiceCommitment."Invoicing Item No.");
        end else begin
            PurchaseLine.Validate(Type, ServiceObject.GetPurchaseLineType());
            PurchaseLine.Validate("No.", ServiceObject."Source No.");
            PurchaseLine.Validate("Variant Code", ServiceObject."Variant Code");
        end;
        SessionStore.RemoveBooleanKey('CreateBillingDocumentsAllowInsertOfInvoicingItemNo');
        PurchaseLine.Validate("Unit of Measure Code", ServiceObject."Unit of Measure");
        PurchaseLine.Validate(Quantity, TempBillingLine.GetSign() * ServiceObject.Quantity);
        PurchaseLine.Validate("Direct Unit Cost", GetPurchaseDocumentSign(PurchaseLine."Document Type") * TempBillingLine."Unit Price");
        PurchaseLine.Validate("Line Discount %", TempBillingLine."Discount %");
        PurchaseLine."Recurring Billing from" := TempBillingLine."Billing from";
        PurchaseLine."Recurring Billing to" := TempBillingLine."Billing to";
        PurchaseLine."Discount" := TempBillingLine.Discount;
        PurchaseLine.GetCombinedDimensionSetID(PurchaseLine."Dimension Set ID", ServiceCommitment."Dimension Set ID");
        PurchaseLine.Description := ServiceCommitment.Description;
        PurchaseLine."Description 2" := CopyStr(ServiceObject.Description, 1, MaxStrLen(PurchaseLine."Description 2"));
        SetInvoicePriceFromUsageDataBilling(PurchaseLine, TempBillingLine);

        OnBeforeInsertPurchaseLineFromContractLine(PurchaseLine, TempBillingLine);
        PurchaseLine.Insert(false);
        InsertDescriptionPurchaseLine(
             StrSubstNo(GetBillingPeriodDescriptionTxt(PurchaseHeader."Language Code"), PurchaseLine."Recurring Billing from", PurchaseLine."Recurring Billing to"), PurchaseLine."Line No.");

        if CreateContractInvoice then
            BillingLine.SetRange("Billing Template Code", '');
        BillingLine.SetRange("Subscription Header No.", TempBillingLine."Subscription Header No.");
        BillingLine.SetRange("Subscription Line Entry No.", TempBillingLine."Subscription Line Entry No.");
        BillingLine.SetRange(Rebilling, TempBillingLine.Rebilling);

        BillingLine.ModifyAll("Document Type", BillingLine.GetBillingDocumentTypeFromSalesDocumentType(PurchaseLine."Document Type"), false);
        BillingLine.ModifyAll("Document No.", PurchaseLine."Document No.", false);
        BillingLine.ModifyAll("Document Line No.", PurchaseLine."Line No.", false);

        UsageDataBilling.SetRange(Partner, Enum::"Service Partner"::Vendor);
        UsageDataBilling.SetRange("Subscription Contract No.", ServiceCommitment."Subscription Contract No.");
        UsageDataBilling.SetRange("Subscription Contract Line No.", ServiceCommitment."Subscription Contract Line No.");
        UsageDataBilling.SetRange("Document Type", Enum::"Usage Based Billing Doc. Type"::None);
        UsageDataBilling.SetRange("Document No.", '');
        if UsageDataBilling.FindSet() then
            repeat
                BillingLineNo := GetBillingLineNo(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchaseLine."Document Type"),
                                                    "Service Partner"::Vendor, PurchaseLine."Document No.", ServiceCommitment."Subscription Contract No.", ServiceCommitment."Subscription Contract Line No.");
                UsageDataBilling.SaveDocumentValues(UsageBasedDocTypeConv.ConvertPurchaseDocTypeToUsageBasedBillingDocType(PurchaseLine."Document Type"), PurchaseLine."Document No.",
                                           PurchaseLine."Line No.", BillingLineNo);
            until UsageDataBilling.Next() = 0;

        OnAfterInsertPurchaseLineFromBillingLine(ServiceCommitment, PurchaseLine);
    end;

    local procedure SetInvoicePriceFromUsageDataBilling(var PurchLine: Record "Purchase Line"; var BillingLine: Record "Billing Line")
    var
        UsageDataBilling: Record "Usage Data Billing";
        ServiceCommitment: Record "Subscription Line";
        NewPurchaseLineQuantity: Decimal;
        NewPurchaseLineAmount: Decimal;
    begin
        if not ServiceCommitment.Get(BillingLine."Subscription Line Entry No.") then
            exit;
        if not ServiceCommitment.IsUsageBasedBillingValid() then
            exit;

        if not ServiceCommitment.IsUsageDataBillingFound(UsageDataBilling, BillingLine."Billing from", BillingLine."Billing to") then
            exit;

        UsageDataBilling.CalcSums("Cost Amount", Quantity);
        NewPurchaseLineQuantity := PurchLine.Quantity;
        NewPurchaseLineAmount := UsageDataBilling."Cost Amount";
        UsageDataBilling.FindLast();
        if UsageDataBilling.Rebilling then
            NewPurchaseLineQuantity := UsageDataBilling.Quantity;

        PurchLine.Validate(Quantity, NewPurchaseLineQuantity);
        PurchLine.Validate("Direct Unit Cost", NewPurchaseLineAmount / NewPurchaseLineQuantity);
    end;

    local procedure GetBillingLineNo(BillingDocumentType: Enum "Rec. Billing Document Type"; ServicePartner: Enum "Service Partner"; DocumentNo: Code[20]; ContractNo: Code[20]; ContractLineNo: Integer): Integer
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnContractLine(ServicePartner, ContractNo, ContractLineNo);
        BillingLine.SetRange("Document Type", BillingDocumentType);
        BillingLine.SetRange("Document No.", DocumentNo);
        if BillingLine.FindLast() then
            exit(BillingLine."Entry No.")
        else
            exit(0);
    end;

    local procedure InitPurchaseLine(var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := PurchaseHeader.GetNextLineNo();
    end;

    local procedure InsertDescriptionPurchaseLine(NewDescription: Text; AttachedToLineNo: Integer)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        InitPurchaseLine(PurchaseLine);
        PurchaseLine."Attached to Line No." := AttachedToLineNo;
        PurchaseLine.Description := CopyStr(NewDescription, 1, MaxStrLen(PurchaseLine.Description));
        PurchaseLine.Insert(false);
    end;

    local procedure InsertContractDescriptionSalesLines(BillingLine: Record "Billing Line")
    var
        SalesLine: Record "Sales Line";
        ContractTypeDescription: Text;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertContractDescriptionSalesLines(SalesHeader, BillingLine, FirstContractDescriptionLineInserted, CustomerRecurringBillingGrouping, IsHandled);
        if not IsHandled then begin
            TranslationHelper.SetGlobalLanguageByCode(SalesHeader."Language Code");
            if FirstContractDescriptionLineInserted then
                SalesLine.InsertDescriptionSalesLine(SalesHeader, '', 0);
            SalesLine.InsertDescriptionSalesLine(SalesHeader, StrSubstNo(ContractNoTxt, BillingLine."Subscription Contract No."), 0);
            InsertAddressInfoForCollectiveInvoice(BillingLine);
            ContractTypeDescription := GetContractTypeDescription(BillingLine."Subscription Contract No.", BillingLine.Partner, SalesHeader."Language Code");
            if ContractTypeDescription <> '' then
                SalesLine.InsertDescriptionSalesLine(SalesHeader, ContractTypeDescription, 0);
            if CustomerRecurringBillingGrouping <> CustomerRecurringBillingGrouping::Contract then
                FirstContractDescriptionLineInserted := true;
            TranslationHelper.RestoreGlobalLanguage();
        end;
        OnAfterInsertContractDescriptionSalesLines(SalesHeader, BillingLine, FirstContractDescriptionLineInserted, CustomerRecurringBillingGrouping);
    end;

    local procedure InsertAddressInfoForCollectiveInvoice(BillingLine: Record "Billing Line")
    var
        SalesLine: Record "Sales Line";
        CustomerContract: Record "Customer Subscription Contract";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertAddressInfoForCollectiveInvoice(BillingLine, CustomerRecurringBillingGrouping, SalesHeader, IsHandled);
        if not IsHandled then
            if (BillingLine.Partner = BillingLine.Partner::Customer) and
               (BillingLine."Subscription Contract No." <> '') and
               (CustomerRecurringBillingGrouping <> CustomerRecurringBillingGrouping::Contract)
            then
                if CustomerContract.Get(BillingLine."Subscription Contract No.") then begin
                    if CustomerContract."Contractor Name in coll. Inv." then begin
                        if CustomerContract."Sell-to Customer Name" <> '' then
                            SalesLine.InsertDescriptionSalesLine(SalesHeader, CustomerContract."Sell-to Customer Name", 0);
                        if CustomerContract."Sell-to Customer Name 2" <> '' then
                            SalesLine.InsertDescriptionSalesLine(SalesHeader, CustomerContract."Sell-to Customer Name 2", 0);
                    end;
                    if CustomerContract."Recipient Name in coll. Inv." then begin
                        if CustomerContract."Ship-to Name" <> '' then
                            SalesLine.InsertDescriptionSalesLine(SalesHeader, CustomerContract."Ship-to Name", 0);
                        if CustomerContract."Ship-to Name 2" <> '' then
                            SalesLine.InsertDescriptionSalesLine(SalesHeader, CustomerContract."Ship-to Name 2", 0);
                    end;
                end;
        OnAfterInsertAddressInfoForCollectiveInvoice(BillingLine, CustomerRecurringBillingGrouping, SalesHeader);
    end;

    local procedure InsertContractDescriptionPurchaseLines(BillingLine: Record "Billing Line")
    var
        ContractTypeDescription: Text;
    begin
        TranslationHelper.SetGlobalLanguageByCode(PurchaseHeader."Language Code");
        if FirstContractDescriptionLineInserted then
            InsertDescriptionPurchaseLine('', 0);
        InsertDescriptionPurchaseLine(StrSubstNo(ContractNoTxt, BillingLine."Subscription Contract No."), 0);
        ContractTypeDescription := GetContractTypeDescription(BillingLine."Subscription Contract No.", BillingLine.Partner, PurchaseHeader."Language Code");
        if ContractTypeDescription <> '' then
            InsertDescriptionPurchaseLine(ContractTypeDescription, 0);
        if VendorRecurringBillingGrouping <> VendorRecurringBillingGrouping::Contract then
            FirstContractDescriptionLineInserted := true;
        TranslationHelper.RestoreGlobalLanguage();
    end;

    internal procedure GetContractTypeDescription(ContractNo: Code[20]; Partner: Enum "Service Partner"; LanguageCode: Code[10]): Text[50]
    var
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
        ContractType: Record "Subscription Contract Type";
        FieldTranslation: Record "Field Translation";
        ContractTypeCode: Code[10];
    begin
        case Partner of
            Enum::"Service Partner"::Customer:
                if CustomerContract.Get(ContractNo) then
                    ContractTypeCode := CustomerContract."Contract Type";
            Enum::"Service Partner"::Vendor:
                if VendorContract.Get(ContractNo) then
                    ContractTypeCode := VendorContract."Contract Type";
        end;
        if ContractType.Get(ContractTypeCode) then
            exit(
                CopyStr(
                    FieldTranslation.FindTranslation(
                        ContractType,
                        ContractType.FieldNo(Description),
                        LanguageCode),
                    1, 50));
    end;

    local procedure CreateSalesHeaderFromContract(CustomerContract: Record "Customer Subscription Contract")
    var
        OldSalesHeader: Record "Sales Header";
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := TempBillingLine.GetSalesDocumentTypeForContractNo();
        DocumentsCreatedCount += 1;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader."Recurring Billing" := true;
        SalesHeader.Validate("Sell-to Customer No.", CustomerContract."Sell-to Customer No.");
        if SalesHeader."Bill-to Customer No." <> CustomerContract."Bill-to Customer No." then
            SalesHeader.Validate("Bill-to Customer No.", CustomerContract."Bill-to Customer No.");
        OldSalesHeader := SalesHeader;
        SalesHeader.TransferFields(CustomerContract, false);
        SalesHeader."Recurring Billing" := true;
        SalesHeader."No. Series" := OldSalesHeader."No. Series";
        SalesHeader."Posting No." := OldSalesHeader."Posting No.";
        SalesHeader."Posting No. Series" := OldSalesHeader."Posting No. Series";
        SalesHeader."Shipping No." := OldSalesHeader."Shipping No.";
        SalesHeader."Shipping No. Series" := OldSalesHeader."Shipping No. Series";
        SalesHeader."No. Printed" := 0;
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Document Date", DocumentDate);
        SalesHeader.Validate("Currency Code");
        SalesHeader."Assigned User ID" := CopyStr(UserId(), 1, MaxStrLen(SalesHeader."Assigned User ID"));
        TranslationHelper.SetGlobalLanguageByCode(SalesHeader."Language Code");
        SalesHeader."Posting Description" := CustomerContractLbl + ' ' + CustomerContract."No.";
        TranslationHelper.RestoreGlobalLanguage();
        SessionStore.SetBooleanKey('SkipContractSalesHeaderModifyCheck', true);
        OnAfterCreateSalesHeaderFromContract(CustomerContract, SalesHeader);
        SalesHeader.Modify(false);
        if PostDocuments then begin
            TempSalesHeader := SalesHeader;
            TempSalesHeader.Insert(false);
        end;
        SessionStore.RemoveBooleanKey('SkipContractSalesHeaderModifyCheck');
    end;

    local procedure CreatePurchaseHeaderFromContract(VendorContract: Record "Vendor Subscription Contract")
    var
        OldPurchaseHeader: Record "Purchase Header";
    begin
        if CreateOnlyPurchaseInvoiceLines then
            exit;
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := TempBillingLine.GetPurchaseDocumentTypeForContractNo();
        DocumentsCreatedCount += 1;
        PurchaseHeader."No." := '';
        PurchaseHeader.Insert(true);
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Pay-to Vendor No.", VendorContract."Pay-to Vendor No.");
        PurchaseHeader.Validate("Buy-from Vendor No.", VendorContract."Buy-from Vendor No.");
        if PurchaseHeader."Pay-to Vendor No." <> VendorContract."Pay-to Vendor No." then
            PurchaseHeader.Validate("Pay-to Vendor No.", VendorContract."Pay-to Vendor No.");
        OldPurchaseHeader := PurchaseHeader;
        PurchaseHeader.TransferFields(VendorContract, false);
        PurchaseHeader."Recurring Billing" := true;
        PurchaseHeader."No. Series" := OldPurchaseHeader."No. Series";
        PurchaseHeader."Posting No." := OldPurchaseHeader."Posting No.";
        PurchaseHeader."Posting No. Series" := OldPurchaseHeader."Posting No. Series";
        PurchaseHeader."Receiving No." := OldPurchaseHeader."Receiving No.";
        PurchaseHeader."Receiving No. Series" := OldPurchaseHeader."Receiving No. Series";
        PurchaseHeader."No. Printed" := 0;
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Document Date", DocumentDate);
        PurchaseHeader.Validate("Currency Code");
        PurchaseHeader."Assigned User ID" := CopyStr(UserId(), 1, MaxStrLen(SalesHeader."Assigned User ID"));
        TranslationHelper.SetGlobalLanguageByCode(PurchaseHeader."Language Code");
        PurchaseHeader."Posting Description" := VendorContractLbl + ' ' + VendorContract."No.";
        TranslationHelper.RestoreGlobalLanguage();
        SessionStore.SetBooleanKey('SkipContractPurchaseHeaderModifyCheck', true);
        PurchaseHeader.Modify(false);
        SessionStore.RemoveBooleanKey('SkipContractPurchaseHeaderModifyCheck');
    end;

    local procedure CreateSalesHeaderForCustomerNo(CustomerNo: Code[20])
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := TempBillingLine.GetSalesDocumentTypeForCustomerNo();
        DocumentsCreatedCount += 1;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader."Recurring Billing" := true;
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Document Date", DocumentDate);
        SalesHeader.Validate("Currency Code");
        SalesHeader."Assigned User ID" := CopyStr(UserId(), 1, MaxStrLen(SalesHeader."Assigned User ID"));
        TranslationHelper.SetGlobalLanguageByCode(SalesHeader."Language Code");
        SalesHeader."Posting Description" := CustomerContractLbl + ' ' + TempBillingLine."Subscription Contract No.";
        TranslationHelper.RestoreGlobalLanguage();
        SessionStore.SetBooleanKey('SkipContractSalesHeaderModifyCheck', true);
        OnAfterCreateSalesHeaderForCustomerNo(SalesHeader, TempBillingLine."Subscription Contract No.");
        SalesHeader.Modify(false);
        if PostDocuments then begin
            TempSalesHeader := SalesHeader;
            TempSalesHeader.Insert(false);
        end;
        SessionStore.RemoveBooleanKey('SkipContractSalesHeaderModifyCheck');
    end;

    local procedure CreatePurchaseHeaderForVendorNo(VendorNo: Code[20])
    begin
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := TempBillingLine.GetPurchaseDocumentTypeForVendorNo();
        DocumentsCreatedCount += 1;
        PurchaseHeader."No." := '';
        PurchaseHeader.Insert(true);
        PurchaseHeader."Recurring Billing" := true;
        PurchaseHeader.Validate("Pay-to Vendor No.", VendorNo);
        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Document Date", DocumentDate);
        PurchaseHeader.Validate("Currency Code");
        PurchaseHeader."Assigned User ID" := CopyStr(UserId(), 1, MaxStrLen(SalesHeader."Assigned User ID"));
        TranslationHelper.SetGlobalLanguageByCode(PurchaseHeader."Language Code");
        PurchaseHeader."Posting Description" := VendorContractLbl + ' ' + TempBillingLine."Subscription Contract No.";
        TranslationHelper.RestoreGlobalLanguage();
        SessionStore.SetBooleanKey('SkipContractPurchaseHeaderModifyCheck', true);
        PurchaseHeader.Modify(false);
        SessionStore.RemoveBooleanKey('SkipContractPurchaseHeaderModifyCheck');
    end;

    internal procedure SetPurchaseHeaderFromExistingPurchaseDocument(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20])
    begin
        SessionStore.SetBooleanKey('SkipContractPurchaseHeaderModifyCheck', true);
        PurchaseHeader.Get(DocumentType, DocumentNo);
        PurchaseHeader.SetRecurringBilling();
        SessionStore.RemoveBooleanKey('SkipContractPurchaseHeaderModifyCheck');
        CreateOnlyPurchaseInvoiceLines := true;
    end;

    local procedure CreateTempBillingLines(var BillingLine: Record "Billing Line")
    var
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
        CurrencyCode: Code[20];
        PartnerNo: Code[20];
        LineNo: Integer;
    begin
        if BillingLine.FindSet() then
            repeat
                case BillingLine.Partner of
                    BillingLine.Partner::Customer:
                        begin
                            CustomerContract.Get(BillingLine."Subscription Contract No.");
                            case CustomerRecurringBillingGrouping of
                                CustomerRecurringBillingGrouping::"Sell-to Customer No.":
                                    PartnerNo := CustomerContract."Sell-to Customer No.";
                                CustomerRecurringBillingGrouping::"Bill-to Customer No.":
                                    PartnerNo := CustomerContract."Bill-to Customer No.";
                            end;
                            CurrencyCode := CustomerContract."Currency Code";
                        end;
                    BillingLine.Partner::Vendor:
                        begin
                            VendorContract.Get(BillingLine."Subscription Contract No.");
                            case VendorRecurringBillingGrouping of
                                VendorRecurringBillingGrouping::"Pay-to Vendor No.":
                                    PartnerNo := VendorContract."Pay-to Vendor No.";
                                VendorRecurringBillingGrouping::"Buy-from Vendor No.":
                                    PartnerNo := VendorContract."Buy-from Vendor No.";
                            end;
                            CurrencyCode := VendorContract."Currency Code";
                        end;
                end;

                TempBillingLine.SetRange("Subscription Contract No.", BillingLine."Subscription Contract No.");
                TempBillingLine.SetRange("Subscription Header No.", BillingLine."Subscription Header No.");
                TempBillingLine.SetRange("Subscription Line Entry No.", BillingLine."Subscription Line Entry No.");
                TempBillingLine.SetRange(Rebilling, BillingLine.Rebilling);
                if not TempBillingLine.FindFirst() then begin
                    TempBillingLine.Init();
                    LineNo += 1;
                    TempBillingLine."Entry No." := LineNo;
                    TempBillingLine."Partner No." := PartnerNo;
                    TempBillingLine.Partner := BillingLine.Partner;
                    TempBillingLine."Subscription Contract No." := BillingLine."Subscription Contract No.";
                    TempBillingLine."Detail Overview" := CustomerContract."Detail Overview";
                    TempBillingLine."Currency Code" := CurrencyCode;
                    TempBillingLine."Subscription Contract Line No." := BillingLine."Subscription Contract Line No.";
                    TempBillingLine."Subscription Header No." := BillingLine."Subscription Header No.";
                    TempBillingLine."Subscription Line Entry No." := BillingLine."Subscription Line Entry No.";
                    TempBillingLine."Discount %" := BillingLine."Discount %";
                    TempBillingLine."Subscription Line Description" := BillingLine."Subscription Line Description";
                    TempBillingLine.Rebilling := BillingLine.Rebilling;
                    OnBeforeInsertTempBillingLine(TempBillingLine, BillingLine);
                    TempBillingLine.Insert(false);
                end;
                TempBillingLine."Unit Price" += BillingLine."Unit Price";
                TempBillingLine.Amount += BillingLine.Amount;
                TempBillingLine.Discount := BillingLine.Discount;
                TempBillingLine."Document Type" := InitRecurringBillingDocumentType(TempBillingLine.Amount, BillingLine.Discount);
                if (TempBillingLine."Billing from" > BillingLine."Billing from") or (TempBillingLine."Billing from" = 0D) then
                    TempBillingLine."Billing from" := BillingLine."Billing from";
                if TempBillingLine."Billing to" < BillingLine."Billing to" then
                    TempBillingLine."Billing to" := BillingLine."Billing to";
                OnCreateTempBillingLinesBeforeSaveTempBillingLine(TempBillingLine, BillingLine);
                TempBillingLine."Unit Cost" += BillingLine."Unit Cost";
                TempBillingLine."Unit Cost (LCY)" += BillingLine."Unit Cost (LCY)";
                TempBillingLine.Modify(false);
            until BillingLine.Next() = 0;
    end;

    local procedure InitRecurringBillingDocumentType(Amount: Decimal; Discount: Boolean) DocumentType: Enum "Rec. Billing Document Type"
    begin
        if Discount then begin
            if Amount <= 0 then
                DocumentType := Enum::"Rec. Billing Document Type"::Invoice
            else
                DocumentType := Enum::"Rec. Billing Document Type"::"Credit Memo";
        end else
            if Amount >= 0 then
                DocumentType := Enum::"Rec. Billing Document Type"::Invoice
            else
                DocumentType := Enum::"Rec. Billing Document Type"::"Credit Memo";
    end;

    local procedure RequestPageSelectionConfirmed(): Boolean
    var
        CreateCustomerBillingDocs: Page "Create Customer Billing Docs";
        CreateVendorBillingDocs: Page "Create Vendor Billing Docs";
    begin
        if CustomerBillingLinesFound then begin
            if CreateCustomerBillingDocs.RunModal() = Action::OK then begin
                CreateCustomerBillingDocs.GetData(DocumentDate, PostingDate, CustomerRecurringBillingGrouping, PostDocuments);
                exit(true);
            end;
        end
        else
            if VendorBillingLinesFound then
                if CreateVendorBillingDocs.RunModal() = Action::OK then begin
                    CreateVendorBillingDocs.GetData(DocumentDate, PostingDate, VendorRecurringBillingGrouping);
                    exit(true);
                end;
    end;

    local procedure CheckBillingLines(var BillingLine: Record "Billing Line")
    begin
        CheckNoUpdateRequired(BillingLine);
        CheckOnlyOneServicePartnerType(BillingLine);
    end;

    local procedure CheckOnlyOneServicePartnerType(var BillingLine: Record "Billing Line")
    begin
        if BillingLine.FindSet() then
            repeat
                case BillingLine.Partner of
                    BillingLine.Partner::Customer:
                        CustomerBillingLinesFound := true;
                    BillingLine.Partner::Vendor:
                        VendorBillingLinesFound := true;
                end;
            until BillingLine.Next() = 0;

        if (CustomerBillingLinesFound and VendorBillingLinesFound) then
            Error(OnlyOneServicePartnerErr);
    end;

    local procedure CheckNoUpdateRequired(var BillingLine: Record "Billing Line")
    begin
        BillingLine.SetRange("Update Required", true);
        if not BillingLine.IsEmpty() then
            Error(UpdateRequiredErr);
        BillingLine.SetRange("Update Required");
    end;

    local procedure ProcessingFinishedMessage()
    begin
        if DocumentsCreatedCount = 0 then
            Message(NoDocumentsCreatedMsg)
        else
            if PostDocuments then
                Message(StrSubstNo(DocumentsCreatedAndPostedMsg, Format(DocumentsCreatedCount), Format(ContractsProcessedCount)))
            else
                Message(StrSubstNo(DocumentsCreatedMsg, Format(DocumentsCreatedCount), Format(ContractsProcessedCount)));
    end;

    local procedure PostCreatedDocuments()
    begin
        TempSalesHeader.Reset();
        if not TempSalesHeader.IsEmpty() then begin
            PostSalesDocuments();
            TempSalesHeader.DeleteAll(false);
        end;
    end;

    local procedure PostSalesDocuments()
    var
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        SalesBatchPostMgt: Codeunit "Sales Batch Post Mgt.";
    begin
        if TempSalesHeader.Count() = 1 then begin
            SalesHeader.Get(TempSalesHeader."Document Type", TempSalesHeader."No.");
            SalesHeader.SendToPosting(Codeunit::"Sales-Post");
        end else begin
            HideProcessingFinishedMessage := true;
            SalesHeader.Reset();
            if TempSalesHeader.FindSet() then
                repeat
                    SalesHeader.Get(TempSalesHeader."Document Type", TempSalesHeader."No.");
                    SalesHeader.Mark(true);
                until TempSalesHeader.Next() = 0;
            SalesHeader.MarkedOnly(true);

            ErrorMessageMgt.Activate(ErrorMessageHandler);
            ErrorMessageMgt.PushContext(ErrorContextElement, Database::"Sales Header", 0, SalesBatchPostingMsg);
            Commit(); // Commit before if Codeunit.Run
            if SalesBatchPostMgt.Run(SalesHeader) then;

            if ErrorMessageMgt.GetLastErrorID() > 0 then
                ErrorMessageHandler.ShowErrors();
        end;
    end;

    local procedure TestPreviousDocumentTotalInvoiceAmount(Sales: Boolean; DiscountLineExists: Boolean; PreviousContractNo: Code[20])
    var
        AmountToCheck: Decimal;
    begin
        OnBeforeTestPreviousDocumentTotalInvoiceAmount(Sales, DiscountLineExists, PreviousContractNo, SalesHeader, PurchaseHeader);
        if not DiscountLineExists then
            exit;
        if PreviousContractNo = '' then
            exit;
        if Sales then begin
            SalesHeader.CalcFields(Amount);
            AmountToCheck := SalesHeader.Amount;
        end else begin
            PurchaseHeader.CalcFields(Amount);
            AmountToCheck := PurchaseHeader.Amount;
        end;

        if AmountToCheck < 0 then
            Error(TotalInvoiceAmountIsLessThanZeroErr, PreviousContractNo);
    end;

    procedure SetSkipRequestPageSelection(NewSkipRequestPageSelection: Boolean)
    begin
        SkipRequestPageSelection := NewSkipRequestPageSelection;
    end;

    procedure SetDocumentDataFromRequestPage(DocumentDateValue: Date; PostingDateValue: Date; PostDocumentValue: Boolean; CreateContractInvoiceValue: Boolean)
    begin
        DocumentDate := DocumentDateValue;
        PostingDate := PostingDateValue;
        PostDocuments := PostDocumentValue;
        CreateContractInvoice := CreateContractInvoiceValue;
    end;

    procedure SetBillingGroupingPerContract(ServicePartner: Enum "Service Partner")
    begin
        if ServicePartner = "Service Partner"::Vendor then
            VendorRecurringBillingGrouping := "Vendor Rec. Billing Grouping"::Contract
        else
            CustomerRecurringBillingGrouping := "Customer Rec. Billing Grouping"::Contract;
    end;

    local procedure GetBillingPeriodDescriptionTxt() DescriptionText: Text
    begin
        DescriptionText := ServicePeriodDescriptionTxt;
    end;

    local procedure GetBillingPeriodDescriptionTxt(LanguageCode: Code[10]) DescriptionText: Text
    begin
        TranslationHelper.SetGlobalLanguageByCode(LanguageCode);
        DescriptionText := GetBillingPeriodDescriptionTxt();
        TranslationHelper.RestoreGlobalLanguage();
    end;

    local procedure CreateAdditionalInvoiceLine(ServiceContractSetupFieldNo: Integer; SalesHeader2: Record "Sales Header"; ParentSalesLine: Record "Sales Line"; ServiceObject: Record "Subscription Header"; ServiceCommitment: Record "Subscription Line")
    var
        SalesLine: Record "Sales Line";
        DescriptionText: Text;
    begin
        DescriptionText := GetAdditionalLineText(ServiceContractSetupFieldNo, ParentSalesLine, ServiceObject, ServiceCommitment);
        if DescriptionText = '' then
            exit;
        SalesLine.InsertDescriptionSalesLine(SalesHeader2, DescriptionText, ParentSalesLine."Line No.");
        OnAfterCreateAdditionalInvoiceLine(SalesLine, ParentSalesLine);
    end;

    local procedure GetAdditionalLineText(ServiceContractSetupFieldNo: Integer; ParentSalesLine: Record "Sales Line"; ServiceObject: Record "Subscription Header"; ServiceCommitment: Record "Subscription Line") DescriptionText: Text
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        ContractInvoiceTextType: Enum "Contract Invoice Text Type";
        IsHandled: Boolean;
        ReferenceNoLbl: Label 'Reference No.: %1';
        SetupOptionNotHandledErr: Label 'Error getting a Line Description: Option %1 (Field %2 in %3) is not handled.';
    begin
        GetServiceContractSetup();
        RecRef.GetTable(ServiceContractSetup);
        FRef := RecRef.Field(ServiceContractSetupFieldNo);
        ContractInvoiceTextType := FRef.Value;
        RecRef.Close();

        case ContractInvoiceTextType of
            ContractInvoiceTextType::" ":
                DescriptionText := '';
            ContractInvoiceTextType::"Service Object":
                DescriptionText := ServiceObject.Description;
            ContractInvoiceTextType::"Service Commitment":
                DescriptionText := ServiceCommitment.Description;
            ContractInvoiceTextType::"Customer Reference":
                if ServiceObject."Customer Reference" <> '' then
                    DescriptionText := StrSubstNo(ReferenceNoLbl, ServiceObject."Customer Reference");
            ContractInvoiceTextType::"Serial No.":
                if ServiceObject."Serial No." <> '' then
                    DescriptionText := ServiceObject.GetSerialNoDescription();
            ContractInvoiceTextType::"Billing Period":
                DescriptionText := StrSubstNo(
                                                GetBillingPeriodDescriptionTxt(),
                                                ParentSalesLine."Recurring Billing from",
                                                ParentSalesLine."Recurring Billing to");
            ContractInvoiceTextType::"Primary attribute":
                DescriptionText := ServiceObject.GetPrimaryAttributeValue();
            else begin
                DescriptionText := '';
                IsHandled := false;
                OnGetAdditionalLineTextElseCase(ContractInvoiceTextType, ServiceObject, ServiceCommitment, DescriptionText, IsHandled);
                if not IsHandled then begin
                    RecRef.GetTable(ServiceContractSetup);
                    FRef := RecRef.Field(ServiceContractSetupFieldNo);
                    Error(SetupOptionNotHandledErr, ContractInvoiceTextType, FRef.Caption, ServiceContractSetup.TableCaption());
                end;
            end;
        end;

        OnAfterGetAdditionalLineText(ServiceContractSetupFieldNo, ParentSalesLine, ServiceObject, ServiceCommitment, DescriptionText);
    end;

    local procedure GetServiceContractSetup()
    begin
        if ServiceContractSetupFetched then
            exit;
        ServiceContractSetup.Get();
        ServiceContractSetup.VerifyContractTextsSetup();
        ServiceContractSetupFetched := true;
    end;

    local procedure GetSalesDocumentSign(SalesDocumentType: Enum "Sales Document Type"): Integer
    begin
        if SalesDocumentType = "Sales Document Type"::"Credit Memo" then
            exit(-1);
        exit(1);
    end;

    local procedure GetPurchaseDocumentSign(PurchaseDocumentType: Enum "Purchase Document Type"): Integer
    begin
        if PurchaseDocumentType = "Purchase Document Type"::"Credit Memo" then
            exit(-1);
        exit(1);
    end;

    internal procedure SetHideProcessingFinishedMessage()
    begin
        HideProcessingFinishedMessage := true;
    end;

    local procedure SetDiscountLineExists(var TempBillingLine2: Record "Billing Line" temporary; var DiscountLineExists: Boolean): Boolean
    begin
        TempBillingLine2.SetRange(Discount, true);
        DiscountLineExists := not TempBillingLine2.IsEmpty();
        TempBillingLine2.SetRange(Discount);
    end;

    local procedure IsNewSalesHeaderNeeded(PreviousCustomerNo: Code[20]; LastDetailOverview: Enum "Contract Detail Overview"; PreviousCurrencyCode: Code[20]; PreviousContractNo: Code[20]) CreateNewSalesHeader: Boolean
    var
    begin
        CreateNewSalesHeader := (TempBillingLine."Partner No." <> PreviousCustomerNo) or
                                (TempBillingLine."Detail Overview" <> LastDetailOverview) or
                                (TempBillingLine."Currency Code" <> PreviousCurrencyCode);

        OnAfterIsNewSalesHeaderNeeded(CreateNewSalesHeader, TempBillingLine, PreviousCustomerNo, LastDetailOverview, PreviousCurrencyCode, PreviousContractNo);
    end;

    internal procedure ErrorIfItemUnitOfMeasureCodeDoesNotExist(ItemNo: Code[20]; ServiceObject: Record "Subscription Header")
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemUOMDoesNotExistErr: Label 'The Unit of Measure of the Subscription (%1) contains a value (%2) that cannot be found in the Item Unit of Measure of the corresponding Invoicing Item (%3).', Comment = '%1 = Subscription No., %2 = Unit Of Measure Code, %3 = Item No.';
    begin
        ItemUnitOfMeasure.SetRange("Item No.", ItemNo);
        ItemUnitOfMeasure.SetRange(Code, ServiceObject."Unit of Measure");
        if ItemUnitOfMeasure.IsEmpty() then
            Error(ItemUOMDoesNotExistErr, ServiceObject."No.", ServiceObject."Unit of Measure", ItemNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesHeaderFromContract(CustomerSubscriptionContract: Record "Customer Subscription Contract"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesHeaderForCustomerNo(var SalesHeader: Record "Sales Header"; ContractNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesLineFromContractLine(var SalesLine: Record "Sales Line"; var TempBillingLine: Record "Billing Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertContractDescriptionSalesLines(SalesHeader: Record "Sales Header"; BillingLine: Record "Billing Line"; var FirstContractDescriptionLineInserted: Boolean; CustomerRecurringBillingGrouping: Enum "Customer Rec. Billing Grouping"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertContractDescriptionSalesLines(SalesHeader: Record "Sales Header"; BillingLine: Record "Billing Line"; var FirstContractDescriptionLineInserted: Boolean; CustomerRecurringBillingGrouping: Enum "Customer Rec. Billing Grouping")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesLineFromBillingLine(CustomerContractLine: Record "Cust. Sub. Contract Line"; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPurchaseLineFromBillingLine(SubscriptionLine: Record "Subscription Line"; PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPurchaseLineFromContractLine(var PurchLine: Record "Purchase Line"; var TempBillingLine: Record "Billing Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateAdditionalInvoiceLines(SalesHeader: Record "Sales Header"; ParentSalesLine: Record "Sales Line"; ServiceObject: Record "Subscription Header"; SubscriptionLine: Record "Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetAdditionalLineTextElseCase(ContractInvoiceTextType: Enum "Contract Invoice Text Type"; SubscriptionHeader: Record "Subscription Header"; SubscriptionLine: Record "Subscription Line"; var DescriptionText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertAddressInfoForCollectiveInvoice(BillingLine: Record "Billing Line"; CustomerRecurringBillingGrouping: Enum "Customer Rec. Billing Grouping"; SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertAddressInfoForCollectiveInvoice(BillingLine: Record "Billing Line"; CustomerRecurringBillingGrouping: Enum "Customer Rec. Billing Grouping"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateTempBillingLinesBeforeSaveTempBillingLine(var TempBillingLine: Record "Billing Line" temporary; var BillingLine: Record "Billing Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTempBillingLine(var TempBillingLine: Record "Billing Line" temporary; var BillingLine: Record "Billing Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessBillingLines(var BillingLine: Record "Billing Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessBillingLines(var BillingLine: Record "Billing Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateBillingDocuments(var BillingLine: Record "Billing Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsNewSalesHeaderNeeded(var CreateNewSalesHeader: Boolean; TempBillingLine: Record "Billing Line" temporary; PreviousCustomerNo: Code[20]; LastDetailOverview: Enum "Contract Detail Overview"; PreviousCurrencyCode: Code[20]; PreviousContractNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestPreviousDocumentTotalInvoiceAmount(Sales: Boolean; DiscountLineExists: Boolean; PreviousContractNo: Code[20]; SalesHeader: Record "Sales Header"; PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCustomerContractLineGetInInsertSalesLineFromTempBillingLine(CustomerContractLine: Record "Cust. Sub. Contract Line"; SalesHeader: Record "Sales Header"; var TempBillingLine: Record "Billing Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesDocumentsPerContractBeforeTempBillingLineFindSet(var TempBillingLine: Record "Billing Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreatePurchaseDocumentsPerContractBeforeTempBillingLineFindSet(var TempBillingLine: Record "Billing Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesDocumentsPerCustomerBeforeTempBillingLineFindSet(var TempBillingLine: Record "Billing Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreatePurchaseDocumentsPerVendorBeforeTempBillingLineFindSet(var TempBillingLine: Record "Billing Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateAdditionalInvoiceLine(var SalesLine: Record "Sales Line"; ParentSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAdditionalLineText(SubscriptionContractSetupFieldNo: Integer; ParentSalesLine: Record "Sales Line"; SubscriptionHeader: Record "Subscription Header"; ServiceCommitment: Record "Subscription Line"; var DescriptionText: Text)
    begin
    end;

    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TempBillingLine: Record "Billing Line" temporary;
        TempSalesHeader: Record "Sales Header" temporary;
        ServiceContractSetup: Record "Subscription Contract Setup";
        SessionStore: Codeunit "Session Store";
        TranslationHelper: Codeunit "Translation Helper";
        DocumentDate: Date;
        PostingDate: Date;
        CustomerRecurringBillingGrouping: Enum "Customer Rec. Billing Grouping";
        VendorRecurringBillingGrouping: Enum "Vendor Rec. Billing Grouping";
        DocumentsCreatedCount: Integer;
        ContractsProcessedCount: Integer;
        CustomerBillingLinesFound: Boolean;
        VendorBillingLinesFound: Boolean;
        FirstContractDescriptionLineInserted: Boolean;
        PostDocuments: Boolean;
        HideProcessingFinishedMessage: Boolean;
        Window: Dialog;
        ProgressTxt: Label 'Creating documents...\Partner No. #1#################################\Contract No. #2#################################';
        OnlyOneServicePartnerErr: Label 'You can create documents only for one type of partner at a time (Customer or Vendor). Please check your filters.';
        UpdateRequiredErr: Label 'At least one Subscription Line was changed after billing proposal was created. Please check the lines marked with "Update Required" field and update the billing proposal before the billing documents can be created.';
        ServicePeriodDescriptionTxt: Label 'Subscription period: %1 to %2';
        NoDocumentsCreatedMsg: Label 'No documents have been created.';
        DocumentsCreatedMsg: Label 'Creation of documents completed.\\%1 document(s) for %2 contract(s) were created.';
        DocumentsCreatedAndPostedMsg: Label 'Creation of documents completed.\\%1 document(s) for %2 contract(s) were created and posted.';
        ContractNoTxt: Label 'Contract No. %1';
        CustomerContractLbl: Label 'Customer Subscription Contract';
        VendorContractLbl: Label 'Vendor Subscription Contract';
        CustomerContractsLbl: Label 'Customer Subscription Contracts';
        VendorContractsLbl: Label 'Vendor Subscription Contracts';
        MultipleLbl: Label 'Multiple';
        SalesBatchPostingMsg: Label 'Batch posting of contract sales invoices.';
        TotalInvoiceAmountIsLessThanZeroErr: Label 'The total amount of an invoice cannot be less than 0. Please check the contract %1.';
        SkipRequestPageSelection: Boolean;
        CreateContractInvoice: Boolean;
        ServiceContractSetupFetched: Boolean;
        CreateOnlyPurchaseInvoiceLines: Boolean;
}
