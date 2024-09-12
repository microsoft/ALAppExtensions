namespace Microsoft.SubscriptionBilling;

using System.IO;
using System.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Purchases.Document;

codeunit 8060 "Create Billing Documents"
{
    Access = Internal;
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
        ShowProcessingFinishedMessage := not PostDocuments;
        if PostDocuments then
            PostCreatedDocuments();
        if ShowProcessingFinishedMessage then
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
        CustomerContract: Record "Customer Contract";
        PreviousContractNo: Code[20];
        DiscountLineExists: Boolean;
    begin
        PreviousContractNo := '';
        TempBillingLine.Reset();
        TempBillingLine.SetCurrentKey("Contract No.", "Contract Line No.");
        SetDiscountLineExists(TempBillingLine, DiscountLineExists);
        if TempBillingLine.FindSet(true) then
            repeat
                if TempBillingLine."Contract No." <> PreviousContractNo then begin
                    TestPreviousDocumentTotalInvoiceAmount(true, DiscountLineExists, PreviousContractNo);
                    CustomerContract.Get(TempBillingLine."Contract No.");
                    CreateSalesHeaderFromContract(CustomerContract);
                    InsertContractDescriptionSalesLines(TempBillingLine);
                    PreviousContractNo := TempBillingLine."Contract No.";
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
        VendorContract: Record "Vendor Contract";
        PreviousContractNo: Code[20];
        DiscountLineExists: Boolean;
    begin
        PreviousContractNo := '';
        TempBillingLine.Reset();
        TempBillingLine.SetCurrentKey("Contract No.", "Service Object No.", "Service Commitment Entry No.");
        SetDiscountLineExists(TempBillingLine, DiscountLineExists);
        if TempBillingLine.FindSet() then
            repeat
                if TempBillingLine."Contract No." <> PreviousContractNo then begin
                    TestPreviousDocumentTotalInvoiceAmount(false, DiscountLineExists, PreviousContractNo);
                    VendorContract.Get(TempBillingLine."Contract No.");
                    CreatePurchaseHeaderFromContract(VendorContract);
                    InsertContractDescriptionPurchaseLines(TempBillingLine);
                    PreviousContractNo := TempBillingLine."Contract No.";
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
        TempBillingLine.SetCurrentKey("Partner No.", "Currency Code", "Detail Overview", "Contract No.", "Service Object No.", "Service Commitment Entry No.");
        SetDiscountLineExists(TempBillingLine, DiscountLineExists);
        if TempBillingLine.FindSet() then
            repeat
                if IsNewSalesHeaderNeeded(PreviousCustomerNo, LastDetailOverview, PreviousCurrencyCode, PreviousContractNo) then begin
                    TestPreviousDocumentTotalInvoiceAmount(true, DiscountLineExists, PreviousContractNo);
                    CreateSalesHeaderForCustomerNo(TempBillingLine."Partner No.");
                    SalesHeader."Contract Detail Overview" := TempBillingLine."Detail Overview";
                    SalesHeader.Modify(false);
                    PreviousCustomerNo := TempBillingLine."Partner No.";
                    LastDetailOverview := TempBillingLine."Detail Overview";
                    PreviousCurrencyCode := TempBillingLine."Currency Code";
                    Window.Update(1, PreviousCustomerNo);
                    FirstContractDescriptionLineInserted := false;
                end;
                if TempBillingLine."Contract No." <> PreviousContractNo then begin
                    InsertContractDescriptionSalesLines(TempBillingLine);
                    if PreviousContractNo <> '' then begin
                        TranslationHelper.SetGlobalLanguageByCode(SalesHeader."Language Code");
                        SalesHeader."Posting Description" := MultipleLbl + ' ' + CustomerContractsLbl;
                        TranslationHelper.RestoreGlobalLanguage();
                        SalesHeader.Modify(false);
                    end;
                    PreviousContractNo := TempBillingLine."Contract No.";
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
        TempBillingLine.SetCurrentKey("Partner No.", "Currency Code", "Contract No.", "Service Object No.", "Service Commitment Entry No.");
        SetDiscountLineExists(TempBillingLine, DiscountLineExists);
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
                if TempBillingLine."Contract No." <> PreviousContractNo then begin
                    InsertContractDescriptionPurchaseLines(TempBillingLine);
                    if PreviousContractNo <> '' then begin
                        TranslationHelper.SetGlobalLanguageByCode(PurchaseHeader."Language Code");
                        PurchaseHeader."Posting Description" := MultipleLbl + ' ' + VendorContractsLbl;
                        TranslationHelper.RestoreGlobalLanguage();
                        PurchaseHeader.Modify(false);
                    end;
                    PreviousContractNo := TempBillingLine."Contract No.";
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
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        BillingLine: Record "Billing Line";
        CustomerContractLine: Record "Customer Contract Line";
        UsageDataBilling: Record "Usage Data Billing";
        UsageBasedDocTypeConv: Codeunit "Usage Based Doc. Type Conv.";
        BillingLineNo: Integer;
    begin
        ServiceObject.Get(TempBillingLine."Service Object No.");
        ServiceCommitment.Get(TempBillingLine."Service Commitment Entry No.");
        CustomerContractLine.Get(TempBillingLine."Contract No.", TempBillingLine."Contract Line No.");
        OnAfterCustomerContractLineGetInInsertSalesLineFromTempBillingLine(CustomerContractLine);

        SalesLine.InitFromSalesHeader(SalesHeader);
        SalesLine.Type := SalesLine.Type::Item;
        if ServiceCommitment."Invoicing Item No." <> '' then begin
            SessionStore.SetBooleanKey('CreateBillingDocumentsAllowInsertOfInvoicingItemNo', true);
            SalesLine.Validate("No.", ServiceCommitment."Invoicing Item No.");
            SessionStore.RemoveBooleanKey('CreateBillingDocumentsAllowInsertOfInvoicingItemNo');
        end
        else
            SalesLine.Validate("No.", ServiceObject."Item No.");
        SalesLine.Validate("Unit of Measure Code", ServiceObject."Unit of Measure");
        SalesLine.Validate(Quantity, TempBillingLine.GetSign() * ServiceObject."Quantity Decimal");
        SalesLine.Validate("Unit Price", GetSalesDocumentSign(SalesLine."Document Type") * TempBillingLine."Unit Price");
        SalesLine.Validate("Line Discount %", TempBillingLine."Discount %");
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

        BillingLine.SetRange("Service Object No.", TempBillingLine."Service Object No.");
        BillingLine.SetRange("Service Commitment Entry No.", TempBillingLine."Service Commitment Entry No.");
        if CreateContractInvoice then
            BillingLine.SetRange("Billing Template Code", '');
        BillingLine.ModifyAll("Document Type", BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), false);
        BillingLine.ModifyAll("Document No.", SalesLine."Document No.", false);
        BillingLine.ModifyAll("Document Line No.", SalesLine."Line No.", false);

        if ServiceCommitment."Usage Based Billing" then begin
            UsageDataBilling.SetRange(Partner, Enum::"Service Partner"::Customer);
            UsageDataBilling.SetRange("Contract No.", CustomerContractLine."Contract No.");
            UsageDataBilling.SetRange("Contract Line No.", CustomerContractLine."Line No.");
            UsageDataBilling.SetRange("Document Type", Enum::"Usage Based Billing Doc. Type"::None);
            UsageDataBilling.SetRange("Document No.", '');
            if UsageDataBilling.FindSet() then
                repeat
                    BillingLineNo := GetBillingLineNo(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"),
                                                        "Service Partner"::Customer, SalesLine."Document No.", CustomerContractLine."Contract No.", CustomerContractLine."Line No.");
                    UsageDataBilling.SaveDocumentValues(UsageBasedDocTypeConv.ConvertSalesDocTypeToUsageBasedBillingDocType(SalesLine."Document Type"), SalesLine."Document No.",
                                                                               SalesLine."Line No.", BillingLineNo);
                until UsageDataBilling.Next() = 0;
        end;

        OnAfterInsertSalesLineFromBillingLine(CustomerContractLine, SalesLine);
    end;

    local procedure InsertPurchaseLineFromTempBillingLine()
    var
        PurchaseLine: Record "Purchase Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        BillingLine: Record "Billing Line";
        UsageDataBilling: Record "Usage Data Billing";
        UsageBasedDocTypeConv: Codeunit "Usage Based Doc. Type Conv.";
        BillingLineNo: Integer;
    begin
        ServiceObject.Get(TempBillingLine."Service Object No.");
        ServiceCommitment.Get(TempBillingLine."Service Commitment Entry No.");

        InitPurchaseLine(PurchaseLine);
        PurchaseLine.Type := PurchaseLine.Type::Item;
        if ServiceCommitment."Invoicing Item No." <> '' then begin
            SessionStore.SetBooleanKey('CreateBillingDocumentsAllowInsertOfInvoicingItemNo', true);
            PurchaseLine.Validate("No.", ServiceCommitment."Invoicing Item No.");
            SessionStore.RemoveBooleanKey('CreateBillingDocumentsAllowInsertOfInvoicingItemNo');
        end else
            PurchaseLine.Validate("No.", ServiceObject."Item No.");
        PurchaseLine.Validate("Unit of Measure Code", ServiceObject."Unit of Measure");
        PurchaseLine.Validate(Quantity, TempBillingLine.GetSign() * ServiceObject."Quantity Decimal");
        PurchaseLine.Validate("Direct Unit Cost", GetPurchaseDocumentSign(PurchaseLine."Document Type") * TempBillingLine."Unit Price");
        PurchaseLine.Validate("Line Discount %", TempBillingLine."Discount %");
        PurchaseLine."Recurring Billing from" := TempBillingLine."Billing from";
        PurchaseLine."Recurring Billing to" := TempBillingLine."Billing to";
        PurchaseLine."Discount" := TempBillingLine.Discount;
        PurchaseLine.GetCombinedDimensionSetID(PurchaseLine."Dimension Set ID", ServiceCommitment."Dimension Set ID");
        PurchaseLine.Description := ServiceCommitment.Description;
        PurchaseLine."Description 2" := CopyStr(ServiceObject.Description, 1, MaxStrLen(PurchaseLine."Description 2"));
        OnBeforeInsertPurchaseLineFromContractLine(PurchaseLine, TempBillingLine);
        PurchaseLine.Insert(false);
        InsertDescriptionPurchaseLine(
             StrSubstNo(GetBillingPeriodDescriptionTxt(PurchaseHeader."Language Code"), PurchaseLine."Recurring Billing from", PurchaseLine."Recurring Billing to"), PurchaseLine."Line No.");

        if CreateContractInvoice then
            BillingLine.SetRange("Billing Template Code", '');
        BillingLine.SetRange("Service Object No.", TempBillingLine."Service Object No.");
        BillingLine.SetRange("Service Commitment Entry No.", TempBillingLine."Service Commitment Entry No.");

        BillingLine.ModifyAll("Document Type", BillingLine.GetBillingDocumentTypeFromSalesDocumentType(PurchaseLine."Document Type"), false);
        BillingLine.ModifyAll("Document No.", PurchaseLine."Document No.", false);
        BillingLine.ModifyAll("Document Line No.", PurchaseLine."Line No.", false);

        UsageDataBilling.SetRange(Partner, Enum::"Service Partner"::Vendor);
        UsageDataBilling.SetRange("Contract No.", ServiceCommitment."Contract No.");
        UsageDataBilling.SetRange("Contract Line No.", ServiceCommitment."Contract Line No.");
        UsageDataBilling.SetRange("Document Type", Enum::"Usage Based Billing Doc. Type"::None);
        UsageDataBilling.SetRange("Document No.", '');
        if UsageDataBilling.FindSet() then
            repeat
                BillingLineNo := GetBillingLineNo(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchaseLine."Document Type"),
                                                    "Service Partner"::Vendor, PurchaseLine."Document No.", ServiceCommitment."Contract No.", ServiceCommitment."Contract Line No.");
                UsageDataBilling.SaveDocumentValues(UsageBasedDocTypeConv.ConvertPurchaseDocTypeToUsageBasedBillingDocType(PurchaseLine."Document Type"), PurchaseLine."Document No.",
                                           PurchaseLine."Line No.", BillingLineNo);
            until UsageDataBilling.Next() = 0;

        OnAfterInsertPurchaseLineFromBillingLine(ServiceCommitment, PurchaseLine);
    end;

    local procedure GetBillingLineNo(BillingDocumentType: Enum "Rec. Billing Document Type"; ServiceParner: Enum "Service Partner"; DocumentNo: Code[20]; ContractNo: Code[20]; ContractLineNo: Integer): Integer
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnContractLine(ServiceParner, ContractNo, ContractLineNo);
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
            SalesLine.InsertDescriptionSalesLine(SalesHeader, StrSubstNo(ContractNoTxt, BillingLine."Contract No."), 0);
            InsertAddressInfoForCollectiveInvoice(BillingLine);
            ContractTypeDescription := GetContractTypeDescription(BillingLine."Contract No.", BillingLine.Partner, SalesHeader."Language Code");
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
        CustomerContract: Record "Customer Contract";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertAddressInfoForCollectiveInvoice(BillingLine, CustomerRecurringBillingGrouping, SalesHeader, IsHandled);
        if not IsHandled then
            if (BillingLine.Partner = BillingLine.Partner::Customer) and
               (BillingLine."Contract No." <> '') and
               (CustomerRecurringBillingGrouping <> CustomerRecurringBillingGrouping::Contract)
            then
                if CustomerContract.Get(BillingLine."Contract No.") then begin
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
        InsertDescriptionPurchaseLine(StrSubstNo(ContractNoTxt, BillingLine."Contract No."), 0);
        ContractTypeDescription := GetContractTypeDescription(BillingLine."Contract No.", BillingLine.Partner, PurchaseHeader."Language Code");
        if ContractTypeDescription <> '' then
            InsertDescriptionPurchaseLine(ContractTypeDescription, 0);
        if VendorRecurringBillingGrouping <> VendorRecurringBillingGrouping::Contract then
            FirstContractDescriptionLineInserted := true;
        TranslationHelper.RestoreGlobalLanguage();
    end;

    internal procedure GetContractTypeDescription(ContractNo: Code[20]; Partner: Enum "Service Partner"; LanguageCode: Code[10]): Text[50]
    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        ContractType: Record "Contract Type";
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

    local procedure CreateSalesHeaderFromContract(CustomerContract: Record "Customer Contract")
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

    local procedure CreatePurchaseHeaderFromContract(VendorContract: Record "Vendor Contract")
    var
        OldPurchaseHeader: Record "Purchase Header";
    begin
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
        SalesHeader."Posting Description" := CustomerContractLbl + ' ' + TempBillingLine."Contract No.";
        TranslationHelper.RestoreGlobalLanguage();
        SessionStore.SetBooleanKey('SkipContractSalesHeaderModifyCheck', true);
        OnAfterCreateSalesHeaderForCustomerNo(SalesHeader, TempBillingLine."Contract No.");
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
        PurchaseHeader."Posting Description" := VendorContractLbl + ' ' + TempBillingLine."Contract No.";
        TranslationHelper.RestoreGlobalLanguage();
        SessionStore.SetBooleanKey('SkipContractPurchaseHeaderModifyCheck', true);
        PurchaseHeader.Modify(false);
        SessionStore.RemoveBooleanKey('SkipContractPurchaseHeaderModifyCheck');
    end;

    local procedure CreateTempBillingLines(var BillingLine: Record "Billing Line")
    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        CurrencyCode: Code[20];
        PartnerNo: Code[20];
        LineNo: Integer;
    begin
        if BillingLine.FindSet() then
            repeat
                case BillingLine.Partner of
                    BillingLine.Partner::Customer:
                        begin
                            CustomerContract.Get(BillingLine."Contract No.");
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
                            VendorContract.Get(BillingLine."Contract No.");
                            case VendorRecurringBillingGrouping of
                                VendorRecurringBillingGrouping::"Pay-to Vendor No.":
                                    PartnerNo := VendorContract."Pay-to Vendor No.";
                                VendorRecurringBillingGrouping::"Buy-from Vendor No.":
                                    PartnerNo := VendorContract."Buy-from Vendor No.";
                            end;
                            CurrencyCode := VendorContract."Currency Code";
                        end;
                end;

                TempBillingLine.SetRange("Contract No.", BillingLine."Contract No.");
                TempBillingLine.SetRange("Service Object No.", BillingLine."Service Object No.");
                TempBillingLine.SetRange("Service Commitment Entry No.", BillingLine."Service Commitment Entry No.");
                if not TempBillingLine.FindFirst() then begin
                    TempBillingLine.Init();
                    LineNo += 1;
                    TempBillingLine."Entry No." := LineNo;
                    TempBillingLine."Partner No." := PartnerNo;
                    TempBillingLine.Partner := BillingLine.Partner;
                    TempBillingLine."Contract No." := BillingLine."Contract No.";
                    TempBillingLine."Detail Overview" := CustomerContract."Detail Overview";
                    TempBillingLine."Currency Code" := CurrencyCode;
                    TempBillingLine."Contract Line No." := BillingLine."Contract Line No.";
                    TempBillingLine."Service Object No." := BillingLine."Service Object No.";
                    TempBillingLine."Service Commitment Entry No." := BillingLine."Service Commitment Entry No.";
                    TempBillingLine."Discount %" := BillingLine."Discount %";
                    TempBillingLine."Service Commitment Description" := BillingLine."Service Commitment Description";
                    OnBeforeInsertTempBillingLine(TempBillingLine, BillingLine);
                    TempBillingLine.Insert(false);
                end;
                TempBillingLine."Unit Price" += BillingLine."Unit Price";
                TempBillingLine."Service Amount" += BillingLine."Service Amount";
                TempBillingLine.Discount := BillingLine.Discount;
                TempBillingLine."Document Type" := InitRecurringBillingDocumentType(TempBillingLine."Service Amount", BillingLine.Discount);
                if (TempBillingLine."Billing from" > BillingLine."Billing from") or (TempBillingLine."Billing from" = 0D) then
                    TempBillingLine."Billing from" := BillingLine."Billing from";
                if TempBillingLine."Billing to" < BillingLine."Billing to" then
                    TempBillingLine."Billing to" := BillingLine."Billing to";
                OnCreateTempBillingLinesBeforeSaveTempBillingLine(TempBillingLine, BillingLine);
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

    internal procedure ProcessingFinishedMessage()
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
            ShowProcessingFinishedMessage := true;
        end else begin
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

    internal procedure SetSkipRequestPageSelection(NewSkipRequestPageSelection: Boolean)
    begin
        SkipRequestPageSelection := NewSkipRequestPageSelection;
    end;

    internal procedure SetDocumentDataFromRequestPage(DocumentDateValue: Date; PostingDateValue: Date; PostDocumentValue: Boolean; CreateContractInvoiceValue: Boolean)
    begin
        DocumentDate := DocumentDateValue;
        PostingDate := PostingDateValue;
        PostDocuments := PostDocumentValue;
        CreateContractInvoice := CreateContractInvoiceValue;
    end;

    internal procedure SetBillingGroupingPerContract(ServicePartner: Enum "Service Partner")
    begin
        if ServicePartner = "Service Partner"::Vendor then
            VendorRecurringBillingGrouping := "Vendor Rec. Billing Grouping"::Contract
        else
            CustomerRecurringBillingGrouping := "Customer Rec. Billing Grouping"::Contract;
    end;

    procedure GetBillingPeriodDescriptionTxt() DescriptionText: Text
    begin
        DescriptionText := ServicePeriodDescriptionTxt;
    end;

    procedure GetBillingPeriodDescriptionTxt(LanguageCode: Code[10]) DescriptionText: Text
    begin
        TranslationHelper.SetGlobalLanguageByCode(LanguageCode);
        DescriptionText := GetBillingPeriodDescriptionTxt();
        TranslationHelper.RestoreGlobalLanguage();
    end;

    procedure CreateAdditionalInvoiceLine(ServiceContractSetupFieldNo: Integer; SalesHeader2: Record "Sales Header"; ParentSalesLine: Record "Sales Line"; ServiceObject: Record "Service Object"; ServiceCommitment: Record "Service Commitment")
    var
        SalesLine: Record "Sales Line";
        DescriptionText: Text;
    begin
        DescriptionText := GetAdditionalLineText(ServiceContractSetupFieldNo, ParentSalesLine, ServiceObject, ServiceCommitment);
        if DescriptionText = '' then
            exit;
        SalesLine.InsertDescriptionSalesLine(SalesHeader2, DescriptionText, ParentSalesLine."Line No.");
    end;

    local procedure GetAdditionalLineText(ServiceContractSetupFieldNo: Integer; ParentSalesLine: Record "Sales Line"; ServiceObject: Record "Service Object"; ServiceCommitment: Record "Service Commitment") DescriptionText: Text
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
                exit('');
            ContractInvoiceTextType::"Service Object":
                exit(ServiceObject.Description);
            ContractInvoiceTextType::"Service Commitment":
                exit(ServiceCommitment.Description);
            ContractInvoiceTextType::"Customer Reference":
                if ServiceObject."Customer Reference" <> '' then
                    exit(StrSubstNo(ReferenceNoLbl, ServiceObject."Customer Reference"));
            ContractInvoiceTextType::"Serial No.":
                if ServiceObject."Serial No." <> '' then
                    exit(ServiceObject.GetSerialNoDescription());
            ContractInvoiceTextType::"Billing Period":
                exit(
                    StrSubstNo(
                        GetBillingPeriodDescriptionTxt(),
                        ParentSalesLine."Recurring Billing from",
                        ParentSalesLine."Recurring Billing to"));
            ContractInvoiceTextType::"Primary attribute":
                exit(ServiceObject.GetPrimaryAttributeValue());
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

    internal procedure HideProcessingFinishedMessage()
    begin
        ShowProcessingFinishedMessage := false;
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

    [InternalEvent(false, false)]
    local procedure OnAfterCreateSalesHeaderFromContract(CustomerContract: Record "Customer Contract"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateSalesHeaderForCustomerNo(var SalesHeader: Record "Sales Header"; ContractNo: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInsertSalesLineFromContractLine(var SalesLine: Record "Sales Line"; var TempBillingLine: Record "Billing Line" temporary)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInsertContractDescriptionSalesLines(SalesHeader: Record "Sales Header"; BillingLine: Record "Billing Line"; var FirstContractDescriptionLineInserted: Boolean; CustomerRecurringBillingGrouping: Enum "Customer Rec. Billing Grouping"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInsertContractDescriptionSalesLines(SalesHeader: Record "Sales Header"; BillingLine: Record "Billing Line"; var FirstContractDescriptionLineInserted: Boolean; CustomerRecurringBillingGrouping: Enum "Customer Rec. Billing Grouping")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInsertSalesLineFromBillingLine(CustomerContractLine: Record "Customer Contract Line"; SalesLine: Record "Sales Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInsertPurchaseLineFromBillingLine(ServiceCommitment: Record "Service Commitment"; PurchaseLine: Record "Purchase Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInsertPurchaseLineFromContractLine(var PurchLine: Record "Purchase Line"; var TempBillingLine: Record "Billing Line" temporary)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateAdditionalInvoiceLines(SalesHeader: Record "Sales Header"; ParentSalesLine: Record "Sales Line"; ServiceObject: Record "Service Object"; ServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnGetAdditionalLineTextElseCase(ContractInvoiceTextType: Enum "Contract Invoice Text Type"; ServiceObject: Record "Service Object"; ServiceCommitment: Record "Service Commitment"; var DescriptionText: Text; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInsertAddressInfoForCollectiveInvoice(BillingLine: Record "Billing Line"; CustomerRecurringBillingGrouping: Enum "Customer Rec. Billing Grouping"; SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInsertAddressInfoForCollectiveInvoice(BillingLine: Record "Billing Line"; CustomerRecurringBillingGrouping: Enum "Customer Rec. Billing Grouping"; SalesHeader: Record "Sales Header")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateTempBillingLinesBeforeSaveTempBillingLine(var TempBillingLine: Record "Billing Line" temporary; var BillingLine: Record "Billing Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInsertTempBillingLine(var TempBillingLine: Record "Billing Line" temporary; var BillingLine: Record "Billing Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeProcessBillingLines(var BillingLine: Record "Billing Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterProcessBillingLines(var BillingLine: Record "Billing Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateBillingDocuments(var BillingLine: Record "Billing Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterIsNewSalesHeaderNeeded(var CreateNewSalesHeader: Boolean; TempBillingLine: Record "Billing Line" temporary; PreviousCustomerNo: Code[20]; LastDetailOverview: Enum "Contract Detail Overview"; PreviousCurrencyCode: Code[20]; PreviousContractNo: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeTestPreviousDocumentTotalInvoiceAmount(Sales: Boolean; DiscountLineExists: Boolean; PreviousContractNo: Code[20]; SalesHeader: Record "Sales Header"; PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCustomerContractLineGetInInsertSalesLineFromTempBillingLine(CustomerContractLine: Record "Customer Contract Line")
    begin
    end;

    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TempBillingLine: Record "Billing Line" temporary;
        TempSalesHeader: Record "Sales Header" temporary;
        ServiceContractSetup: Record "Service Contract Setup";
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
        ShowProcessingFinishedMessage: Boolean;
        Window: Dialog;
        ProgressTxt: Label 'Creating documents...\Partner No. #1#################################\Contract No. #2#################################';
        OnlyOneServicePartnerErr: Label 'You can create documents only for one type of partner at a time (Customer or Vendor). Please check your filters.';
        UpdateRequiredErr: Label 'At least one service was changed after billing proposal was created. Please check the lines marked with "Update Required" field and update the billing proposal before the billing documents can be created.';
        ServicePeriodDescriptionTxt: Label 'Service period: %1 to %2';
        NoDocumentsCreatedMsg: Label 'No documents have been created.';
        DocumentsCreatedMsg: Label 'Creation of documents completed.\\%1 document(s) for %2 contract(s) were created.';
        DocumentsCreatedAndPostedMsg: Label 'Creation of documents completed.\\%1 document(s) for %2 contract(s) were created and posted.';
        ContractNoTxt: Label 'Contract No. %1';
        CustomerContractLbl: Label 'Customer Contract';
        VendorContractLbl: Label 'Vendor Contract';
        CustomerContractsLbl: Label 'Customer Contracts';
        VendorContractsLbl: Label 'Vendor Contracts';
        MultipleLbl: Label 'Multiple';
        SalesBatchPostingMsg: Label 'Batch posting of contract sales invoices.';
        TotalInvoiceAmountIsLessThanZeroErr: Label 'The total amount of an invoice cannot be less than 0. Please check the contract %1.';
        SkipRequestPageSelection: Boolean;
        CreateContractInvoice: Boolean;
        ServiceContractSetupFetched: Boolean;
}
