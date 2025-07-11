// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;

codeunit 18244 "GST Journal Line Validations"
{
    var
        CustGSTTypeErr: Label ' You can select POS Out Of India field on header only if GST Customer/Vednor Type is Registered, Unregistered or Deemed Export.';
        VendGSTTypeErr: Label 'You can select POS Out Of India field on header only if GST Vendor Type is Registered.';
        POSLOCDiffErr: Label 'You can select POS Out Of India field on header only if Customer / Vendor State Code and Location State Code are same.';
        LocationErr: Label 'Bill To-Location and Location code must not be same.';
        CurrencyCodePOSErr: Label 'Currency code should be blank for POS as Vendor State, current value is %1.', Comment = '%1 = Currency Code';
        ProvisionalEntryAppliedErr: Label 'Provisional Entry is already applied against Document No. %1, you must unapply the provisional entry first.', Comment = '%1 = Document No.';
        POSasAccountTypeErr: Label 'POS as Vendor State is only applicable for Purchase Document Type where Invoice or Credit Memo.';
        GSTRelevantInfoErr: Label ' You cannot change any GST Relevant Information of Refund Doument after Payment Application.';
        ReferenceInvoiceErr: Label 'Document is attached with Reference Invoice No. Please delete attached Reference Invoice No.';
        GSTGroupReverseChargeErr: Label 'GST Group Code %1 with Reverse Charge cannot be selected for Customer.', Comment = '%1 GST Group Code';
        BlankShiptoCodeErr: Label 'You must select Ship-to Code as "GST Place of Supply" is "Ship-to Address" on GST Group.';
        ShiptoGSTARNErr: Label 'Either GST Registration No. or ARN No. should have a value in Ship To Code.';
        FinChargeMemoAppliestoDocTypeErr: Label 'You cannot select GST on Advance Payment if Applies to Doc Type is Fin Charge Memo.';
        PlaceOfSupplyErr: Label 'You cannot select Blank Place of Supply for Template %1 and Batch %2 for Line %3.', Comment = '%1 =Journal Template Name , %2 = Journal Batch Name , %3 =Line No.';
        ExemptedGoodsErr: Label 'GST on Advance Payment is Exempted for Goods.';
        RCMExcemptErr: Label 'Advance Payment against Unregistered Vendor is not allowed for exempted period,start date %1 to end date %2.', Comment = '%1 = RCM Exempt Start Date (Unreg) , %2 = RCM Exempt end Date (Unreg)';
        CompGSTRegNoARNNoErr: Label 'Company Information must have either GST Registration No or ARN No.';
        LocGSTRegNoARNNoErr: Label 'Location must have either GST Registration No or Location ARN No.';
        CompanyGSTRegNoErr: Label 'Please specify GST Registration No in Company Information.';
        LocationCodeErr: Label 'Please specify the Location Code or Location GST Registration No for the selected document.';
        ReferencenotxtErr: Label 'Reference Invoice No is required where Invoice Type is Debit note and Supplementary.';
        InvoiceTypeErr: Label 'You can not select the Sales Invoice Type %1 for GST Customer Type %2.', Comment = '%1 = Sales Invoice Type , %2 = GST Customer Type';
        POSasVendorErr: Label 'POS as Vendor State is only applicable for Registered vendor, current vendor is %1.', Comment = '%1 = GST Vendor Type';
        GSTPlaceOfSuppErr: Label 'You can not select POS Out Of India field on header if GST Place of Supply is Location Address.';
        POSLineErr: Label 'Please select POS Out Of India field only on header line.';
        POSasVendErr: Label 'POS as Vendor State is only applicable for Registered Vendor.';
        VendGSTARNErr: Label 'Either Vendor GST Registration No. or ARN No. in Vendor should have a value.';
        OrderAddGSTARNErr: Label 'Either GST Registration No. or ARN No. should have a value in Order Address.';

    procedure OnValidateGSTTDSTCS(var GenJournalLine: Record "Gen. Journal Line")
    var
        GSTGroup: Record "GST Group";
        CompanyInformation: Record "Company Information";
        Location: Record Location;
    begin
        if GenJournalLine."GST TDS/GST TCS" = GenJournalLine."GST TDS/GST TCS"::" " then
            exit;

        GenJournalLine.TestField("TDS Certificate Receivable", false);
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then begin
            GenJournalLine.TestField("GST TCS State Code");
            if GSTGroup.Get(GenJournalLine."GST Group Code") then
                GSTGroup.TestField("Reverse Charge", false);
        end;

        GenJournalLine.TestField("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.TestField("Location State Code");
        if not (GenJournalLine."Account Type" in [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor]) then
            GenJournalLine.TestField("GST TDS/GST TCS", GenJournalLine."GST TDS/GST TCS"::" ");

        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer then
            GenJournalLine.TestField("GST Customer Type", "GST Customer Type"::Registered);

        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then
            GenJournalLine.TestField("GST Vendor Type", "GST Vendor Type"::Registered);

        CompanyInformation.Get();
        if Location.Get(GenJournalLine."Location Code") then begin
            if (Location."GST Registration No." = '') and (Location."Location ARN No." = '') then
                Error(LocGSTRegNoARNNoErr);

            if (CompanyInformation."ARN No." <> '') and (CompanyInformation."GST Registration No." = '') then
                if (Location."Location ARN No." = '') or ((Location."Location ARN No." <> '') and (Location."GST Registration No." <> '')) then
                    Error(CompanyGSTRegNoErr);
        end;

        if GenJournalLine."GST TDS/GST TCS" in [GenJournalLine."GST TDS/GST TCS"::TCS, GenJournalLine."GST TDS/GST TCS"::TDS] then
            GenJournalLine.TestField("GST TDS/TCS Base Amount");

        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Customer:
                if GenJournalLine."Location State Code" <> GenJournalLine."GST Bill-to/BuyFrom State Code" then
                    GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Interstate
                else
                    GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Intrastate;
            GenJournalLine."Account Type"::Vendor:
                if GenJournalLine."Location State Code" <> GenJournalLine."GST TCS State Code" then
                    GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Interstate
                else
                    GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Intrastate;
        end;
    end;

    procedure POSOutOfIndia(var GenJournalLine3: Record "Gen. Journal Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
        ConfigType: Enum "Party Type";
        GSTVendorType: Enum "GST Vendor Type";
        GSTCustType: Enum "GST Customer Type";
    begin
        GenJournalLine3.TestField("POS as Vendor State", false);
        if GenJournalLine3."POS Out Of India" then begin
            if not (GenJournalLine3."Account Type" in [GenJournalLine3."Account Type"::Customer, GenJournalLine3."Account Type"::Vendor]) then
                Error(POSLineErr);

            if GenJournalLine3."Account Type" = GenJournalLine3."Account Type"::Customer then begin
                if not (GenJournalLine3."GST Place of Supply" in [GenJournalLine3."GST Place of Supply"::" ", GenJournalLine3."GST Place of Supply"::"Location Address"]) then
                    Error(GSTPlaceOfSuppErr);

                if GenJournalLine3."GST Place of Supply" = GenJournalLine3."GST Place of Supply"::" " then
                    if GetTotalDoclineNos(GenJournalLine3) > 1 then begin
                        GenJournalLine2.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Document No.", "Line No.");
                        GenJournalLine2.SetRange("Journal Template Name", GenJournalLine3."Journal Template Name");
                        GenJournalLine2.SetRange("Journal Batch Name", GenJournalLine3."Journal Batch Name");
                        GenJournalLine2.SetRange("Document No.", GenJournalLine3."Document No.");
                        if GenJournalLine2.FindFirst() then
                            GenJournalLine2.SetFilter("GST Customer Type", '=%1', "GST Customer Type"::" ");
                        if GenJournalLine2.Count() <> 0 then
                            if GenJournalLine2.FindFirst() then begin
                                if GenJournalLine2."GST Place of Supply" = GenJournalLine2."GST Place of Supply"::"Location Address" then
                                    Error(GSTPlaceOfSuppErr);
                                GenJournalLine := GenJournalLine3;
                                GenJournalLine."GST Place of Supply" := GenJournalLine2."GST Place of Supply";
                                VerifyPOSOutOfIndia(
                                  ConfigType::Customer, GenJournalLine3."Location State Code", GetPlaceOfSupply(GenJournalLine), GSTVendorType::" ", GenJournalLine3."GST Customer Type");
                            end;
                    end;
                if GenJournalLine3."GST Place of Supply" <> GenJournalLine3."GST Place of Supply"::"Location Address" then
                    VerifyPOSOutOfIndia(
                      ConfigType::Customer,
                      GenJournalLine3."Location State Code",
                      GetPlaceOfSupply(GenJournalLine3),
                      GSTVendorType::" ",
                      GenJournalLine3."GST Customer Type");
            end;

            if GenJournalLine3."Account Type" = GenJournalLine3."Account Type"::Vendor then
                if GenJournalLine3."Order Address Code" <> '' then
                    VerifyPOSOutOfIndia(
                      ConfigType::Vendor, GenJournalLine3."Location State Code", GenJournalLine3."Order Address State Code", GenJournalLine3."GST Vendor Type", GSTCustType::" ")
                else
                    VerifyPOSOutOfIndia(
                      ConfigType::Vendor, GenJournalLine3."Location State Code", GenJournalLine3."GST Bill-to/BuyFrom State Code", GenJournalLine3."GST Vendor Type", GSTCustType::" ");
        end;
        UpdateGSTJurisdictionType(GenJournalLine3);
        CheckReferenceInvoiceNo(GenJournalLine3);
    end;

    procedure OrderAddressCode(var GenJournalLine: Record "Gen. Journal Line")
    var
        OrderAddress: Record "Order Address";
        Vendor: Record Vendor;
    begin
        if GenJournalLine."Order Address Code" <> '' then begin
            OrderAddress.Get(GenJournalLine."Account No.", GenJournalLine."Order Address Code");
            if GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::"Credit Memo"] then begin
                UpdateOrderAddressFields(GenJournalLine, OrderAddress);

                if GenJournalLine."GST Vendor Type" in ["GST Vendor Type"::Registered, "GST Vendor Type"::Composite,
                                                       "GST Vendor Type"::SEZ, "GST Vendor Type"::Exempted] then
                    if OrderAddress.Get(GenJournalLine."Account No.", GenJournalLine."Order Address Code") then
                        if (OrderAddress."GST Registration No." = '') and (OrderAddress."ARN No." = '') then
                            Error(OrderAddGSTARNErr);

                if GenJournalLine."GST Vendor Type" in ["GST Vendor Type"::Registered, "GST Vendor Type"::Composite, "GST Vendor Type"::SEZ, "GST Vendor Type"::Exempted] then
                    if GenJournalLine."Vendor GST Reg. No." = '' then
                        if Vendor.Get(GenJournalLine."Account No.") and (Vendor."ARN No." = '') then
                            Error(VendGSTARNErr);
            end;
        end else begin
            GenJournalLine."Order Address State Code" := '';
            GenJournalLine."Order Address GST Reg. No." := '';
            GenJournalLine.Modify();
        end;
    end;

    local procedure UpdateOrderAddressFields(var GenJournalLine: Record "Gen. Journal Line"; OrderAddress: Record "Order Address")
    begin
        if ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Customer)) then
            exit;

        GenJournalLine."Order Address State Code" := OrderAddress.State;
        GenJournalLine."Order Address GST Reg. No." := OrderAddress."GST Registration No.";
        UpdateGSTJurisdictionType(GenJournalLine);
        GenJournalLine.Modify();
    end;

    procedure POSasVendorState(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if not (GenJournalLine."Document Type" in ["Document Type Enum"::Invoice, "Document Type Enum"::"Credit Memo"]) then
            Error(POSasAccountTypeErr);

        if (GenJournalLine."GST Customer Type" <> "GST Customer Type"::" ") or (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::Vendor) then
            Error(POSasVendErr);

        if not (GenJournalLine."GST Vendor Type" = "GST Vendor Type"::Registered) then
            Error(POSasVendorErr, GenJournalLine."GST Vendor Type");

        if GenJournalLine."Currency Code" <> '' then
            Error(CurrencyCodePOSErr, GenJournalLine."Currency Code");

        GenJournalLine.TestField("POS Out Of India", false);
        CheckBilltoLocation(GenJournalLine);
    end;

    procedure GSTAssessableValue(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Document Type" in ["Document Type Enum"::"Credit Memo"] then
            GenJournalLine.TestField("GST Assessable Value", 0);

        if (GenJournalLine."GST Group Type" <> "GST Group Type"::Goods) then
            GenJournalLine.TestField("GST Assessable Value", 0);

        GenJournalLine."GST Assessable Value" := Abs(GenJournalLine."GST Assessable Value");
    end;

    procedure CustomDutyAmount(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Document Type" in ["Document Type Enum"::"Credit Memo"] then
            GenJournalLine.TestField("Custom Duty Amount", 0);

        if (GenJournalLine."GST Group Type" <> "GST Group Type"::Goods) then
            GenJournalLine.TestField("Custom Duty Amount", 0);

        GenJournalLine."Custom Duty Amount" := Abs(GenJournalLine."Custom Duty Amount");
    end;

    procedure SalesInvoiceType(var GenJournalLine: Record "Gen. Journal Line")
    var
        GenJournalLine2: Record "Gen. Journal Line";
        PostingNoSeries: Record "Posting No. Series";
        TotalNoOfLines: Integer;
        Record: Variant;
    begin
        GenJournalLine.TestField("GST Vendor Type", "GST Vendor Type"::" ");
        TotalNoOfLines := GetTotalDoclineNos(GenJournalLine);
        if TotalNoOfLines > 1 then begin
            GenJournalLine2.SetRange("Document No.", GenJournalLine."Document No.");
            GenJournalLine2.SetFilter("GST Customer Type", '<>%1', GenJournalLine2."GST Customer Type"::" ");
            if (GenJournalLine2.Count() = 1) and GenJournalLine2.FindFirst() then
                if GenJournalLine2."GST Customer Type" <> GenJournalLine2."GST Customer Type"::Exempted then
                    if not CheckAllLinesExemptedJournal(GenJournalLine2) then
                        GenJournalLine.TestField("Sales Invoice Type", "Sales Invoice Type"::"Bill of Supply")
                    else
                        CheckInvoiceTypeWithExempted(false, GenJournalLine);
        end else
            if TotalNoOfLines = 1 then
                CheckInvoiceTypeWithExempted(GenJournalLine.Exempted, GenJournalLine);
        //Get posting No Seried form posting no. series table
        Record := GenJournalLine;
        GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::Sales;
        postingnoseries.GetPostingNoSeriesCode(Record);

        if (GenJournalLine."Document Type" = "Document Type Enum"::Invoice) and (GenJournalLine."Reference Invoice No." <> '') then
            if not (GenJournalLine."Sales Invoice Type" in ["Sales Invoice Type"::"Debit note", "Sales Invoice Type"::Supplementary]) then
                Error(ReferencenotxtErr);
    end;

    procedure GSTonAdvancePayment(var GenJournalLine: Record "Gen. Journal Line")
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CompanyInformation: Record "Company Information";
        Location: Record location;
    begin
        if GenJournalLine."Tax Type" <> "Tax Type"::" " then
            GenJournalLine.FieldError("Tax Type");
        GenJournalLine.TestField("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.TestField("Work Tax Nature Of Deduction", '');
        if not (GenJournalLine."Account Type" in [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor]) then
            GenJournalLine.TestField("GST on Advance Payment", false);
        if GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::"Finance Charge Memo" then
            Error(FinChargeMemoAppliestoDocTypeErr);
        if GenJournalLine."Amount Excl. GST" <> 0 then
            GenJournalLine.TestField("GST on Advance Payment", false);
        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Customer:
                begin
                    if not (GenJournalLine."GST Customer Type" in ["GST Customer Type"::Registered, "GST Customer Type"::Unregistered]) then begin
                        GenJournalLine.TestField("GST on Advance Payment", false);
                        GenJournalLine.TestField("Currency Code", '');
                    end;
                    GenJournalLine.TestField("GST Input Service Distribution", false);
                    if GenJournalLine."GST Place of Supply" = GenJournalLine."GST Place of Supply"::" " then
                        Error(PlaceOfSupplyErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");
                    if GenJournalLine."GST Group Type" = "GST Group Type"::Goods then
                        Error(ExemptedGoodsErr);
                end;
            GenJournalLine."Account Type"::Vendor:
                begin
                    GenJournalLine.TestField("GST Input Service Distribution", false);
                    if not GenJournalLine."GST Reverse Charge" then
                        GenJournalLine.TestField("GST on Advance Payment", false);

                    if CheckRCMExemptDate(GenJournalLine) then begin
                        PurchasesPayablesSetup.Get();
                        Error(RCMExcemptErr, PurchasesPayablesSetup."RCM Exempt Start Date (Unreg)", PurchasesPayablesSetup."RCM Exempt end Date (Unreg)");
                    end;

                    if (GenJournalLine."GST Vendor Type" = "GST Vendor Type"::Import) or (GenJournalLine."GST Vendor Type" = "GST Vendor Type"::SEZ) then
                        GenJournalLine.TestField("GST Group Type", "GST Group Type"::Service);

                    if GenJournalLine."GST Group Type" = "GST Group Type"::Goods then
                        Error(ExemptedGoodsErr);
                end;
        end;

        if (GenJournalLine."GST Place of Supply" = GenJournalLine."GST Place of Supply"::"Ship-to Address") and (GenJournalLine."Ship-to Code" = '') then
            Error(BlankShiptoCodeErr);

        CompanyInformation.Get();
        if (CompanyInformation."GST Registration No." = '') and (CompanyInformation."ARN No." = '') then
            Error(CompGSTRegNoARNNoErr);

        if (GenJournalLine."Location Code" = '') and (GenJournalLine."Location GST Reg. No." = '') then
            Error(LocationCodeErr);

        if Location.Get(GenJournalLine."Location Code") then begin
            if (Location."GST Registration No." = '') and (Location."Location ARN No." = '') then
                Error(LocGSTRegNoARNNoErr);

            if (CompanyInformation."ARN No." <> '') and (CompanyInformation."GST Registration No." = '') then
                if (Location."Location ARN No." = '') or ((Location."Location ARN No." <> '') and (Location."GST Registration No." <> '')) then
                    Error(CompanyGSTRegNoErr);
        end;

        GenJournalLine.TestField("Location State Code");
        UpdateGSTJurisdictionType(GenJournalLine);
    end;

    procedure GSTPlaceofsuppply(var GenJournalLine: Record "Gen. Journal Line"; var XGenJournalLine: Record "Gen. Journal Line")
    begin
        if (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Refund) and (GenJournalLine."Applies-to Doc. No." <> '') then
            if XGenJournalLine."GST Place of Supply" <> GenJournalLine."GST Place of Supply" then
                Error(GSTRelevantInfoErr);

        if GenJournalLine."GST Place of Supply" <> GenJournalLine."GST Place of Supply"::"Ship-to Address" then begin
            GenJournalLine."Ship-to Code" := '';
            GenJournalLine."Ship-to GST Reg. No." := '';
        end;

        if XGenJournalLine."GST Place of Supply" <> XGenJournalLine."GST Place of Supply"::" " then
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Fixed Asset") and GenJournalLine."FA Reclassification Entry" and
               (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Acquisition Cost")
            then
                if XGenJournalLine."GST Place of Supply" <> GenJournalLine."GST Place of Supply" then
                    GenJournalLine.TestField("GST Place of Supply", XGenJournalLine."GST Place of Supply");

        CheckShipCode(GenJournalLine);
        if GenJournalLine."GST Transaction Type" = "GST Transaction Type"::Sale then
            GenJournalLine.TestField("POS Out Of India", false);
    end;

    procedure GSTGroupCode(var GenJournalLine: Record "Gen. Journal Line"; var XGenJournalLine: Record "Gen. Journal Line")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GSTGroup: Record "GST Group";
        GenJournalLine2: Record "Gen. Journal Line";
        PostingNoSeries: Record "Posting No. Series";
        TransactionType: Enum "JournalLine TransactionType";
        Record: Variant;
        GstPlaceOfSupply: Enum "GST Dependency Type";
        GSTPOS: Text;
    begin
        GenJournalLine."GST TDS/GST TCS" := GenJournalLine."GST TDS/GST TCS"::" ";
        GenJournalLine."Exclude GST in TCS Base" := false;
        GenJournalLine."GST On Assessable Value" := false;
        GenJournalLine."GST Assessable Value Sale(LCY)" := 0;
        if GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Refund] then
            GenJournalLine."GST Reverse Charge" := GenJournalLine."GST Vendor Type" in ["GST Vendor Type"::Import];

        GenJournalLine."RCM Exempt" := CheckRCMExemptDate(GenJournalLine);
        if (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Refund) and (GenJournalLine."Applies-to Doc. No." <> '') then
            if XGenJournalLine."GST Group Code" <> GenJournalLine."GST Group Code" then
                Error(GSTRelevantInfoErr);

        GenJournalLine.TestField("Work Tax Nature Of Deduction", '');

        if XGenJournalLine."GST Group Code" <> '' then
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Fixed Asset") and GenJournalLine."FA Reclassification Entry" and
               (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Acquisition Cost")
            then
                if XGenJournalLine."GST Group Code" <> GenJournalLine."GST Group Code" then begin
                    GenJournalLine.TestField("GST Group Code", XGenJournalLine."GST Group Code");
                    GenJournalLine.TestField("GST Group Code");
                end;

        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Fixed Asset") and GenJournalLine."FA Reclassification Entry" and
           (GenJournalLine."FA Posting Type" <> GenJournalLine."FA Posting Type"::"Acquisition Cost")
        then
            GenJournalLine.TestField("GST Group Code", '');

        if GenJournalLine."GST Group Code" <> '' then begin
            SalesReceivablesSetup.Get();
            if GSTGroup.Get(GenJournalLine."GST Group Code") then begin
                GenJournalLine."GST Group Type" := GSTGroup."GST Group Type";
                if GenJournalLine."Document Type" in ["Document Type Enum"::Invoice, "Document Type Enum"::"Credit Memo"] then begin
                    GenJournalLine."GST Place of Supply" := GSTGroup."GST Place Of Supply";
                    GSTPOS := Format(SalesReceivablesSetup."GST Dependency Type");
                    Evaluate(GstPlaceOfSupply, GSTPOS);

                    if GenJournalLine."GST Place of Supply" = GenJournalLine."GST Place of Supply"::" " then
                        GenJournalLine."GST Place of Supply" := GstPlaceOfSupply;
                end;

                if (GenJournalLine."GST Vendor Type" in ["GST Vendor Type"::Registered, "GST Vendor Type"::Unregistered, "GST Vendor Type"::SEZ]) and
                   (GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Refund])
                then
                    GenJournalLine."GST Reverse Charge" := GSTGroup."Reverse Charge"
                else
                    if GenJournalLine."Document Type" in ["Document Type Enum"::Invoice, "Document Type Enum"::"Credit Memo"] then
                        GenJournalLine."GST Reverse Charge" := GSTGroup."Reverse Charge";

                if GenJournalLine."GST Vendor Type" = GenJournalLine."GST Vendor Type"::Unregistered then
                    GenJournalLine."GST Reverse Charge" := true;
            end;

            if (GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::"Credit Memo"]) and
                    (GenJournalLine."GST Vendor Type" = GenJournalLine."GST Vendor Type"::Unregistered) then
                GenJournalLine."GST Reverse Charge" := true;

            if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer then begin
                if GSTGroup."Reverse Charge" then
                    Error(GSTGroupReverseChargeErr, GenJournalLine."GST Group Code");

                if GSTGroup."GST Place Of Supply" = GSTGroup."GST Place Of Supply"::" " then begin
                    GSTPOS := Format(SalesReceivablesSetup."GST Dependency Type");
                    Evaluate(GstPlaceOfSupply, GSTPOS);
                    GenJournalLine."GST Place of Supply" := GstPlaceOfSupply;
                end else
                    GenJournalLine."GST Place of Supply" := GSTGroup."GST Place Of Supply";
            end;
            GetJournalHeader(GenJournalLine2, GenJournalLine, TransactionType::Purchase);
            if (GenJournalLine2."GST Vendor Type" in [GenJournalLine2."GST Vendor Type"::Unregistered,
                                                      GenJournalLine2."GST Vendor Type"::Registered]) and
               GenJournalLine."GST Reverse Charge"
            then begin
                //Get Posting No. Series 
                Record := GenJournalLine;
                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::purchase;
                PostingNoSeries.GetPostingNoSeriesCode(Record);
            end;
        end else begin
            GenJournalLine."GST Place of Supply" := GenJournalLine."GST Place of Supply"::" ";
            GenJournalLine."GST Group Type" := "GST Group Type"::Goods;
        end;
        if XGenJournalLine."GST Group Code" <> GenJournalLine."GST Group Code" then
            GenJournalLine."HSN/SAC Code" := '';


        if GenJournalLine."GST Group Code" <> '' then
            GenJournalLine.TestField("Provisional Entry", false);
    end;

    procedure PartyCode(var GenJournalLine: Record "Gen. Journal Line")
    begin
        case GenJournalLine."Party Type" of
            GenJournalLine."Party Type"::Vendor:
                begin
                    GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Vendor);
                    GenJournalLine.Validate("Account No.", GenJournalLine."Party Code");
                end;
            GenJournalLine."Party Type"::Customer:
                begin
                    GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
                    GenJournalLine.Validate("Account No.", GenJournalLine."Party Code");
                end;
            GenJournalLine."Party Type"::Party:
                UpdateorClearVendCustInfo(GenJournalLine."Party Code", false, false, true, GenJournalLine);
            GenJournalLine."Party Type"::" ":
                UpdateorClearVendCustInfo(GenJournalLine."Party Code", false, false, false, GenJournalLine);
        end;
        if GenJournalLine."Party Code" = '' then
            UpdateorClearVendCustInfo(GenJournalLine."Party Code", false, false, true, GenJournalLine);
    end;

    procedure LocationCode(var GenJournalLine: Record "Gen. Journal Line")
    var
        Location: Record Location;
        Location2: Record Location;
        GSTPostingSetup: Record "GST Posting Setup";
        GSTSetup: Record "GST Setup";
        TAXComponent: Record "Tax Component";
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
        LocationARNNo: Code[20];
    begin
        GenJournalLine."Provisional Entry" := false;
        ProvisionalEntryAlreadyAppliedErr(GenJournalLine);
        GenJournalLine."Location State Code" := '';
        GenJournalLine."Location GST Reg. No." := '';
        GenJournalLine."GST Input Service Distribution" := false;
        if not GenJournalLine."POS as Vendor State" then begin
            if Location.Get(GenJournalLine."Location Code") then begin
                GenJournalLine."Location State Code" := Location."State Code";
                GenJournalLine."Location GST Reg. No." := Location."GST Registration No.";
                GenJournalLine."GST Input Service Distribution" := Location."GST Input Service Distributor";
            end;
            if Location2.Get(GenJournalLine."Location Code") then
                LocationARNNo := Location."Location ARN No.";
        end else
            if GenJournalLine."Order Address Code" <> '' then
                GenJournalLine."Location State Code" := GenJournalLine."Order Address State Code"
            else
                GenJournalLine."Location State Code" := GenJournalLine."GST Bill-to/BuyFrom State Code";
        if (GenJournalLine."Tax Type" <> "Tax Type"::" ") and ((GenJournalLine."Location GST Reg. No." <> '') or (LocationARNNo <> '')) and (GenJournalLine."GST Component Code" <> '') then begin
            //Get GST Component ID
            if not GSTSetup.Get() then
                exit;

            GSTSetup.TestField("GST Tax Type");

            TAXComponent.Reset();
            TAXComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
            TAXComponent.SetRange(Name, GenJournalLine."GST Component Code");
            TAXComponent.FindFirst();
            GSTPostingSetup.Get(GenJournalLine."Location State Code", TAXComponent.Id);
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
            if not (GenJournalLine."Tax Type" in ["Tax Type"::"GST TDS Credit", "Tax Type"::"GST TCS Credit", "Tax Type"::"GST Liability"]) then begin
                GSTPostingSetup.TestField("Receivable Account");
                GenJournalLine."Account No." := GSTPostingSetup."Receivable Account";
            end else
                if GenJournalLine."Tax Type" = "Tax Type"::"GST TDS Credit" then begin
                    GSTPostingSetup.TestField("GST TDS Receivable Account");
                    GenJournalLine."Account No." := GSTPostingSetup."GST TDS Receivable Account";
                end else
                    if GenJournalLine."Tax Type" = "Tax Type"::"GST Liability" then begin
                        GSTPostingSetup.TestField("Payable Account");
                        GenJournalLine."Account No." := GSTPostingSetup."Payable Account";
                    end else
                        if GenJournalLine."Tax Type" = "Tax Type"::"GST TCS Credit" then begin
                            GSTPostingSetup.TestField("GST TCS Receivable Account");
                            GenJournalLine."Account No." := GSTPostingSetup."GST TCS Receivable Account";
                        end;
            GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        end;

        if GenJournalLine."Location Code" <> '' then
            if GenJournalLine."Location Code" = GenJournalLine."Bill to-Location(POS)" then
                Error(LocationErr);

        CheckBilltoLocation(GenJournalLine);
        if GenJournalLine."Document Type" in ["Document Type Enum"::Invoice, "Document Type Enum"::"Credit Memo"] then begin
            //Get Posting No. Series 
            Record := GenJournalLine;
            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::Sales;
            PostingNoSeries.GetPostingNoSeriesCode(Record);
            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::Purchase;
            PostingNoSeries.GetPostingNoSeriesCode(Record);
        end;

        CheckReferenceInvoiceNo(GenJournalLine);
        GenJournalLine."POS Out Of India" := false;
        UpdateGSTJurisdictionType(GenJournalLine);
    end;

    procedure amount(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Validate("Bank Charge", GenJournalLine."Bank Charge");
    end;

    procedure CurrencyCode(var GenJournalLine: Record "Gen. Journal Line")
    var
        JnlBankCharges: Record "Journal Bank Charges";
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        JnlBankCharges.Reset();
        JnlBankCharges.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        JnlBankCharges.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        JnlBankCharges.SetRange("Line No.", GenJournalLine."Line No.");
        if JnlBankCharges.FindSet() then
            repeat
                if GenJournalLine."Currency Code" <> '' then
                    JnlBankCharges."Amount (LCY)" := Round(CurrExchRate.ExchangeAmtFCYToLCY(GenJournalLine."Posting Date",
                          GenJournalLine."Currency Code", JnlBankCharges.Amount, GenJournalLine."Currency Factor"))
                else
                    JnlBankCharges."Amount (LCY)" := JnlBankCharges.Amount;
                JnlBankCharges.Modify();
            until JnlBankCharges.Next() = 0;

        GenJournalLine."GST TDS/GST TCS" := GenJournalLine."GST TDS/GST TCS"::" ";
        GenJournalLine."GST On Assessable Value" := false;
        GenJournalLine."GST Assessable Value Sale(LCY)" := 0;
        if GenJournalLine."POS as Vendor State" then
            Error(CurrencyCodePOSErr, GenJournalLine."Currency Code");
    end;

    procedure BalVendNo(var Rec: Record "Gen. Journal Line"; Vend: Record Vendor)
    begin
        UpdateGSTfromPartyVendCust(Rec."Bal. Account No.", false, true, Rec);
        Rec."Journal Entry" := true;
    end;

    procedure BalCustNo(var Rec: Record "Gen. Journal Line"; Cust: Record customer)
    begin
        UpdateGSTfromPartyVendCust(Rec."Bal. Account No.", false, true, Rec);
        Rec."Journal Entry" := true;
    end;

    procedure BalGLAccountNo(var Rec: Record "Gen. Journal Line")
    begin
        PopulateGSTInvoiceCrMemo(false, true, Rec);
    end;

    procedure DocumentType(var GenJournalLine: Record "Gen. Journal Line")
    begin
        ProvisionalEntryAlreadyAppliedErr(GenJournalLine);
        GenJournalLine."Provisional Entry" := false;
        GenJournalLine.TestField("Bank Charge", false);
        if GenJournalLine."POS as Vendor State" then
            if not (GenJournalLine."Document Type" in ["Document Type Enum"::Invoice, "Document Type Enum"::"Credit Memo"]) then
                Error(POSasAccountTypeErr);

        GenJournalLine."GST TDS/GST TCS" := GenJournalLine."GST TDS/GST TCS"::" ";
        GenJournalLine."GST On Assessable Value" := false;
        GenJournalLine."GST Assessable Value Sale(LCY)" := 0;
    end;

    procedure BalAccountNo(var Rec: Record "Gen. Journal Line")
    begin
        UpdateGSTfromPartyVendCust(Rec."Bal. Account No.", false, true, Rec);
        PopulateGSTInvoiceCrMemo(false, true, Rec);
    end;

    procedure FAAccount(var Rec: Record "Gen. Journal Line"; Fa: Record "Fixed Asset")
    begin
        if not Rec."FA Reclassification Entry" then
            PopulateGSTInvoiceCrMemo(true, false, Rec);
    end;

    procedure VendAccount(var GenJournalLine: Record "Gen. Journal Line"; Vendor: Record Vendor)
    begin
        GenJournalLine."Vendor GST Reg. No." := Vendor."GST Registration No.";
        GenJournalLine."GST Bill-to/BuyFrom State Code" := Vendor."State Code";
        GenJournalLine."GST Vendor Type" := Vendor."GST Vendor Type";
        GenJournalLine."Associated Enterprises" := Vendor."Associated Enterprises";
        UpdateGSTfromPartyVendCust(GenJournalLine."Account No.", true, false, GenJournalLine);
        GenJournalLine."Journal Entry" := true;
        UpdateGSTJurisdictionType(GenJournalLine);
    end;

    procedure CustAccount(var GenJournalLine: Record "Gen. Journal Line"; Customer: Record Customer)
    var
        postingnoseries: Record "Posting No. Series";
        Record: Variant;
    begin
        GenJournalLine."Customer GST Reg. No." := Customer."GST Registration No.";
        GenJournalLine."GST Customer Type" := Customer."GST Customer Type";
        if (GenJournalLine."Document Type" in ["Document Type Enum"::Invoice, "Document Type Enum"::"Credit Memo"]) and GenJournalLine."GST in Journal" then begin
            //Get posting No Seried form posting no. series table
            Record := GenJournalLine;
            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::Sales;
            postingnoseries.GetPostingNoSeriesCode(Record);
        end;
        if GenJournalLine."GST Customer Type" = "GST Customer Type"::Unregistered then
            GenJournalLine."Nature of Supply" := GenJournalLine."Nature of Supply"::B2C;

        if not (GenJournalLine."GST Customer Type" = "GST Customer Type"::Export) then
            GenJournalLine."GST Bill-to/BuyFrom State Code" := Customer."State Code";
        UpdateGSTfromPartyVendCust(GenJournalLine."Account No.", true, false, GenJournalLine);
        UpdateGSTJurisdictionType(GenJournalLine);
    end;

    procedure BeforeValidateAccountNo(var GenJournalLine: Record "Gen. Journal Line")
    begin
        ProvisionalEntryAlreadyAppliedErr(GenJournalLine);
        GenJournalLine."Provisional Entry" := false;
        GenJournalLine."GST Bill-to/BuyFrom State Code" := '';
        GenJournalLine."Vendor GST Reg. No." := '';
        GenJournalLine."Customer GST Reg. No." := '';
        GenJournalLine."GST Vendor Type" := "GST Vendor Type"::" ";
        GenJournalLine."GST Customer Type" := "GST Customer Type"::" ";
        GenJournalLine."RCM Exempt" := false;
        GenJournalLine."GST Group Code" := '';
        GenJournalLine."HSN/SAC Code" := '';
        GenJournalLine."Reference Invoice No." := '';
        GenJournalLine."GST TDS/GST TCS" := GenJournalLine."GST TDS/GST TCS"::" ";
        GenJournalLine."GST On Assessable Value" := false;
        GenJournalLine."GST Assessable Value Sale(LCY)" := 0;
        GenJournalLine."POS Out Of India" := false;
        if GenJournalLine."Account No." = '' then begin
            UpdateGSTfromPartyVendCust(GenJournalLine."Account No.", true, false, GenJournalLine);
            PopulateGSTInvoiceCrMemo(true, false, GenJournalLine);
        end;
    end;

    procedure AfterValidateAccountNo(var GenJournalLine: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
    begin
        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Customer:
                if GenJournalLine."Account No." <> '' then
                    if Customer.Get(GenJournalLine."Account No.") then
                        GenJournalLine.State := Customer."State Code";
        end;
    end;

    procedure AfterValidateShipToCode(var GenJournalLine: Record "Gen. Journal Line")
    begin
        CheckShipCode(GenJournalLine);
    end;

    procedure AccountType(var GenJournalLine: Record "Gen. Journal Line")
    var
        Location: Record Location;
        GSTPostingSetup: Record "GST Posting Setup";
        TaxComponents: Record "Tax Component";
        TaxType: Record "Tax Type";
    begin
        ProvisionalEntryAlreadyAppliedErr(GenJournalLine);
        GenJournalLine."Provisional Entry" := false;
        GenJournalLine."GST TDS/GST TCS" := GenJournalLine."GST TDS/GST TCS"::" ";
        GenJournalLine."GST On Assessable Value" := false;
        GenJournalLine."GST Assessable Value Sale(LCY)" := 0;
        if GenJournalLine."Tax Type" <> "Tax Type"::" " then begin
            GenJournalLine.TestField("Account Type", GenJournalLine."Account Type"::"G/L Account");
            Location.Get(GenJournalLine."Location Code");

            //Get GST posting setup
            if not TaxType.Get() then
                exit;
            TaxType.TestField(Code);

            TaxComponents.Reset();
            TaxComponents.SetRange("Tax Type", TaxType.Code);
            TaxComponents.SetRange(Name, GenJournalLine."GST Component Code");
            TaxComponents.FindFirst();
            GSTPostingSetup.Get(Location."State Code", TaxComponents.Id);

            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
            if not (GenJournalLine."Tax Type" in ["Tax Type"::"GST TDS Credit", "Tax Type"::"GST TCS Credit"]) then begin
                GSTPostingSetup.TestField("Receivable Account");
                GenJournalLine."Account No." := GSTPostingSetup."Receivable Account";
            end else
                if GenJournalLine."Tax Type" = "Tax Type"::"GST TDS Credit" then begin
                    GSTPostingSetup.TestField("GST TDS Receivable Account");
                    GenJournalLine."Account No." := GSTPostingSetup."GST TDS Receivable Account";
                end else begin
                    GSTPostingSetup.TestField("GST TCS Receivable Account");
                    GenJournalLine."Account No." := GSTPostingSetup."GST TCS Receivable Account";
                end;
            GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        end;
        GenJournalLine.Validate("Bank Charge", GenJournalLine."Bank Charge");
    end;

    procedure PopulateGSTInvoiceCrMemo(Acc: Boolean; BalAcc: Boolean; var GenJnlLine: Record "gen. journal line")
    begin
        if not (GenJnlLine."Document Type" in ["Document Type Enum"::Invoice, "Document Type Enum"::"Credit Memo"]) then
            exit;
        if Acc and not BalAcc and (GenJnlLine."Account No." <> '') then
            UpdateGSTInfoFromAcc(GenJnlLine."Account No.", false, GenJnlLine)
        else
            if not Acc and BalAcc and (GenJnlLine."Bal. Account No." <> '') then
                UpdateGSTInfoFromAcc(GenJnlLine."Bal. Account No.", false, GenJnlLine)
            else
                if (not Acc and not BalAcc) or (Acc and (GenJnlLine."Account No." = '')) or (BalAcc and (GenJnlLine."Bal. Account No." = '')) then
                    UpdateGSTInfoFromAcc('', true, GenJnlLine);
    end;

    local procedure UpdateGSTfromPartyVendCust(AccountNo: Code[20]; Acc: Boolean; BalAcc: Boolean; var GenJnlLine: Record "Gen. Journal Line")
    begin
        if not (GenJnlLine."Document Type" in ["Document Type Enum"::Invoice, "Document Type Enum"::"Credit Memo"]) then
            exit;

        if AccountNo <> '' then
            if GenJnlLine."Party Code" <> '' then
                case GenJnlLine."Party Type" of
                    GenJnlLine."Party Type"::Vendor:
                        UpdateorClearVendCustInfo(GenJnlLine."Party Code", true, false, false, GenJnlLine);
                    GenJnlLine."Party Type"::Customer:
                        UpdateorClearVendCustInfo(GenJnlLine."Party Code", false, true, false, GenJnlLine);
                    GenJnlLine."Party Type"::Party:
                        if ((GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor) and (GenJnlLine."Account No." <> '')) or
                           ((GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Vendor) and (GenJnlLine."Bal. Account No." <> ''))
                        then begin
                            if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor) and (GenJnlLine."Account No." = AccountNo) then
                                UpdateorClearVendCustInfo(AccountNo, true, false, false, GenJnlLine)
                            else
                                if (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Vendor) and (GenJnlLine."Bal. Account No." = AccountNo) then
                                    UpdateorClearVendCustInfo(AccountNo, true, false, false, GenJnlLine);
                        end else
                            if ((GenJnlLine."Account Type" = GenJnlLine."Account Type"::Customer) and (GenJnlLine."Account No." <> '')) or
                               ((GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Customer) and (GenJnlLine."Bal. Account No." <> ''))
                            then begin
                                if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::Customer) and (GenJnlLine."Account No." = AccountNo) then
                                    UpdateorClearVendCustInfo(AccountNo, false, true, false, GenJnlLine)
                                else
                                    if (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Vendor) and (GenJnlLine."Bal. Account No." = AccountNo) then
                                        UpdateorClearVendCustInfo(AccountNo, false, true, false, GenJnlLine);
                            end else
                                UpdateorClearVendCustInfo(GenJnlLine."Party Code", false, false, true, GenJnlLine);
                end
            else begin
                if ((Acc and (GenJnlLine."Account Type" <> GenJnlLine."Account Type"::Vendor)) or (Acc and (GenJnlLine."Account Type" <> GenJnlLine."Account Type"::Customer)) or
                    (BalAcc and (GenJnlLine."Bal. Account Type" <> GenJnlLine."Bal. Account Type"::Vendor)) or
                    (BalAcc and (GenJnlLine."Bal. Account Type" <> GenJnlLine."Bal. Account Type"::Customer)))
                then
                    exit;
                if ((GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor) and (GenJnlLine."Account No." <> '')) or
                   ((GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Vendor) and (GenJnlLine."Bal. Account No." <> ''))
                then
                    UpdateorClearVendCustInfo(AccountNo, true, false, false, GenJnlLine);
                if ((GenJnlLine."Account Type" = GenJnlLine."Account Type"::Customer) and (GenJnlLine."Account No." <> '')) or
                   ((GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Customer) and (GenJnlLine."Bal. Account No." <> ''))
                then
                    UpdateorClearVendCustInfo(AccountNo, false, true, false, GenJnlLine);
            end else
            if GenJnlLine."Party Code" <> '' then
                case GenJnlLine."Party Type" of
                    GenJnlLine."Party Type"::Vendor:
                        UpdateorClearVendCustInfo(GenJnlLine."Party Code", true, false, false, GenJnlLine);
                    GenJnlLine."Party Type"::Customer:
                        UpdateorClearVendCustInfo(GenJnlLine."Party Code", false, true, false, GenJnlLine);
                    GenJnlLine."Party Type"::Party:
                        UpdateorClearVendCustInfo(GenJnlLine."Party Code", false, false, true, GenJnlLine);
                end else
                UpdateorClearVendCustInfo(AccountNo, false, false, false, GenJnlLine);
    end;

    local procedure ProvisionalEntryAlreadyAppliedErr(GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Applied Provisional Entry" <> 0 then
            Error(ProvisionalEntryAppliedErr, GenJournalLine."Document No.");
    end;

    local procedure UpdateorClearVendCustInfo(AccNo: Code[20]; Vend: Boolean; Cust: Boolean; Party: Boolean; var GenJnlLine: Record "Gen. Journal Line")
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Party1: Record Party;
    begin
        if AccNo <> '' then begin
            ClearGSTVendCustInfo(GenJnlLine);
            GenJnlLine."Bill of Entry No." := '';
            GenJnlLine."Bill of Entry Date" := 0D;
            if Vend then begin
                Vendor.Get(AccNo);
                GenJnlLine.Validate("GST Vendor Type", Vendor."GST Vendor Type");
                GenJnlLine."GST Bill-to/BuyFrom State Code" := Vendor."State Code";
                GenJnlLine."Vendor GST Reg. No." := Vendor."GST Registration No.";
                GenJnlLine."Associated Enterprises" := Vendor."Associated Enterprises";
                GenJnlLine."Nature of Supply" := GenJnlLine."Nature of Supply"::B2B;
            end else
                if Cust then begin
                    Customer.Get(AccNo);
                    GenJnlLine."GST Customer Type" := Customer."GST Customer Type";
                    GenJnlLine."GST Bill-to/BuyFrom State Code" := Customer."State Code";
                    GenJnlLine."Customer GST Reg. No." := Customer."GST Registration No.";
                    if GenJnlLine."GST Customer Type" = "GST Customer Type"::Unregistered then
                        GenJnlLine."Nature of Supply" := GenJnlLine."Nature of Supply"::B2C;

                    GenJnlLine."Sales Invoice Type" := "Sales Invoice Type"::" ";
                end else
                    if Party then begin
                        Party1.Get(AccNo);
                        GenJnlLine."GST Customer Type" := Party1."GST Customer Type";
                        GenJnlLine.Validate("GST Vendor Type", Party1."GST Vendor Type");
                        GenJnlLine."Associated Enterprises" := Party1."Associated Enterprises";
                        GenJnlLine."GST Bill-to/BuyFrom State Code" := Party1.State;
                        if Party1."GST Party Type" = Party1."GST Party Type"::Vendor then
                            GenJnlLine."Vendor GST Reg. No." := Party1."GST Registration No."
                        else
                            if Party1."GST Party Type" = Party1."GST Party Type"::Customer then
                                GenJnlLine."Customer GST Reg. No." := Party1."GST Registration No.";

                        if GenJnlLine."GST Customer Type" = "GST Customer Type"::Unregistered then
                            GenJnlLine."Nature of Supply" := GenJnlLine."Nature of Supply"::B2C;

                        if GenJnlLine."GST Vendor Type" = GenJnlLine."GST Vendor Type"::Unregistered then
                            GenJnlLine.Validate("GST Reverse Charge", true)
                        else
                            GenJnlLine.Validate("GST Reverse Charge", false);

                        GenJnlLine."Sales Invoice Type" := "Sales Invoice Type"::" ";
                    end else
                        ClearGSTVendCustInfo(GenJnlLine)
        end else
            ClearGSTVendCustInfo(GenJnlLine);
    end;

    local procedure ClearGSTVendCustInfo(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine.Validate("GST Vendor Type", "GST Vendor Type"::" ");
        Clear(GenJnlLine."GST Customer Type");
        Clear(GenJnlLine."GST Bill-to/BuyFrom State Code");
        Clear(GenJnlLine."Associated Enterprises");
        Clear(GenJnlLine."Nature of Supply");
        Clear(GenJnlLine."Bill of Entry Date");
        Clear(GenJnlLine."Bill of Entry No.");
        GenJnlLine."Vendor GST Reg. No." := '';
        GenJnlLine."Customer GST Reg. No." := '';
        GenJnlLine."Ship-to GST Reg. No." := '';
        GenJnlLine."POS Out Of India" := false;
    end;

    local procedure UpdateGSTInfoFromAcc(
        AccountNo: Code[20];
        ClearVars: Boolean;
        var GenJnlLine: Record "Gen. Journal Line")
    var
        FixedAsset: Record "Fixed Asset";
        GLAccount: Record "G/L Account";
    begin
        if ClearVars or (AccountNo = '') then begin
            Clear(GenJnlLine."GST Group Code");
            Clear(GenJnlLine."GST Group Type");
            Clear(GenJnlLine."GST Place of Supply");
            Clear(GenJnlLine."HSN/SAC Code");
            Clear(GenJnlLine.Exempted);
            Clear(GenJnlLine."GST Jurisdiction Type");
            Clear(GenJnlLine."GST Reverse Charge");
            Clear(GenJnlLine."GST Reason Type");
            Clear(GenJnlLine."Inc. GST in TDS Base");
            Clear(GenJnlLine."GST Credit");
            Clear(GenJnlLine."Custom Duty Amount");
            Clear(GenJnlLine."Custom Duty Amount (LCY)");
        end else
            if GLAccount.Get(AccountNo) then begin
                GenJnlLine.Validate("GST Group Code", GLAccount."GST Group Code");
                GenJnlLine.Validate("HSN/SAC Code", GLAccount."HSN/SAC Code");
                GenJnlLine.Validate(Exempted, GLAccount.Exempted);
                GenJnlLine.Validate("GST Credit", GLAccount."GST Credit");
            end else
                if FixedAsset.Get(GenJnlLine."Account No.") then begin
                    GenJnlLine.Validate("GST Group Code", FixedAsset."GST Group Code");
                    GenJnlLine.Validate("HSN/SAC Code", FixedAsset."HSN/SAC Code");
                    GenJnlLine.Validate(Exempted, FixedAsset.Exempted);
                    GenJnlLine.Validate("GST Credit", FixedAsset."GST Credit");
                end;
    end;

    local procedure CheckBilltoLocation(var GenJnlLine: Record "gen. journal line")
    var
        Location: Record Location;
    begin
        if not GenJnlLine."POS as Vendor State" then
            if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor) or
               (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Vendor)
            then
                if GenJnlLine."Bill to-Location(POS)" <> '' then begin
                    if GenJnlLine."Bill to-Location(POS)" = GenJnlLine."Location Code" then
                        Error(LocationErr);

                    Location.Get(GenJnlLine."Bill to-Location(POS)");
                    GenJnlLine."Location GST Reg. No." := Location."GST Registration No.";
                    GenJnlLine."Location State Code" := Location."State Code";
                    GenJnlLine."GST Input Service Distribution" := Location."GST Input Service Distributor";
                end else
                    if GenJnlLine."Location Code" <> '' then begin
                        Location.Get(GenJnlLine."Location Code");
                        GenJnlLine."Location GST Reg. No." := Location."GST Registration No.";
                        GenJnlLine."Location State Code" := Location."State Code";
                        GenJnlLine."GST Input Service Distribution" := Location."GST Input Service Distributor";
                    end;

        if GenJnlLine."POS as Vendor State" then
            if GenJnlLine."Order Address Code" <> '' then
                GenJnlLine."Location State Code" := GenJnlLine."Order Address State Code"
            else
                GenJnlLine."Location State Code" := GenJnlLine."GST Bill-to/BuyFrom State Code";
    end;

    local procedure CheckReferenceInvoiceNo(GenJnlLine: Record "Gen. Journal Line")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        DocType: Text;
        DocTypeEnum: Enum "Document Type Enum";
    begin
        DocType := Format(GenJnlLine."Document Type");
        if not Evaluate(DocTypeEnum, DocType) then
            exit;
        ReferenceInvoiceNo.SetRange("Document No.", GenJnlLine."Document No.");
        ReferenceInvoiceNo.SetRange("Document Type", DocTypeEnum);
        ReferenceInvoiceNo.SetRange("Source No.", GenJnlLine."Account No.");
        ReferenceInvoiceNo.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        ReferenceInvoiceNo.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        ReferenceInvoiceNo.SetRange(Verified, true);
        if not ReferenceInvoiceNo.IsEmpty() then
            Error(ReferenceInvoiceErr);
    end;

    local procedure CheckRCMExemptDate(GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if GenJournalLine."GST Vendor Type" <> "GST Vendor Type"::Unregistered then
            exit(false);

        if GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Payment then
            exit(false);

        GenJournalLine.TestField("Posting Date");
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.TestField("RCM Exempt Start Date (Unreg)");
        PurchasesPayablesSetup.TestField("RCM Exempt Start Date (Unreg)");
        if (GenJournalLine."Posting Date" >= PurchasesPayablesSetup."RCM Exempt Start Date (Unreg)") and
           (GenJournalLine."Posting Date" <= PurchasesPayablesSetup."RCM Exempt end Date (Unreg)")
        then
            exit(true);

        exit(false);
    end;

    local procedure GetJournalHeader(
        var GenJournalLine: Record "Gen. Journal Line";
        GenJournalLine1: Record "Gen. Journal Line";
        TransactionType: Enum "JournalLine TransactionType")
    var
        DocNo: Code[20];
    begin
        GenJournalLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Document No.");
        GenJournalLine.SetRange("Journal Template Name", GenJournalLine1."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalLine1."Journal Batch Name");
        GenJournalLine.SetRange("Line No.", GenJournalLine1."Line No.");
        if GenJournalLine.FindFirst() then
            DocNo := GenJournalLine."Document No.";

        GenJournalLine.SetRange("Line No.");
        GenJournalLine.SetRange("Document No.", DocNo);
        if TransactionType = TransactionType::Purchase then
            GenJournalLine.SetFilter("GST Vendor Type", '<>%1', "GST Vendor Type"::" ");

        if TransactionType = TransactionType::Sales then
            GenJournalLine.SetFilter("GST Customer Type", '<>%1', "GST Customer Type"::" ");
    end;

    local procedure CheckShipCode(var GenJnlLine: Record "gen. journal line")
    var
        ShiptoAddress: Record "Ship-to Address";
    begin
        GenJnlLine."GST Ship-to State Code" := '';
        GenJnlLine."Ship-to GST Reg. No." := '';
        if GenJnlLine."Ship-to Code" <> '' then begin
            ShiptoAddress.Get(GenJnlLine."Account No.", GenJnlLine."Ship-to Code");
            GenJnlLine."GST Ship-to State Code" := ShiptoAddress.State;
            GenJnlLine."Ship-to GST Reg. No." := ShiptoAddress."GST Registration No.";
            GenJnlLine.State := ShiptoAddress.State;
            if GenJnlLine."GST Customer Type" <> "GST Customer Type"::" " then
                if GenJnlLine."GST Customer Type" in ["GST Customer Type"::Exempted, "GST Customer Type"::"Deemed Export",
                                           "GST Customer Type"::"SEZ Development", "GST Customer Type"::"SEZ Unit",
                                           "GST Customer Type"::Registered]
                then
                    if GenJnlLine."Ship-to GST Reg. No." = '' then
                        if ShiptoAddress."ARN No." = '' then
                            Error(ShiptoGSTARNErr);

            UpdateGSTJurisdictionType(GenJnlLine);
        end;
        if GenJnlLine."GST on Advance Payment" and
           (GenJnlLine."GST Place of Supply" = GenJnlLine."GST Place of Supply"::"Ship-to Address") and (GenJnlLine."Ship-to Code" = '')
        then
            Error(BlankShiptoCodeErr);
    end;

    local procedure GetTotalDoclineNos(GenJournalLine: Record "Gen. Journal Line"): Integer
    var
        GenJournalLineDummy: Record "Gen. Journal Line";
    begin
        GenJournalLineDummy.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Document No.", "Line No.");
        GenJournalLineDummy.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLineDummy.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        if GenJournalLine."Document No." = GenJournalLine."Old Document No." then
            GenJournalLineDummy.SetRange("Document No.", GenJournalLine."Document No.")
        else
            GenJournalLineDummy.SetRange("Document No.", GenJournalLine."Old Document No.");
        exit(GenJournalLineDummy.Count());
    end;

    local procedure CheckAllLinesExemptedJournal(GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        GenJournalLine1: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        GenJournalLine1.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLine1.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJournalLine1.SetRange("Document No.", GenJournalLine."Document No.");
        GenJournalLine1.SetRange("GST Customer Type", GenJournalLine."GST Customer Type"::" ");
        GenJournalLine2.CopyFilters(GenJournalLine1);
        GenJournalLine2.SetRange(Exempted, true);
        if GenJournalLine1.Count() <> GenJournalLine2.Count() then
            exit(true);
    end;

    local procedure CheckInvoiceTypeWithExempted(ExemptedValue: Boolean; var GenJnlLine: Record "Gen. Journal Line")
    begin
        case GenJnlLine."GST Customer Type" of
            "GST Customer Type"::" ", "GST Customer Type"::Registered, "GST Customer Type"::Unregistered:
                begin
                    if (GenJnlLine."Sales Invoice Type" in ["Sales Invoice Type"::"Bill of Supply",
                                                 "Sales Invoice Type"::Export]) and (not ExemptedValue)
                    then
                        Error(InvoiceTypeErr, GenJnlLine."Sales Invoice Type", GenJnlLine."GST Customer Type");
                    if ExemptedValue then
                        GenJnlLine.TestField("Sales Invoice Type", "Sales Invoice Type"::"Bill of Supply");
                    if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Fixed Asset") and GenJnlLine."FA Reclassification Entry" and
                       (GenJnlLine."Customer GST Reg. No." <> '') and (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Acquisition Cost")
                    then
                        GenJnlLine.TestField("Sales Invoice Type", "Sales Invoice Type"::Taxable);
                end;
            "GST Customer Type"::Export, "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development", "GST Customer Type"::"SEZ Unit":
                begin
                    if (GenJnlLine."Sales Invoice Type" in ["Sales Invoice Type"::"Bill of Supply",
                                                 "Sales Invoice Type"::Taxable]) and (not ExemptedValue)
                    then
                        Error(InvoiceTypeErr, GenJnlLine."Sales Invoice Type", GenJnlLine."GST Customer Type");
                    if ExemptedValue then
                        GenJnlLine.TestField("Sales Invoice Type", "Sales Invoice Type"::"Bill of Supply");
                end;
            "GST Customer Type"::Exempted:
                if GenJnlLine."Sales Invoice Type" in ["Sales Invoice Type"::"Debit note",
                                            "Sales Invoice Type"::Export,
                                            "Sales Invoice Type"::Taxable]
                then
                    Error(InvoiceTypeErr, GenJnlLine."Sales Invoice Type", GenJnlLine."GST Customer Type");
        end;
    end;

    local procedure VerifyPOSOutOfIndia(
        ConfigType: Enum "Party Type";
                        LocationStateCode: Code[10];
                        VendCustStateCode: Code[10];
                        GSTVendorType: Enum "GST Vendor Type";
                        GSTCustomerType: Enum "GST Customer Type")
    begin
        if LocationStateCode <> VendCustStateCode then
            Error(POSLOCDiffErr);

        if ConfigType = ConfigType::Customer then begin
            if not (GSTCustomerType in [GSTCustomerType::" ",
                                        GSTCustomerType::Registered,
                                        GSTCustomerType::Unregistered,
                                        GSTCustomerType::"Deemed Export"])
            then
                Error(CustGSTTypeErr);
        end else
            if not (GSTVendorType in [GSTVendorType::Registered, GSTVendorType::" "]) then
                Error(VendGSTTypeErr);
    end;

    local procedure GetPlaceOfSupply(GenJournalLine: Record "Gen. Journal Line"): Code[10]
    var
        PlaceofSupplyStateCode: Code[10];
    begin
        case GenJournalLine."GST Place of Supply" of
            GenJournalLine."GST Place of Supply"::"Bill-to Address":
                PlaceofSupplyStateCode := GenJournalLine."GST Bill-to/BuyFrom State Code";
            GenJournalLine."GST Place of Supply"::"Ship-to Address":
                PlaceofSupplyStateCode := GenJournalLine."GST Ship-to State Code";
            GenJournalLine."GST Place of Supply"::"Location Address":
                PlaceofSupplyStateCode := GenJournalLine."Location State Code";
        end;
        exit(PlaceofSupplyStateCode);
    end;

    local procedure UpdateGSTJurisdictionType(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."POS Out Of India" then begin
            GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Interstate;
            exit;
        end;

        if (GenJournalLine."GST Vendor Type" = GenJournalLine."GST Vendor Type"::SEZ) then begin
            GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Interstate;
            exit;
        end;

        if GenJournalLine."GST Customer Type" In [GenJournalLine."GST Customer Type"::"SEZ Development", GenJournalLine."GST Customer Type"::"SEZ Unit"] then begin
            GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Interstate;
            exit;
        end;

        if GenJournalLine.State = '' then begin
            if GenJournalLine."Location State Code" <> GenJournalLine."GST Bill-to/BuyFrom State Code" then
                GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Interstate
            else
                GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Intrastate;
        end else
            if GenJournalLine."Location State Code" = GenJournalLine.State then
                GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Intrastate
            else
                GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Interstate;
    end;
}
