// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Reconcilation;
using Microsoft.Finance.GST.Payments;
using Microsoft.FixedAssets.FADepreciation;
using Microsoft.Finance.TDS.TDSForCustomer;

codeunit 19004 "Contoso IN Tax Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata State = rim,
        tabledata "Act Applicable" = rim,
        tabledata "Assessee Code" = rim,
        tabledata "Deductor Category" = rim,
        tabledata Ministry = rim,
        tabledata "TAN Nos." = rim,
        tabledata "T.C.A.N. No." = rim,
        tabledata "GST Group" = rim,
        tabledata "HSN/SAC" = rim,
        tabledata "GST Posting Setup" = rim,
        tabledata "GST Recon. Mapping" = rim,
        tabledata "TDS Section" = rim,
        tabledata "TDS Posting Setup" = rim,
        tabledata "TDS Nature Of Remittance" = rim,
        tabledata "TCS Nature Of Collection" = rim,
        tabledata "TCS Posting Setup" = rim,
        tabledata "Bank Charge" = rim,
        tabledata "Concessional Code" = rim,
        tabledata "Fixed Asset Block" = rim,
        tabledata "Customer Allowed Sections" = rim,
        tabledata "Allowed Sections" = rim,
        tabledata "Allowed NOC" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertState(StateCode: Code[10]; Description: Text[50]; StateETDSTCS: Code[2]; StateGSTRegNo: Code[10])
    var
        State: Record State;
        Exists: Boolean;
    begin
        if State.Get(StateCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        State.Code := StateCode;
        State.Description := Description;
        State."State Code (GST Reg. No.)" := StateGSTRegNo;
        State."State Code for eTDS/TCS" := StateETDSTCS;

        if Exists then
            State.Modify(true)
        else
            State.Insert(true);
    end;

    procedure InsertActApplicable(Code: Code[10]; Description: Text[50])
    var
        ActApplicable: Record "Act Applicable";
        Exists: Boolean;
    begin
        if ActApplicable.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ActApplicable.Validate(Code, Code);
        ActApplicable.Validate(Description, Description);

        if Exists then
            ActApplicable.Modify(true)
        else
            ActApplicable.Insert(true);
    end;

    procedure InsertAssesseeCode(Code: Code[10]; Description: Text[100]; AssesseeType: Enum "Assessee Type")
    var
        AssesseeCode: Record "Assessee Code";
        Exists: Boolean;
    begin
        if AssesseeCode.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AssesseeCode.Validate(Code, Code);
        AssesseeCode.Validate(Description, Description);
        AssesseeCode.Validate(Type, AssesseeType);

        if Exists then
            AssesseeCode.Modify(true)
        else
            AssesseeCode.Insert(true);
    end;

    procedure InsertDeductorCategory(Code: Code[1]; Description: Text[50]; PAOCodeMandatory: Boolean; DDOCodeMandatory: Boolean; StateCodeMandatory: Boolean; MinistryDetailsMandatory: Boolean; TransferVoucherNoMandatory: Boolean)
    var
        DeductorCategory: Record "Deductor Category";
        Exists: Boolean;
    begin
        if DeductorCategory.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DeductorCategory.Validate(Code, Code);
        DeductorCategory.Validate(Description, Description);
        DeductorCategory.Validate("PAO Code Mandatory", PAOCodeMandatory);
        DeductorCategory.Validate("DDO Code Mandatory", DDOCodeMandatory);
        DeductorCategory.Validate("State Code Mandatory", StateCodeMandatory);
        DeductorCategory.Validate("Ministry Details Mandatory", MinistryDetailsMandatory);
        DeductorCategory.Validate("Transfer Voucher No. Mandatory", TransferVoucherNoMandatory);

        if Exists then
            DeductorCategory.Modify(true)
        else
            DeductorCategory.Insert(true);
    end;

    procedure InsertMinistry(Code: Code[3]; Name: Text[150]; OtherMinistry: Boolean)
    var
        Ministry: Record Ministry;
        Exists: Boolean;
    begin
        if Ministry.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Ministry.Validate(Code, Code);
        Ministry.Validate(Name, Name);
        Ministry.Validate("Other Ministry", OtherMinistry);

        if Exists then
            Ministry.Modify(true)
        else
            Ministry.Insert(true);
    end;

    procedure InsertTANNos(Code: Code[10]; Description: Text[50])
    var
        TANNos: Record "TAN Nos.";
        Exists: Boolean;
    begin
        if TANNos.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TANNos.Validate("Code", Code);
        TANNos.Validate(Description, Description);

        if Exists then
            TANNos.Modify(true)
        else
            TANNos.Insert(true);
    end;

    procedure InsertTCANNos(Code: Code[10]; Description: Text[50])
    var
        TCANNos: Record "T.C.A.N. No.";
        Exists: Boolean;
    begin
        if TCANNos.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TCANNos.Validate("Code", Code);
        TCANNos.Validate(Description, Description);

        if Exists then
            TCANNos.Modify(true)
        else
            TCANNos.Insert(true);
    end;

    procedure InsertGSTGroup(Code: Code[20]; GSTGroupType: Enum "GST Group Type"; GSTPlaceOfSupply: Enum "GST Dependency Type"; Description: Code[250]; ReverseCharge: Boolean)
    var
        GSTGroup: Record "GST Group";
        Exists: Boolean;
    begin
        if GSTGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GSTGroup.Validate(Code, Code);
        GSTGroup.Validate("GST Group Type", GSTGroupType);
        GSTGroup.Validate("GST Place Of Supply", GSTPlaceOfSupply);
        GSTGroup.Validate(Description, Description);
        GSTGroup.Validate("Reverse Charge", ReverseCharge);

        if Exists then
            GSTGroup.Modify(true)
        else
            GSTGroup.Insert(true);
    end;

    procedure InsertHSNSAC(GSTGroupCode: Code[10]; HSNSACCode: code[10]; Description: Text[50]; HSNSACType: Enum "GST Goods And Services Type");
    var
        HSNSAC: Record "HSN/SAC";
        Exists: Boolean;
    begin
        if HSNSAC.Get(GSTGroupCode, HSNSACCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        HSNSAC.Validate("GST Group Code", GSTGroupCode);
        HSNSAC.Validate(Code, HSNSACCode);
        HSNSAC.Validate(Description, Description);
        HSNSAC.Validate(Type, HSNSACType);

        if Exists then
            HSNSAC.Modify(true)
        else
            HSNSAC.Insert(true);
    end;

    procedure InsertGSTPostingSetup(StateCode: Code[10]; ComponentId: Integer; ReceivableAcc: Code[20]; PaybleAcc: Code[20]; ReceiveableAccInt: Code[20]; PaybleAccInt: Code[20]; ExpenseAcc: Code[20]; RefundAcc: Code[20]; ReceivableAccIntDist: Code[20]; ReceivableAccDist: Code[20]; GSTCreditMismatch: Code[20]; GSTTDSRecAcc: Code[20]; GSTTCSRecAcc: Code[20]; GSTTCSPaybleAcc: Code[20]; IGSTPayableAccImport: Code[20])
    var
        GSTPostingSetup: Record "GST Posting Setup";
        Exists: Boolean;
    begin
        if GSTPostingSetup.Get(StateCode, ComponentId) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GSTPostingSetup.Validate("State Code", StateCode);
        GSTPostingSetup.Validate("Component ID", ComponentId);
        GSTPostingSetup.Validate("Receivable Account", ReceivableAcc);
        GSTPostingSetup.Validate("Payable Account", PaybleAcc);
        GSTPostingSetup.Validate("Receivable Account (Interim)", ReceiveableAccInt);
        GSTPostingSetup.Validate("Payables Account (Interim)", PaybleAccInt);
        GSTPostingSetup.Validate("Expense Account", ExpenseAcc);
        GSTPostingSetup.Validate("Refund Account", RefundAcc);
        GSTPostingSetup.Validate("Receivable Acc. Interim (Dist)", ReceivableAccIntDist);
        GSTPostingSetup.Validate("Receivable Acc. (Dist)", ReceivableAccDist);
        GSTPostingSetup.Validate("GST Credit Mismatch Account", GSTCreditMismatch);
        GSTPostingSetup.Validate("GST TDS Receivable Account", GSTTDSRecAcc);
        GSTPostingSetup.Validate("GST TCS Receivable Account", GSTTCSRecAcc);
        GSTPostingSetup.Validate("GST TCS Payable Account", GSTTCSPaybleAcc);
        GSTPostingSetup.Validate("IGST Payable A/c (Import)", IGSTPayableAccImport);

        if Exists then
            GSTPostingSetup.Modify(true)
        else
            GSTPostingSetup.Insert(true);
    end;

    procedure CreateGSTCompReconMapping(GSTComponentCode: Code[10]; GSTReconciliationFieldNo: Integer; GSTReconciliationFieldName: Text[30]; ISDFieldNo: Integer; ISDFieldName: Text[30])
    var
        GSTReconMapping: Record "GST Recon. Mapping";
        Exists: Boolean;
    begin
        if GSTReconMapping.Get(GSTComponentCode, GSTReconciliationFieldNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GSTReconMapping.Validate("GST Component Code", GSTComponentCode);
        GSTReconMapping.Validate("GST Reconciliation Field No.", GSTReconciliationFieldNo);
        GSTReconMapping.Validate("GST Reconciliation Field Name", GSTReconciliationFieldName);
        GSTReconMapping.Validate("ISD Ledger Field No.", ISDFieldNo);
        GSTReconMapping.Validate("ISD Ledger Field Name", ISDFieldName);

        if Exists then
            GSTReconMapping.Modify(true)
        else
            GSTReconMapping.Insert(true);
    end;

    procedure InsertTDSSection(Code: Code[10]; Description: Text[100]; eCode: Code[10]; ParentSection: Code[20])
    var
        TDSSection: Record "TDS Section";
        Exists: Boolean;
    begin
        if TDSSection.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TDSSection.Validate("Code", Code);
        TDSSection.Validate(Description, Description);
        TDSSection.Validate(ecode, eCode);
        TDSSection.Validate("Parent Code", ParentSection);
        TDSSection.Validate("Indentation Level", GetIndentationLevel(ParentSection));

        if Exists then
            TDSSection.Modify(true)
        else
            TDSSection.Insert(true);
    end;

    local procedure GetIndentationLevel(ParentCode: Code[20]): Integer
    var
        TDSSection: Record "TDS Section";
    begin
        if ParentCode = '' then
            exit(0);

        TDSSection.Get(ParentCode);
        exit(TDSSection."Indentation Level" + 1);
    end;

    procedure InsertTDSPostingSetup(SectionCode: Code[10]; EffectiveDate: Date; TDSAccount: Code[20]; TDSReceivableAccount: Code[20])
    var
        TDSPostingSetup: Record "TDS Posting Setup";
        Exists: Boolean;
    begin
        if TDSPostingSetup.Get(SectionCode, EffectiveDate) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TDSPostingSetup.Validate("TDS Section", SectionCode);
        TDSPostingSetup.Validate("Effective Date", EffectiveDate);
        TDSPostingSetup."TDS Account" := TDSAccount;
        TDSPostingSetup."TDS Receivable Account" := TDSReceivableAccount;

        if Exists then
            TDSPostingSetup.Modify(true)
        else
            TDSPostingSetup.Insert(true);
    end;

    procedure InsertTDSNatureOfRemittance(Code: Code[10]; Description: Text[50])
    var
        TDSNatureOfRemittance: Record "TDS Nature Of Remittance";
        Exists: Boolean;
    begin
        if TDSNatureOfRemittance.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TDSNatureOfRemittance.Validate(Code, Code);
        TDSNatureOfRemittance.Validate(Description, Description);

        if Exists then
            TDSNatureOfRemittance.Modify(true)
        else
            TDSNatureOfRemittance.Insert(true);
    end;

    procedure InsertTCSNatureofCollection(Code: Code[10]; Description: Text[30]; TCSOnReceipt: Boolean)
    var
        TCSNatureofCollection: Record "TCS Nature Of Collection";
        Exists: Boolean;
    begin
        if TCSNatureofCollection.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TCSNatureofCollection.Validate("Code", Code);
        TCSNatureofCollection.Validate(Description, Description);
        TCSNatureofCollection.Validate("TCS On Recpt. Of Pmt.", TCSOnReceipt);

        if Exists then
            TCSNatureofCollection.Modify(true)
        else
            TCSNatureofCollection.Insert(true);
    end;

    procedure InsertTCSPostingSetup(TCSNatureofCollection: Code[10]; EffectiveDate: Date; TCSAccount: Code[20])
    var
        TCSPostingSetup: Record "TCS Posting Setup";
        Exists: Boolean;
    begin
        if TCSPostingSetup.Get(TCSNatureofCollection, EffectiveDate) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TCSPostingSetup.Validate("TCS Nature of Collection", TCSNatureofCollection);
        TCSPostingSetup.Validate("Effective Date", EffectiveDate);
        TCSPostingSetup.Validate("TCS Account No.", TCSAccount);

        if Exists then
            TCSPostingSetup.Modify(true)
        else
            TCSPostingSetup.Insert(true);
    end;

    procedure InsertTaxAccountingPeriod(TaxTypeCode: Code[10]; "Starting Date": Date; "Ending Date": Date)
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
        YearStartDate: Date;
    begin
        YearStartDate := "Starting Date";
        while "Starting Date" <= "Ending Date" do begin
            TaxAccountingPeriod.Init();
            TaxAccountingPeriod."Tax Type Code" := TaxTypeCode;
            TaxAccountingPeriod.Validate("Starting Date", "Starting Date");
            if (Date2DMY("Starting Date", 1) = 1) and
               (Date2DMY("Starting Date", 2) = 4)
            then
                TaxAccountingPeriod."New Fiscal Year" := true;
            TaxAccountingPeriod.Name := FORMAT(TaxAccountingPeriod."Starting Date", 0, '<Month Text>');
            TaxAccountingPeriod."Ending Date" := CalcDate('<CM>', TaxAccountingPeriod."Starting Date");
            case Date2DMY("Starting Date", 2) of
                4, 5, 6:
                    TaxAccountingPeriod.Quarter := 'Q1';
                7, 8, 9:
                    TaxAccountingPeriod.Quarter := 'Q2';
                10, 11, 12:
                    TaxAccountingPeriod.Quarter := 'Q3';
                1, 2, 3:
                    TaxAccountingPeriod.Quarter := 'Q4';
            end;
            TaxAccountingPeriod."Financial Year" := Strsubstno('%1-%2', Date2DMY(YearStartDate, 3), Date2DMY("Ending Date", 3));
            TaxAccountingPeriod.Insert();
            "Starting Date" := CalcDate('<1M>', "Starting Date");
        end;
    end;

    procedure InsertBankCharge(Code: Code[10]; Description: Text[50]; BankChargeAccount: Code[20]; ForeignExchange: Boolean; GSTGroupCode: Code[10]; GSTCredit: Enum "GST Credit"; HSNSACCode: Code[10]; Exempted: Boolean)
    var
        BankCharge: Record "Bank Charge";
        Exists: Boolean;
    begin
        if BankCharge.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BankCharge.Validate(Code, Code);
        BankCharge.Validate(Description, Description);
        BankCharge.Validate(Account, BankChargeAccount);
        BankCharge.Validate("Foreign Exchange", ForeignExchange);
        BankCharge.Validate("GST Group Code", GSTGroupCode);
        BankCharge.Validate("GST Credit", GSTCredit);
        BankCharge.Validate("HSN/SAC Code", HSNSACCode);
        BankCharge.Validate(Exempted, Exempted);

        if Exists then
            BankCharge.Modify(true)
        else
            BankCharge.Insert(true);
    end;

    procedure InsertConcessionalCode(Code: Code[10]; Description: Text[30])
    var
        ConcessionalCode: Record "Concessional Code";
        Exists: Boolean;
    begin
        if ConcessionalCode.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ConcessionalCode.Validate(Code, Code);
        ConcessionalCode.Validate(Description, Description);

        if Exists then
            ConcessionalCode.Modify(true)
        else
            ConcessionalCode.Insert(true);
    end;

    procedure InsertFixedAssetBlock(FAClassCode: Code[10]; FABlockCode: Code[10]; Description: Text[30]; DepreciationPercent: Decimal; AddlDepreciationPercent: Decimal)
    var
        FixedAssetBlock: Record "Fixed Asset Block";
        Exists: Boolean;
    begin
        if FixedAssetBlock.Get(FAClassCode, FABlockCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FixedAssetBlock."FA Class Code" := FAClassCode;
        FixedAssetBlock.Code := FABlockCode;
        FixedAssetBlock.Description := Description;
        FixedAssetBlock."Depreciation %" := DepreciationPercent;
        FixedAssetBlock."Add. Depreciation %" := AddlDepreciationPercent;

        if Exists then
            FixedAssetBlock.Modify(true)
        else
            FixedAssetBlock.Insert(true);
    end;

    procedure CreateCustomerAllowedSection(CustomerNo: Code[20]; TDSSection: Code[20]; ThresholdOverlook: Boolean; SurchargeOverlook: Boolean)
    var
        CustomerAllowedSection: Record "Customer Allowed Sections";
        Exists: Boolean;
    begin
        if CustomerAllowedSection.Get(CustomerNo, TDSSection) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CustomerAllowedSection.Validate("Customer No", CustomerNo);
        CustomerAllowedSection.Validate("TDS Section", TDSSection);
        CustomerAllowedSection.Validate("Threshold Overlook", ThresholdOverlook);
        CustomerAllowedSection.Validate("Surcharge Overlook", SurchargeOverlook);

        if Exists then
            CustomerAllowedSection.Modify(true)
        else
            CustomerAllowedSection.Insert(true);
    end;

    procedure CreateVendorAllowedSection(VendorNo: Code[20]; TDSSection: Code[10]; ThresholdOverlook: Boolean; SurchargeOverlook: Boolean; NonResidentPayment: Boolean; ActApplicable: Code[10]; NatureofRemittance: Code[10])
    var
        VendorAllowedSection: Record "Allowed Sections";
        Exists: Boolean;
    begin
        if VendorAllowedSection.Get(VendorNo, TDSSection) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VendorAllowedSection.Validate("Vendor No", VendorNo);
        VendorAllowedSection.Validate("TDS Section", TDSSection);
        VendorAllowedSection.Validate("Threshold Overlook", ThresholdOverlook);
        VendorAllowedSection.Validate("Surcharge Overlook", SurchargeOverlook);
        VendorAllowedSection.Validate("Non Resident Payments", NonResidentPayment);
        VendorAllowedSection.Validate("Nature of Remittance", NatureofRemittance);
        VendorAllowedSection.Validate("Act Applicable", ActApplicable);

        if Exists then
            VendorAllowedSection.Modify(true)
        else
            VendorAllowedSection.Insert(true);
    end;

    procedure CreateCustomerAllowedNOC(CustomerNo: Code[20]; TCSNOC: Code[10]; ThresholdOverlook: Boolean; SurchargeOverlook: Boolean)
    var
        CustomerAllowedNOC: Record "Allowed NOC";
        Exists: Boolean;
    begin
        if CustomerAllowedNOC.Get(CustomerNo, TCSNOC) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CustomerAllowedNOC.Validate("Customer No.", CustomerNo);
        CustomerAllowedNOC.Validate("TCS Nature of Collection", TCSNOC);
        CustomerAllowedNOC.Validate("Threshold Overlook", ThresholdOverlook);
        CustomerAllowedNOC.Validate("Surcharge Overlook", SurchargeOverlook);

        if Exists then
            CustomerAllowedNOC.Modify(true)
        else
            CustomerAllowedNOC.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}
