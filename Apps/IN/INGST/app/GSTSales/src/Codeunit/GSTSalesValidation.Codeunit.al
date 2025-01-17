// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Project.Planning;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
#if not CLEAN25
using Microsoft.Sales.Pricing;
#endif
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;

codeunit 18143 "GST Sales Validation"
{
    var
        GSTBaseValidation: Codeunit "GST Base Validation";
        RefErr: Label 'Document is attached with Reference Invoice No. Please delete attached Reference Invoice No.';
        ReferenceNoErr: Label 'Selected Document No does not exit for Reference Invoice No.';
        GSTPaymentDutyErr: Label 'You can only select GST without payment Of Duty in Sez,Export or Deemed Export Customer.';
        PostingErr: Label 'You must have to select GST without payment of duty - Yes for Ship to GST customer type - SEZ/Deemed';
        NonGSTInvTypeErr: Label 'You cannot enter Non-GST Invoice Type for any GST document.';
        POSGSTInvoiceErr: Label 'You can not select POS Out Of India field without GST Invoice.';
        AppliesToDocErr: Label 'You must remove Applies-to Doc No. before modifying Exempted value';
        NGLStructErr: Label 'You can select Non-GST Line field in transaction only for GST related structure.';
        GSTPlaceOfSuppErr: Label 'You can not select POS Out Of India field on header if GST Place Of Supply is Location Address.';
        ShippedInvoiceTypeErr: Label 'You can not change the Invoice Type for Shipped Document.';
        ShipToGSTARNErr: Label 'Either Ship-To Address GST Registration No. or ARN No. in Ship-To Address should have a value.';
        GSTGroupReverseChargeErr: Label 'GST Group Code %1 with Reverse Charge cannot be selected for Sales transactions.', Comment = '%1 = GSTGroupCode';
        PANCustErr: Label 'PAN No. must be entered in Customer.';
        PANErr: Label 'PAN No. must be entered.';
        GSTCustRegErr: Label 'GST Customer type format Blank & Registered is allowed to select when GST Registration Type is UID or GID.';
        GSTPANErr: Label 'Please update GST Registration No. to blank in the record %1 from Ship To Address.', Comment = '%1 = ShipToAddress';
        GSTARNErr: Label 'Either GST Registration No. or ARN No. should have a value.';
        InvoiceTypeErr: Label 'You can not select the Invoice Type %1 for GST Customer Type %2.', Comment = '%1 = Invoice Type ; %2 = GST Customer Type';
        SamePANErr: Label 'From postion 3 to 12 in GST Registration No. should be same as it is in PAN No. so delete and Then update it.';
        SellToBillToCustomerErr: Label 'Sell-to Customer No. and Bill-to Customer No. must be same for the Document Type %1 and Document No. %2.', Comment = '%1 = Document Type ; %2 = Document No.';
        ShipToCodeErr: Label 'GST Calculation on Ship-to Code/Address is allowed only if Sell-to and Bill-to Customer are same.';
        GSTPlaceOfSupplyErr: Label 'You must select Ship-to Code or Ship-to Customer in transaction header.';
        PostGSTtoCustErr: Label 'Only allow for GST Customer type Deemed Export, SEZ Development & SEZ Unit.';
        ExemptedLinesErr: Label 'All lines in the document are GST Exempted, the preferred Invoice type should be Bill of Supply.';
        NonExemptedLinesErr: Label 'All lines in the document are not GST Exempted, the preferred Invoice type should be according to GST Customer Type.';
        GSTDependencyTypeErr: Label 'GST dependency type must be Bill to Address or Ship to Address';
        GSTGroupCodeEqualErr: Label 'GST Group Code must be same in Sales Document Lines for the Document Type %1 and Document No. %2.', Comment = '%1 = Document Type ; %2 = Document No.';

    procedure GetPostInvoiceNoSeries(var SalesHeader: Record "Sales Header")
    var
        PostingNoseries: Record "Posting No. Series";
        VariantRec: Variant;
    begin
        VariantRec := SalesHeader;
        PostingNoseries.GetPostingNoSeriesCode(VariantRec);
        SalesHeader := VariantRec;
    end;

    //CopyDocument 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesLineFromSalesLineBuffer', '', false, false)]
    local procedure CallTaxEngineOnAfterCopySalesLineFromSalesLineBuffer(var ToSalesLine: Record "Sales Line"; RecalculateLines: Boolean)
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        GSTPlaceOfSupply(ToSalesLine);
        if not RecalculateLines then
            CalculateTax.CallTaxEngineOnSalesLine(ToSalesLine, ToSalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesDocOnAfterTransferPostedInvoiceFields', '', false, false)]
    local procedure OnCopySalesDocOnAfterCopySalesDocUpdateHeader(var ToSalesHeader: Record "Sales Header")
    var
        ShiptoAddr: Record "Ship-to Address";
    begin
        if ToSalesHeader."Ship-to Code" <> '' then
            if ShiptoAddr.Get(ToSalesHeader."Bill-to Customer No.", ToSalesHeader."Ship-to Code") then
                ToSalesHeader."GST-Ship to Customer Type" := ShiptoAddr."Ship-to GST Customer Type";

        if ToSalesHeader."GST Customer Type" = ToSalesHeader."GST Customer Type"::Unregistered then
            ToSalesHeader."GST-Ship to Customer Type" := ToSalesHeader."GST Customer Type";

        AssignInvoiceType(ToSalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Tax", 'OnAfterValidateSalesLineFields', '', false, false)]
    local procedure AssignUnitPricePIT(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        NewSalesLine: Record "Sales Line";
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTBaseAmt: Decimal;
    begin
        if not SalesLine."Price Inclusive of Tax" then
            exit;

        if not GSTSetup.Get() then
            exit;

        SalesLine."Total UPIT Amount" := SalesLine."Unit Price Incl. of Tax" * SalesLine.Quantity - SalesLine."Line Discount Amount";
        if (SalesLine."Unit Price Incl. of Tax" = 0) or (SalesLine."Total UPIT Amount" = 0) then
            exit;

        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetRange(TaxTransactionValue."Value ID", 10);
        if TaxTransactionValue.FindFirst() then begin
            GSTBaseAmt := RoundGSTBaseAmount(TaxTransactionValue.Amount);
            if GSTBaseAmt = 0 then
                exit;
            SalesLine."Unit Price" := Round((GSTBaseAmt + SalesLine."Line Discount Amount") / SalesLine.Quantity, GetRoundingPrecisionUnitPrice(SalesLine));
            SalesLine."Line Amount" := GSTBaseAmt;
            SalesLine.Amount := GSTBaseAmt;
            SalesLine."Amount Including VAT" := GSTBaseAmt;
            SalesLine."Recalculate Invoice Disc." := false;
            SalesLine."Outstanding Amount" := GSTBaseAmt;
            SalesLine."Outstanding Amount (LCY)" := GSTBaseAmt;
            if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
                if SalesHeader."Currency Code" <> '' then
                    SalesLine."Outstanding Amount (LCY)" := Round(GSTBaseAmt / SalesHeader."Currency Factor");

            if NewSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") then
                SalesLine.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterUpdateAmountsDone', '', false, false)]
    local procedure UpdateTotalUPITAmount(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line")
    begin
        if not SalesLine."Price Inclusive of Tax" then
            exit;

        SalesLine."Total UPIT Amount" := SalesLine."Unit Price Incl. of Tax" * SalesLine.Quantity - SalesLine."Line Discount Amount";
    end;

#if not CLEAN25
    //AssignPrice Inclusice of Tax
#pragma warning disable AS0072
    [Obsolete('Replaced by the new implementation (V16) of price calculation.', '19.0')]
#pragma warning restore AS0072
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Price Calc. Mgt.", 'OnAfterFindSalesLineItemPrice', '', false, false)]
    local procedure AssignPriceInclusiveTax(var SalesLine: Record "Sales Line"; var TempSalesPrice: Record "Sales Price")
    begin
        if TempSalesPrice.IsEmpty() then
            exit;

        SalesLine."Price Inclusive of Tax" := TempSalesPrice."Price Inclusive of Tax";
        SalesLine."Unit Price Incl. of Tax" := 0;
        SalesLine."Total UPIT Amount" := 0;
        if SalesLine."Price Inclusive of Tax" then begin
            SalesLine."Unit Price Incl. of Tax" := TempSalesPrice."Unit Price";
            SalesLine."Total UPIT Amount" := SalesLine."Unit Price Incl. of Tax" * SalesLine.Quantity - SalesLine."Line Discount Amount";
        end;
    end;
#endif

    //Check Accounting Period
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnAfterConfirmPost', '', false, false)]
    local procedure CheckAccountignPeriod(var SalesHeader: Record "Sales Header")
    var
        GSTShiptoAddress: Codeunit "GST Ship To Address";
    begin
        CheckPostingDate(SalesHeader);
        GSTShiptoAddress.SalesPostGSTPlaceOfSupply(SalesHeader);
        if (SalesHeader."GST Customer Type" <> SalesHeader."GST Customer Type"::Exempted) and (SalesHeader."GST Customer Type" <> SalesHeader."GST Customer Type"::" ") then
            CheckExemptedInvoiceTypeSales(SalesHeader);
    end;

    //Check Accounting Period - Post Preview
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnRunPreviewOnAfterSetPostingFlags', '', false, false)]
    local procedure CheckAccountignPeriodPostPreview(var SalesHeader: Record "Sales Header")
    var
        GSTShiptoAddress: Codeunit "GST Ship To Address";
    begin
        CheckPostingDate(SalesHeader);
        GSTShiptoAddress.SalesPostGSTPlaceOfSupply(SalesHeader);
        if (SalesHeader."GST Customer Type" <> SalesHeader."GST Customer Type"::Exempted) and (SalesHeader."GST Customer Type" <> SalesHeader."GST Customer Type"::" ") then
            CheckExemptedInvoiceTypeSales(SalesHeader);
    end;

    //Sales Quote to Sales Order
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnBeforeModifySalesOrderHeader', '', false, false)]
    local procedure CopyInfotoSalesOrder(
        SalesQuoteHeader: Record "Sales Header";
        var SalesOrderHeader: Record "Sales Header")
    begin
        SalesOrderHeader."Location GST Reg. No." := SalesQuoteHeader."Location GST Reg. No.";
        SalesOrderHeader."Location State Code" := SalesQuoteHeader."Location State Code";
    end;

    //Invoice Discount Calculation
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales - Calc Discount By Type", 'OnAfterResetRecalculateInvoiceDisc', '', False, False)]
    local procedure ReCalculateGST(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);
            until SalesLine.Next() = 0;
    end;

    //Sales Header Subscribers
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'GST Customer Type', false, false)]
    local procedure UpdateInvoieType(var Rec: Record "Sales Header")
    begin
        GSTInvoiceType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'GST Without Payment Of Duty', false, false)]
    local procedure ValidateGSTWithoutPaymentOfDuty(var Rec: Record "Sales Header")
    begin
        GSTWithoutPaymentOfDuty(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Invoice Type', false, false)]
    local procedure ValidateInvoiceType(var Rec: Record "Sales Header")
    begin
        InvoiceType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'E-Comm. Merchant Id', false, false)]
    local procedure validateEcommerceMerchantId(var Rec: Record "Sales Header")
    begin
        EcommerceMerchantId(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Location GST Reg. No.', false, false)]
    local procedure ValidateLocationGSTRegNo(var Rec: Record "Sales Header")
    begin
        LocationGSTRegNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill Of Export Date', false, false)]
    local procedure validateBillOfExportDate(var Rec: Record "Sales Header")
    begin
        BillOfExportDate(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill Of Export No.', false, false)]
    local procedure validateBillOfExportNo(var Rec: Record "Sales Header")
    begin
        BillOfExportNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'POS Out Of India', false, false)]
    local procedure ValidatePOSOutOfIndia(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        POSOutOfIndia(Rec, xRec, Rec.FieldNo("POS Out Of India"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInitRecord', '', false, false)]
    local procedure UpdateTradingInfo(var SalesHeader: Record "Sales Header")
    begin
        TradingInfo(SalesHeader)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateInvoiceType(var SalesHeader: Record "Sales Header")
    begin
        InvoiceType(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopySellToCustomerAddressFieldsFromCustomer', '', false, false)]
    local procedure UpdateSelltoStateCode(var SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer)
    begin
        SelltoStateCode(SalesHeader, SellToCustomer);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure ValidateSelltoCustNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        SelltoCustNo(Rec, xRec);
        AssignInvoiceType(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCheckBillToCust', '', false, false)]
    local procedure UpdateBilltoCustinfo(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    var
        ShiptoAddress: Record "Ship-to Address";
    begin
        BilltoCustinfo(SalesHeader);

        if (SalesHeader."Ship-to Code" <> '') and not (SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::Unregistered) then begin
            if ShiptoAddress.Get(SalesHeader."Bill-to Customer No.", SalesHeader."Ship-to Code") then
                SalesHeader."GST-Ship to Customer Type" := ShiptoAddress."Ship-to GST Customer Type";
        end
        else
            SalesHeader."GST-Ship to Customer Type" := SalesHeader."GST Customer Type";

        AssignInvoiceType(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterSetFieldsBilltoCustomer', '', false, false)]
    local procedure UpdateBilltoNatureOfSupply(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        BilltoNatureOfSupply(SalesHeader, Customer);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr', '', false, false)]
    local procedure UpdateShipToAddrfields(var SalesHeader: Record "Sales Header"; ShipToAddress: Record "Ship-to Address")
    begin
        ShipToAddrfields(SalesHeader, ShipToAddress);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopyShipToCustomerAddressFieldsFromCustomer', '', false, false)]
    local procedure UpdateCustomerFields(var SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer)
    begin
        CustomerFields(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure UpdateLocationinfo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        Locationinfo(Rec, xRec, Rec.FieldNo("Location Code"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Ship-to Customer', false, false)]
    local procedure OnAfterValidateEventShipToCustomer(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        ShiptoCustomer(Rec, xRec, Rec.FieldNo("Ship-to Customer"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnValidateShipToCodeOnBeforeCopyShipToAddress', '', false, false)]
    local procedure OnValidateShipToCodeOnBeforeCopy(var SalesHeader: Record "Sales Header"; var CopyShipToAddress: Boolean)
    begin
        UpdateBeforeShiptoFields(SalesHeader);
        UpdateShiptoCodeCreditDocument(SalesHeader, CopyShipToAddress);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Post GST to Customer', false, false)]
    local procedure OnValidatePostGSTtoCustomer(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        Rec.TestField(Status, Rec.Status::Open);
        ReferenceInvoiceNoValidation(Rec, xRec, Rec.FieldNo("Post GST to Customer"));
        if not (Rec."GST Customer Type" IN [Rec."GST Customer Type"::"SEZ Development", Rec."GST Customer Type"::"SEZ Unit", Rec."GST Customer Type"::"Deemed Export"]) then
            Error(PostGSTtoCustErr);

        if Rec."Ship-to GST Customer Type" = Rec."Ship-to GST Customer Type"::Registered then
            Error(PostGSTtoCustErr);
    end;

    //Sales Line Subscribers
    [EventSubscriber(ObjectType::Table, Database::"Sales line", 'OnAfterValidateEvent', 'GST Place Of Supply', false, false)]
    local procedure ValidateGSTPlaceOfSupply(var Rec: Record "Sales Line")
    var
        GSTShiptoAddress: Codeunit "GST Ship To Address";
    begin
        GSTPlaceOfSupply(Rec);
        GSTShiptoAddress.ValidateGSTRegistration(Rec);
    end;

    [EventSubscriber(ObjectType::table, Database::"Sales line", 'onaftervalidateevent', 'GST Assessable Value (LCY)', false, false)]
    local procedure AssignGSTAssessableValueFCY(var Rec: Record "Sales Line")
    begin
        ExchangeAmtLCYToFCY(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales line", 'OnAfterValidateEvent', 'GST Group Code', false, false)]
    local procedure ValidateGSTGroupCode(var Rec: Record "Sales Line")
    begin
        GSTGroupCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales line", 'OnAfterValidateEvent', 'Exempted', false, false)]
    local procedure ValidateExepmted(var Rec: Record "Sales Line")
    begin
        Exepmted(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales line", 'OnAfterValidateEvent', 'GST On Assessable Value', false, false)]
    local procedure ValidateGSTOnAssessableValue(var Rec: Record "Sales Line")
    begin
        GSTOnAssessableValue(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales line", 'OnAfterValidateEvent', 'GST Assessable Value (LCY)', false, false)]
    local procedure ValidateGSTAssessableValueLCY(var Rec: Record "Sales Line")
    begin
        GSTAssessableValueLCY(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales line", 'OnAfterValidateEvent', 'Non-GST Line', false, false)]
    local procedure ValidateNonGSTLine(var Rec: Record "Sales Line")
    begin
        NonGSTLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignGLAccountValues', '', False, False)]
    local procedure AssignGLAccValue(var SalesLine: Record "Sales Line"; GLAccount: Record "G/L Account")
    begin
        GLAccValue(SalesLine, GLAccount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterCopyFromItem', '', False, False)]
    local procedure AssignItemValue(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
        ItemValue(SalesLine, Item);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignResourceValues', '', False, False)]
    local procedure AssignResourceValue(var SalesLine: Record "Sales Line"; Resource: Record Resource)
    begin
        ResourceValue(SalesLine, Resource);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignFixedAssetValues', '', False, False)]
    local procedure AssignFAValue(var SalesLine: Record "Sales Line"; FixedAsset: Record "Fixed Asset")
    begin
        FAValue(SalesLine, FixedAsset);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignItemChargeValues', '', False, False)]
    local procedure AssignItemChargeValue(var SalesLine: Record "Sales Line"; ItemCharge: Record "Item Charge")
    begin
        ItemChargeValue(SalesLine, ItemCharge);
    end;

    //Ship-to Address Validation
    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", 'OnAfterValidateEvent', 'State', false, false)]
    local procedure ValidateState(var Rec: Record "Ship-to Address")
    begin
        state(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", 'OnAfterValidateEvent', 'GST Registration No.', false, false)]
    local procedure validateShiptoAddGSTRegistrationNo(var Rec: Record "Ship-to Address")
    begin
        ShiptoAddGSTRegistrationNo(Rec);
    end;

    //Customer - Subscribers 
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'GST Registration No.', False, False)]
    local procedure ValidateGSTRegistrationNo(var Rec: Record Customer)
    begin
        CustGSTRegistrationNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'GST Registration Type', False, False)]
    local procedure ValidateCustGSTRegistrationType(var Rec: Record Customer)
    begin
        CustGSTRegistrationType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'GST Customer Type', False, False)]
    local procedure ValidateCustGSTCustomerType(var Rec: Record Customer)
    begin
        CustGSTCustomerType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'ARN No.', False, False)]
    local procedure ValidateCustARNNo(var Rec: Record Customer)
    begin
        CustARNNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'P.A.N. No.', False, False)]
    local procedure ValidateCustPANNo(var Rec: Record Customer; var xRec: Record Customer)
    begin
        CustPANNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'State Code', False, False)]
    local procedure validateStateCode(var Rec: Record Customer)
    begin
        CustStateCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure OnAfterValidateEventLocationCode(var Rec: Record "Sales Line")
    begin
        CheckHeaderLocation(Rec);
        UpdateGSTJurisdictionType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Currency Factor', false, false)]
    local procedure OnAfterValidateEventCurrencyFactor(var Rec: Record "Sales Header")
    begin
        CallTaxEngineOnSalesHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Price Inclusive of Tax', false, false)]
    local procedure OnAfterValidateEventPIT(var Rec: Record "Sales Line")
    begin
        Rec.TestField(Type, Rec.Type::Item);
        CalcTotalUPITAmount(Rec);

        if Rec."Price Inclusive of Tax" then
            Rec.Validate("Line Discount %")
        else begin
            Rec.Validate("Unit Price", 0);
            Rec."Line Amount" := 0;
            Rec."Unit Price Incl. of Tax" := 0;
            Rec."Outstanding Amount" := 0;
            Rec."Outstanding Amount (LCY)" := 0
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Unit Price Incl. of Tax', false, false)]
    local procedure OnAfterValidateEventUPIT(var Rec: Record "Sales Line")
    begin
        if Rec."Price Inclusive of Tax" then
            Rec.Validate("Line Discount %");

        CalcTotalUPITAmount(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Line Discount %', false, false)]
    local procedure OnAfterValidateEventLineDiscountPercent(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        Currency: Record Currency;
        CalculateTax: Codeunit "Calculate Tax";
    begin
        if not Rec."Price Inclusive of Tax" then
            exit;

        GetCurrency(Rec, Currency);
        Rec."Line Discount Amount" := Round(Round(Rec.Quantity * Rec."Unit Price Incl. of Tax", Currency."Amount Rounding Precision") *
            Rec."Line Discount %" / 100, Currency."Amount Rounding Precision");

        CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Line Discount Amount', false, false)]
    local procedure OnAfterValidateEventLineDiscountAmount(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        Currency: Record Currency;
        CalculateTax: Codeunit "Calculate Tax";
    begin
        if not Rec."Price Inclusive of Tax" then
            exit;

        GetCurrency(Rec, Currency);
        if Round(Rec.Quantity * Rec."Unit Price Incl. of Tax", Currency."Amount Rounding Precision") <> 0 then
            Rec."Line Discount %" := Round(Rec."Line Discount Amount" / Round(Rec.Quantity * Rec."Unit Price Incl. of Tax",
                                        Currency."Amount Rounding Precision") * 100, 0.00001);

        CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
    end;

    //Sales & Receivables Setup
    [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnBeforeValidateEvent', 'GST Dependency Type', false, false)]
    local procedure OnBeforeValidateEvenetGSTDependencyType(var Rec: Record "Sales & Receivables Setup")
    begin
        if Rec."GST Dependency Type" = Rec."GST Dependency Type"::"Location Address" then
            Error(GSTDependencyTypeErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Ship-To Code', false, false)]
    local procedure OnBeforeUpdateShipToAddress(var Rec: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if Customer.Get(Rec."Sell-to Customer No.") then
            Rec."GST Customer Type" := Customer."GST Customer Type";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Ship-To Code', false, false)]
    local procedure OnAfterUpdateShipToAddress(var Rec: Record "Sales Header")
    begin
        OnValidateShipToCodeForUpdateShipToAddress(Rec);
        if (Rec."Ship-to Code" = '') or (Rec."GST Customer Type" = Rec."GST Customer Type"::Unregistered) then
            Rec."GST-Ship to Customer Type" := Rec."GST Customer Type";

        AssignInvoiceType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeUpdateLineDiscPct', '', false, false)]
    local procedure OnBeforeUpdateLineDiscPct(var SalesLine: Record "Sales Line"; var IsHandled: Boolean; Currency: Record Currency)
    var
        LineDiscountPct: Decimal;
        IsOutOfStandardDiscPctRange: Boolean;
        LineDiscountPctErr: Label 'The value in the Line Discount % field must be between 0 and 100.';
    begin
        if not SalesLine."Price Inclusive of Tax" then
            exit;

        if Round(SalesLine.Quantity * SalesLine."Unit Price Incl. of Tax", Currency."Amount Rounding Precision") <> 0 then begin
            LineDiscountPct :=
                Round(
                    SalesLine."Line Discount Amount" /
                    Round(SalesLine.Quantity * SalesLine."Unit Price Incl. of Tax", Currency."Amount Rounding Precision") * 100,
                    0.00001);

            IsOutOfStandardDiscPctRange := not (LineDiscountPct in [0 .. 100]);

            if IsOutOfStandardDiscPctRange then
                Error(LineDiscountPctErr);

            SalesLine."Line Discount %" := LineDiscountPct;
        end else
            SalesLine."Line Discount %" := 0;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnUpdateAmountsOnAfterCalcLineAmount', '', false, false)]
    local procedure OnUpdateAmountsOnAfterCalcLineAmount(var SalesLine: Record "Sales Line"; var LineAmount: Decimal)
    var
        Currency: Record Currency;
    begin
        if not SalesLine."Price Inclusive of Tax" then
            exit;

        GetCurrency(SalesLine, Currency);

        SalesLine."Line Discount Amount" := Round(Round(SalesLine.Quantity * SalesLine."Unit Price Incl. of Tax", Currency."Amount Rounding Precision") *
            SalesLine."Line Discount %" / 100, Currency."Amount Rounding Precision");

        LineAmount := Round(SalesLine.Quantity * SalesLine."Unit Price Incl. of Tax", Currency."Amount Rounding Precision") - SalesLine."Line Discount Amount";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterAppliesToDocNoOnLookup', '', false, false)]
    local procedure OnAfterAppliesToDocNoOnLookup(var SalesHeader: Record "Sales Header"; CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        ValidateGSTGroupCodeonSalesLines(SalesHeader, CustLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure OnAfterValidateQuantity(var Rec: Record "Sales Line")
    begin
        OnQuantityChangeValidation(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Invoice", 'OnAfterOnRun', '', false, false)]
    local procedure OnAfterOnRun(SalesHeader: Record "Sales Header")
    begin
        if (SalesHeader."Location GST Reg. No." = '') and (SalesHeader."Location State Code" = '') then
            exit;

        CallTaxEngineOnSalesHeader(SalesHeader);
    end;

    local procedure OnQuantityChangeValidation(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        ShipToAddress: Record "Ship-to Address";
    begin
        if (SalesLine."GST Group Code" = '') or (SalesLine."HSN/SAC Code" = '') then
            exit;

        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesHeader.TestField("POS Out Of India", false);

        if SalesLine."GST Place Of Supply" = SalesLine."GST Place Of Supply"::"Ship-to Address" then begin
            if (SalesHeader."Ship-to Code" = '') and (SalesHeader."Ship-to Customer" = '') then
                error(GSTPlaceOfSupplyErr);

            SalesHeader.TestField("POS Out Of India", false);
            if SalesHeader."Ship-to GST Reg. No." = '' then
                if ShipToAddress.Get(SalesLine."Sell-to Customer No.", SalesHeader."Ship-to Code") then
                    if not (SalesHeader."GST Customer Type" in [SalesHeader."GST Customer Type"::Unregistered, SalesHeader."GST Customer Type"::Export]) then
                        if ShipToAddress."ARN No." = '' then
                            Error(ShipToGSTARNErr);
        end;

        if SalesLine."Document Type" In [SalesLine."Document Type"::Invoice,
            SalesLine."Document Type"::"Credit Memo",
            SalesLine."Document Type"::Order,
            SalesLine."Document Type"::"Return Order"]
        then
            ReferenceInvoiceNoValidation(SalesLine, SalesLine, SalesLine.FieldNo(Quantity));

        UpdateStateCode(SalesHeader, SalesLine);
        UpdateGSTJurisdictionType(SalesLine);
    end;

    local procedure ValidateGSTGroupCodeonSalesLines(var SalesHeader: Record "Sales Header"; CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        SalesLine: Record "Sales Line";
    begin
        if not CustLedgerEntry."GST on Advance Payment" then
            exit;

        SalesLine.SetCurrentKey("Document Type", "Document No.", "No.", "GST Group Code");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetFilter("GST Group Code", '<>%1', CustLedgerEntry."GST Group Code");
        if not SalesLine.IsEmpty() then
            Error(GSTGroupCodeEqualErr, SalesHeader."Document Type", SalesHeader."No.");
    end;

    local procedure CalcTotalUPITAmount(var Rec: Record "Sales Line")
    begin
        if not Rec."Price Inclusive of Tax" then
            exit;

        Rec.Validate("Line Discount %");
        Rec.Validate(Quantity);
        Rec."Total UPIT Amount" := (Rec."Unit Price Incl. of Tax" * Rec.Quantity) - Rec."Line Discount Amount";
    end;

    local procedure GetCurrency(SalesLine: Record "Sales Line"; var Currency: Record Currency)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        if SalesHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else begin
            SalesHeader.TestField("Currency Factor");
            Currency.Get(SalesHeader."Currency Code");
            Currency.TestField("Amount Rounding Precision");
        end;
    end;

    local procedure RoundGSTBaseAmount(GSTBaseAmount: Decimal): Decimal
    var
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        GSTRoundingDirection: Text;
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(ID, 10);
        TaxComponent.FindFirst();
        case TaxComponent.Direction of
            TaxComponent.Direction::Nearest:
                GSTRoundingDirection := '=';
            TaxComponent.Direction::Up:
                GSTRoundingDirection := '>';
            TaxComponent.Direction::Down:
                GSTRoundingDirection := '<';
        end;
        exit(Round(GSTBaseAmount, TaxComponent."Rounding Precision", GSTRoundingDirection));
    end;

    local procedure GetRoundingPrecisionUnitPrice(SalesLine: Record "Sales Line") Precision: Decimal
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        LoopCount: Integer;
    begin
        if SalesLine."Currency Code" = '' then begin
            GeneralLedgerSetup.Get();
            if GeneralLedgerSetup."Unit-Amount Rounding Precision" <> 0 then
                Precision := GeneralLedgerSetup."Unit-Amount Rounding Precision"
            else begin
                Evaluate(LoopCount, CopyStr(GeneralLedgerSetup."Unit-Amount Decimal Places", StrPos(GeneralLedgerSetup."Unit-Amount Decimal Places", ':') + 1));
                Precision := 1;
                repeat
                    LoopCount -= 1;
                    Precision := (1 * Precision) / 10
                until LoopCount = 0;
            end;
        end else begin
            Currency.Get(SalesLine."Currency Code");
            if Currency."Unit-Amount Rounding Precision" <> 0 then
                Precision := Currency."Unit-Amount Rounding Precision"
            else begin
                Evaluate(LoopCount, CopyStr(Currency."Unit-Amount Decimal Places", StrPos(Currency."Unit-Amount Decimal Places", ':') + 1));
                Precision := 1;
                repeat
                    LoopCount -= 1;
                    Precision := (1 * Precision) / 10;
                until LoopCount = 0;
            end;
        end;
    end;

    //Sales Header Validation - Definition
    local procedure GSTInvoiceType(var SalesHeader: Record "Sales Header")
    begin
        case SalesHeader."GST Customer Type" of
            "GST Customer Type"::" ",
            "GST Customer Type"::Registered,
            "GST Customer Type"::Unregistered:
                SalesHeader."Invoice Type" := SalesHeader."Invoice Type"::Taxable;
            "GST Customer Type"::Export,
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit":
                SalesHeader.Validate("Invoice Type", SalesHeader."Invoice Type"::Export);
            "GST Customer Type"::Exempted:
                SalesHeader."Invoice Type" := SalesHeader."Invoice Type"::"Bill Of Supply";
        end;
    end;

    local procedure GSTWithoutPaymentOfDuty(var SalesHeader: Record "Sales Header")
    begin
        if not (SalesHeader."GST-Ship to Customer Type" in [
            "GST Customer Type"::Export,
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit"])
        then
            Error(GSTPaymentDutyErr);

        if SalesHeader."Ship-to GST Customer Type" = SalesHeader."Ship-to GST Customer Type"::Registered then
            Error(GSTPaymentDutyErr);
    end;

    local procedure TradingInfo(var SalesHeader: Record "Sales Header")
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        SalesHeader.Trading := CompanyInfo."Trading Co.";
    end;

    local procedure InvoiceType(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := SalesHeader;
        if SalesHeader."Invoice Type" = SalesHeader."Invoice Type"::"Non-GST" then
            if SalesHeader."GST Invoice" then
                Error(NonGSTInvTypeErr);

        CheckShippedDocument(SalesHeader);
        if ((SalesHeader."Ship-to Customer" = '') and (SalesHeader."GST Customer Type" <> SalesHeader."GST Customer Type"::Exempted)) or
            ((SalesHeader."Ship-to Customer" <> '') and (SalesHeader."Ship-to GST Customer Type" <> SalesHeader."Ship-to GST Customer Type"::Exempted)) then begin
            if CheckAllLinesExemptedSales(SalesHeader) then
                CheckInvoiceType(SalesHeader)
            else begin
                SalesLine.Reset();
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if not SalesLine.IsEmpty() then
                    SalesHeader.TestField("Invoice Type", SalesHeader."Invoice Type"::"Bill Of Supply");
            end;
        end else
            CheckInvoiceType(SalesHeader);

        if SalesHeader."Document Type" in ["Document Type Enum"::Order, "Document Type Enum"::Invoice] then
            PostingNoSeries.GetPostingNoSeriesCode(Record)
        else
            if SalesHeader."Document Type" in ["Document Type Enum"::"Credit Memo", "Document Type Enum"::"Return Order"] then
                PostingNoSeries.GetPostingNoSeriesCode(Record);

        UpdateInvoiceTypeLine(SalesHeader);
        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) and (SalesHeader."Reference Invoice No." <> '') then
            if not (SalesHeader."Invoice Type" in [SalesHeader."Invoice Type"::"Debit Note", SalesHeader."Invoice Type"::Supplementary]) then
                Error(ReferenceNoErr);

        if SalesHeader."Document Type" in ["Document Type Enum"::Order, "Document Type Enum"::Invoice] then
            ReferenceInvoiceNoValidation(SalesHeader, SalesHeader, SalesHeader.FieldNo("Invoice Type"));
    end;

    local procedure CheckAllLinesExemptedSales(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesLine1: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine1.CopyFilters(SalesLine);
        SalesLine1.SetRange(Exempted, true);
        if SalesLine.Count() <> SalesLine1.Count() then
            exit(true);
    end;

    local procedure CheckInvoiceType(SalesHeader: Record "Sales Header")
    begin
        case SalesHeader."GST Customer Type" of
            "GST Customer Type"::" ",
            "GST Customer Type"::Registered,
            "GST Customer Type"::Unregistered:
                if SalesHeader."Invoice Type" in [SalesHeader."Invoice Type"::"Bill Of Supply", SalesHeader."Invoice Type"::Export] then
                    Error(InvoiceTypeErr, SalesHeader."Invoice Type", SalesHeader."GST Customer Type");
            "GST Customer Type"::Export,
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit":
                if SalesHeader."Invoice Type" in [SalesHeader."Invoice Type"::"Bill Of Supply", SalesHeader."Invoice Type"::Taxable] then
                    Error(InvoiceTypeErr, SalesHeader."Invoice Type", SalesHeader."GST Customer Type");
            "GST Customer Type"::Exempted:
                if SalesHeader."Invoice Type" in [SalesHeader."Invoice Type"::"Debit Note", SalesHeader."Invoice Type"::Export, SalesHeader."Invoice Type"::Taxable] then
                    Error(InvoiceTypeErr, SalesHeader."Invoice Type", SalesHeader."GST Customer Type");
        end;
    end;

    local procedure EcommerceMerchantId(var SalesHeader: Record "Sales Header")
    var
        EcommMerchantRec: Record "E-Comm. Merchant";
    begin
        EcommMerchantRec.SetRange("Customer No.", SalesHeader."Sell-to Customer No.");
        EcommMerchantRec.SetRange("Company GST Reg. No.", SalesHeader."Location GST Reg. No.");
        if EcommMerchantRec.FindFirst() then
            SalesHeader.TestField("E-Comm. Merchant Id", EcommMerchantRec."Merchant Id");
    end;

    local procedure LocationGSTRegNo(var SalesHeader: Record "Sales Header")
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
    begin
        SalesHeader.TestField(Status, SalesHeader.Status::Open);
        if GSTRegistrationNos.Get(SalesHeader."Location GST Reg. No.") then
            SalesHeader."Location State Code" := GSTRegistrationNos."State Code"
        else
            SalesHeader."Location State Code" := '';

        ReferenceInvoiceNoValidation(SalesHeader, SalesHeader, SalesHeader.FieldNo("Location GST Reg. No."));
        SalesHeader."POS Out Of India" := false;
    end;

    local procedure POSOutOfIndia(var SalesHeader: Record "Sales Header"; var xSalesHeader: Record "Sales Header"; CurrFieldNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesHeader.TestField(Status, SalesHeader.Status::Open);
        SalesHeader.TestField("Ship-to Customer", '');
        ReferenceInvoiceNoValidation(SalesHeader, xSalesHeader, CurrFieldNo);
        if not SalesHeader."GST Invoice" then
            Error(POSGSTInvoiceErr);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine."GST Place Of Supply" <> SalesLine."GST Place Of Supply"::"Location Address" then
                    GSTBaseValidation.VerifyPOSOutOfIndia(
                        "Party Type"::Customer,
                        SalesHeader."Location State Code",
                        GetPlaceOfSupplyStateCode(SalesLine),
                        "GST VEndor Type"::" ",
                        SalesHeader."GST Customer Type")
                else
                    Error(GSTPlaceOfSuppErr);

                SalesLine.Validate(Quantity);
                SalesLine.Validate("Unit Cost");
            until SalesLine.Next() = 0;

        GSTBaseValidation.VerifyPOSOutOfIndia(
          "Party Type"::Customer,
          SalesHeader."Location State Code",
          SalesHeader."GST Bill-to State Code",
          "GST VEndor Type"::" ",
          SalesHeader."GST Customer Type");
    end;

    local procedure BillOfExportDate(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.TestField("GST Customer Type", SalesHeader."GST Customer Type"::Export);
    end;

    local procedure BillOfExportNo(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.TestField("GST Customer Type", SalesHeader."GST Customer Type"::Export);
    end;

    local procedure ReferenceInvoiceNoValidation(SalesHeader: Record "Sales Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocTye: Text;
        DocTypeEnum: Enum "Document Type Enum";
    begin
        DocTye := Format(SalesHeader."Document Type");
        Evaluate(DocTypeEnum, DocTye);
        ReferenceInvoiceNo.SetRange("Document Type", DocTypeEnum);
        ReferenceInvoiceNo.SetRange("Document No.", SalesHeader."No.");
        ReferenceInvoiceNo.SetRange("Source Type", ReferenceInvoiceNo."Source Type"::Customer);
        ReferenceInvoiceNo.SetRange("Source No.", SalesHeader."Sell-to Customer No.");
        ReferenceInvoiceNo.SetRange(Verified, true);
        if not ReferenceInvoiceNo.IsEmpty() then
            Error(RefErr);
    end;

    local procedure GetPlaceOfSupplyStateCode(SalesLine: Record "Sales Line"): Code[10]
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesHeader: Record "Sales Header";
        PlaceOfSupplyStateCode: Code[10];
    begin
        SalesSetup.Get();
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        case SalesLine."GST Place Of Supply" of
            SalesLine."GST Place Of Supply"::"Bill-to Address":
                PlaceOfSupplyStateCode := SalesHeader."GST Bill-to State Code";
            SalesLine."GST Place Of Supply"::"Ship-to Address":
                PlaceOfSupplyStateCode := SalesHeader."GST Ship-to State Code";
            SalesLine."GST Place Of Supply"::"Location Address":
                PlaceOfSupplyStateCode := SalesHeader."Location State Code";
            SalesLine."GST Place Of Supply"::" ":
                if SalesSetup."GST DepEndency Type" = SalesSetup."GST DepEndency Type"::"Bill-to Address" then
                    PlaceOfSupplyStateCode := SalesHeader."GST Bill-to State Code"
                else
                    if SalesSetup."GST DepEndency Type" = SalesSetup."GST DepEndency Type"::"Ship-to Address" then
                        PlaceOfSupplyStateCode := SalesHeader."GST Ship-to State Code"
        end;
        exit(PlaceOfSupplyStateCode);
    end;

    local procedure UpdateInvoiceTypeLine(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet(true, false) then
            repeat
                SalesLine."Invoice Type" := SalesHeader."Invoice Type";
                SalesLine.Modify(true);
            until SalesLine.Next() = 0;
    end;

    local procedure CheckShippedDocument(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Qty. Shipped (Base)", '<>%1', 0);
        if not SalesLine.IsEmpty() then
            Error(ShippedInvoiceTypeErr);
    end;

    //Sales Line Validation Definition
    local procedure GSTPlaceOfSupply(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        ShipToAddress: Record "Ship-to Address";
    begin
        SalesLine.TestField("Quantity Shipped", 0);
        SalesLine.TestField("Quantity Invoiced", 0);
        SalesLine.TestField("Return Qty. Received", 0);
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesHeader.TestField("POS Out Of India", false);
        if SalesLine."GST Place Of Supply" = SalesLine."GST Place Of Supply"::"Ship-to Address" then begin
            if (SalesHeader."Ship-to Code" = '') and (SalesHeader."Ship-to Customer" = '') then
                error(GSTPlaceOfSupplyErr);

            SalesHeader.TestField("POS Out Of India", false);
            if SalesHeader."Ship-to GST Reg. No." = '' then
                if ShipToAddress.Get(SalesLine."Sell-to Customer No.", SalesHeader."Ship-to Code") then
                    if not (SalesHeader."GST Customer Type" in [SalesHeader."GST Customer Type"::Unregistered, SalesHeader."GST Customer Type"::Export]) then
                        if ShipToAddress."ARN No." = '' then
                            Error(ShipToGSTARNErr);
        end;
        if SalesLine."Document Type" In [SalesLine."Document Type"::Invoice,
            SalesLine."Document Type"::"Credit Memo",
            SalesLine."Document Type"::Order,
            SalesLine."Document Type"::"Return Order"] then
            ReferenceInvoiceNoValidation(SalesLine, SalesLine, SalesLine.FieldNo("GST Place Of Supply"));

        UpdateStateCode(SalesHeader, SalesLine);
        UpdateGSTJurisdictionType(SalesLine);
    end;

    procedure UpdateGSTJurisdictionTypeFromPlaceOfSupply(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.LoadFields("Document Type", "Document No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                GSTPlaceOfSupply(SalesLine);
                SalesLine.Modify();
            until SalesLine.Next() = 0;
    end;

    local procedure GSTGroupCode(var SalesLine: Record "Sales Line")
    var
        GSTGroup: Record "GST Group";
        SalesSetup: Record "Sales & Receivables Setup";
        GSTDependencyType: Text;
    begin
        SalesLine.TestStatusOpen();
        SalesLine.TestField("Non-GST Line", false);
        if GSTGroup.Get(SalesLine."GST Group Code") then begin
            if GSTGroup."Reverse Charge" then
                Error(GSTGroupReverseChargeErr, SalesLine."GST Group Code");

            SalesLine."GST Place Of Supply" := GSTGroup."GST Place Of Supply";
            SalesLine."GST Group Type" := GSTGroup."GST Group Type";
        end;

        if SalesLine."GST Place Of Supply" = SalesLine."GST Place Of Supply"::" " then begin
            SalesSetup.Get();
            GSTDependencyType := Format(SalesSetup."GST DepEndency Type");
            Evaluate(SalesLine."GST Place Of Supply", GSTDependencyType);
        end;

        SalesLine."HSN/SAC Code" := '';
        SalesLine."GST On Assessable Value" := false;
        SalesLine."GST Assessable Value (LCY)" := 0;
    end;

    local procedure Exepmted(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesLine.TestField("Quantity Shipped", 0);
        SalesLine.TestField("Quantity Invoiced", 0);
        SalesLine.TestField("Return Qty. Received", 0);
        GetSalesHeader2(SalesHeader, SalesLine);
        if (SalesHeader."Applies-to Doc. No." <> '') or (SalesHeader."Applies-to ID" <> '') then
            Error(AppliesToDocErr);
    end;

    local procedure GSTOnAssessableValue(var SalesLine: Record "Sales Line")
    var
        GSTGroup: Record "GST Group";
    begin
        SalesLine.TestField("Currency Code");
        SalesLine.TestField("GST Group Code");
        if GSTGroup.Get(SalesLine."GST Group Code") then
            GSTGroup.TestField("GST Group Type", GSTGroup."GST Group Type"::Goods);

        if SalesLine.Type = Type::"Charge (Item)" then
            SalesLine.TestField("GST On Assessable Value", false);

        SalesLine."GST Assessable Value (LCY)" := 0;
    end;

    local procedure GSTAssessableValueLCY(var SalesLine: Record "Sales Line")
    begin
        SalesLine.TestField("GST On Assessable Value", true);
    end;

    local procedure NonGSTLine(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesLine."Non-GST Line" then begin
            SalesLine.TestStatusOpen();
            SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
            if not SalesHeader."GST Invoice" then
                Error(NGLStructErr);

            SalesLine."GST Group Code" := '';
            SalesLine."HSN/SAC Code" := '';
            SalesLine."GST On Assessable Value" := false;
            SalesLine."GST Assessable Value (LCY)" := 0;
        end;
    end;

    local procedure GetSalesHeader2(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        Currency: Record Currency;
    begin
        SalesLine.TestField("Document No.");
        if (SalesLine."Document Type" <> SalesHeader."Document Type") or
            (SalesLine."Document No." <> SalesHeader."No.")
        then begin
            SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
            if SalesHeader."Currency Code" = '' then
                Currency.InitRoundingPrecision()
            else begin
                SalesHeader.TestField("Currency Factor");
                Currency.Get(SalesHeader."Currency Code");
                Currency.TestField("Amount Rounding Precision");
            end;
        end;
    end;

    local procedure SelltoStateCode(var SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer)
    begin
        if SalesHeader."GST Customer Type" in [
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::Export,
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit"]
        then
            SalesHeader.State := ''
        else
            SalesHeader.State := SellToCustomer."State Code";
    end;

    local procedure SelltoCustNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        if Rec."Invoice Type" = Rec."Invoice Type"::" " then
            Rec."Invoice Type" := Rec."Invoice Type"::Taxable;

        if Rec."Reference Invoice No." <> '' then
            Rec."Reference Invoice No." := '';

        if (Rec."GST Customer Type" <> "GST Customer Type"::" ") and (xRec."Sell-to Customer No." <> Rec."Sell-to Customer No.") then
            Rec.Validate("Invoice Type");
    end;

    local procedure BilltoCustinfo(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        GetCust2(SalesHeader."Bill-to Customer No.", SalesHeader, Customer);
        SalesHeader."GST Customer Type" := Customer."GST Customer Type";
        SalesHeader."GST Bill-to State Code" := '';
        SalesHeader."GST Without Payment Of Duty" := false;
        SalesHeader."Customer GST Reg. No." := '';
        SalesHeader."Post GST to Customer" := Customer."Post GST to Customer";
        if SalesHeader."GST Customer Type" <> "GST Customer Type"::" " then
            Customer.TestField(Address);

        if not (SalesHeader."GST Customer Type" = "GST Customer Type"::Export) then
            SalesHeader."GST Bill-to State Code" := Customer."State Code";

        if not (SalesHeader."GST Customer Type" in ["GST Customer Type"::Export]) then
            SalesHeader."Customer GST Reg. No." := Customer."GST Registration No.";

        if SalesHeader."GST Customer Type" = "GST Customer Type"::Unregistered then
            SalesHeader."Nature Of Supply" := SalesHeader."Nature Of Supply"::B2C
        else
            SalesHeader."Nature of Supply" := SalesHeader."Nature of Supply"::B2B;
    end;

    local procedure BilltoNatureOfSupply(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        SalesHeader."GST Customer Type" := Customer."GST Customer Type";
        if SalesHeader."GST Customer Type" = "GST Customer Type"::Unregistered then
            SalesHeader."Nature Of Supply" := SalesHeader."Nature Of Supply"::B2C
        else
            SalesHeader."Nature of Supply" := SalesHeader."Nature of Supply"::B2B;
    end;

    local procedure ShipToAddrfields(var SalesHeader: Record "Sales Header"; ShipToAddress: Record "Ship-to Address")
    var
        IsHandled: Boolean;
    begin
        OnBeforeShipToAddrfields(SalesHeader, ShipToAddress, IsHandled);
        if IsHandled then
            exit;

        if SalesHeader."GST Customer Type" <> "GST Customer Type"::" " then
            if SalesHeader."GST Customer Type" in [
                "GST Customer Type"::Exempted,
                "GST Customer Type"::"Deemed Export",
                "GST Customer Type"::"SEZ Development",
                "GST Customer Type"::"SEZ Unit",
                "GST Customer Type"::Registered,
                "GST Customer Type"::Unregistered]
            then begin
                ShipToAddress.TestField(State);
                if SalesHeader."GST Customer Type" <> SalesHeader."GST Customer Type"::Unregistered then
                    if ShipToAddress."GST Registration No." = '' then
                        if ShipToAddress."ARN No." = '' then
                            Error(ShiptoGSTARNErr);
                SalesHeader."GST Ship-to State Code" := ShipToAddress.State;
                SalesHeader."Ship-to GST Reg. No." := ShipToAddress."GST Registration No.";
                SalesHeader."GST-Ship to Customer Type" := ShipToAddress."Ship-to GST Customer Type";
                SalesHeader."Ship-to GST Customer Type" := ShipToAddress."Ship-to GST Customer Type";

                if CheckGSTPlaceOfSupply(SalesHeader) then
                    SalesHeader.State := ShipToAddress.State;
                AssignInvoiceType(SalesHeader);
            end;

        OnAfterShipToAddrfields(SalesHeader, ShipToAddress);
    end;

    local procedure CustomerFields(var SalesHeader: Record "Sales Header")
    var
        ShipToAddr: Record "Ship-to Address";
    begin
        if SalesHeader."Document Type" in ["Document Type Enum"::"Credit Memo", "Document Type Enum"::"Return Order"] then
            if ShipToAddr.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code") then begin
                if not (SalesHeader."GST Customer Type" in [
                    "GST Customer Type"::Export,
                    "GST Customer Type"::"Deemed Export",
                    "GST Customer Type"::"SEZ Development",
                    "GST Customer Type"::"SEZ Unit"])
                then begin
                    ShipToAddr.TestField(State);
                    SalesHeader."GST Ship-to State Code" := ShipToAddr.State;
                end;
                if not (SalesHeader."GST Customer Type" in ["GST Customer Type"::Export]) then begin
                    ShipToAddr.TestField(State);
                    SalesHeader."Ship-to GST Reg. No." := ShipToAddr."GST Registration No.";
                end;
            end;
    end;

    local procedure Locationinfo(var SalesHeader: Record "Sales Header"; var xSalesHeader: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Location: Record Location;
    begin
        if SalesHeader."Location Code" = '' then begin
            SalesHeader."Location GST Reg. No." := '';
            SalesHeader."Location State Code" := '';
        end else begin
            Location.Get(SalesHeader."Location Code");
            SalesHeader."Location GST Reg. No." := Location."GST Registration No.";
            SalesHeader."Location State Code" := Location."State Code";
        end;
        if SalesHeader."Location Code" <> '' then
            GetPostInvoiceNoSeries(SalesHeader);

        SalesHeader."Location State Code" := Location."State Code";
        ReferenceInvoiceNoValidation(SalesHeader, xSalesHeader, CurrFieldNo);
    end;

    local procedure GLAccValue(var SalesLine: Record "Sales Line"; GLAccount: Record "G/L Account")
    var
        SalesHeader: Record "Sales Header";
    begin
        Salesheader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesLine."Invoice Type" := SalesHeader."Invoice Type";
        SalesLine."GST Customer Type" := SalesHeader."GST Customer Type";
        UpdateGSTPlaceOfSupply(GLAccount."HSN/SAC Code", GLAccount."GST Group Code", GLAccount.Exempted, GLAccount."GST Credit", SalesLine);
    end;

    local procedure ItemValue(var SalesLine: Record "Sales Line"; Item: Record Item)
    var
        SalesHeader: Record "Sales Header";
    begin
        if not Salesheader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            exit;

        SalesLine."Invoice Type" := SalesHeader."Invoice Type";
        if SalesLine."Location Code" = '' then
            SalesLine."Location Code" := SalesHeader."Location Code";

        SalesLine."GST Customer Type" := SalesHeader."GST Customer Type";
        UpdateGSTPlaceOfSupply(Item."HSN/SAC Code", Item."GST Group Code", Item.Exempted, Item."GST Credit", SalesLine);
    end;

    local procedure ResourceValue(var SalesLine: Record "Sales Line"; Resource: Record Resource)
    var
        SalesHeader: Record "Sales Header";
    begin
        Salesheader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesLine."Invoice Type" := SalesHeader."Invoice Type";
        SalesLine."GST Customer Type" := SalesHeader."GST Customer Type";
        UpdateGSTPlaceOfSupply(Resource."HSN/SAC Code", Resource."GST Group Code", Resource.Exempted, Resource."GST Credit", SalesLine);
    end;

    local procedure FAValue(var SalesLine: Record "Sales Line"; FixedAsset: Record "Fixed Asset")
    var
        SalesHeader: Record "Sales Header";
    begin
        Salesheader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesLine."Invoice Type" := SalesHeader."Invoice Type";
        SalesLine."GST Customer Type" := SalesHeader."GST Customer Type";
        UpdateGSTPlaceOfSupply(FixedAsset."HSN/SAC Code", FixedAsset."GST Group Code", FixedAsset.Exempted, FixedAsset."GST Credit", SalesLine);
    end;

    local procedure ItemChargeValue(var SalesLine: Record "Sales Line"; ItemCharge: Record "Item Charge")
    var
        SalesHeader: Record "Sales Header";
    begin
        Salesheader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesLine."Invoice Type" := SalesHeader."Invoice Type";
        UpdateGSTPlaceOfSupply(ItemCharge."HSN/SAC Code", ItemCharge."GST Group Code", ItemCharge.Exempted, ItemCharge."GST Credit", SalesLine);
    end;

    local procedure UpdateGSTPlaceOfSupply(
        HSNSACCode: Code[10];
        GSTGroupCode: Code[20];
        GSTExempted: Boolean;
        GSTCredit: Enum "GST Credit";
        var SalesLine: Record "Sales Line")
    var
        SalesSetup: Record "Sales & Receivables Setup";
        GSTGroup: Record "GST Group";
        GSTShiptoAddress: Codeunit "GST Ship To Address";
    begin
        SalesLine."HSN/SAC Code" := HSNSACCode;
        SalesLine."GST Group Code" := GSTGroupCode;
        SalesLine."GST Credit" := GSTcredit;
        SalesLine.Exempted := GSTExempted;
        SalesSetup.Get();
        SalesLine."GST Place Of Supply" := SalesSetup."GST Dependency Type";
        if GSTGroup.Get(GSTGroupCode) then begin
            if GSTGroup."Reverse Charge" then
                Error(GSTGroupReverseChargeErr, GSTGroupCode);

            SalesLine."GST Group Type" := GSTGroup."GST Group Type";
            if GSTGroup."GST Place Of Supply" <> GSTGroup."GST Place Of Supply"::" " then
                SalesLine."GST Place Of Supply" := GSTGroup."GST Place Of Supply";
        end;

        UpdateGSTJurisdictionType(SalesLine);
        GSTShiptoAddress.CheckUpdatePreviousLineGSTPlaceofSupply(SalesLine);
    end;

    local procedure GetCust2(
        CustNo: Code[20];
        var SalesHeader: Record "Sales Header";
        var Customer: Record customer)
    begin
        if not ((SalesHeader."Document Type" = "Document Type Enum"::Quote) and (CustNo = '')) then begin
            if CustNo <> Customer."No." then
                Customer.Get(CustNo);
        end else
            Clear(Customer);
    end;

    //Ship-to Address Validation
    local procedure State(var ShiptoAddress: Record "Ship-to Address")
    begin
        if ShiptoAddress.State = '' then
            ShiptoAddress."GST Registration No." := '';
    end;

    local procedure ShiptoAddGSTRegistrationNo(var ShiptoAddress: Record "Ship-to Address")
    var
        Customer: Record Customer;
    begin
        ShiptoAddress.TestField(State);
        ShiptoAddress.TestField(Address);
        Customer.Get(ShiptoAddress."Customer No.");
        if Customer."P.A.N. No." <> '' then
            GSTBaseValidation.CheckGSTRegistrationNo(ShiptoAddress.State, ShiptoAddress."GST Registration No.", Customer."P.A.N. No.")
        else
            if ShiptoAddress."GST Registration No." <> '' then
                Error(PANCustErr);
    end;

    //Customer Validations - Definition
    local procedure CustGSTRegistrationNo(var Customer: Record Customer)
    begin
        if Customer."GST Registration No." <> '' then
            if Customer."GST Registration Type" = "GST Registration Type"::GSTIN then begin
                Customer.TestField("State Code");
                if (Customer."P.A.N. No." <> '') and (Customer."P.A.N. Status" = Customer."P.A.N. Status"::" ") then
                    GSTBaseValidation.CheckGSTRegistrationNo(
                        Customer."State Code",
                        Customer."GST Registration No.",
                        Customer."P.A.N. No.")
                else
                    if Customer."GST Registration No." <> '' then
                        Error(PANErr);

                if Customer."GST Customer Type" = "GST Customer Type"::" " then
                    Customer."GST Customer Type" := "GST Customer Type"::Registered
                else
                    if not (Customer."GST Customer Type" in [
                        "GST Customer Type"::Registered,
                        "GST Customer Type"::Exempted,
                        "GST Customer Type"::"SEZ Development",
                        "GST Customer Type"::"SEZ Unit"])
                    then
                        Customer."GST Customer Type" := "GST Customer Type"::Registered;
            end else
                Customer."GST Customer Type" := "GST Customer Type"::" "
        else
            if Customer."ARN No." = '' then
                Customer."GST Customer Type" := "GST Customer Type"::" ";
    end;

    local procedure CustGSTRegistrationType(var Customer: Record Customer)
    begin
        if not (Customer."GST Customer Type" in ["GST Customer Type"::Registered, "GST Customer Type"::" "]) and
            not (Customer."GST Registration Type" = "GST Registration Type"::GSTIN) then
            Error(GSTCustRegErr);

        if (Customer."P.A.N. No." <> '') and (Customer."P.A.N. Status" = Customer."P.A.N. Status"::" ") then begin
            if (Customer."GST Registration Type" = "GST Registration Type"::GSTIN) then
                GSTBaseValidation.CheckGSTRegistrationNo(Customer."State Code", Customer."GST Registration No.", Customer."P.A.N. No.")
            else
                if (Customer."GST Registration Type" in ["GST Registration Type"::GID, "GST Registration Type"::UID]) then
                    GSTBaseValidation.CheckGSTRegistrationNoforGidandUid(Customer."State Code", Customer."GST Registration No.", Customer."P.A.N. No.")
        end
        else
            if Customer."GST Registration No." <> '' then
                Error(PANErr);
    end;

    local procedure CustGSTCustomerType(var Customer: Record Customer)
    begin
        if Customer."GST Customer Type" = "GST Customer Type"::" " then begin
            Customer."GST Registration No." := '';
            exit;
        end;
        Customer.TestField(Address);

        if not (Customer."GST Customer Type" in ["GST Customer Type"::Registered]) and not
           (Customer."GST Registration Type" = "GST Registration Type"::GSTIN)
        then
            Error(GSTCustRegErr);

        if Customer."GST Customer Type" in [
            "GST Customer Type"::Registered,
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::Exempted,
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit"]
        then
            if Customer."GST Registration No." = '' then
                if Customer."ARN No." = '' then
                    Error(GSTARNErr);

        if (Customer."GST Customer Type" in [
            "GST Customer Type"::Registered,
            "GST Customer Type"::Unregistered,
            "GST Customer Type"::Exempted,
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit"])
        then
            Customer.TestField("State Code")
        else
            if Customer."GST Customer Type" <> "GST Customer Type"::"Deemed Export" then
                Customer.TestField("State Code", '');

        if not (Customer."GST Customer Type" in [
            "GST Customer Type"::Registered,
            "GST Customer Type"::Exempted,
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit"])
        then begin
            Customer."GST Registration No." := '';
            Customer."ARN No." := '';
        end;

        if Customer."GST Registration No." <> '' then begin
            Customer.TestField("State Code");
            if Customer."GST Registration Type" = Customer."GST Registration Type"::GSTIN then
                if (Customer."P.A.N. No." <> '') and (Customer."P.A.N. Status" = Customer."P.A.N. Status"::" ") then
                    GSTBaseValidation.CheckGSTRegistrationNo(
                        Customer."State Code",
                        Customer."GST Registration No.",
                        Customer."P.A.N. No.")
                else
                    if Customer."GST Registration No." <> '' then
                        Error(PANErr);
        end;
    end;

    local procedure CustARNNo(var Customer: Record Customer)
    begin
        if (Customer."ARN No." = '') and (Customer."GST Registration No." = '') then
            if not (Customer."GST Customer Type" in [
                "GST Customer Type"::Export,
                "GST Customer Type"::Unregistered])
            then
                Customer."GST Customer Type" := "GST Customer Type"::" ";

        if Customer."GST Customer Type" in [
            "GST Customer Type"::Export,
            "GST Customer Type"::Unregistered]
        then
            Customer.TestField("ARN No.", '');
    end;

    local procedure CustPANNo(var Customer: Record Customer)
    begin
        if (Customer."GST Registration No." <> '') and
            (Customer."P.A.N. No." <> CopyStr(Customer."GST Registration No.", 3, 10))
        then
            Error(SamePANErr);

        CheckGSTRegBlankInRef(Customer);
    end;

    local procedure CheckGSTRegBlankInRef(var Customer: Record Customer)
    var
        ShipToAddress: Record "Ship-to Address";
    begin
        ShipToAddress.SetRange("Customer No.", Customer."No.");
        ShipToAddress.SetFilter("GST Registration No.", '<>%1', '');
        if ShipToAddress.FindSet() then
            repeat
                if Customer."P.A.N. No." <> CopyStr(ShipToAddress."GST Registration No.", 3, 10) then
                    Error(GSTPANErr, ShipToAddress.Code);
            until ShipToAddress.Next() = 0;
    end;

    local procedure CustStateCode(var Customer: Record Customer)
    begin
        Customer.TestField("GST Registration No.", '');
        if Customer."GST Customer Type" in [
            "GST Customer Type"::Registered,
            "GST Customer Type"::Exempted,
            "GST Customer Type"::Unregistered]
        then
            Customer.TestField("State Code")
        else
            if not (Customer."GST Customer Type" in [
                "GST Customer Type"::"Deemed Export",
                "GST Customer Type"::" ",
                "GST Customer Type"::"SEZ Development",
                "GST Customer Type"::"SEZ Unit"])
            then
                Customer.TestField("State Code", '');
    end;

    local procedure AssignInvoiceType(var SalesHeader: Record "Sales Header")
    begin
        case SalesHeader."GST Customer Type" of
            SalesHeader."GST Customer Type"::" ", SalesHeader."GST Customer Type"::Registered, SalesHeader."GST Customer Type"::Unregistered:
                SalesHeader."Invoice Type" := SalesHeader."Invoice Type"::Taxable;
            "GST Customer Type"::Export, "GST Customer Type"::"Deemed Export",
          SalesHeader."GST Customer Type"::"SEZ Development", SalesHeader."GST Customer Type"::"SEZ Unit":
                SalesHeader.Validate("Invoice Type", SalesHeader."Invoice Type"::Export);
            SalesHeader."GST Customer Type"::Exempted:
                SalesHeader."Invoice Type" := SalesHeader."Invoice Type"::"Bill Of Supply";
        end;
        case SalesHeader."GST-Ship to Customer Type" of
            SalesHeader."GST-Ship to Customer Type"::" ", SalesHeader."GST-Ship to Customer Type"::Registered, SalesHeader."GST-Ship to Customer Type"::Unregistered:
                SalesHeader."GST-Ship to Invoice Type" := SalesHeader."GST-Ship to Invoice Type"::Taxable;
            SalesHeader."GST-Ship to Customer Type"::Export, SalesHeader."GST-Ship to Customer Type"::"Deemed Export",
          SalesHeader."GST-Ship to Customer Type"::"SEZ Development", SalesHeader."GST-Ship to Customer Type"::"SEZ Unit":
                SalesHeader.Validate("GST-Ship to Invoice Type", SalesHeader."GST-Ship to Invoice Type"::Export);
            SalesHeader."GST-Ship to Customer Type"::Exempted:
                SalesHeader."GST-Ship to Invoice Type" := SalesHeader."GST-Ship to Invoice Type"::"Bill Of Supply";
        end;
    end;

    local procedure ExchangeAmtLCYToFCY(var SalesLine: Record "Sales Line")
    var
        CurrExChangeRate: Record "Currency Exchange Rate";
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesLine."GST Assessable Value (FCY)" :=
         CurrExChangeRate.ExchangeAmtLCYToFCY
        (SalesHeader."Posting Date", SalesHeader."Currency Code",
        SalesLine."GST Assessable Value (LCY)", SalesHeader."Currency Factor");
    end;

    local procedure CheckPostingDate(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
        if SalesLine.FindSet() then
            repeat
                TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
                TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
                if not TaxTransactionValue.IsEmpty() then
                    GSTBaseValidation.CheckGSTAccountingPeriod(SalesHeader."Posting Date", false);
            until SalesLine.Next() = 0;

    end;

    local procedure UpdateGSTJurisdictionType(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then begin
            if SalesLine."GST Place Of Supply" = SalesLine."GST Place Of Supply"::"Ship-to Address" then begin
                if SalesHeader."Ship-to Code" <> '' then
                    UpdateGSTJurisdictionShiptoAdddress(SalesLine);
                exit;
            end;

            if SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::Exempted then
                SalesLine.Exempted := true;

            if SalesHeader."POS Out Of India" then begin
                SalesLine."GST Jurisdiction Type" := SalesLine."GST Jurisdiction Type"::Interstate;
                exit;
            end;

            if SalesHeader."Ship-to Customer" <> '' then begin
                UpdateGSTJurisdictionShiptoCustomer(SalesLine);
                exit;
            end;

            if (SalesHeader."Invoice Type" = SalesHeader."Invoice Type"::Export) then begin
                SalesLine."GST Jurisdiction Type" := SalesLine."GST Jurisdiction Type"::Interstate;
                exit;
            end;

            if SalesHeader."Location State Code" <> SalesHeader."State" then
                SalesLine."GST Jurisdiction Type" := SalesLine."GST Jurisdiction Type"::Interstate
            else
                if SalesHeader."Location State Code" = SalesHeader."State" then
                    SalesLine."GST Jurisdiction Type" := SalesLine."GST Jurisdiction Type"::Intrastate
                else
                    if (SalesHeader."Location State Code" <> '') and (SalesHeader."State" = '') then
                        SalesLine."GST Jurisdiction Type" := SalesLine."GST Jurisdiction Type"::Interstate;
        end;
    end;

    procedure CallTaxEngineOnSalesHeader(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        SalesLine.LoadFields("Document Type", "Document No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);
            until SalesLine.Next() = 0;
    end;

    local procedure UpdateGSTJurisdictionShiptoAdddress(var SalesLine: Record "Sales Line")
    var
        ShiptoAddress: Record "Ship-to Address";
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            if ShiptoAddress.Get(SalesHeader."Bill-to Customer No.", SalesHeader."Ship-to Code") then
                case SalesHeader."GST-Ship to Invoice Type" of
                    SalesHeader."GST-Ship to Invoice Type"::Taxable,
                    SalesHeader."GST-Ship to Invoice Type"::"Bill of Supply",
                    SalesHeader."GST-Ship to Invoice Type"::"Debit Note",
                    SalesHeader."GST-Ship to Invoice Type"::"Non-GST",
                    SalesHeader."GST-Ship to Invoice Type"::Supplementary:
                        if SalesHeader."Location State Code" <> ShiptoAddress."State" then
                            SalesLine."GST Jurisdiction Type" := SalesLine."GST Jurisdiction Type"::Interstate
                        else
                            if SalesHeader."Location State Code" = ShiptoAddress."State" then
                                SalesLine."GST Jurisdiction Type" := SalesLine."GST Jurisdiction Type"::Intrastate;

                    SalesHeader."GST-Ship to Invoice Type"::Export:
                        SalesLine."GST Jurisdiction Type" := SalesLine."GST Jurisdiction Type"::Interstate;
                end;
    end;

    local procedure ShiptoCustomer(Var SalesHeader: Record "Sales Header"; var xSalesHeader: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
    begin
        SalesHeader.TestField(Status, SalesHeader.Status::Open);
        CheckShipToCustomer(SalesHeader);

        if SalesHeader."Ship-to Customer" <> '' then begin
            SalesHeader.TestField("GST Customer Type", SalesHeader."GST Customer Type"::Export);
            SalesHeader."Ship-to Code" := '';
        end else
            if SalesHeader."Ship-to Code" <> '' then
                SalesHeader.Validate("Ship-to Code");

        SalesHeader.TestField("POS Out Of India", FALSE);
        SalesHeader.TestField("Applies-to Doc. Type", SalesHeader."Applies-to Doc. Type"::" ");
        SalesHeader.TestField("Applies-to Doc. No.", '');
        ReferenceInvoiceNoValidation(SalesHeader, xSalesHeader, CurrFieldNo);

        if SalesHeader."Ship-to Customer" <> '' then begin
            Customer.Get(SalesHeader."Ship-to Customer");
            Customer.TestField("GST Customer Type", Customer."GST Customer Type"::Registered);
            SalesHeader."Ship-to Name" := Customer.Name;
            SalesHeader."Ship-to Name 2" := Customer."Name 2";
            SalesHeader."Ship-to Address" := Customer.Address;
            SalesHeader."Ship-to Address 2" := Customer."Address 2";
            SalesHeader."Ship-to City" := Customer.City;
            SalesHeader."GST Ship-to State Code" := Customer."State Code";
            SalesHeader."Ship-to Contact" := Customer.Contact;
            SalesHeader."Ship-to Post Code" := Customer."Post Code";
            SalesHeader."Ship-to County" := Customer.County;
            SalesHeader."Ship-to Country/Region Code" := Customer."Country/Region Code";
            SalesHeader."Ship-to GST Reg. No." := Customer."GST Registration No.";
            if SalesHeader."Ship-to Customer" <> '' then
                Customer.TestField("GST Customer Type");

            SalesHeader."Ship-to GST Customer Type" := Customer."GST Customer Type";
            UpdateInvoiceType(SalesHeader);
        end;
    end;

    local procedure CheckShipToCustomer(Var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Ship-to Customer" = '' then
            exit;

        if SalesHeader."Sell-to Customer No." <> SalesHeader."Bill-to Customer No." then
            Error(SellToBillToCustomerErr, SalesHeader."Document Type", SalesHeader."No.");
    end;

    local procedure UpdateBeforeShiptoFields(Var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."GST Ship-to State Code" := '';
        SalesHeader."Ship-to GST Customer Type" := SalesHeader."Ship-to GST Customer Type"::" ";
        SalesHeader."Ship-to Customer" := '';
        SalesHeader."Ship-to GST Reg. No." := '';
        CheckShipToCode(SalesHeader);
    end;

    local procedure CheckShipToCode(Var SalesHeader: Record "Sales Header")
    var
        GSTDependencyType: Enum "GST Dependency Type";
    begin
        if (SalesHeader."Ship-to Code" = '') or (not IsGSTPlaceOfSupplyExist(SalesHeader."Document Type", SalesHeader."No.", GSTDependencyType::"Ship-to Address")) then
            exit;

        if SalesHeader."Sell-to Customer No." <> SalesHeader."Bill-to Customer No." then
            error(ShipToCodeErr);
    end;

    local procedure IsGSTPlaceOfSupplyExist(DocType: enum "Sales Document Type"; DocNo: Code[20];
                                                         GSTDependencyType: Enum "GST Dependency Type"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", DocType);
        SalesLine.SetRange("Document No.", DocNo);
        SalesLine.SetRange("GST Place of Supply", GSTDependencyType);
        exit(not SalesLine.IsEmpty);
    end;

    local procedure UpdateGSTJurisdictionShiptoCustomer(Var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
    begin
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            if Customer.Get(SalesHeader."Ship-to Customer") then
                if SalesHeader."Location State Code" <> Customer."State Code" then
                    SalesLine."GST Jurisdiction Type" := SalesLine."GST Jurisdiction Type"::Interstate
                else
                    if SalesHeader."Location State Code" = Customer."State Code" then
                        SalesLine."GST Jurisdiction Type" := SalesLine."GST Jurisdiction Type"::Intrastate
    end;

    procedure SetHSNSACEditable(SalesLine: Record "Sales Line"; var IsEditable: Boolean)
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        IsEditable := false;
        OnBeforeSalesLineHSNSACEditable(SalesLine, IsEditable, IsHandled);
        if IsHandled then
            exit;

        case
            SalesLine.Type of
            SalesLine.Type::Item:
                if Item.Get(SalesLine."No.") then
                    if Item.Type in [Item.Type::Inventory, Item.Type::"Non-Inventory"] then
                        IsEditable := false
                    else
                        IsEditable := true;
            SalesLine.Type::"Fixed Asset":
                IsEditable := false;
            else
                IsEditable := true;
        end;
    end;

    local procedure UpdateStateCode(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        GSTShiptoAddress: Codeunit "GST Ship To Address";
    begin
        Case SalesLine."GST Place of Supply" of
            SalesLine."GST Place Of Supply"::"Bill-to Address":
                GSTShiptoAddress.UpdateBilltiAddressState(SalesHeader);
            SalesLine."GST Place Of Supply"::"Ship-to Address":
                GSTShiptoAddress.UpdateShiptoAddressState(SalesHeader);
            SalesLine."GST Place Of Supply"::"Location Address":
                GSTShiptoAddress.UpdateLocationAddressState(SalesHeader);
        end;
        SalesHeader.Modify();
    end;

    local Procedure CheckGSTPlaceOfSupply(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("GST Place of Supply", SalesLine."GST Place of Supply"::"Ship-to Address");
        if not SalesLine.IsEmpty() then
            exit(true);

        exit(false);
    end;

    local procedure UpdateShiptoCodeCreditDocument(var SalesHeader: Record "Sales Header"; CopyShipToAddres: Boolean)
    var
        ShipToAddr: Record "Ship-to Address";
    begin
        if CopyShipToAddres then
            exit;

        if SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::" " then
            exit;

        if SalesHeader."Document Type" In [SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order"] then
            if ShipToAddr.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code") then begin
                if not (SalesHeader."GST Customer Type" In [
                    SalesHeader."GST Customer Type"::Export,
                    SalesHeader."GST Customer Type"::"Deemed Export",
                    SalesHeader."GST Customer Type"::"SEZ Development",
                    SalesHeader."GST Customer Type"::"SEZ Unit"])
                then begin
                    ShipToAddr.TestField(State);
                    SalesHeader."GST Ship-to State Code" := ShipToAddr.State;
                end;

                if not (SalesHeader."GST Customer Type" In ["GST Customer Type"::Export]) then begin
                    ShipToAddr.TestField(State);
                    SalesHeader."Ship-to GST Reg. No." := ShipToAddr."GST Registration No.";
                    SalesHeader."Ship-to GST Customer Type" := ShipToAddr."Ship-to GST Customer Type";
                    SalesHeader."GST-Ship to Customer Type" := ShipToAddr."Ship-to GST Customer Type";
                end;
                AssignInvoiceType(SalesHeader);
            end;
    end;

    local procedure CheckExemptedInvoiceTypeSales(SalesHeader: Record "Sales Header")
    begin
        if not CheckAllLinesExemptedSales(SalesHeader) and (SalesHeader."Invoice Type" <> SalesHeader."Invoice Type"::"Bill of Supply") then
            Error(ExemptedLinesErr);

        if CheckAllLinesExemptedSales(SalesHeader) and (SalesHeader."Invoice Type" = SalesHeader."Invoice Type"::"Bill of Supply") then
            Error(NonExemptedLinesErr);
    end;


    local procedure FilterTaxTransactionValue(
        TaxTypeSetupCode: Code[10];
        RecordId: RecordId): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Type", TaxTypeSetupCode);
        TaxTransactionValue.SetRange("Tax Record ID", RecordId);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            exit(true);
    end;

    local procedure IsGSTApplicable(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        GSTSetup: Record "GST Setup";
        SalesInvLine: Record "Sales Invoice Line";
        TaxTransactionFound: Boolean;
    begin
        if not GSTSetup.Get() then
            exit;

        SalesInvLine.Reset();
        SalesInvLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvLine.SetFilter(Type, '<>%1', SalesInvLine.Type::" ");
        if SalesInvLine.FindSet() then
            repeat
                if SalesInvLine."System-Created Entry" = false then begin
                    GSTSetup.TestField("GST Tax Type");
                    TaxTransactionFound := FilterTaxTransactionValue(GSTSetup."GST Tax Type", SalesInvLine.RecordId);
                end;
            until SalesInvLine.Next() = 0
        else
            exit(false);

        exit(TaxTransactionFound);
    end;

    procedure ValidateGSTWithoutPaymentOfDutyOnPost(var Rec: Record "Sales Header")
    begin
        if Rec."GST Customer Type" = Rec."GST Customer Type"::Registered then
            if Rec."GST-Ship to Customer Type" In [Rec."GST-Ship to Customer Type"::"SEZ Unit",
                                                     Rec."GST-Ship to Customer Type"::"SEZ Development",
                                                     Rec."GST-Ship to Customer Type"::"Deemed Export"] then
                if (Rec."GST Without Payment of Duty" <> true) and (Rec."Post GST to Customer" <> true) then
                    Error(PostingErr);
    end;

    local procedure CreateReferenceInvoiceNo(SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
    begin
        if not IsGSTApplicable(SalesInvoiceHeader) then
            exit;

        ReferenceInvoiceNo.Init();
        ReferenceInvoiceNo."Document Type" := ReferenceInvoiceNo."Document Type"::"Credit Memo";
        ReferenceInvoiceNo."Document No." := SalesHeader."No.";
        ReferenceInvoiceNo."Source Type" := ReferenceInvoiceNo."Source Type"::Vendor;
        ReferenceInvoiceNo."Source No." := SalesHeader."Bill-to Customer No.";
        ReferenceInvoiceNo."Reference Invoice Nos." := SalesInvoiceHeader."No.";
        ReferenceInvoiceNo.Verified := true;
        ReferenceInvoiceNo.Insert();
    end;

    local procedure ReferenceInvoiceNoValidation(RecVar: Variant; xRecVar: Variant; FieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        IsHandled: Boolean;
    begin
        RecRef.GetTable(RecVar);
        xRecRef.GetTable(xRecVar);

        if (xRecRef.Field(FieldNo).Value <> RecRef.Field(FieldNo).Value) and (Format(xRecRef.Field(FieldNo).Value) <> '') then begin
            case RecRef.Number of
                Database::"Sales Line":
                    begin
                        RecRef.SetTable(SalesLine);
                        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
                    end;
                Database::"Sales Header":
                    RecRef.SetTable(SalesHeader);
                else begin
                    OnBeforeValidateReferenceInvoiceNo(RecVar, xRecVar, FieldNo, IsHandled);
                    if not IsHandled then
                        Error('Record is not handled for Reference Invoice No.');
                end;
            end;
            ReferenceInvoiceNoValidation(SalesHeader);
        end
    end;

    local procedure CheckHeaderLocation(SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        IsHandled: Boolean;
    begin
        OnBeforeCheckHeaderLocation(SalesLine, IsHandled);
        if IsHandled then
            exit;

        if not SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            exit;

        if SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::" " then
            exit;

        SalesLine.TestField("Location Code", SalesHeader."Location Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", 'OnAfterCreateCorrectiveSalesCrMemo', '', false, false)]
    local procedure UpdateReferenceInvoiceNo(SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header"; var CancellingOnly: Boolean)
    begin
        CreateReferenceInvoiceNo(SalesInvoiceHeader, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Sales Validation", 'OnBeforeSalesLineHSNSACEditable', '', false, false)]
    local procedure SetGstHsnEditableforAllType(var IsEditable: Boolean; var IsHandled: Boolean)
    begin
        IsEditable := true;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterGetLineAmountToHandle', '', false, false)]
    local procedure OnAfterGetLineAmountToHandle(SalesLine: Record "Sales Line"; QtyToHandle: Decimal; var LineDiscAmount: Decimal)
    var
        Currency: Record Currency;
    begin
        if not (SalesLine."Price Inclusive of Tax") then
            exit;

        if (SalesLine."Line Discount %" = 0) then
            exit;

        if QtyToHandle = SalesLine.Quantity then
            exit;

        GetCurrency(SalesLine, Currency);
        LineDiscAmount := Round(SalesLine."Line Discount Amount" * QtyToHandle / SalesLine.Quantity, Currency."Amount Rounding Precision");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Create-Invoice", 'OnBeforeModifySalesHeader', '', false, false)]
    local procedure UpdateLocationOnSalesHeader(var SalesHeader: Record "Sales Header"; JobPlanningLine: Record "Job Planning Line")
    begin
        SalesHeader.Validate("Location Code", JobPlanningLine."Location Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnPostedSalesInvoiceFullyOpen', '', false, false)]
    local procedure OnPostedSalesInvoiceFullyOpen(var SalesInvoiceHeader: Record "Sales Invoice Header"; var FullyOpen: Boolean; var IsHandled: Boolean)
    var
        GSTStatistics: Codeunit "GST Statistics";
        GSTAmount: Decimal;
    begin
        IsHandled := true;
        GSTStatistics.GetStatisticsPostedSalesInvAmount(SalesInvoiceHeader, GSTAmount);
        SalesInvoiceHeader.CalcFields("Amount Including VAT", "Remaining Amount");
        FullyOpen := (SalesInvoiceHeader."Amount Including VAT" + GSTAmount) = SalesInvoiceHeader."Remaining Amount";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesLineHSNSACEditable(SalesLine: Record "Sales Line"; var IsEditable: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateReferenceInvoiceNo(var RecVar: Variant; var xRecVar: Variant; var FieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckHeaderLocation(SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateShipToCodeForUpdateShipToAddress(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShipToAddrfields(var SalesHeader: Record "Sales Header"; ShipToAddress: Record "Ship-to Address"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShipToAddrfields(var SalesHeader: Record "Sales Header"; ShipToAddress: Record "Ship-to Address")
    begin
    end;
}
