// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Services;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sales.Customer;
using Microsoft.Service.Contract;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Posting;
using Microsoft.Service.Pricing;
using Microsoft.Service.Setup;

codeunit 18440 "GST Service Validations"
{
    var
        ShiptoGSTARNErr: Label 'Either GST Registration No. or ARN No. should have a value in Ship To Code.';
        RefErr: Label 'Document is attached with Reference Invoice No. Please delete attached Reference Invoice No.';
        GSTGroupReverseChargeErr: Label 'GST Group Code %1 with Reverse Charge cannot be selected for Service transactions.', Comment = 'GST Group Code %1.';
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Service Header Document Type';
        GSTPlaceOfSupplyErr: Label 'You must select Ship-to Code or Ship-to Customer in transaction header.';

    procedure ReferenceInvoiceNoValidation(DocumentType: Enum "Service Document Type"; DocNo: Code[20]; CustNum: Code[20])
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocType: Enum "Document Type Enum";
    begin
        DocType := ServiceHeaderDocument2DocumentTypeEnum(DocumentType);
        ReferenceInvoiceNo.SetRange("Document Type", DocType);
        ReferenceInvoiceNo.SetRange("Document No.", DocNo);
        ReferenceInvoiceNo.SetRange("Source No.", CustNum);
        ReferenceInvoiceNo.SetRange(Verified, true);
        if not ReferenceInvoiceNo.IsEmpty() then
            Error(RefErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure CallTaxEngine(var Rec: Record "Service Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnServiceLine(Rec, Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ServContractManagement, 'OnAfterCreateServHeader', '', false, false)]
    local procedure CopyServiceContractFields(ServiceContractHeader: Record "Service Contract Header"; var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader."GST Customer Type" := ServiceContractHeader."GST Customer Type";
        ServiceHeader.State := ServiceContractHeader."GST Bill-to State Code";
        ServiceHeader."Invoice Type" := ServiceContractHeader."Invoice Type";
        if ServiceHeader."Currency Code" = '' then
            ServiceHeader."Currency Factor" := 0;

        ServiceHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ServContractManagement, 'OnAfterCreateOrGetCreditHeader', '', false, false)]
    local procedure UpdateStateCreditMemo(ServiceContractHeader: Record "Service Contract Header"; var ServiceHeader: Record "Service Header")
    begin
        if ServiceHeader.State <> '' then
            exit;

        ServiceHeader.State := ServiceContractHeader."GST Bill-to State Code";
        ServiceHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ServContractManagement, 'OnCreateContractLineCreditMemoOnAfterCreateAllCreditLines', '', false, false)]
    local procedure OnCreateContractLineCreditMemo(ServContractHeader: Record "Service Contract Header"; CreditMemoNo: Code[20])
    var
        ServiceHeader: Record "Service Header";
    begin
        if ServiceHeader.Get(ServiceHeader."Document Type"::"Credit Memo", CreditMemoNo) then;

        ServiceHeader."GST Customer Type" := ServContractHeader."GST Customer Type";
        ServiceHeader.State := ServContractHeader."GST Bill-to State Code";
        ServiceHeader."Invoice Type" := ServContractHeader."Invoice Type";
        if ServiceHeader."Currency Code" = '' then
            ServiceHeader."Currency Factor" := 0;

        ServiceHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ServContractManagement, 'OnAfterCreateContractLineCreditMemo', '', false, false)]
    local procedure CallTaxEngineCreditMemo(ServiceCreditMemoNo: Code[20])
    var
        ServiceLine: Record "Service Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        ServiceLine.Reset();
        ServiceLine.SetRange("Document Type", ServiceLine."Document Type"::"Credit Memo");
        ServiceLine.SetRange("Document No.", ServiceCreditMemoNo);
        if ServiceLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnServiceLine(ServiceLine, ServiceLine);
            until ServiceLine.Next() = 0;
    end;

    //Service Contract Header
    [EventSubscriber(ObjectType::Table, Database::"Service Contract Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure UpdateGSTCustomerType(var Rec: Record "Service Contract Header")
    var
        Customer: Record Customer;
    begin
        if Customer.Get(Rec."Customer No.") then
            Rec."GST Customer Type" := Customer."GST Customer Type";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Contract Header", 'OnAfterValidateEvent', 'Bill-to Customer No.', false, false)]
    local procedure UpdateGSTBillToStateCode(var Rec: Record "Service Contract Header")
    var
        Customer: Record Customer;
    begin
        if Customer.Get(Rec."Bill-to Customer No.") then
            Rec."GST Bill-to State Code" := Customer."State Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostLedgerEntryOnBeforeGenJnlPostLine(var GenJournalLine: Record "Gen. Journal Line"; ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
    begin
        GenJournalLine."GST Customer Type" := ServiceHeader."GST Customer Type";
        GenJournalLine."Location State Code" := ServiceHeader."Location State Code";
        GenJournalLine."Location GST Reg. No." := ServiceHeader."Location GST Reg. No.";
        GenJournalLine."GST Bill-to/BuyFrom State Code" := ServiceHeader."GST Bill-to State Code";
        GenJournalLine."Customer GST Reg. No." := ServiceHeader."Customer GST Reg. No.";
        GenJournalLine."GST Place of Supply" := GenJournalLine."GST Place of Supply"::"Bill-to Address";
        GenJournalLine."Ship-to Code" := ServiceHeader."Ship-to Code";
        GenJournalLine."GST Ship-to State Code" := ServiceHeader."GST Ship-to State Code";
        GenJournalLine."Ship-to GST Reg. No." := ServiceHeader."Ship-to GST Reg. No.";
        GenJournalLine."Location Code" := ServiceHeader."Location Code";

        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetFilter("Qty. to Invoice", '<>%1', 0);
        if ServiceLine.FindFirst() then
            GenJournalLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type";
    end;

    //Attach Use case Event to Libarary
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAddUseCaseEventstoLibrary', '', false, false)]
    local procedure OnAddUseCaseEventstoLibrary()
    var
        UseCaseEventLibrary: Codeunit "Use Case Event Library";
    begin
        UseCaseEventLibrary.AddUseCaseEventToLibrary('OnAfterUpdateServiceLinePrice', Database::"Service Line", 'After Update Service Line Price');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterValidateEvent', 'Unit Price', false, false)]
    local procedure HandleServiceLineCases(var Rec: Record "Service Line")
    var
        ServiceLine: Record "Service Line";
        ServiceHeader: Record "Service Header";
        UseCaseExecution: Codeunit "Use Case Execution";
    begin
        if not ServiceHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if ServiceLine.Get(Rec."Document Type", Rec."Document No.", Rec."Line No.") then;

        UseCaseExecution.HandleEvent('OnAfterUpdateServiceLinePrice', Rec, ServiceLine."Currency Code", ServiceHeader."Currency Factor");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Transaction Value", 'OnBeforeTableFilterApplied', '', false, false)]
    local procedure OnServiceLineFilter(DocumentNoFilter: Text; TableIDFilter: Integer; LineNoFilter: Integer; DocumentTypeFilter: Integer; var TaxRecordID: RecordID)
    begin
        if TableIDFilter = Database::"Service Line" then
            GetTaxRecIDForServiceDocument(DocumentTypeFilter, DocumentNoFilter, LineNoFilter, TaxRecordID);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Transaction Value", 'OnBeforeTableFilterApplied', '', false, false)]
    local procedure OnServiceInvoiceLineFilter(DocumentNoFilter: Text; TableIDFilter: Integer; LineNoFilter: Integer; var TaxRecordID: RecordID)
    begin
        if TableIDFilter = Database::"Service Invoice Line" then
            GetTaxRecIDForServiceInvoice(DocumentNoFilter, LineNoFilter, TaxRecordID);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Transaction Value", 'OnBeforeTableFilterApplied', '', false, false)]
    local procedure OnServiceCreditMemoLineFilter(DocumentNoFilter: Text; TableIDFilter: Integer; LineNoFilter: Integer; var TaxRecordID: RecordID)
    begin
        if TableIDFilter = Database::"Service Cr.Memo Line" then
            GetTaxRecIDForServiceCreditMemo(DocumentNoFilter, LineNoFilter, TaxRecordID);
    end;

    //Service Header Validations
    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateTradingInformation(var Rec: Record "Service Header")
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        Rec.Trading := CompanyInformation."Trading Co.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyCustomerFields', '', false, false)]
    local procedure UpdateCustomerInfo(Customer: Record Customer; var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader.State := Customer."State Code";
        ServiceHeader."GST Customer Type" := Customer."GST Customer Type";
        if Customer."GST Customer Type" = Customer."GST Customer Type"::Unregistered then
            ServiceHeader."Nature of Supply" := ServiceHeader."Nature of Supply"::B2C
        else
            ServiceHeader."Nature of Supply" := ServiceHeader."Nature of Supply"::B2B;

        if Customer."GST Customer Type" = Customer."GST Customer Type"::Exempted then
            ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::"Bill of Supply");

        if Customer."GST Customer Type" in [
            Customer."GST Customer Type"::Export,
            Customer."GST Customer Type"::"Deemed Export",
            Customer."GST Customer Type"::"SEZ Development",
            Customer."GST Customer Type"::"SEZ Unit"] then
            ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::Export);

        if Customer."GST Customer Type" in [Customer."GST Customer Type"::Registered, Customer."GST Customer Type"::Unregistered] then
            ServiceHeader.Validate("Invoice Type", ServiceHeader."Invoice Type"::Taxable);

        if ServiceHeader."Reference Invoice No." <> '' then
            ServiceHeader."Reference Invoice No." := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Bill-to Customer No.', false, false)]
    local procedure OnBeforeValidateBilltoCustomerNo(var Rec: Record "Service Header")
    begin
        Rec."GST Bill-to State Code" := '';
        Rec."Customer GST Reg. No." := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyBillToCustomerFields', '', false, false)]
    local procedure UpdateBilltoCustomerNoInfo(Customer: Record Customer; var ServiceHeader: Record "Service Header")
    begin
        if not (Customer."GST Customer Type" in [Customer."GST Customer Type"::Export]) then
            ServiceHeader."GST Bill-to State Code" := Customer."State Code";

        if not (Customer."GST Customer Type" in [Customer."GST Customer Type"::Export]) then
            ServiceHeader."Customer GST Reg. No." := Customer."GST Registration No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Ship-To Code', false, false)]
    local procedure OnBeforeValidateShipToCode(var Rec: Record "Service Header")
    begin
        Rec."GST Ship-to State Code" := '';
        Rec."Ship-to GST Reg. No." := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Ship-To Code', false, false)]
    local procedure OnAfterValidateShipToCode(var Rec: Record "Service Header")
    var
        ShiptoAddress: Record "Ship-to Address";
    begin
        if Rec."Ship-to GST Reg. No." = '' then
            exit;

        if not ShiptoAddress.Get(Rec."Customer No.", Rec."Ship-to Code") then
            exit;

        if not (Rec."GST Customer Type" in [Rec."GST Customer Type"::Export, Rec."GST Customer Type"::"SEZ Development", Rec."GST Customer Type"::"SEZ Unit"]) then
            Rec."GST Ship-to State Code" := ShiptoAddress.State;

        if not (Rec."GST Customer Type" in [Rec."GST Customer Type"::" ", Rec."GST Customer Type"::Unregistered, Rec."GST Customer Type"::Export]) then
            if ShiptoAddress."GST Registration No." = '' then
                if ShiptoAddress."ARN No." = '' then
                    Error(ShiptoGSTARNErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure OnAfterValidateEventLocationCode(var Rec: Record "Service Header")
    var
        Location: Record Location;
        CompanyInformation: Record "Company Information";
        GSTServicePostingNoSeries: Codeunit "GST Service Posting No. Series";
    begin
        Rec."Location State Code" := '';
        Rec."Location GST Reg. No." := '';

        if Rec."Location Code" <> '' then begin
            Location.Get(Rec."Location Code");
            Rec.Trading := Location."Trading Location";
            Rec."Location State Code" := Location."State Code";
            Rec."Location GST Reg. No." := Location."GST Registration No.";
            GSTServicePostingNoSeries.GetPostingNoSeriesforservice(Rec);
        end else begin
            CompanyInformation.Get();
            Rec.Trading := CompanyInformation."Trading Co.";
        end;

        ReferenceInvoiceNoValidation(Rec."Document Type", Rec."No.", Rec."Customer No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure OnAfterValidateCurrencyCode(var Rec: Record "Service Header")
    var
        GeneralLedgerSetup: Record "General ledger Setup";
        GSTBaseValidation: Codeunit "Gst Base Validation";
    begin
        GeneralLedgerSetup.Get();
        Rec."GST Inv. Rounding Precision" := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
        Rec."GST Inv. Rounding Type" := GSTBaseValidation.GenLedInvRoundingType2GSTInvRoundingTypeEnum(GeneralLedgerSetup."Inv. Rounding Type (LCY)");

    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Currency Factor', false, false)]
    local procedure OnAfterValidateEventCurrencyFactor(var Rec: Record "Service Header")
    begin
        CallTaxEngineOnServiceHeader(Rec);
    end;

    //Service Line Validation
    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignGLAccountValues', '', false, false)]
    local procedure CopyGLAccountValues(GLAccount: Record "G/L Account"; var ServiceLine: Record "Service Line")
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        GSTGroup: Record "GST Group";
    begin
        ServiceMgtSetup.Get();
        ServiceLine."HSN/SAC Code" := GLAccount."HSN/SAC Code";
        ServiceLine."GST Group Code" := GLAccount."GST Group Code";
        ServiceLine.Exempted := GLAccount.Exempted;
        ServiceLine."GST Place Of Supply" := ServiceMgtSetup."GST Dependency Type";
        if GStGroup.Get(ServiceLine."GST Group Code") then begin
            if GSTGroup."Reverse Charge" then
                Error(GSTGroupReverseChargeErr, ServiceLine."GST Group Code");

            ServiceLine."GST Group Type" := GSTGroup."GST Group Type";
            if GSTGroup."GST Place Of Supply" <> GSTGroup."GST Place Of Supply"::" " then
                ServiceLine."GST Place Of Supply" := GSTGroup."GST Place Of Supply";
        end;

        UpdateGSTJurisdictionType(ServiceLine);
        UpdateExempetedCustomerLine(ServiceLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignServCostValues', '', false, false)]
    local procedure CopyServCostValues(ServiceCost: Record "Service Cost"; var ServiceLine: Record "Service Line")
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        GSTGroup: Record "GST Group";
    begin
        ServiceMgtSetup.Get();
        ServiceLine."HSN/SAC Code" := ServiceCost."HSN/SAC Code";
        ServiceLine."GST Group Code" := ServiceCost."GST Group Code";
        ServiceLine.Exempted := ServiceCost.Exempted;

        ServiceLine."GST Place Of Supply" := ServiceMgtSetup."GST Dependency Type";
        if GSTGroup.Get(ServiceLine."GST Group Code") then begin
            if GSTGroup."Reverse Charge" then
                Error(GSTGroupReverseChargeErr, ServiceLine."GST Group Code");

            ServiceLine."GST Group Type" := GSTGroup."GST Group Type";
            if GSTGroup."GST Place Of Supply" <> GSTGroup."GST Place Of Supply"::" " then
                ServiceLine."GST Place Of Supply" := GSTGroup."GST Place Of Supply";
        end;

        UpdateGSTJurisdictionType(ServiceLine);
        UpdateExempetedCustomerLine(ServiceLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyItemValues(Item: Record Item; var ServiceLine: Record "Service Line")
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        GSTGroup: Record "GST Group";
    begin
        ServiceMgtSetup.Get();
        ServiceLine."HSN/SAC Code" := Item."HSN/SAC Code";
        ServiceLine."GST Group Code" := Item."GST Group Code";
        ServiceLine.Exempted := Item.Exempted;
        ServiceLine."GST Place Of Supply" := ServiceMgtSetup."GST Dependency Type";
        if GSTGroup.Get(ServiceLine."GST Group Code") then begin
            if GSTGroup."Reverse Charge" then
                Error(GSTGroupReverseChargeErr, ServiceLine."GST Group Code");

            ServiceLine."GST Group Type" := GSTGroup."GST Group Type";
            if GSTGroup."GST Place Of Supply" <> GSTGroup."GST Place Of Supply"::" " then
                ServiceLine."GST Place Of Supply" := GSTGroup."GST Place Of Supply";

            if ServiceLine."Document Type" <> ServiceLine."Document Type"::"Credit Memo" then
                if ServiceLine."GST Place Of Supply" <> ServiceLine."GST Place Of Supply"::" " then
                    GSTPlaceOfSupply(ServiceLine);
        end;

        UpdateGSTJurisdictionType(ServiceLine);
        UpdateExempetedCustomerLine(ServiceLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure CopyResourceValue(Resource: Record Resource; var ServiceLine: Record "Service Line")
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        GSTGroup: Record "GST Group";
    begin
        ServiceMgtSetup.Get();
        ServiceLine."HSN/SAC Code" := Resource."HSN/SAC Code";
        ServiceLine."GST Group Code" := Resource."GST Group Code";
        ServiceLine.Exempted := Resource.Exempted;
        ServiceLine."GST Place Of Supply" := ServiceMgtSetup."GST Dependency Type";
        if GSTGroup.Get(ServiceLine."GST Group Code") then begin
            if GSTGroup."Reverse Charge" then
                Error(GSTGroupReverseChargeErr, ServiceLine."GST Group Code");

            ServiceLine."GST Group Type" := GSTGroup."GST Group Type";
            if GSTGroup."GST Place Of Supply" <> GSTGroup."GST Place Of Supply"::" " then
                ServiceLine."GST Place Of Supply" := GSTGroup."GST Place Of Supply";
        end;

        UpdateGSTJurisdictionType(ServiceLine);
        UpdateExempetedCustomerLine(ServiceLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure OnAfterValidateEventLocationCodeServiceLine(var Rec: Record "Service Line")
    begin
        UpdateGSTJurisdictionType(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post (Yes/No)", 'OnBeforeConfirmServPost', '', false, false)]
    local procedure CheckInvoiceType(var ServiceHeader: Record "Service Header")
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
        ServiceLine: Record "Service Line";
    begin
        if not GSTSetup.Get() then
            exit;

        ServiceLine.Reset();
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        if ServiceLine.FindSet() then
            repeat
                TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransactionValue.SetRange("Tax Record ID", ServiceLine.RecordId);
                if not TaxTransactionValue.IsEmpty() then
                    ServiceHeader.TestField("Invoice Type");
            until ServiceLine.Next() = 0
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr', '', false, false)]
    local procedure UpdateShipToAddrfields(var ServiceHeader: Record "Service Header"; ShipToAddress: Record "Ship-to Address")
    begin
        if ShipToAddress.State <> '' then
            ShipToAddrfields(ServiceHeader, ShipToAddress);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyShipToCustomerAddressFieldsFromCustomer', '', false, false)]
    local procedure UpdateCustomerFields(var ServiceHeader: Record "Service Header"; SellToCustomer: Record Customer)
    begin
        CustomerFields(ServiceHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service line", 'OnAfterValidateEvent', 'GST Place Of Supply', false, false)]
    local procedure ValidateGSTPlaceOfSupply(var Rec: Record "Service Line")
    var
        GSTServiceShiptoAddress: Codeunit "GST Service Ship To Address";
    begin
        GSTPlaceOfSupply(Rec);
        GSTServiceShiptoAddress.ValidateGSTRegistration(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post (Yes/No)", 'OnAfterConfirmPost', '', false, false)]
    local procedure CheckAccountignPeriod(var ServiceHeader: Record "Service Header")
    var
        GSTServiceShiptoAddress: Codeunit "GST Service Ship To Address";
    begin
        GSTServiceShiptoAddress.ServicePostGSTPlaceOfSupply(ServiceHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Ship-to Code', false, false)]
    local procedure OnBeforeUpdateShipToCode(var Rec: Record "Service Header")
    var
        Customer: Record Customer;
    begin
        if Customer.Get(Rec."Customer No.") then
            Rec."GST Customer Type" := Customer."GST Customer Type";
    end;

    local procedure CustomerFields(var ServiceHeader: Record "Service Header")
    var
        ShipToAddr: Record "Ship-to Address";
    begin
        if ServiceHeader."Document Type" in ["Document Type Enum"::"Credit Memo", "Document Type Enum"::"Return Order"] then
            if ShipToAddr.Get(ServiceHeader."Customer No.", ServiceHeader."Ship-to Code") then begin
                if not (ServiceHeader."GST Customer Type" in [
                    "GST Customer Type"::Export,
                    "GST Customer Type"::"Deemed Export",
                    "GST Customer Type"::"SEZ Development",
                    "GST Customer Type"::"SEZ Unit"])
                then begin
                    ShipToAddr.TestField(State);
                    ServiceHeader."GST Ship-to State Code" := ShipToAddr.State;
                end;
                if not (ServiceHeader."GST Customer Type" in ["GST Customer Type"::Export]) then begin
                    ShipToAddr.TestField(State);
                    ServiceHeader."Ship-to GST Reg. No." := ShipToAddr."GST Registration No.";
                end;
            end;
    end;

    local procedure ShipToAddrfields(var ServiceHeader: Record "Service Header"; ShipToAddress: Record "Ship-to Address")
    begin
        if ServiceHeader."GST Customer Type" <> "GST Customer Type"::" " then
            if ServiceHeader."GST Customer Type" in [
                "GST Customer Type"::Exempted,
                "GST Customer Type"::"Deemed Export",
                "GST Customer Type"::"SEZ Development",
                "GST Customer Type"::"SEZ Unit",
                "GST Customer Type"::Registered]
            then begin
                ShipToAddress.TestField(State);
                if ShipToAddress."GST Registration No." = '' then
                    if ShipToAddress."ARN No." = '' then
                        Error(ShiptoGSTARNErr);
                ServiceHeader."GST Ship-to State Code" := ShipToAddress.State;
                ServiceHeader."Ship-to GST Reg. No." := ShipToAddress."GST Registration No.";

                if CheckGSTPlaceOfSupply(ServiceHeader) then
                    ServiceHeader.State := ShipToAddress.State;
            end;
    end;

    local Procedure CheckGSTPlaceOfSupply(ServiceHeader: Record "Service Header"): Boolean
    var
        ServiceLine: Record "Service Line";
    begin
        ServiceLine.Reset();
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetRange("GST Place of Supply", ServiceLine."GST Place of Supply"::"Ship-to Address");
        if not ServiceLine.IsEmpty() then
            exit(true);

        exit(false);
    end;

    local procedure UpdateExempetedCustomerLine(var ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
    begin
        if ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.") then
            if ServiceHeader."GST Customer Type" = ServiceHeader."GST Customer Type"::Exempted then
                ServiceLine.Exempted := true;
    end;

    local procedure GetTaxRecIDForServiceDocument(DocumentTypeFilter: Integer; DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordID)
    var
        ServiceLine: Record "Service Line";
    begin
        if ServiceLine.Get(DocumentTypeFilter, DocumentNoFilter, LineNoFilter) then
            TaxRecordID := ServiceLine.RecordId();
    end;

    local procedure GetTaxRecIDForServiceInvoice(DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordID)
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
    begin
        if ServiceInvoiceLine.Get(DocumentNoFilter, LineNoFilter) then
            TaxRecordID := ServiceInvoiceLine.RecordId();
    end;

    local procedure GetTaxRecIDForServiceCreditMemo(DocumentNoFilter: Text; LineNoFilter: Integer; var TaxRecordID: RecordID)
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
    begin
        if ServiceCrMemoLine.Get(DocumentNoFilter, LineNoFilter) then
            TaxRecordID := ServiceCrMemoLine.RecordId();
    end;

    local procedure ServiceHeaderDocument2DocumentTypeEnum(ServiceHeaderDocumentType: Enum "Service Document Type"): Enum "Document Type Enum"
    begin
        case ServiceHeaderDocumentType of
            ServiceHeaderDocumentType::"Credit Memo":
                exit("Document Type Enum"::"Credit Memo");
            ServiceHeaderDocumentType::Invoice:
                exit("Document Type Enum"::Invoice);
            ServiceHeaderDocumentType::Quote:
                exit("Document Type Enum"::Quote);
            ServiceHeaderDocumentType::Order:
                exit("Document Type Enum"::Order);
            else
                Error(ConversionErr, ServiceHeaderDocumentType);
        end;
    end;

    local procedure UpdateGSTJurisdictionType(var ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
    begin
        if not ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.") then
            exit;

        if ServiceHeader."Ship-to Code" <> '' then begin
            UpdateGSTJurisdictionShiptoAdddress(ServiceLine, ServiceHeader);
            exit;
        end;

        if ServiceHeader."GST Customer Type" = ServiceHeader."GST Customer Type"::Exempted then
            ServiceLine.Exempted := true;

        if ServiceHeader."POS Out Of India" then begin
            ServiceLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type"::Interstate;
            exit;
        end;

        if (ServiceHeader."Invoice Type" = ServiceHeader."Invoice Type"::Export) and (ServiceHeader."GST Customer Type" <> ServiceHeader."GST Customer Type"::"Deemed Export")
        then begin
            ServiceLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type"::Interstate;
            exit;
        end;

        if (ServiceHeader."Location State Code" <> '') and (ServiceHeader."State" = '') then begin
            ServiceLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type"::Interstate;
            exit;
        end;

        if ServiceHeader."Location State Code" <> ServiceHeader."State" then
            ServiceLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type"::Interstate
        else
            if ServiceHeader."Location State Code" = ServiceHeader."State" then
                ServiceLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type"::Intrastate;
    end;

    local procedure UpdateGSTJurisdictionShiptoAdddress(var ServiceLine: Record "Service Line"; ServiceHeader: Record "Service Header")
    var
        ShiptoAddress: Record "Ship-to Address";
    begin
        if not ServiceHeader.IsEmpty() then begin
            if ServiceHeader."GST Customer Type" in [ServiceHeader."GST Customer Type"::"SEZ Unit", ServiceHeader."GST Customer Type"::"SEZ Development"] then begin
                ServiceLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type"::Interstate;
                exit;
            end;

            case ServiceLine."GST Place Of Supply" of
                ServiceLine."GST Place Of Supply"::"Ship-to Address":
                    if ShiptoAddress.Get(ServiceHeader."Bill-to Customer No.", ServiceHeader."Ship-to Code") and
                    (ServiceHeader."Location State Code" <> ShiptoAddress."State") then
                        ServiceLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type"::Interstate
                    else
                        if ServiceHeader."Location State Code" = ShiptoAddress."State" then
                            ServiceLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type"::Intrastate;

                ServiceLine."GST Place Of Supply"::"Bill-to Address":
                    if ServiceHeader."Location State Code" <> ServiceHeader."State" then
                        ServiceLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type"::Interstate
                    else
                        if ServiceHeader."Location State Code" = ServiceHeader."State" then
                            ServiceLine."GST Jurisdiction Type" := ServiceLine."GST Jurisdiction Type"::Intrastate;

            end;
        end;
    end;

    procedure CallTaxEngineOnServiceHeader(ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        if ServiceLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnServiceLine(ServiceLine, ServiceLine);
            until ServiceLine.Next() = 0;
    end;

    procedure SetHSNSACEditable(ServiceLine: Record "Service Line"; var IsEditable: Boolean)
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        IsEditable := false;
        OnBeforeServiceLineHSNSACEditable(ServiceLine, IsEditable, IsHandled);
        if IsHandled then
            exit;

        if ServiceLine.Type = ServiceLine.Type::Item then begin
            if Item.Get(ServiceLine."No.") then
                if Item.Type in [Item.Type::Inventory, Item.Type::"Non-Inventory"] then
                    IsEditable := false
                else
                    IsEditable := true
        end else
            IsEditable := true;
    end;

    local procedure UpdateStateCode(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line")
    var
        GSTServiceShiptoAddress: Codeunit "GST Service Ship To Address";
    begin
        Case ServiceLine."GST Place of Supply" of
            ServiceLine."GST Place Of Supply"::"Bill-to Address":
                GSTServiceShiptoAddress.UpdateBillToAddressState(ServiceHeader);
            ServiceLine."GST Place Of Supply"::"Ship-to Address":
                GSTServiceShiptoAddress.UpdateShiptoAddressState(ServiceHeader);
            ServiceLine."GST Place Of Supply"::"Location Address":
                GSTServiceShiptoAddress.UpdateLocationAddressState(ServiceHeader);
        end;
        ServiceHeader.Modify();
    end;

    local procedure GSTPlaceOfSupply(var ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
        ShipToAddress: Record "Ship-to Address";
    begin
        ServiceLine.TestField("Quantity Shipped", 0);
        ServiceLine.TestField("Quantity Invoiced", 0);
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        ServiceHeader.TestField("POS Out Of India", false);
        if ServiceLine."GST Place Of Supply" = ServiceLine."GST Place Of Supply"::"Ship-to Address" then begin
            if (ServiceHeader."Ship-to Code" = '') then
                error(GSTPlaceOfSupplyErr);

            ServiceHeader.TestField("POS Out Of India", false);
            if ServiceHeader."Ship-to GST Reg. No." = '' then
                if ShipToAddress.Get(ServiceLine."Customer No.", ServiceLine."Ship-to Code") then
                    if not (ServiceHeader."GST Customer Type" in [ServiceHeader."GST Customer Type"::Unregistered, ServiceHeader."GST Customer Type"::Export]) then
                        if ShipToAddress."ARN No." = '' then
                            Error(ShipToGSTARNErr);
        end;
        if ServiceLine."Document Type" In [ServiceLine."Document Type"::Invoice,
            ServiceLine."Document Type"::"Credit Memo",
            ServiceLine."Document Type"::Order] then
            ReferenceInvoiceNoValidation(ServiceHeader);

        UpdateStateCode(ServiceHeader, ServiceLine);
        UpdateGSTJurisdictionType(ServiceLine);
    end;

    local procedure ReferenceInvoiceNoValidation(ServiceHeader: Record "Service Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocTye: Text;
        DocTypeEnum: Enum "Document Type Enum";
    begin
        DocTye := Format(ServiceHeader."Document Type");
        Evaluate(DocTypeEnum, DocTye);
        ReferenceInvoiceNo.SetRange("Document Type", DocTypeEnum);
        ReferenceInvoiceNo.SetRange("Document No.", ServiceHeader."No.");
        ReferenceInvoiceNo.SetRange("Source Type", ReferenceInvoiceNo."Source Type"::Customer);
        ReferenceInvoiceNo.SetRange("Source No.", ServiceHeader."Customer No.");
        ReferenceInvoiceNo.SetRange(Verified, true);
        if not ReferenceInvoiceNo.IsEmpty() then
            Error(RefErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnValidateShipToCodeOnAfterCalcShouldUpdateShipToAddressFields', '', false, false)]
    local procedure OnValidateShipToCodeOnAfterCalcShouldUpdateShipToAddressFields(var ServiceHeader: Record "Service Header"; var ShouldUpdateShipToAddressFields: Boolean)
    begin
        UpdateShiptoCodeCreditMemoDocument(ServiceHeader, ShouldUpdateShipToAddressFields);
    end;

    local procedure UpdateShiptoCodeCreditMemoDocument(var ServiceHeader: Record "Service Header"; ShouldUpdateShipToAddressFields: Boolean)
    var
        ShipToAddress: Record "Ship-to Address";
    begin
        if ShouldUpdateShipToAddressFields then
            exit;

        if ServiceHeader."GST Customer Type" = ServiceHeader."GST Customer Type"::" " then
            exit;

        if ServiceHeader."Document Type" = ServiceHeader."Document Type"::"Credit Memo" then
            if ShipToAddress.Get(ServiceHeader."Customer No.", ServiceHeader."Ship-to Code") then
                ShipToAddrfields(ServiceHeader, ShipToAddress);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeServiceLineHSNSACEditable(ServiceLine: Record "Service Line"; var IsEditable: Boolean; var IsHandled: Boolean)
    begin
    end;
}
