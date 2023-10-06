// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Distribution;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.GST.ReturnSettlement;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.Utilities;

report 18042 "GSTR-3B"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/GSTR3B.rdl';
    Caption = 'GSTR-3B';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number)
                                order(Ascending)
                                where(Number = const(1));
            column(GSTRLbl; GSTRLbl)
            {
            }
            column(RuleLbl; RuleLbl)
            {
            }
            column(YearLbl; YearLbl)
            {
            }
            column(MonthLbl; MonthLbl)
            {
            }
            column(GSTINLbl; GSTINLbl)
            {
            }
            column(LegalNameLbl; LegalNameLbl)
            {
            }
            column(TradeNameLbl; TradeNameLbl)
            {
            }
            column(ARNLbl; ARNLbl)
            {
            }
            column(DateofArnLbl; DateofArnLbl)
            {
            }
            column(OutwardSpplyLbl; OutwardSpplyLbl)
            {
            }
            column(OutwardSpplyProvisioningLbl; OutwardSpplyProvisioningLbl)
            {
            }
            column(OutwardSupplyforelectronicLbl; OutwardSupplyforelectronicLbl)
            {
            }
            column(OutwardSupplyforRegisteredelectronicLbl; OutwardSupplyforRegisteredelectronicLbl)
            {
            }
            column(NatureofSpplyLbl; NatureofSpplyLbl)
            {
            }
            column(TotTaxableLbl; TotTaxableLbl)
            {
            }
            column(IntegratedLbl; IntegratedLbl)
            {
            }
            column(CentralLbl; CentralLbl)
            {
            }
            column(StateTaxLbl; StateTaxLbl)
            {
            }
            column(CessLbl; CESSLbl)
            {
            }
            column(OutwardTaxableSpplyLbl; OutwardTaxableSpplyLbl)
            {
            }
            column(OutwardTaxableSpplyZeroLbl; OutwardTaxableSpplyZeroLbl)
            {
            }
            column(OutwardTaxableSpplyNilLbl; OutwardTaxableSpplyNilLbl)
            {
            }
            column(InwardSpplyLbl; InwardSpplyLbl)
            {
            }
            column(NonGSTOutwardSpplyLbl; NonGSTOutwardSpplyLbl)
            {
            }
            column(UnregCompoLbl; UnregCompoLbl)
            {
            }
            column(PlaceOfSupplyLbl; PlaceOfSupplyLbl)
            {
            }
            column(IntegratedTaxLbl; IntegratedTaxLbl)
            {
            }
            column(InCashLbl; InCashLbl)
            {
            }
            column(EligibleITCLbl; EligibleITCLbl)
            {
            }
            column(NatureOfSuppliesLbl; NatureOfSuppliesLbl)
            {
            }
            column(ITCAvlLbl; ITCAvlLbl)
            {
            }
            column(ImportGoodLbl; ImportGoodLbl)
            {
            }
            column(ImportServiceLbl; ImportServiceLbl)
            {
            }
            column(InwrdReverseLbl; InwrdReverseLbl)
            {
            }
            column(InwrdISDLbl; InwrdISDLbl)
            {
            }
            column(AllITCLbl; AllITCLbl)
            {
            }
            column(ITCReverseLbl; ITCReverseLbl)
            {
            }
            column(RulesLbl; RulesLbl)
            {
            }
            column(OthersLbl; OthersLbl)
            {
            }
            column(NetITCLbl; NetITCLbl)
            {
            }
            column(IneligibleITCLbl; IneligibleITCLbl)
            {
            }
            column(SectionLbl; SectionLbl)
            {
            }
            column(ValuesExemptLbl; ValuesExemptLbl)
            {
            }
            column(ValuesForLateFeeLbl; ValuesForLateFeeLbl)
            {
            }
            column(ComputedInterestLbl; ComputedInterestLbl)
            {
            }
            column(InterestPaidLbl; InterestPaidLbl)
            {
            }
            column(InterStateSpplyLbl; InterStateSpplyLbl)
            {
            }
            column(IntraStateLbl; IntraStateLbl)
            {
            }
            column(SupplierCompLbl; SupplierCompLbl)
            {
            }
            column(NonGSTSpply; NonGSTSpplyLbl)
            {
            }
            column(PaymentLbl; PaymentLbl)
            {
            }
            column(PaymentOtherThanReverseChargeLbl; PaymentOtherThanReverseChargeLbl)
            {
            }
            column(PaymentReverseChargeLbl; PaymentReverseChargeLbl)
            {
            }
            column(DescLbl; DescLbl)
            {
            }
            column(TaxLbl; TaxLbl)
            {
            }
            column(PayableLbl; PayableLbl)
            {
            }
            column(PaidITCLbl; PaidITCLbl)
            {
            }
            column(TaxPaidLbl; TaxPaidLbl)
            {
            }
            column(TDSTCSLbl; TDSTCSLbl)
            {
            }
            column(TaxCessLbl; TaxCessLbl)
            {
            }
            column(CashLbl; CashLbl)
            {
            }
            column(InterestLbl; InterestLbl)
            {
            }
            column(LateFeeLbl; LateFeeLbl)
            {
            }
            column(DetailsLbl; DetailsLbl)
            {
            }
            column(VerificationLbl; VerificationLbl)
            {
            }
            column(VerifyTxtLbl; VerifyTxtLbl)
            {
            }
            column(PlaceLbl; PlaceLbl)
            {
            }
            column(DateLbl; DateLbl)
            {
            }
            column(Place; Place)
            {
            }
            column(PostingDate; PostingDate)
            {
            }
            column(ResponsibleLbl; AuthorisedPerson)
            {
            }
            column(SignatoryLbl; SignatoryLbl)
            {
            }
            column(GSTIN; GSTIN)
            {
            }
            column(Year; Year)
            {
            }
            column(Month; Month)
            {
            }
            column(LegalName; CompanyInformation.Name + CompanyInformation."Name 2")
            {
            }
            column(GSTINChar1; gstinchar[1])
            {
            }
            column(GSTINChar2; gstinchar[2])
            {
            }
            column(GSTINChar3; gstinchar[3])
            {
            }
            column(GSTINChar4; gstinchar[4])
            {
            }
            column(GSTINChar5; gstinchar[5])
            {
            }
            column(GSTINChar6; gstinchar[6])
            {
            }
            column(GSTINChar7; gstinchar[7])
            {
            }
            column(GSTINChar8; gstinchar[8])
            {
            }
            column(GSTINChar9; gstinchar[9])
            {
            }
            column(GSTINChar10; gstinchar[10])
            {
            }
            column(GSTINChar11; gstinchar[11])
            {
            }
            column(GSTINChar12; gstinchar[12])
            {
            }
            column(GSTINChar13; gstinchar[13])
            {
            }
            column(GSTINChar14; gstinchar[14])
            {
            }
            column(GSTINChar15; gstinchar[15])
            {
            }
            column(OwrdtaxableTotalAmount; -OwrdtaxableTotalAmount)
            {
            }
            column(OwrdtaxableIGSTAmount; -OwrdtaxableIGSTAmount)
            {
            }
            column(OwrdtaxableCGSTAmount; -OwrdtaxableCGSTAmount)
            {
            }
            column(OwrdtaxableSGSTUTGSTAmount; -OwrdtaxableSGSTUTGSTAmount)
            {
            }
            column(OwrdtaxableCESSAmount; -OwrdtaxableCESSAmount)
            {
            }
            column(OwrdZeroTotalAmount; -OwrdZeroTotalAmount)
            {
            }
            column(OwrdZeroIGSTAmount; -OwrdZeroIGSTAmount)
            {
            }
            column(OwrdZeroCGSTAmount; -OwrdZeroCGSTAmount)
            {
            }
            column(OwrdZeroSGSTUTGSTAmount; -OwrdZeroSGSTUTGSTAmount)
            {
            }
            column(OwrdZeroCESSAmount; -OwrdZeroCESSAmount)
            {
            }
            column(OwrdNilTotalAmount; -OwrdNilTotalAmount)
            {
            }
            column(OwrdExempTotalAmount; -OwrdExempTotalAmount)
            {
            }
            column(OwrdNilIGSTAmount; -OwrdNilIGSTAmount)
            {
            }
            column(OwrdNilCGSTAmount; -OwrdNilCGSTAmount)
            {
            }
            column(OwrdNilSGSTUTGSTAmount; -OwrdNilSGSTUTGSTAmount)
            {
            }
            column(OwrdNilCESSAmount; -OwrdNilCESSAmount)
            {
            }
            column(InwrdtotalAmount; InwrdtotalAmount)
            {
            }
            column(InwrdIGSTAmount; InwrdIGSTAmount)
            {
            }
            column(InwrdCGSTAmount; InwrdCGSTAmount)
            {
            }
            column(InwrdSGSTUTGSTAmount; InwrdSGSTUTGSTAmount)
            {
            }
            column(InwrdCESSAmount; InwrdCESSAmount)
            {
            }
            column(OwrdNonGSTTotalAmount; OwrdNonGSTTotalAmount)
            {
            }
            column(ImportGoodsIGSTAmount; ImportGoodsIGSTAmount)
            {
            }
            column(ImportGoodsCGSTAmount; ImportGoodsCGSTAmount)
            {
            }
            column(ImportGoodsSGSTUTGSTAmount; ImportGoodsSGSTUTGSTAmount)
            {
            }
            column(ImportGoodsCESSAmount; ImportGoodsCESSAmount)
            {
            }
            column(ImportServiceIGSTAmount; ImportServiceIGSTAmount)
            {
            }
            column(ImportServiceCGSTAmount; ImportServiceCGSTAmount)
            {
            }
            column(ImportServiceSGSTUTGSTAmount; ImportServiceSGSTUTGSTAmount)
            {
            }
            column(ImportServiceCESSAmount; ImportServiceCESSAmount)
            {
            }
            column(InwrdReverseIGSTAmount; InwrdReverseIGSTAmount)
            {
            }
            column(InwrdReverseCGSTAmount; InwrdReverseCGSTAmount)
            {
            }
            column(InwrdReverseSGSTUTGSTAmount; InwrdReverseSGSTUTGSTAmount)
            {
            }
            column(InwrdReverseCESSAmount; InwrdReverseCESSAmount)
            {
            }
            column(TaxableECommTotalAmount; -TaxableECommTotalAmount)
            {
            }
            column(TaxableECommCGSTAmount; -TaxableECommCGSTAmount)
            {
            }
            column(TaxableECommSGSTUTGSTAmount; -TaxableECommSGSTUTGSTAmount)
            {
            }
            column(TaxableECommIGSTAmount; -TaxableECommIGSTAmount)
            {
            }
            column(TaxableECommCESSAmount; TaxableECommCESSAmount)
            {
            }
            column(AllOtherITCIGSTAmount; AllOtherITCIGSTAmount)
            {
            }
            column(AllOtherITCCGSTAmount; AllOtherITCCGSTAmount)
            {
            }
            column(AllOtherITCSGSTUTGSTAmount; AllOtherITCSGSTUTGSTAmount)
            {
            }
            column(AllOtherITCCESSAmount; AllOtherITCCESSAmount)
            {
            }
            column(IneligibleITCIGSTAmount; IneligibleITCIGSTAmount)
            {
            }
            column(IneligibleITCCGSTAmount; IneligibleITCCGSTAmount)
            {
            }
            column(IneligibleITCSGSTUTGSTAmount; IneligibleITCSGSTUTGSTAmount)
            {
            }
            column(IneligibleITCCESSAmount; IneligibleITCCESSAmount)
            {
            }
            column(InwrdISDIGSTAmount; InwrdISDIGSTAmount)
            {
            }
            column(InwrdISDCGSTAmount; InwrdISDCGSTAmount)
            {
            }
            column(InwrdISDSGSTUTGSTAmount; InwrdISDSGSTUTGSTAmount)
            {
            }
            column(InwrdISDCESSAmount; InwrdISDCESSAmount)
            {
            }
            column(InterStateCompSupplyAmount; InterStateCompSupplyAmount)
            {
            }
            column(IntraStateCompSupplyAmount; IntraStateCompSupplyAmount)
            {
            }
            column(PurchInterStateAmount; PurchInterStateAmount)
            {
            }
            column(PurchIntraStateAmount; PurchIntraStateAmount)
            {
            }
            column(SupplyUnregLbl; SupplyUnregLbl)
            {
            }
            column(SupplyCompLbl; SupplyCompLbl)
            {
            }
            column(SupplyUINLbl; SupplyUINLbl)
            {
            }
            column(OthersIGSTAmount; OthersIGSTAmount)
            {
            }
            column(OthersCGSTAmount; OthersCGSTAmount)
            {
            }
            column(OthersSGSTUTGSTAmount; OthersSGSTUTGSTAmount)
            {
            }
            column(OthersCESSAmount; OthersCESSAmount)
            {
            }
            column(InwrdtotalAmount1; InwrdtotalAmount1)
            {
            }
            column(InwrdIGSTAmount1; InwrdIGSTAmount1)
            {
            }
            column(InwrdCGSTAmount1; InwrdCGSTAmount1)
            {
            }
            column(InwrdSGSTUTGSTAmount1; InwrdSGSTUTGSTAmount1)
            {
            }
            column(InwrdCESSAmount1; InwrdCESSAmount1)
            {
            }
            column(InwrdReverseIGSTAmount1; InwrdReverseIGSTAmount1)
            {
            }
            column(InwrdReverseCGSTAmount1; InwrdReverseCGSTAmount1)
            {
            }
            column(InwrdReverseSGSTUTGSTAmount1; InwrdReverseSGSTUTGSTAmount1)
            {
            }
            column(InwrdReverseCESSAmount1; InwrdReverseCESSAmount1)
            {
            }
            column(ImportServiceIGSTAmount1; ImportServiceIGSTAmount1)
            {
            }
            column(ImportServiceCGSTAmount1; ImportServiceCGSTAmount1)
            {
            }
            column(ImportServiceSGSTUTGSTAmount1; ImportServiceSGSTUTGSTAmount1)
            {
            }
            column(ImportServiceCESSAmount1; ImportServiceCESSAmount1)
            {
            }
            column(TDSCGSTAmount; TDSCGSTAmount)
            {
            }
            column(TDSSGSTAmount; TDSSGSTAmount)
            {
            }
            column(TDSIGSTAmount; TDSIGSTAmount)
            {
            }
            column(TCSCGSTAmount; TCSCGSTAmount)
            {
            }
            column(TCSSGSTAmount; TCSSGSTAmount)
            {
            }
            column(TCSIGSTAmount; TCSIGSTAmount)
            {
            }
            column(InstructionsLbl; InstructionsLbl)
            {
            }
            column(Instruction1Lbl; Instruction1Lbl)
            {
            }
            column(Instruction2Lbl; Instruction2Lbl)
            {
            }
            column(Instruction3Lbl; Instruction3Lbl)
            {
            }

            trigger OnPreDataItem()
            begin
                for i := 1 to 15 do
                    if GSTIN = '' then
                        gstinchar[i] := ''
                    else
                        gstinchar[i] := CopyStr(GSTIN, i, 1);

                if PeriodDate = 0D then
                    Error(PeriodDateErr);
                if AuthorisedPerson = '' then
                    Error(AuthErr);
                if Place = '' then
                    Error(PlaceErr);
                if PostingDate = 0D then
                    Error(PostingDateBlankErr);

                Month := Date2DMY(PeriodDate, 2) - 1;
                Year := Format(Date2DMY(PeriodDate, 3));
                StartingDate := CalcDate('<-CM>', PeriodDate);
                EndingDate := CalcDate('<CM>', PeriodDate);
                CompanyInformation.Get();
                CalculateValues();
            end;
        }
        dataitem(SupplyUnreg; "Detailed GST Ledger Entry")
        {
            DataItemTableView = where("GST Jurisdiction Type" = const(Interstate));
            column(PlaceOfSupplyUnreg; PlaceOfSupplyUnreg)
            {
            }
            column(SupplyBaseAmtUnreg; -SupplyBaseAmtUnreg)
            {
            }
            column(SupplyIGSTAmtUnreg; -SupplyIGSTAmtUnreg)
            {
            }

            trigger OnAfterGetRecord()
            var
                DetailedGSTLedgerEntryInfo: record "Detailed GST Ledger Entry Info";
                GSTAmtGSTR3B: Query "GST Amount GSTR3B";
                Count: Integer;
            begin
                DetailedGSTLedgerEntryInfo.Get(SupplyUnreg."Entry No.");
                if not (DetailedGSTLedgerEntryInfo."Component Calc. Type" IN [DetailedGSTLedgerEntryInfo."Component Calc. Type"::General,
                                                                                DetailedGSTLedgerEntryInfo."Component Calc. Type"::Threshold,
                                                                                DetailedGSTLedgerEntryInfo."Component Calc. Type"::"Cess %"])
                then
                    Count := 0;
                GSTAmtGSTR3B.SetRange(Location__Reg__No_, GSTIN);
                GSTAmtGSTR3B.SetRange(Posting_Date, StartingDate, EndingDate);
                GSTAmtGSTR3B.SetRange(Source_Type, "Source Type"::Customer);
                GSTAmtGSTR3B.SetRange(GST_Customer_Type, "GST Customer Type"::Unregistered);
                GSTAmtGSTR3B.SetRange(Entry_Type, "Entry Type");
                GSTAmtGSTR3B.SetRange(Document_Type, "Document Type");
                GSTAmtGSTR3B.SetRange(Document_No_, "Document No.");
                GSTAmtGSTR3B.SetRange(Transaction_No_, "Transaction No.");
                GSTAmtGSTR3B.SetRange(Original_Doc__No_, DetailedGSTLedgerEntryInfo."Original Doc. No.");
                GSTAmtGSTR3B.SetRange(Document_Line_No_, "Document Line No.");
                GSTAmtGSTR3B.SetRange(Original_Invoice_No_, "Original Invoice No.");
                GSTAmtGSTR3B.SetRange(Item_Charge_Assgn__Line_No_, DetailedGSTLedgerEntryInfo."Item Charge Assgn. Line No.");
                GSTAmtGSTR3B.SetFilter(e_Comm__Merchant_Id, '%1', '');
                GSTAmtGSTR3B.Open();
                while GSTAmtGSTR3B.Read() do
                    if Count < 1 then begin
                        SupplyBaseAmtUnreg := GSTAmtGSTR3B.GST_Base_Amount;
                        Count := 1;
                    end
                    else
                        SupplyBaseAmtUnreg := (GSTAmtGSTR3B.GST_Base_Amount / 2);

                if "GST Base Amount" <> 0 then begin
                    if DetailedGSTLedgerEntryInfo."Shipping Address State Code" <> '' then
                        PlaceOfSupplyUnreg := DetailedGSTLedgerEntryInfo."Shipping Address State Code"
                    else
                        PlaceOfSupplyUnreg := DetailedGSTLedgerEntryInfo."Buyer/Seller State Code";
                    SupplyIGSTAmtUnreg := GetSupplyGSTAmountLine(SupplyUnreg, IGSTLbl);
                end;
                GSTAmtGSTR3B.Close();
            end;

            trigger OnPreDataItem()
            begin
                SetCurrentKey("Location  Reg. No.", "Source Type", "GST Customer Type", "Posting Date");
                SetRange("Location  Reg. No.", GSTIN);
                SetRange("Source Type", "Source Type"::Customer);
                SetFilter("GST Customer Type", '%1', "GST Customer Type"::Unregistered);
                SetRange("Posting Date", StartingDate, EndingDate);
                SetCurrentKey("Transaction Type", "Entry Type", "Document Type", "Document No.",
                  "Transaction No.", "Document Line No.", "Original Invoice No.");
            end;
        }
        dataitem(SupplyUIN; "Detailed GST Ledger Entry")
        {
            DataItemTableView = where("GST Jurisdiction Type" = const(Interstate));
            column(PlaceOfSupplyUIN; PlaceOfSupplyUIN)
            {
            }
            column(SupplyBaseAmtUIN; -SupplyBaseAmtUIN)
            {
            }
            column(SupplyIGSTAmtUIN; -SupplyIGSTAmtUIN)
            {
            }

            trigger OnAfterGetRecord()
            var
                DetailedGSTLedgerEntryInfo: record "Detailed GST Ledger Entry Info";
                Customer: Record Customer;
                GSTAmtGSTR3B: Query "GST Amount GSTR3B";
            begin
                Customer.Get(SupplyUIN."Source No.");
                if Customer."GST Registration Type" <> Customer."GST Registration Type"::UID then
                    CurrReport.skip();
                DetailedGSTLedgerEntryInfo.Get(SupplyUIN."Entry No.");
                if not (DetailedGSTLedgerEntryInfo."Component Calc. Type" IN [DetailedGSTLedgerEntryInfo."Component Calc. Type"::General,
                                                                                DetailedGSTLedgerEntryInfo."Component Calc. Type"::Threshold,
                                                                                DetailedGSTLedgerEntryInfo."Component Calc. Type"::"Cess %"])
                then
                    GSTAmtGSTR3B.SetRange(Location__Reg__No_, GSTIN);
                GSTAmtGSTR3B.SetRange(Posting_Date, StartingDate, EndingDate);
                GSTAmtGSTR3B.SetRange(Source_Type, "Source Type"::Customer);
                GSTAmtGSTR3B.SetRange(Entry_Type, "Entry Type");
                GSTAmtGSTR3B.SetRange(Document_Type, "Document Type");
                GSTAmtGSTR3B.SetRange(Document_No_, "Document No.");
                GSTAmtGSTR3B.SetRange(Transaction_No_, "Transaction No.");
                GSTAmtGSTR3B.SetRange(Original_Doc__No_, DetailedGSTLedgerEntryInfo."Original Doc. No.");
                GSTAmtGSTR3B.SetRange(Document_Line_No_, "Document Line No.");
                GSTAmtGSTR3B.SetRange(Original_Invoice_No_, "Original Invoice No.");
                GSTAmtGSTR3B.SetRange(Item_Charge_Assgn__Line_No_, DetailedGSTLedgerEntryInfo."Item Charge Assgn. Line No.");
                GSTAmtGSTR3B.SetFilter(e_Comm__Merchant_Id, '%1', '');
                GSTAmtGSTR3B.Open();
                while GSTAmtGSTR3B.Read() do
                    SupplyBaseAmtUIN := (GSTAmtGSTR3B.GST_Base_Amount / 2);

                if "GST Base Amount" <> 0 then begin
                    if DetailedGSTLedgerEntryInfo."Shipping Address State Code" <> '' then
                        PlaceOfSupplyUIN := DetailedGSTLedgerEntryInfo."Shipping Address State Code"
                    else
                        PlaceOfSupplyUIN := DetailedGSTLedgerEntryInfo."Buyer/Seller State Code";
                    SupplyIGSTAmtUIN := GetSupplyGSTAmountLine(SupplyUIN, IGSTLbl);
                end;
                GSTAmtGSTR3B.Close();
            end;

            trigger OnPreDataItem()
            begin
                SetCurrentKey("Location  Reg. No.", "Source Type", "GST Customer Type", "Posting Date");
                SetRange("Location  Reg. No.", GSTIN);
                SetRange("Source Type", "Source Type"::Customer);
                SetFilter("GST Customer Type", '%1', "GST Customer Type"::Registered);
                SetRange("Posting Date", StartingDate, EndingDate);
                SetCurrentKey("Transaction Type", "Entry Type", "Document Type",
                  "Document No.", "Transaction No.", "Document Line No.",
                  "Original Invoice No.");
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("GSTIN No"; GSTIN)
                {
                    Caption = 'GSTIN No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number for which the report will be generated.';
                    TableRelation = "GST Registration Nos.";
                }
                field("Period Date"; PeriodDate)
                {
                    Caption = 'Period Date';
                    ToolTip = 'Specifies the date that you want the period of the Return.';
                    ApplicationArea = Basic, Suite;
                }
                field("Authorised Person"; AuthorisedPerson)
                {
                    Caption = 'Name of the Authorized Person';
                    ToolTip = 'Specifies the Authorised Person Name for Print on Report.';
                    ApplicationArea = Basic, Suite;
                }
                field("Place Name"; Place)
                {
                    Caption = 'Place';
                    ToolTip = 'Specifies the Place Name for Print on Reports.';
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; PostingDate)
                {
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the Date for print on Reports. Date should be after end of the period.';
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        if PeriodDate = 0D then
                            Error(PeriodDateErr);
                        if PostingDate <= CalcDate('<CM>', PeriodDate) then
                            Error(PostingDateErr, CalcDate('<CM>', PeriodDate));
                    end;
                }
            }
        }
    }

    var
        CompanyInformation: Record "Company Information";
        GSTIN: Code[15];
        PeriodDate: Date;
        AuthorisedPerson: Text[100];
        Place: Text[50];
        PostingDate: Date;
        Month: Option January,February,March,April,May,June,July,August,September,October,November,December;
        Year: Code[4];
        StartingDate: Date;
        EndingDate: Date;
        PlaceOfSupplyUnreg: Code[10];
        SupplyBaseAmtUnreg: Decimal;
        SupplyIGSTAmtUnreg: Decimal;
        PlaceOfSupplyUIN: Code[10];
        SupplyBaseAmtUIN: Decimal;
        SupplyIGSTAmtUIN: Decimal;
        OwrdtaxableTotalAmount: Decimal;
        TaxableECommTotalAmount: Decimal;
        TaxableECommIGSTAmount: Decimal;
        TaxableECommCGSTAmount: Decimal;
        TaxableECommSGSTUTGSTAmount: Decimal;
        TaxableECommCESSAmount: Decimal;
        OwrdtaxableIGSTAmount: Decimal;
        OwrdtaxableCGSTAmount: Decimal;
        OwrdtaxableSGSTUTGSTAmount: Decimal;
        OwrdtaxableCESSAmount: Decimal;
        OwrdZeroTotalAmount: Decimal;
        OwrdZeroIGSTAmount: Decimal;
        OwrdZeroCGSTAmount: Decimal;
        OwrdZeroSGSTUTGSTAmount: Decimal;
        OwrdZeroCESSAmount: Decimal;
        OwrdNilTotalAmount: Decimal;
        OwrdExempTotalAmount: Decimal;
        OwrdNilIGSTAmount: Decimal;
        OwrdNilCGSTAmount: Decimal;
        OwrdNilSGSTUTGSTAmount: Decimal;
        OwrdNilCESSAmount: Decimal;
        InwrdtotalAmount: Decimal;
        InwrdIGSTAmount: Decimal;
        InwrdCGSTAmount: Decimal;
        InwrdSGSTUTGSTAmount: Decimal;
        InwrdCESSAmount: Decimal;
        InwrdtotalAmount1: Decimal;
        InwrdIGSTAmount1: Decimal;
        InwrdCGSTAmount1: Decimal;
        InwrdSGSTUTGSTAmount1: Decimal;
        InwrdCESSAmount1: Decimal;
        OwrdNonGSTTotalAmount: Decimal;
        ImportGoodsIGSTAmount: Decimal;
        ImportGoodsCGSTAmount: Decimal;
        ImportGoodsSGSTUTGSTAmount: Decimal;
        ImportGoodsCESSAmount: Decimal;
        ImportServiceIGSTAmount: Decimal;
        ImportServiceCGSTAmount: Decimal;
        ImportServiceSGSTUTGSTAmount: Decimal;
        ImportServiceCESSAmount: Decimal;
        ImportServiceIGSTAmount1: Decimal;
        ImportServiceCGSTAmount1: Decimal;
        ImportServiceSGSTUTGSTAmount1: Decimal;
        ImportServiceCESSAmount1: Decimal;
        InwrdReverseIGSTAmount: Decimal;
        InwrdReverseCGSTAmount: Decimal;
        InwrdReverseSGSTUTGSTAmount: Decimal;
        InwrdReverseCESSAmount: Decimal;
        InwrdReverseIGSTAmount1: Decimal;
        InwrdReverseCGSTAmount1: Decimal;
        InwrdReverseSGSTUTGSTAmount1: Decimal;
        InwrdReverseCESSAmount1: Decimal;
        AllOtherITCIGSTAmount: Decimal;
        AllOtherITCCGSTAmount: Decimal;
        AllOtherITCSGSTUTGSTAmount: Decimal;
        AllOtherITCCESSAmount: Decimal;
        IneligibleITCIGSTAmount: Decimal;
        IneligibleITCCGSTAmount: Decimal;
        IneligibleITCSGSTUTGSTAmount: Decimal;
        IneligibleITCCESSAmount: Decimal;
        InwrdISDIGSTAmount: Decimal;
        InwrdISDCGSTAmount: Decimal;
        InwrdISDSGSTUTGSTAmount: Decimal;
        InwrdISDCESSAmount: Decimal;
        InterStateCompSupplyAmount: Decimal;
        IntraStateCompSupplyAmount: Decimal;
        PurchInterStateAmount: Decimal;
        PurchIntraStateAmount: Decimal;
        OthersIGSTAmount: Decimal;
        OthersCGSTAmount: Decimal;
        OthersSGSTUTGSTAmount: Decimal;
        OthersCESSAmount: Decimal;
        TCSCGSTAmount: Decimal;
        TCSSGSTAmount: Decimal;
        TCSIGSTAmount: Decimal;
        TDSCGSTAmount: Decimal;
        TDSSGSTAmount: Decimal;
        TDSIGSTAmount: Decimal;
        Sign: Integer;
        DocNoForOutWard: Text;
        i: Integer;
        PeriodDateErr: Label 'Period Date can not be Blank.', Locked = true;
        AuthErr: Label 'Provide a name for the Authorised Person.', Locked = true;
        PlaceErr: Label 'Provide the name of Place.', Locked = true;
        PostingDateBlankErr: Label 'Posting Date can not be Blank.', Locked = true;
        gstinchar: array[15] of Text[1];
        GSTRLbl: Label 'FORM GSTR-3B', Locked = true;
        RuleLbl: Label '[See rule 61(5)]', Locked = true;
        YearLbl: Label 'Year', Locked = true;
        MonthLbl: Label 'Month', Locked = true;
        GSTINLbl: Label 'Gstin', Locked = true;
        LegalNameLbl: Label 'Legal name of the registered person', Locked = true;
        TradeNameLbl: Label 'Trade name,if any', Locked = true;
        ARNLbl: Label 'ARN', Locked = true;
        DateofArnLbl: Label 'Date of ARN', Locked = true;
        OutwardSpplyLbl: Label 'Details of Outward Supplies and inward supplies liable to reverse charge (other than those covered by Table 3.1.1)', Locked = true;
        OutwardSpplyProvisioningLbl: Label 'Details of Supplies notified under section 9(5) of the CGST Act, 2017 and corresponding provisions in IGST/UTGST/SGST Acts', Locked = true;
        OutwardSupplyforelectronicLbl: Label '(i) Taxable Supplies on which electronic commerce operator pays tax u/s 9(5) [to be furnished by electronic commerce operator]', Locked = true;
        OutwardSupplyforRegisteredelectronicLbl: Label '(ii) Taxable supplies made by registered person through electronic commerce operator, on which electronic commerce operator is required to pay tax u/s 9(5) [to be furnished by registered person making supplies thorugh electronic commerce operator]', Locked = true;
        NatureofSpplyLbl: Label 'Nature of Supplies', Locked = true;
        TotTaxableLbl: Label 'Total Taxable Value', Locked = true;
        IntegratedLbl: Label 'Integrated Tax', Locked = true;
        CentralLbl: Label 'Central Tax', Locked = true;
        StateTaxLbl: Label 'State/UT Tax', Locked = true;
        OutwardTaxableSpplyLbl: Label '(a) Outward taxable supplies (other than zero rated, nil rated and exempted)', Locked = true;
        OutwardTaxableSpplyZeroLbl: Label '(b) Outward taxable supplies (zero rated )', Locked = true;
        OutwardTaxableSpplyNilLbl: Label '(c) Other outward supplies (Nil rated, exempted)', Locked = true;
        InwardSpplyLbl: Label '(d) Inward supplies (liable to reverse charge)', Locked = true;
        NonGSTOutwardSpplyLbl: Label '(e) Non-GST outward supplies', Locked = true;
        UnregCompoLbl: Label 'Out of supplies made in 3.1 (a) and 3.1.1 (i), details of interstate supplies made', Locked = true;
        PlaceOfSupplyLbl: Label 'Place of Supply     (State/UT)', Locked = true;
        IntegratedTaxLbl: Label 'Integrated Tax', Locked = true;
        InCashLbl: Label 'in cash', Locked = true;
        EligibleITCLbl: Label 'Eligible ITC', Locked = true;
        NatureOfSuppliesLbl: Label 'Nature of Supplies', Locked = true;
        ITCAvlLbl: Label '(A) ITC Available (whether in full or part)', Locked = true;
        ImportGoodLbl: Label '(1) Import of goods', Locked = true;
        ImportServiceLbl: Label '(2) Import of services', Locked = true;
        InwrdReverseLbl: Label '(3) Inward supplies liable to reverse charge (other    than 1 & 2 above)', Locked = true;
        InwrdISDLbl: Label '(4) Inward supplies from ISD', Locked = true;
        AllITCLbl: Label '(5) All other ITC', Locked = true;
        ITCReverseLbl: Label '(B) ITC Reversed', Locked = true;
        RulesLbl: Label '(1) As per rules 42 & 43 of CGST Rules', Locked = true;
        OthersLbl: Label '(2) Others', Locked = true;
        NetITCLbl: Label '(C) Net ITC Available (A) - (B)', Locked = true;
        IneligibleITCLbl: Label '(D) Ineligible ITC', Locked = true;
        SectionLbl: Label '(1) As per section 17(5)', Locked = true;
        ValuesExemptLbl: Label 'Values of exempt, nil-rated and non-GST inward supplies', Locked = true;
        ValuesForLateFeeLbl: Label 'Interest and Late fee for previous tax period', Locked = true;
        ComputedInterestLbl: Label 'System computed Interest', Locked = true;
        InterestPaidLbl: Label 'Interest Paid', Locked = true;
        InterStateSpplyLbl: Label 'Inter-State supplies', Locked = true;
        IntraStateLbl: Label 'Intra-State supplies', Locked = true;
        SupplierCompLbl: Label 'From a supplier under composition scheme, Exempt and Nil    rated supply', Locked = true;
        NonGSTSpplyLbl: Label 'Non GST supply', Locked = true;
        PaymentLbl: Label 'Payment of tax', Locked = true;
        PaymentOtherThanReverseChargeLbl: Label '(A) Other than reverse charge', Locked = true;
        PaymentReverseChargeLbl: Label '(B) Reverse charge', Locked = true;
        DescLbl: Label 'Description', Locked = true;
        TaxLbl: Label 'Total Tax', Locked = true;
        PayableLbl: Label 'payable', Locked = true;
        PaidITCLbl: Label 'Tax Paid through ITC', Locked = true;
        TaxPaidLbl: Label 'Tax paid ', Locked = true;
        TDSTCSLbl: Label 'TDS / TCS', Locked = true;
        TaxCessLbl: Label 'Tax / Cess', Locked = true;
        CashLbl: Label 'paid in cash', Locked = true;
        InterestLbl: Label 'Interest', Locked = true;
        LateFeeLbl: Label 'Late Fee paid', Locked = true;
        DetailsLbl: Label 'Details', Locked = true;
        GSTLbl: Label 'GST', locked = true;
        VerificationLbl: Label 'Verification (by Authorised Signatory)', Locked = true;
        VerifyTxtLbl: Label 'I hereby solemnly affirm and declare that the information given herein above is true and correct to the best of my knowledge and belief and nothing has been concealed there from.', Locked = true;
        PlaceLbl: Label 'Place :', Locked = true;
        DateLbl: Label 'Date :', Locked = true;
        SignatoryLbl: Label '(Authorised Signatory)', Locked = true;
        SupplyUnregLbl: Label 'Supplies made to Unregistered Persons', Locked = true;
        SupplyCompLbl: Label 'Supplies made to Composition Taxable Persons', Locked = true;
        SupplyUINLbl: Label 'Supplies made to UIN holders', Locked = true;
        PostingDateErr: Label 'Posting Date must be after Period End Date %1.', Comment = '%1= period date';
        IGSTLbl: Label 'IGST', Locked = true;
        CGSTLbl: Label 'CGST', Locked = true;
        SGSTLbl: Label 'SGST', Locked = true;
        CESSLbl: Label 'Cess', Locked = true;
        CESSCompLbl: Label 'CESS', Locked = true;
        InstructionsLbl: Label 'Instructions:', Locked = true;
        Instruction1Lbl: Label '1) Value of Taxable Supplies = Value of invoices + value of Debit Notes â€“ value of credit Notes + value of advances received for which invoices have not been issued in the same month â€“ value of advances adjusted against invoices.', Locked = true;
        Instruction2Lbl: Label '2) Details of advances as well as adjustment of same against invoices to be adjusted and not shown separately.', Locked = true;
        Instruction3Lbl: Label '3) Amendment in any details to be adjusted and not shown separately.', Locked = true;

    local procedure GetBaseAmount(EntryNo: Integer): Decimal
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        BaseAmount: Decimal;
    begin
        if not DetailedGSTLedgerEntry.Get(EntryNo) then
            exit;

        if DetailedGSTLedgerEntry."GST Component Code" = CESSCompLbl then
            exit;

        case DetailedGSTLedgerEntry."Entry Type" of
            DetailedGSTLedgerEntry."Entry Type"::"Initial Entry":
                if (DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::Invoice) or
                   (DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::"Credit Memo")
                then
                    BaseAmount := DetailedGSTLedgerEntry."GST Base Amount"
                else
                    if DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::Payment then
                        BaseAmount := DetailedGSTLedgerEntry."GST Base Amount";
            DetailedGSTLedgerEntry."Entry Type"::Application:
                BaseAmount := DetailedGSTLedgerEntry."GST Base Amount";
        end;

        if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Intrastate then
            exit(BaseAmount / 2)
        else
            exit(BaseAmount);
    end;

    local procedure GetOutwardBaseAmount(EntryNo: Integer; DocumentNo: Text): Decimal
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        BaseAmount: Decimal;
    begin
        if not DetailedGSTLedgerEntry.Get(EntryNo) then
            exit;

        if DetailedGSTLedgerEntry."GST Component Code" = CESSCompLbl then
            exit;

        case DetailedGSTLedgerEntry."Entry Type" of
            DetailedGSTLedgerEntry."Entry Type"::"Initial Entry":
                if (DocumentNo <> DocNoForOutWard) and (DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::Invoice)
                then
                    BaseAmount := DetailedGSTLedgerEntry."GST Base Amount"
                else
                    if (DocumentNo <> DocNoForOutWard) and (DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::"Credit Memo")
                    then
                        BaseAmount := DetailedGSTLedgerEntry."GST Base Amount"
                    else
                        if DetailedGSTLedgerEntry."Document Type" = DetailedGSTLedgerEntry."Document Type"::Payment then
                            BaseAmount := DetailedGSTLedgerEntry."GST Base Amount";
            DetailedGSTLedgerEntry."Entry Type"::Application:
                BaseAmount := DetailedGSTLedgerEntry."GST Base Amount";
        end;

        if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Intrastate then begin
            DocNoForOutWard := DocumentNo;
            exit(BaseAmount);
        end
    end;

    local procedure GetSupplyGSTAmountLine(DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; ComponentCode: Code[20]): Decimal
    var
        TaxComponent: Record "Tax Component";
    begin
        TaxComponent.SetRange("Tax Type", GSTLbl);
        TaxComponent.SetRange(Name, DetailedGSTLedgerEntry."GST Component Code");
        if TaxComponent.FindFirst() then
            if TaxComponent.Name = ComponentCode then
                exit(DetailedGSTLedgerEntry."GST Amount");
    end;

    local procedure GetSupplyGSTAmountISDLine(DetailedGSTDistEntry: Record "Detailed GST Dist. Entry"; ComponentCode: Code[20]): Decimal
    var
        TaxComponent: Record "Tax Component";
    begin
        TaxComponent.SetRange("Tax Type", GSTLbl);
        TaxComponent.SetRange(Name, DetailedGSTDistEntry."Rcpt. Component Code");
        if TaxComponent.FindFirst() then
            if TaxComponent.Name = ComponentCode then
                exit(DetailedGSTDistEntry."Distribution Amount");
    end;

    local procedure CalculateValues()
    begin
        OutwardTaxableSupplies();
        OutwardTaxableSuppliesZeroRated();
        OutwardSuppliesNilRated();
        OutwardSuppliesForExempted();
        InwardSuppliesReverseCharge();
        InwardSuppliesReverseChargeforGSTAdjustment();
        NonGSTOutwardSupplies();
        ImportGoodsServiceInwardReverse();
        TaxableSuppliesWithECommerce();
        AllAndIneligibleITC();
        InputFromComposition();
        InwardFromISD();
        NonGSTInwardSupply();
        GSTTDSTCSAmount();
    end;

    local procedure ImportGoodsServiceInwardReverse()
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGstLedEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        // Eligible ITC
        // Import of Goods
        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetCurrentKey("Location  Reg. No.", "Posting Date", "Transaction Type", "Source Type", "GST Credit",
          "Credit Availed", "GST Vendor Type", "GST Group Type");
        DetailedGSTLedgerEntry.SetRange("Location  Reg. No.", GSTIN);
        DetailedGSTLedgerEntry.SetRange("Posting Date", StartingDate, EndingDate);
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Source Type", "Source Type"::Vendor);
        DetailedGSTLedgerEntry.SetRange("GST Credit", "GST Credit"::Availment);
        DetailedGSTLedgerEntry.SetRange("Credit Availed", true);
        DetailedGSTLedgerEntry.SetRange("GST Group Type", "GST Group Type"::Goods);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if DetailedGSTLedgerEntry."GST Vendor Type" = DetailedGSTLedgerEntry."GST Vendor Type"::Import then begin
                    ImportGoodsIGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, IGSTLbl);
                    ImportGoodsCGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CGSTLbl);
                    ImportGoodsSGSTUTGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, SGSTLbl);
                    ImportGoodsCESSAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CESSCompLbl);
                end else
                    DetailedGSTLedgerEntryInfo.Reset();
                DetailedGSTLedgerEntryInfo.SetRange("Entry No.", DetailedGSTLedgerEntry."Entry No.");
                if DetailedGSTLedgerEntryInfo.FindSet() then
                    if (DetailedGSTLedgerEntry."GST Vendor Type" = DetailedGSTLedgerEntry."GST Vendor Type"::SEZ)
                          and (DetailedGSTLedgerEntryInfo."Without Bill Of Entry" = false) then begin
                        ImportGoodsIGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, IGSTLbl);
                        ImportGoodsCGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CGSTLbl);
                        ImportGoodsSGSTUTGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, SGSTLbl);
                        ImportGoodsCESSAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CESSCompLbl);
                    end;
            until DetailedGSTLedgerEntry.Next() = 0;

        // Import of Services
        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetCurrentKey("Location  Reg. No.", "Posting Date", "Transaction Type", "Source Type", "GST Credit",
         "Credit Availed", "GST Vendor Type", "GST Group Type");
        DetailedGSTLedgerEntry.SetRange("Location  Reg. No.", GSTIN);
        DetailedGSTLedgerEntry.SetRange("Posting Date", StartingDate, EndingDate);
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Source Type", "Source Type"::Vendor);
        DetailedGSTLedgerEntry.SetRange("GST Credit", "GST Credit"::Availment);
        DetailedGSTLedgerEntry.SetRange("Credit Availed", true);
        DetailedGSTLedgerEntry.SetRange("GST Group Type", "GST Group Type"::Service);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                DetailedGstLedEntry.CopyFilters(DetailedGSTLedgerEntry);
                GetImportofServiceValue(DetailedGstLedEntry);
            until DetailedGSTLedgerEntry.Next() = 0;

        Sign := 1;
        // Inward supplies liable to reverse charge
        DetailedGSTLedgerEntry.SetRange("GST Vendor Type", "GST Vendor Type"::Registered, "GST Vendor Type"::Unregistered);
        DetailedGSTLedgerEntry.SetRange("GST Group Type");
        DetailedGSTLedgerEntry.SetRange("Reverse Charge", true);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if DetailedGSTLedgerEntry."Entry Type" = "Entry Type"::Application then
                    if DetailedGSTLedgerEntry."GST Group Type" = "GST Group Type"::Service then
                        Sign := -1;

                InwrdReverseIGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, IGSTLbl) * Sign;
                InwrdReverseCGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CGSTLbl) * Sign;
                InwrdReverseSGSTUTGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, SGSTLbl) * Sign;
                InwrdReverseCESSAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CESSCompLbl) * Sign;
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure GetImportofServiceValue(DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry")
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        DetailedGSTLedgerEntry.SetRange("GST Vendor Type", "GST Vendor Type"::Import, "GST Vendor Type"::SEZ);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::Application);
        DetailedGSTLedgerEntry.SetRange("Reverse Charge", true);
        DetailedGSTLedgerEntry.SetRange("Associated Enterprises", false);
        if DetailedGSTLedgerEntry.FindFirst() then begin
            DetailedGSTLedgerEntryInfo.SetRange("Entry No.", DetailedGSTLedgerEntry."Entry No.");
            if DetailedGSTLedgerEntryInfo."Without Bill Of Entry" = false then begin
                Sign := -1;
                ImportServiceIGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, IGSTLbl) * Sign;
                ImportServiceCGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CGSTLbl) * Sign;
                ImportServiceSGSTUTGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, SGSTLbl) * Sign;
                ImportServiceCESSAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CESSCompLbl) * Sign;
            end;
        end;
    end;

    local procedure AllAndIneligibleITC()
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedCrAdjstmntEntry: Record "Detailed Cr. Adjstmnt. Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        // All other ITC
        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetCurrentKey("Location  Reg. No.", "Posting Date", "Transaction Type", "Source Type",
          "Input Service Distribution", "Reverse Charge", "GST Credit", "Credit Availed");
        DetailedGSTLedgerEntry.SetRange("Location  Reg. No.", GSTIN);
        DetailedGSTLedgerEntry.SetRange("Posting Date", StartingDate, EndingDate);
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Source Type", "Source Type"::Vendor);
        DetailedGSTLedgerEntry.SetRange("Input Service Distribution", false);
        DetailedGSTLedgerEntry.SetRange("Reverse Charge", false);
        DetailedGSTLedgerEntry.SetRange("GST Credit", "GST Credit"::Availment);
        DetailedGSTLedgerEntry.SetRange("Credit Availed", true);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                DetailedGSTLedgerEntryInfo.Reset();
                DetailedGSTLedgerEntryInfo.SetRange("Entry No.", DetailedGSTLedgerEntry."Entry No.");
                if DetailedGSTLedgerEntryInfo.FindSet() then
                    if (DetailedGSTLedgerEntry."GST Vendor Type" = DetailedGSTLedgerEntry."GST Vendor Type"::SEZ)
                         and (DetailedGSTLedgerEntry."GST Group Type" = DetailedGSTLedgerEntry."GST Group Type"::Goods)
                        and (DetailedGSTLedgerEntryInfo."Without Bill Of Entry" = true) then begin
                        AllOtherITCIGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, IGSTLbl);
                        AllOtherITCCGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CGSTLbl);
                        AllOtherITCSGSTUTGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, SGSTLbl);
                        AllOtherITCCESSAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CESSCompLbl);
                    end
                    else
                        if (DetailedGSTLedgerEntry."GST Vendor Type" = DetailedGSTLedgerEntry."GST Vendor Type"::Registered) then begin
                            AllOtherITCIGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, IGSTLbl);
                            AllOtherITCCGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CGSTLbl);
                            AllOtherITCSGSTUTGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, SGSTLbl);
                            AllOtherITCCESSAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CESSCompLbl);
                        end
                        else
                            if (DetailedGSTLedgerEntry."GST Vendor Type" = DetailedGSTLedgerEntry."GST Vendor Type"::SEZ)
                            and (DetailedGSTLedgerEntry."GST Group Type" = DetailedGSTLedgerEntry."GST Group Type"::Service)
                            and (DetailedGSTLedgerEntryInfo."Without Bill Of Entry" = false) then begin
                                AllOtherITCIGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, IGSTLbl);
                                AllOtherITCCGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CGSTLbl);
                                AllOtherITCSGSTUTGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, SGSTLbl);
                                AllOtherITCCESSAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CESSCompLbl);
                            end;
            until DetailedGSTLedgerEntry.Next() = 0;

        // Ineligible ITC  17(5) DGLE
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Reverse Charge");
        DetailedGSTLedgerEntry.SetRange("GST Credit", "GST Credit"::"Non-Availment");
        DetailedGSTLedgerEntry.SetRange("Credit Availed", FALSE);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                IneligibleITCIGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, IGSTLbl);
                IneligibleITCCGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CGSTLbl);
                IneligibleITCSGSTUTGSTAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, SGSTLbl);
                IneligibleITCCESSAmount += GetSupplyGSTAmountLine(DetailedGSTLedgerEntry, CESSCompLbl);
            until DetailedGSTLedgerEntry.Next() = 0;

        DetailedCrAdjstmntEntry.SetCurrentKey("Location  Reg. No.", "Posting Date", "Reverse Charge");
        DetailedCrAdjstmntEntry.SetRange("Location  Reg. No.", GSTIN);
        DetailedCrAdjstmntEntry.SetRange("Posting Date", StartingDate, EndingDate);
        DetailedCrAdjstmntEntry.SetRange("Reverse Charge", true);
        DetailedCrAdjstmntEntry.SetFilter("Credit Adjustment Type", '%1|%2',
          "Credit Adjustment Type"::"Credit Reversal", "Credit Adjustment Type"::"Reversal of Availment");
        if DetailedCrAdjstmntEntry.FindSet() then
            repeat
                AllOtherITCIGSTAmount += GetSupplyGSTAmountDCrAdjmntLine(DetailedCrAdjstmntEntry, IGSTLbl);
                AllOtherITCCGSTAmount += GetSupplyGSTAmountDCrAdjmntLine(DetailedCrAdjstmntEntry, CGSTLbl);
                AllOtherITCSGSTUTGSTAmount += GetSupplyGSTAmountDCrAdjmntLine(DetailedCrAdjstmntEntry, SGSTLbl);
                AllOtherITCCESSAmount += GetSupplyGSTAmountDCrAdjmntLine(DetailedCrAdjstmntEntry, CESSCompLbl);
            until DetailedCrAdjstmntEntry.Next() = 0;

        DetailedCrAdjstmntEntry.Reset();
        DetailedCrAdjstmntEntry.SetCurrentKey("Location  Reg. No.", "Posting Date", "Reverse Charge");
        DetailedCrAdjstmntEntry.SetRange("Location  Reg. No.", GSTIN);
        DetailedCrAdjstmntEntry.SetRange("Posting Date", StartingDate, EndingDate);
        DetailedCrAdjstmntEntry.SetRange("Reverse Charge", true);
        DetailedCrAdjstmntEntry.SetFilter("Credit Adjustment Type", '%1|%2',
          DetailedCrAdjstmntEntry."Credit Adjustment Type"::"Credit Availment", "Credit Adjustment Type"::"Credit Re-Availment");
        if DetailedCrAdjstmntEntry.FindSet() then
            repeat
                OthersIGSTAmount += GetSupplyGSTAmountDCrAdjmntLine(DetailedCrAdjstmntEntry, IGSTLbl);
                OthersCGSTAmount += GetSupplyGSTAmountDCrAdjmntLine(DetailedCrAdjstmntEntry, CGSTLbl);
                OthersSGSTUTGSTAmount += GetSupplyGSTAmountDCrAdjmntLine(DetailedCrAdjstmntEntry, SGSTLbl);
                OthersCESSAmount += GetSupplyGSTAmountDCrAdjmntLine(DetailedCrAdjstmntEntry, CESSCompLbl);
            until DetailedCrAdjstmntEntry.Next() = 0
    end;

    local procedure InwardFromISD()
    var
        DetailedGSTDistEntry: Record "Detailed GST Dist. Entry";
    begin
        // Inward Supplies from ISD
        DetailedGSTDistEntry.SetCurrentKey("Rcpt. GST Reg. No.", "Posting Date", "Rcpt. GST Credit", "Credit Availed");
        DetailedGSTDistEntry.SetRange("Rcpt. GST Reg. No.", GSTIN);
        DetailedGSTDistEntry.SetRange("Posting Date", StartingDate, EndingDate);
        DetailedGSTDistEntry.SetRange("Rcpt. GST Credit", DetailedGSTDistEntry."Rcpt. GST Credit"::Availment);
        DetailedGSTDistEntry.SetRange("Credit Availed", true);
        if DetailedGSTDistEntry.FindSet() then
            repeat
                InwrdISDIGSTAmount += GetSupplyGSTAmountISDLine(DetailedGSTDistEntry, IGSTLbl);
                InwrdISDCGSTAmount += GetSupplyGSTAmountISDLine(DetailedGSTDistEntry, CGSTLbl);
                InwrdISDSGSTUTGSTAmount += GetSupplyGSTAmountISDLine(DetailedGSTDistEntry, SGSTLbl);
                InwrdISDCESSAmount += GetSupplyGSTAmountISDLine(DetailedGSTDistEntry, CESSCompLbl);
            until DetailedGSTDistEntry.Next() = 0;

        // Ineligible ITC  17(5) DGDE
        DetailedGSTDistEntry.SetRange("Rcpt. GST Credit", DetailedGSTDistEntry."Rcpt. GST Credit"::"Non-Availment");
        DetailedGSTDistEntry.SetRange("Credit Availed", false);
        if DetailedGSTDistEntry.FindSet() then
            repeat
                IneligibleITCIGSTAmount += GetSupplyGSTAmountISDLine(DetailedGSTDistEntry, IGSTLbl);
                IneligibleITCCGSTAmount += GetSupplyGSTAmountISDLine(DetailedGSTDistEntry, CGSTLbl);
                IneligibleITCSGSTUTGSTAmount += GetSupplyGSTAmountISDLine(DetailedGSTDistEntry, SGSTLbl);
                IneligibleITCCESSAmount += GetSupplyGSTAmountISDLine(DetailedGSTDistEntry, CESSCompLbl);
            until DetailedGSTDistEntry.Next() = 0;
    end;

    local procedure GetSupplyGSTAmountDCrAdjmntLine(DetailedCrAdjstmntEntry: Record "Detailed Cr. Adjstmnt. Entry"; ComponentCode: Code[20]): Decimal
    var
        TaxComponent: Record "Tax Component";
    begin
        TaxComponent.SetRange("Tax Type", GSTLbl);
        TaxComponent.SetRange(Name, DetailedCrAdjstmntEntry."GST Component Code");
        if TaxComponent.FindFirst() then
            if TaxComponent.Name = ComponentCode then
                exit(DetailedCrAdjstmntEntry."GST Amount");
    end;

    local procedure InwardSuppliesReverseChargeforGSTAdjustment()
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        PostedGSTLiabilityAdj: Record "Posted GST Liability Adj.";
        DocNo: Code[20];
        GSTBaseAmount: Decimal;
        GSTBaseAmount1: Decimal;
        LineNo: Integer;
        LineNo1: Integer;
    begin
        Clear(LineNo);
        Clear(DocNo);
        Clear(LineNo1);
        PostedGSTLiabilityAdj.Reset();
        PostedGSTLiabilityAdj.SetRange("Location  Reg. No.", GSTIN);
        PostedGSTLiabilityAdj.SetRange("Posting Date", StartingDate, EndingDate);
        PostedGSTLiabilityAdj.SetRange("Liable to Pay", true);
        if PostedGSTLiabilityAdj.FindSet() then
            repeat
                DetailedGSTLedgerEntry.SetRange("Document No.", PostedGSTLiabilityAdj."Document No.");
                DetailedGSTLedgerEntry.SetRange("Document Type", PostedGSTLiabilityAdj."Document Type");
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
                if DetailedGSTLedgerEntry.FindSet() then
                    repeat
                        if PostedGSTLiabilityAdj."Credit Adjustment Type" = PostedGSTLiabilityAdj."Credit Adjustment Type"::Generate then begin
                            if (LineNo <> DetailedGSTLedgerEntry."Document Line No.") and
                               (DocNo <> DetailedGSTLedgerEntry."Document No.")
                            then
                                GSTBaseAmount := DetailedGSTLedgerEntry."GST Base Amount";
                            LineNo := DetailedGSTLedgerEntry."Document Line No.";
                        end else begin
                            if (LineNo1 <> DetailedGSTLedgerEntry."Document Line No.") and
                               (DocNo <> DetailedGSTLedgerEntry."Document No.")
                            then
                                GSTBaseAmount1 := DetailedGSTLedgerEntry."GST Base Amount";
                            LineNo1 := DetailedGSTLedgerEntry."Document Line No.";
                        end;
                        DocNo := DetailedGSTLedgerEntry."Document No.";
                    until DetailedGSTLedgerEntry.Next() = 0;

                InwrdtotalAmount1 := GSTBaseAmount - GSTBaseAmount1;
                InwrdIGSTAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, IGSTLbl);
                InwrdCGSTAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, CGSTLbl);
                InwrdSGSTUTGSTAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, SGSTLbl);
                InwrdCESSAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, CESSCompLbl);
            until PostedGSTLiabilityAdj.Next() = 0;
        InwardSuppliesReverseChargeforGSTAdjCreditAvail();
    end;

    local procedure InwardSuppliesReverseChargeforGSTAdjCreditAvail()
    var
        PostedGSTLiabilityAdj: Record "Posted GST Liability Adj.";
    begin
        PostedGSTLiabilityAdj.Reset();
        PostedGSTLiabilityAdj.SetRange("Location  Reg. No.", GSTIN);
        PostedGSTLiabilityAdj.SetRange("Posting Date", StartingDate, EndingDate);
        PostedGSTLiabilityAdj.SetRange("Credit Availed", true);
        if PostedGSTLiabilityAdj.FindSet() then
            repeat
                if not (PostedGSTLiabilityAdj."GST Vendor Type" = PostedGSTLiabilityAdj."GST Vendor Type"::Import) then begin
                    InwrdReverseIGSTAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, IGSTLbl);
                    InwrdReverseCGSTAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, CGSTLbl);
                    InwrdReverseSGSTUTGSTAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, SGSTLbl);
                    InwrdReverseCESSAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, CESSCompLbl);
                end else begin
                    ImportServiceIGSTAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, IGSTLbl);
                    ImportServiceCGSTAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, CGSTLbl);
                    ImportServiceSGSTUTGSTAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, SGSTLbl);
                    ImportServiceCESSAmount1 += GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj, CESSCompLbl);
                end;
            until PostedGSTLiabilityAdj.Next() = 0;
    end;

    local procedure GetSupplyGSTAmountRecforGSTAdjust(PostedGSTLiabilityAdj: Record "Posted GST Liability Adj."; ComponentCode: Code[20]): Decimal
    var
        TaxComponent: Record "Tax Component";
        GSTAmount: Decimal;
    begin
        TaxComponent.SetRange("Tax Type", GSTLbl);
        TaxComponent.SetRange(Name, PostedGSTLiabilityAdj."GST Component Code");
        if TaxComponent.FindFirst() then
            if TaxComponent.Name = ComponentCode then
                GSTAmount += PostedGSTLiabilityAdj."GST Amount";

        exit(GSTAmount);
    end;

    local procedure OutwardTaxableSupplies()
    var
        GSTAmountGSTR3B: Query "GST Amount GSTR3B";
    begin
        GSTAmountGSTR3B.SetRange(Location__Reg__No_, GSTIN);
        GSTAmountGSTR3B.SetRange(Posting_Date, StartingDate, EndingDate);
        GSTAmountGSTR3B.SetFilter(GST__, '<>%1', 0);
        GSTAmountGSTR3B.SetRange(GST_Exempted_Goods, false);
        GSTAmountGSTR3B.SetRange(Transaction_Type, "Detail Ledger Transaction Type"::Sales);
        GSTAmountGSTR3B.SetFilter(GST_Customer_Type, '%1|%2|%3',
          "GST Customer Type"::Registered,
          "GST Customer Type"::Unregistered,
          "GST Customer Type"::" ");
        GSTAmountGSTR3B.SetFilter(Component_Calc__Type, '%1|%2|%3',
          "Component Calc Type"::General,
          "Component Calc Type"::Threshold,
          "Component Calc Type"::"Cess %");
        GSTAmountGSTR3B.SetFilter(e_Comm__Merchant_Id, '%1', '');
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdtaxableTotalAmount += GetBaseAmount(GSTAmountGSTR3B.Entry_No_);
        GSTAmountGSTR3B.Close();

        GSTAmountGSTR3B.SetRange(GST_Component_Code, IGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdtaxableIGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();

        GSTAmountGSTR3B.SetRange(GST_Component_Code, CGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdtaxableCGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, SGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdtaxableSGSTUTGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, CESSCompLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdtaxableCESSAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
    end;

    local procedure OutwardTaxableSuppliesZeroRated()
    var
        GSTAmountGSTR3B: Query "GST Amount GSTR3B";
    begin
        GSTAmountGSTR3B.SetRange(Location__Reg__No_, GSTIN);
        GSTAmountGSTR3B.SetRange(Posting_Date, StartingDate, EndingDate);
        GSTAmountGSTR3B.SetRange(Transaction_Type, "Detail Ledger Transaction Type"::Sales);
        GSTAmountGSTR3B.SetFilter(GST_Customer_Type, '%1|%2|%3|%4',
          "GST Customer Type"::Export,
          "GST Customer Type"::"Deemed Export",
          "GST Customer Type"::"SEZ Unit",
          "GST Customer Type"::"SEZ Development");
        GSTAmountGSTR3B.SetFilter(Component_Calc__Type, '%1|%2|%3',
          "Component Calc Type"::General,
          "Component Calc Type"::Threshold,
          "Component Calc Type"::"Cess %");
        GSTAmountGSTR3B.SetFilter(e_Comm__Merchant_Id, '%1', '');
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdZeroTotalAmount += GetBaseAmount(GSTAmountGSTR3B.Entry_No_);
        GSTAmountGSTR3B.Close();

        GSTAmountGSTR3B.SetRange(GST_Component_Code, IGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdZeroIGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, CGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdZeroCGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, SGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdZeroSGSTUTGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, CESSCompLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdZeroCESSAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
    end;

    local procedure OutwardSuppliesNilRated()
    var
        GSTAmountGSTR3B: Query "GST Amount GSTR3B";
    begin
        GSTAmountGSTR3B.SetRange(Location__Reg__No_, GSTIN);
        GSTAmountGSTR3B.SetRange(Posting_Date, StartingDate, EndingDate);
        GSTAmountGSTR3B.SetFilter(GST__, '%1', 0);
        GSTAmountGSTR3B.SetRange(Transaction_Type, "Detail Ledger Transaction Type"::Sales);
        GSTAmountGSTR3B.SetFilter(GST_Customer_Type, '%1|%2|%3',
          "GST Customer Type"::Registered,
          "GST Customer Type"::Unregistered,
          "GST Customer Type"::" ");
        GSTAmountGSTR3B.SetFilter(Component_Calc__Type, '%1|%2|%3',
          "Component Calc Type"::General,
          "Component Calc Type"::Threshold,
          "Component Calc Type"::"Cess %");
        GSTAmountGSTR3B.SetFilter(e_Comm__Merchant_Id, '%1', '');
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdNilTotalAmount += GetBaseAmount(GSTAmountGSTR3B.Entry_No_);
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, IGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdNilIGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, CGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdNilCGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, SGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdNilSGSTUTGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, CESSCompLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdNilCESSAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
    end;

    local procedure OutwardSuppliesForExempted()
    var
        GSTAmountGSTR3B: Query "GST Amount GSTR3B";
    begin
        GSTAmountGSTR3B.SetRange(Location__Reg__No_, GSTIN);
        GSTAmountGSTR3B.SetRange(Posting_Date, StartingDate, EndingDate);
        GSTAmountGSTR3B.SetRange(GST_Exempted_Goods, true);
        GSTAmountGSTR3B.SetRange(Transaction_Type, "Detail Ledger Transaction Type"::Sales);
        GSTAmountGSTR3B.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Exempted);
        GSTAmountGSTR3B.SetFilter(e_Comm__Merchant_Id, '%1', '');
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            OwrdExempTotalAmount += GetBaseAmount(GSTAmountGSTR3B.Entry_No_);
        GSTAmountGSTR3B.Close();
    end;

    local procedure TaxableSuppliesWithECommerce()
    var
        GSTAmountGSTR3B: Query "GST Amount GSTR3B";
    begin
        GSTAmountGSTR3B.SetRange(Location__Reg__No_, GSTIN);
        GSTAmountGSTR3B.SetRange(Posting_Date, StartingDate, EndingDate);
        GSTAmountGSTR3B.SetFilter(GST__, '<>%1', 0);
        GSTAmountGSTR3B.SetRange(GST_Exempted_Goods, false);
        GSTAmountGSTR3B.SetRange(Transaction_Type, "Detail Ledger Transaction Type"::Sales);
        GSTAmountGSTR3B.SetFilter(GST_Customer_Type, '%1|%2|%3',
          "GST Customer Type"::Registered,
          "GST Customer Type"::Unregistered,
          "GST Customer Type"::" ");
        GSTAmountGSTR3B.SetFilter(Component_Calc__Type, '%1|%2|%3',
          "Component Calc Type"::General,
          "Component Calc Type"::Threshold,
          "Component Calc Type"::"Cess %");
        GSTAmountGSTR3B.SetFilter(e_Comm__Merchant_Id, '<>%1', '');
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            TaxableECommTotalAmount += GetBaseAmount(GSTAmountGSTR3B.Entry_No_);
        GSTAmountGSTR3B.Close();

        GSTAmountGSTR3B.SetRange(GST_Component_Code, IGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            TaxableECommIGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();

        GSTAmountGSTR3B.SetRange(GST_Component_Code, CGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            TaxableECommCGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, SGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            TaxableECommSGSTUTGSTAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
        GSTAmountGSTR3B.SetRange(GST_Component_Code, CESSCompLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            TaxableECommCESSAmount += GSTAmountGSTR3B.GST_Amount;
        GSTAmountGSTR3B.Close();
    end;

    local procedure InwardSuppliesReverseCharge()
    var
        GSTAmountGSTR3B: Query "GST Amount GSTR3B";
    begin
        GSTAmountGSTR3B.SetRange(Location__Reg__No_, GSTIN);
        GSTAmountGSTR3B.SetRange(Posting_Date, StartingDate, EndingDate);
        GSTAmountGSTR3B.SetRange(Transaction_Type, "Detail Ledger Transaction Type"::Purchase);
        GSTAmountGSTR3B.SetRange(Reverse_Charge, true);
        GSTAmountGSTR3B.SetRange(Liable_to_Pay, true);
        GSTAmountGSTR3B.SetRange(GSTAmountGSTR3B.GST_Component_Code);
        GSTAmountGSTR3B.SetFilter(Component_Calc__Type, '%1|%2|%3',
          "Component Calc Type"::General,
          "Component Calc Type"::Threshold,
          "Component Calc Type"::"Cess %");
        GSTAmountGSTR3B.SetFilter(e_Comm__Merchant_Id, '%1', '');
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do begin
            Sign := 1;
            Sign := GetSign(GSTAmountGSTR3B.Entry_No_);
            InwrdtotalAmount += GetBaseAmount(GSTAmountGSTR3B.Entry_No_) * Sign;
        end;
        GSTAmountGSTR3B.Close();

        GSTAmountGSTR3B.SetRange(GST_Component_Code, IGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            InwrdIGSTAmount += GSTAmountGSTR3B.GST_Amount * Sign;
        GSTAmountGSTR3B.Close();

        GSTAmountGSTR3B.SetRange(GST_Component_Code, CGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            InwrdCGSTAmount += GSTAmountGSTR3B.GST_Amount * Sign;
        GSTAmountGSTR3B.Close();

        GSTAmountGSTR3B.SetRange(GST_Component_Code, SGSTLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            InwrdSGSTUTGSTAmount += GSTAmountGSTR3B.GST_Amount * Sign;
        GSTAmountGSTR3B.Close();

        GSTAmountGSTR3B.SetRange(GST_Component_Code, CESSCompLbl);
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            InwrdCESSAmount += GSTAmountGSTR3B.GST_Amount * Sign;
        GSTAmountGSTR3B.Close();
    end;

    local procedure GetSign(EntryNo: Integer): Integer
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        Sign := 1;
        if not DetailedGSTLedgerEntry.Get(EntryNo) then
            exit(Sign);

        if DetailedGSTLedgerEntry."Entry Type" <> DetailedGSTLedgerEntry."Entry Type"::Application then
            exit(Sign);

        if DetailedGSTLedgerEntry."GST Group Type" = DetailedGSTLedgerEntry."GST Group Type"::Service then
            if not DetailedGSTLedgerEntry."Associated Enterprises" then
                Sign := -1;

        exit(Sign);
    end;

    local procedure NonGSTOutwardSupplies()
    var
        location: Record Location;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        // Non - GST Outward Supplies
        location.SetRange("GST Registration No.", GSTIN);
        if location.FindSet() then
            repeat
                SalesInvoiceHeader.SetRange("Location Code", Location.Code);
                SalesInvoiceHeader.SetRange("Posting Date", StartingDate, EndingDate);
                if SalesInvoiceHeader.FindSet() then
                    repeat
                        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                        SalesInvoiceLine.SetFilter("GST Group Code", '%1', '');
                        SalesInvoiceLine.SetFilter("HSN/SAC Code", '%1', '');
                        if SalesInvoiceLine.FindSet() then
                            repeat
                                OwrdNonGSTTotalAmount += SalesInvoiceLine."Amount Including VAT";
                            until SalesInvoiceLine.Next() = 0;
                    until SalesInvoiceHeader.Next() = 0;

                SalesCrMemoHeader.SetRange("Location Code", Location.Code);
                SalesCrMemoHeader.SetRange("Posting Date", StartingDate, EndingDate);
                if SalesCrMemoHeader.FindSet() then
                    repeat
                        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                        SalesCrMemoLine.SetFilter("GST Group Code", '%1', '');
                        SalesCrMemoLine.SetFilter("HSN/SAC Code", '%1', '');
                        if SalesCrMemoLine.FindSet() then
                            repeat
                                OwrdNonGSTTotalAmount -= SalesCrMemoLine."Amount Including VAT";
                            until SalesCrMemoLine.Next() = 0;
                    until SalesCrMemoHeader.Next() = 0;
            until location.Next() = 0;
    end;

    local procedure InputFromComposition()
    var
        GSTAmountGSTR3B: Query "GST Amount GSTR3B";
    begin
        GSTAmountGSTR3B.SetRange(Location__Reg__No_, GSTIN);
        GSTAmountGSTR3B.SetRange(Posting_Date, StartingDate, EndingDate);
        GSTAmountGSTR3B.SetRange(Transaction_Type, "Detail Ledger Transaction Type"::Purchase);
        GSTAmountGSTR3B.SetRange(GSTAmountGSTR3B.Source_Type, "Source Type"::Vendor);
        GSTAmountGSTR3B.SetRange(GSTAmountGSTR3B.GST__, 0);
        GSTAmountGSTR3B.SetFilter(GSTAmountGSTR3B.GST_Component_Code, '<>%1', CESSCompLbl);
        GSTAmountGSTR3B.SetFilter(Component_Calc__Type, '%1|%2|%3',
          "Component Calc Type"::General,
          "Component Calc Type"::Threshold,
          "Component Calc Type"::"Cess %");
        GSTAmountGSTR3B.Open();
        while GSTAmountGSTR3B.Read() do
            if GSTAmountGSTR3B.GST_Jurisdiction_Type = GSTAmountGSTR3B.GST_Jurisdiction_Type::Intrastate then
                IntraStateCompSupplyAmount += GSTAmountGSTR3B.GST_Base_Amount / 2
            else
                if GSTAmountGSTR3B.GST_Jurisdiction_Type = GSTAmountGSTR3B.GST_Jurisdiction_Type::Interstate then
                    InterStateCompSupplyAmount += GSTAmountGSTR3B.GST_Base_Amount;
        GSTAmountGSTR3B.Close();
    end;

    local procedure NonGSTInwardSupply()
    var
        location: Record Location;
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        // Non - GST Outward Supplies
        location.SetRange("GST Registration No.", GSTIN);
        if location.FindSet() then
            repeat
                PurchInvHeader.SetRange("Location Code", Location.Code);
                PurchInvHeader.SetRange("Posting Date", StartingDate, EndingDate);
                if PurchInvHeader.FindSet() then
                    repeat
                        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                        PurchInvLine.SetFilter("GST Group Code", '%1', '');
                        PurchInvLine.SetFilter("HSN/SAC Code", '%1', '');
                        if PurchInvLine.FindSet() then
                            repeat
                                if SameStateCode(PurchInvHeader."Location Code", PurchInvHeader."Buy-from Vendor No.") then
                                    PurchIntraStateAmount += PurchInvLine."Amount Including VAT"
                                else
                                    PurchInterStateAmount += PurchInvLine."Amount Including VAT";
                            until PurchInvLine.Next() = 0;
                    until PurchInvHeader.Next() = 0;

                PurchCrMemoHdr.SetRange("Location Code", Location.Code);
                PurchCrMemoHdr.SetRange("Posting Date", StartingDate, EndingDate);
                if PurchCrMemoHdr.FindSet() then
                    repeat
                        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
                        PurchCrMemoLine.SetFilter("GST Group Code", '%1', '');
                        PurchCrMemoLine.SetFilter("HSN/SAC Code", '%1', '');
                        if PurchCrMemoLine.FindSet() then
                            repeat
                                if SameStateCode(PurchCrMemoHdr."Location Code", PurchCrMemoHdr."Buy-from Vendor No.") then
                                    PurchIntraStateAmount -= PurchCrMemoLine."Amount Including VAT"
                                else
                                    PurchInterStateAmount -= PurchCrMemoLine."Amount Including VAT";
                            until PurchCrMemoLine.Next() = 0;
                    until PurchCrMemoHdr.Next() = 0;
            until location.Next() = 0;
    end;

    local procedure GSTTDSTCSAmount()
    var
        GSTTDSTCSEntry: Record "GST TDS/TCS Entry";
    begin
        Sign := -1;
        GSTTDSTCSEntry.SetRange("Location GST Reg. No.", GSTIN);
        GSTTDSTCSEntry.SetRange("Posting Date", StartingDate, EndingDate);
        if GSTTDSTCSEntry.FindSet() then
            repeat
                case
                    GSTTDSTCSEntry.Type of
                    GSTTDSTCSEntry.Type::TCS:
                        case
                            GSTTDSTCSEntry."GST Component Code" of
                            CGSTLbl:
                                TCSCGSTAmount += GSTTDSTCSEntry."GST TDS/TCS Amount (LCY)" * Sign;
                            SGSTLbl:
                                TCSSGSTAmount += GSTTDSTCSEntry."GST TDS/TCS Amount (LCY)" * Sign;
                            IGSTLbl:
                                TCSIGSTAmount += GSTTDSTCSEntry."GST TDS/TCS Amount (LCY)" * Sign;
                        end;
                    GSTTDSTCSEntry.Type::TDS:
                        case
                            GSTTDSTCSEntry."GST Component Code" of
                            CGSTLbl:
                                TDSCGSTAmount += GSTTDSTCSEntry."GST TDS/TCS Amount (LCY)";
                            SGSTLbl:
                                TDSSGSTAmount += GSTTDSTCSEntry."GST TDS/TCS Amount (LCY)";
                            IGSTLbl:
                                TDSIGSTAmount += GSTTDSTCSEntry."GST TDS/TCS Amount (LCY)";
                        end;
                end;
            until GSTTDSTCSEntry.Next() = 0;
    end;

    local procedure SameStateCode(LocationCode: Code[10]; VendorCode: Code[20]): Boolean
    var
        Location: Record Location;
        Vendor: Record Vendor;
    begin
        Location.Get(LocationCode);
        Vendor.Get(VendorCode);
        if Location."State Code" = Vendor."State Code" then
            exit(true);
    end;
}
