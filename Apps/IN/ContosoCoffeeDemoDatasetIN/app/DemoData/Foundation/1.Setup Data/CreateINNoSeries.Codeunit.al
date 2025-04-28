// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.TaxBase;

codeunit 19020 "Create IN No. Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateNoSeries: Codeunit "Create No. Series";
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(BankPaymentVoucher(), BankPaymentVoucherLbl, 'BP-00001', 'BP-00700', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(BankReceiptVoucher(), BankReceiptVoucherLbl, 'BR-00001', 'BR-00700', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedBankPaymentVoucher(), PostedBankPaymentVoucherLbl, 'PBP-00001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedBankReceiptVoucher(), PostedBankReceiptVoucherLbl, 'PBR-00001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(CashPaymentVoucher(), CashPaymentVoucherLbl, 'CP-00001', 'CP-00700', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(CashReceiptVoucher(), CashReceiptVoucherLbl, 'CR-00001', 'CR-00700', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedContraVoucher(), PostedContraVoucherLbl, 'PCV-00001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(ContraVoucher(), ContraVoucherLbl, 'CV-00001', 'CV-00700', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedCashPaymentVoucher(), PostedCashPaymentVoucherLbl, 'PCP-00001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedCashReceiptVoucher(), PostedCashReceiptVoucherLbl, 'PCR-00001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(GateEntryInwards(), GateEntryInwardsLbl, 'GATE/IN/00001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(GateEntryOutward(), GateEntryOutwardLbl, 'GATE/OUT/00001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(GSTCreditJournalAdjustment(), GSTCreditJournalAdjustmentLbl, 'GST-CRJNL-00001', '', '', 'GST-CRJNL-00001', 10, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(GSTLiablilityAdjustmentJournal(), GSTLiablilityAdjustmentJournalLbl, '101001', '102999', '102995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(GSTSettlement(), GSTSettlementLbl, 'GST-STL_JNL/001', '', '', 'GST-STL_JNL/001', 10, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(GateBlue(), GateBlueLbl, 'GTINBL000001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(GateOUTBlue(), GateOUTBlueLbl, 'GTOUTBL000001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedSalesINInvoice(), PostedSalesINInvoiceLbl, 'IN-SI-00001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(JournalVoucher(), JournalVoucherLbl, 'JV-00001', 'JV-00700', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedJournalVoucher(), PostedJournalVoucherLbl, 'PJV-00001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PostedDistributionInvoice(), PostedDistributionInvoiceLbl, 'PD-INV-0001', '', '', 'PD-INV-0001', 10, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(TCSIH(), TCSIHLbl, 'XTCSI00001', '', '', '', 1, Enum::"No. Series Implementation"::Normal, true);

        UpdateDescriptionInNoSeries(CreateNoSeries.CatalogItems(), CatalogueItemsLbl);

        CreatePostingNoSeries();
    end;

    procedure UpdateManualNosInNoSeries(NoSeriesCode: Code[20]; ManualNos: Boolean)
    var
        NoSeries: Record "No. Series";
    begin
        if NoSeries.Get(NoSeriesCode) then begin
            NoSeries.Validate("Manual Nos.", ManualNos);
            NoSeries.Modify(true);
        end;
    end;

    local procedure UpdateDescriptionInNoSeries(NoSeriesCode: Code[20]; Description: Text[100])
    var
        NoSeries: Record "No. Series";
    begin
        if NoSeries.Get(NoSeriesCode) then begin
            NoSeries.Validate(Description, Description);
            NoSeries.Modify(true);
        end;
    end;



    local procedure CreatePostingNoSeries()
    var
        PostingNoSeries: Record "Posting No. Series";
        "Posting No. Series Mgmt.": Codeunit "Posting No. Series Mgmt.";
    begin
        PostingNoSeries.Init();
        PostingNoSeries.ID := 1;
        PostingNoSeries.Validate("Document Type", PostingNoSeries."Document Type"::"Gate Entry");
        PostingNoSeries.Validate("Posting No. Series", GateBlue());
        PostingNoSeries.Insert();
        "Posting No. Series Mgmt.".SetTablesCondition(PostingNoSeries, 'VERSION(1) SORTING(Field1,Field2) where(Field1=1(0),Field7=1(BLUE))');

        PostingNoSeries.Init();
        PostingNoSeries.ID := 2;
        PostingNoSeries.Validate("Document Type", PostingNoSeries."Document Type"::"Gate Entry");
        PostingNoSeries.Validate("Posting No. Series", GateOUTBlue());
        PostingNoSeries.Insert();
        "Posting No. Series Mgmt.".SetTablesCondition(PostingNoSeries, 'VERSION(1) SORTING(Field1,Field2) where(Field1=1(1),Field7=1(BLUE))');
    end;

    procedure BankPaymentVoucher(): Code[20]
    begin
        exit(BankPaymentVoucherTok);
    end;

    procedure BankReceiptVoucher(): Code[20]
    begin
        exit(BankReceiptVoucherTok);
    end;

    procedure PostedBankPaymentVoucher(): Code[20]
    begin
        exit(PostedBankPaymentVoucherTok);
    end;

    procedure PostedBankReceiptVoucher(): Code[20]
    begin
        exit(PostedBankReceiptVoucherTok);
    end;

    procedure CashPaymentVoucher(): Code[20]
    begin
        exit(CashPaymentVoucherTok);
    end;

    procedure CashReceiptVoucher(): Code[20]
    begin
        exit(CashReceiptVoucherTok);
    end;

    procedure PostedContraVoucher(): Code[20]
    begin
        exit(PostedContraVoucherTok);
    end;

    procedure ContraVoucher(): Code[20]
    begin
        exit(ContraVoucherTok);
    end;

    procedure PostedCashPaymentVoucher(): Code[20]
    begin
        exit(PostedCashPaymentVoucherTok);
    end;

    procedure PostedCashReceiptVoucher(): Code[20]
    begin
        exit(PostedCashReceiptVoucherTok);
    end;

    procedure GateEntryInwards(): Code[20]
    begin
        exit(GateEntryInwardsTok);
    end;

    procedure GateEntryOutward(): Code[20]
    begin
        exit(GateEntryOutwardTok);
    end;

    procedure GSTCreditJournalAdjustment(): Code[20]
    begin
        exit(GSTCreditJournalAdjustmentTok);
    end;

    procedure GSTLiablilityAdjustmentJournal(): Code[20]
    begin
        exit(GSTLiablilityAdjustmentJournalTok);
    end;

    procedure GSTSettlement(): Code[20]
    begin
        exit(GSTSettlementTok);
    end;

    procedure GateBlue(): Code[20]
    begin
        exit(GateBlueTok);
    end;

    procedure GateOUTBlue(): Code[20]
    begin
        exit(GateOUTBlueTok);
    end;

    procedure PostedSalesINInvoice(): Code[20]
    begin
        exit(PostedSalesINInvoiceTok);
    end;

    procedure JournalVoucher(): Code[20]
    begin
        exit(JournalVoucherTok);
    end;

    procedure PostedJournalVoucher(): Code[20]
    begin
        exit(PostedJournalVoucherTok);
    end;

    procedure PostedDistributionInvoice(): Code[20]
    begin
        exit(PostedDistributionInvoiceTok);
    end;

    procedure TCSIH(): Code[20]
    begin
        exit(TCSIHTok);
    end;

    var
        BankPaymentVoucherTok: Label 'BANKPYMTV', MaxLength = 20;
        BankReceiptVoucherTok: Label 'BANKRCPTV', MaxLength = 20;
        PostedBankPaymentVoucherTok: Label 'BNKPYV-P', MaxLength = 20;
        PostedBankReceiptVoucherTok: Label 'BNKRCV-P', MaxLength = 20;
        CashPaymentVoucherTok: Label 'CASHPYMTV', MaxLength = 20;
        CashReceiptVoucherTok: Label 'CASHRCPTV', MaxLength = 20;
        PostedContraVoucherTok: Label 'CNTRV-P', MaxLength = 20;
        ContraVoucherTok: Label 'CONTRAV', MaxLength = 20;
        PostedCashPaymentVoucherTok: Label 'CSHPYV-P', MaxLength = 20;
        PostedCashReceiptVoucherTok: Label 'CSHRCV-P', MaxLength = 20;
        GateEntryInwardsTok: Label 'GEINW', MaxLength = 20;
        GateEntryOutwardTok: Label 'GEOUT', MaxLength = 20;
        GSTCreditJournalAdjustmentTok: Label 'GST-CR-JNL', MaxLength = 20;
        GSTLiablilityAdjustmentJournalTok: Label 'GST-GLB', MaxLength = 20;
        GSTSettlementTok: Label 'GST-SETTLE', MaxLength = 20;
        GateBlueTok: Label 'GT-IN-BL+', MaxLength = 20;
        GateOUTBlueTok: Label 'GT-OUT-BL+', MaxLength = 20;
        PostedSalesINInvoiceTok: Label 'IN-SALES', MaxLength = 20;
        JournalVoucherTok: Label 'JOURNALV', MaxLength = 20;
        PostedJournalVoucherTok: Label 'JRNLV-P', MaxLength = 20;
        PostedDistributionInvoiceTok: Label 'P-D-INV', MaxLength = 20;
        TCSIHTok: Label 'TCS-IH', MaxLength = 20;
        BankPaymentVoucherLbl: Label 'Bank Payment Voucher', MaxLength = 100;
        BankReceiptVoucherLbl: Label 'Bank Receipt Voucher', MaxLength = 100;
        PostedBankPaymentVoucherLbl: Label 'Posted Bank Payment Voucher', MaxLength = 100;
        PostedBankReceiptVoucherLbl: Label 'Posted Bank Receipt Voucher', MaxLength = 100;
        CashPaymentVoucherLbl: Label 'Cash Payment Voucher', MaxLength = 100;
        CashReceiptVoucherLbl: Label 'Cash Receipt Voucher', MaxLength = 100;
        PostedContraVoucherLbl: Label 'Posted Contra Voucher', MaxLength = 100;
        ContraVoucherLbl: Label 'Contra Voucher', MaxLength = 100;
        PostedCashPaymentVoucherLbl: Label 'Posted Cash Payment Voucher', MaxLength = 100;
        PostedCashReceiptVoucherLbl: Label 'Posted Cash Receipt Voucher', MaxLength = 100;
        GateEntryInwardsLbl: Label 'Gate Entry-Inwards', MaxLength = 100;
        GateEntryOutwardLbl: Label 'Gate Entry Outward', MaxLength = 100;
        GSTCreditJournalAdjustmentLbl: Label 'GST Credit Journal Adjustment', MaxLength = 100;
        GSTLiablilityAdjustmentJournalLbl: Label 'GST Liablility Adjustment Journal', MaxLength = 100;
        GSTSettlementLbl: Label 'GST Settlement', MaxLength = 100;
        GateBlueLbl: Label 'Gate Blue', MaxLength = 100;
        GateOUTBlueLbl: Label 'Gate OUT Blue', MaxLength = 100;
        PostedSalesINInvoiceLbl: Label 'Posted Sales IN Invoice', MaxLength = 100;
        JournalVoucherLbl: Label 'Journal Voucher', MaxLength = 100;
        PostedJournalVoucherLbl: Label 'Posted Journal Voucher', MaxLength = 100;
        PostedDistributionInvoiceLbl: Label 'Posted Distribution Invoice', MaxLength = 100;
        TCSIHLbl: Label 'TCS-IH', MaxLength = 100;
        CatalogueItemsLbl: Label 'Catalogue Items', MaxLength = 100;
}
