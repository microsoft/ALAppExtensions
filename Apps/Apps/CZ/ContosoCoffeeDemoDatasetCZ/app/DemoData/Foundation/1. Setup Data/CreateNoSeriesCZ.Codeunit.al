// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.NoSeries;

codeunit 31196 "Create No. Series CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        DeleteNoSeries();
        ContosoNoSeries.InsertNoSeries(PaymentOrder(), PaymentOrderLbl, 'BPRI0001', 'BPRI9999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(IssuedPaymentOrder(), IssuedPaymentOrderLbl, 'BPRI00001', 'BPRI99999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(BankStatement(), BankStatementLbl, 'BVYP0001', 'BVYP9999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(IssuedBankStatement(), IssuedBankStatementLbl, 'BVYP00001', 'BVYP99999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(DomesticPurchaseAdvance(), DomesticPurchaseAdvanceLbl, 'NZ01220001', 'NZ01229999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(ForeignPurchaseAdvance(), ForeignPurchaseAdvanceLbl, 'NZ03220001', 'NZ03229999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(EUPurchaseAdvance(), EUPurchaseAdvanceLbl, 'NZ02220001', 'NZ02229999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PurchaseAdvanceVATInvoice(), PurchAdvanceVatInvoiceLbl, 'NZDF220001', 'NZDF229999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PurchaseAdvanceVATCreditMemo(), PurchAdvanceVatCrMemoLbl, 'NZDD220001', 'NZDD229999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(DomesticSalesAdvance(), DomesticSalesAdvanceLbl, 'PZ01220001', 'PZ01229999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(ForeignSalesAdvance(), ForeignSalesAdvanceLbl, 'PZ03220001', 'PZ03229999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(EUSalesAdvance(), EUSalesAdvanceLbl, 'PZ02220001', 'PZ02229999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(SalesAdvanceVATInvoice(), SalesAdvanceVatInvoiceLbl, 'PZDF220001', 'PZDF229999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(SalesAdvanceVATCreditMemo(), SalesAdvanceVatCrMemoLbl, 'PZDD220001', 'PZDD229999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(CashDesk(), CashDeskLbl, 'POK01', 'POK99', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(CashDocumentReceipt(), CashDocumentReceiptLbl, 'PPD0001', 'PPD9999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(CashDocumentWithdrawal(), CashDocumentWithdrawalLbl, 'VPD0001', 'VPD9999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(Compensation(), CompensationLbl, 'ZAP0001', 'ZAP9999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(AccountingScheduleResult(), ResultsOfAccountingScheduleLbl, 'USV00001', 'USV99999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(CompanyOfficial(), CompanyOfficialLbl, 'OSO0010', 'OSO9990', '', '', 10, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(VATControlReport(), VATControlReportLbl, 'VCR001', 'VCR999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(VIESDeclaration(), VIESDeclarationLbl, 'VIES16001', 'VIES16999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(RecurringGeneralJournal(), RecurringGeneralJournalLbl, 'G06001', 'G07000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(VATReturnPeriod(), VATReturnPeriodLbl, 'ODPH00001', 'ODPH99999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        CreateVATReturnNoSeries();
    end;

    local procedure CreateVATReturnNoSeries()
    var
        ContosoNoSeriesCZ: Codeunit "Contoso No. Series CZ";
        ContosoUtilities: Codeunit "Contoso Utilities";
        StartingDate: Date;
        StartingNo: Code[20];
        EndingNo: Code[20];
    begin
        ContosoNoSeriesCZ.InsertNoSeries(VATReturn(), VATReturnLbl, true);

        StartingDate := ContosoUtilities.AdjustDate(19030101D);
        StartingNo := StrSubstNo(VATReturnNoTok, Format(StartingDate, 0, '<Year>'), '01');
        EndingNo := StrSubstNo(VATReturnNoTok, Format(StartingDate, 0, '<Year>'), '99');
        ContosoNoSeriesCZ.InsertNoSeriesLine(VATReturn(), 10000, StartingDate, StartingNo, EndingNo, '', '', 1, "No. Series Implementation"::Normal);

        StartingDate := ContosoUtilities.AdjustDate(19040101D);
        StartingNo := StrSubstNo(VATReturnNoTok, Format(StartingDate, 0, '<Year>'), '01');
        EndingNo := StrSubstNo(VATReturnNoTok, Format(StartingDate, 0, '<Year>'), '99');
        ContosoNoSeriesCZ.InsertNoSeriesLine(VATReturn(), 20000, StartingDate, StartingNo, EndingNo, '', '', 1, "No. Series Implementation"::Normal);
    end;

    internal procedure CreateDummyNoSeries()
    var
        ContosoNoSeriesCZ: Codeunit "Contoso No. Series CZ";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        ContosoNoSeriesCZ.InsertNoSeries(CreateNoSeries.VATReturnsReports(), '', false);
        ContosoNoSeriesCZ.InsertNoSeries(CreateNoSeries.VATReturnPeriods(), '', false);
    end;

    internal procedure DeleteNoSeries()
    var
        NoSeries: Record "No. Series";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        NoSeries.SetFilter(Code, '%1|%2', CreateNoSeries.VATReturnPeriods(), CreateNoSeries.VATReturnsReports());
        NoSeries.DeleteAll(true);
    end;

    procedure PaymentOrder(): Code[20]
    begin
        exit(PORDERTok);
    end;

    procedure IssuedPaymentOrder(): Code[20]
    begin
        exit(PORDERPlusTok);
    end;

    procedure BankStatement(): Code[20]
    begin
        exit(BSTMTTok);
    end;

    procedure IssuedBankStatement(): Code[20]
    begin
        exit(BSTMTPlusTok);
    end;

    procedure DomesticPurchaseAdvance(): Code[20]
    begin
        exit(PADVDTok);
    end;

    procedure ForeignPurchaseAdvance(): Code[20]
    begin
        exit(PADVFTok);
    end;

    procedure EUPurchaseAdvance(): Code[20]
    begin
        exit(PADVETok);
    end;

    procedure PurchaseAdvanceVATInvoice(): Code[20]
    begin
        exit(PADVINVTok);
    end;

    procedure PurchaseAdvanceVATCreditMemo(): Code[20]
    begin
        exit(PADVCMTok);
    end;

    procedure DomesticSalesAdvance(): Code[20]
    begin
        exit(SADVDTok);
    end;

    procedure ForeignSalesAdvance(): Code[20]
    begin
        exit(SADVFTok);
    end;

    procedure EUSalesAdvance(): Code[20]
    begin
        exit(SADVETok);
    end;

    procedure SalesAdvanceVATInvoice(): Code[20]
    begin
        exit(SADVINVTok);
    end;

    procedure SalesAdvanceVATCreditMemo(): Code[20]
    begin
        exit(SADVCMTok);
    end;

    procedure CashDocumentReceipt(): Code[20]
    begin
        exit(CDRCPTTok);
    end;

    procedure CashDocumentWithdrawal(): Code[20]
    begin
        exit(CDWDRLTok);
    end;

    procedure Compensation(): Code[20]
    begin
        exit(COMPENSATIONTok);
    end;

    procedure CashDesk(): Code[20]
    begin
        exit(CDTok);
    end;

    procedure AccountingScheduleResult(): Code[20]
    begin
        exit(ASRESTok);
    end;

    procedure CompanyOfficial(): Code[20]
    begin
        exit(COTok);
    end;

    procedure VATControlReport(): Code[20]
    begin
        exit(VCRTok);
    end;

    procedure VIESDeclaration(): Code[20]
    begin
        exit(VIESTok);
    end;

    procedure RecurringGeneralJournal(): Code[20]
    begin
        exit(GJNLRECTok);
    end;

    procedure VATReturn(): Code[20]
    begin
        exit(VATRTok);
    end;

    procedure VATReturnPeriod(): Code[20]
    begin
        exit(VATPTok);
    end;

    var
        BSTMTTok: Label 'B-STMT', MaxLength = 20, Comment = 'Bank Statement';
        BSTMTPlusTok: Label 'B-STMT+', MaxLength = 20, Comment = 'Issued Bank Statement';
        PADVDTok: Label 'P-ADVD', MaxLength = 20, Comment = 'Purchase Advance - Domestic';
        PADVFTok: Label 'P-ADVF', MaxLength = 20, Comment = 'Purchase Advance - Foreign';
        PADVETok: Label 'P-ADVE', MaxLength = 20, Comment = 'Purchase Advance - EU';
        PADVINVTok: Label 'P-ADVINV', MaxLength = 20, Comment = 'Purchase Advance - VAT Invoice';
        PADVCMTok: Label 'P-ADVCM', MaxLength = 20, Comment = 'Purchase Advance - VAT Credit Memo';
        PORDERTok: Label 'P-ORDER', MaxLength = 20, Comment = 'Payment Order';
        PORDERPlusTok: Label 'P-ORDER+', MaxLength = 20, Comment = 'Issued Payment Order';
        SADVDTok: Label 'S-ADVD', MaxLength = 20, Comment = 'Sales Advance - Domestic';
        SADVFTok: Label 'S-ADVF', MaxLength = 20, Comment = 'Sales Advance - Foreign';
        SADVETok: Label 'S-ADVE', MaxLength = 20, Comment = 'Sales Advance - EU';
        SADVINVTok: Label 'S-ADVINV', MaxLength = 20, Comment = 'Sales Advance - VAT Invoice';
        SADVCMTok: Label 'S-ADVCM', MaxLength = 20, Comment = 'Sales Advance - VAT Credit Memo';
        CDRCPTTok: Label 'CD-RCPT', MaxLength = 20, Comment = 'Cash Document Receipt';
        CDWDRLTok: Label 'CD-WDRL', MaxLength = 20, Comment = 'Cash Document Withdrawal';
        COMPENSATIONTok: Label 'COMPENSATION', MaxLength = 20;
        CDTok: Label 'CD', MaxLength = 20, Comment = 'Cash Desk';
        ASRESTok: Label 'AS-RES', MaxLength = 20, Comment = 'Results of Acc. Schedule';
        COTok: Label 'CO', MaxLength = 20, Comment = 'Company Official';
        VCRTok: Label 'VCR', MaxLength = 20, Comment = 'VAT Control Report';
        VIESTok: Label 'VIES', MaxLength = 20, Comment = 'VIES Declaration';
        GJNLRECTok: Label 'GJNL-REC', MaxLength = 20, Comment = 'Recurring General Journal';
        VATRTok: Label 'VAT-R', MaxLength = 20, Comment = 'VAT Return';
        VATPTok: Label 'VAT-P', MaxLength = 20, Comment = 'VAT Return Period';
        VATReturnNoTok: Label 'PDPH%1%2', MaxLength = 20, Comment = '%1 = <Year>, %2 = <No>', Locked = true;
        RecurringGeneralJournalLbl: Label 'Recurring General Journal', MaxLength = 100;
        CompanyOfficialLbl: Label 'Company Official', MaxLength = 100;
        VATControlReportLbl: Label 'VAT Control Report', MaxLength = 100;
        VIESDeclarationLbl: Label 'VIES Declaration', MaxLength = 100;
        ResultsOfAccountingScheduleLbl: Label 'Results of Acc. Schedule', MaxLength = 100;
        CashDeskLbl: Label 'Cash Desk', MaxLength = 100;
        CompensationLbl: Label 'Compensation', MaxLength = 100;
        CashDocumentReceiptLbl: Label 'Cash Document Receipt', MaxLength = 100;
        CashDocumentWithdrawalLbl: Label 'Cash Document Withdrawal', MaxLength = 100;
        BankStatementLbl: Label 'Bank Statement', MaxLength = 100;
        IssuedBankStatementLbl: Label 'Issued Bank Statement', MaxLength = 100;
        PaymentOrderLbl: Label 'Payment Order', MaxLength = 100;
        IssuedPaymentOrderLbl: Label 'Issued Payment Order', MaxLength = 100;
        PurchAdvanceVatInvoiceLbl: Label 'Purchase Advance - VAT Invoice', MaxLength = 100;
        PurchAdvanceVatCrMemoLbl: Label 'Purchase Advance - VAT Credit Memo', MaxLength = 100;
        DomesticPurchaseAdvanceLbl: Label 'Domestic Purchase Advance', MaxLength = 100;
        ForeignPurchaseAdvanceLbl: Label 'Foreign Purchase Advance', MaxLength = 100;
        EUPurchaseAdvanceLbl: Label 'EU Purchase Advance', MaxLength = 100;
        SalesAdvanceVatInvoiceLbl: Label 'Sales Advance - VAT Invoice', MaxLength = 100;
        SalesAdvanceVatCrMemoLbl: Label 'Sales Advance - VAT Credit Memo', MaxLength = 100;
        DomesticSalesAdvanceLbl: Label 'Domestic Sales Advance', MaxLength = 100;
        ForeignSalesAdvanceLbl: Label 'Foreign Sales Advance', MaxLength = 100;
        EUSalesAdvanceLbl: Label 'EU Sales Advance', MaxLength = 100;
        VATReturnLbl: Label 'VAT Return', MaxLength = 100;
        VATReturnPeriodLbl: Label 'VAT Return Period', MaxLength = 100;
}
