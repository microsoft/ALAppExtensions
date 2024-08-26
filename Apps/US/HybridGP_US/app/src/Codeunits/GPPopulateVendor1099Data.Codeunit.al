namespace Microsoft.DataMigration.GP;

using Microsoft.Finance.GeneralLedger.Journal;
using System.Integration;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Purchases.Payables;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Reporting;

codeunit 42003 "GP Populate Vendor 1099 Data"
{
    EventSubscriberInstance = Manual;
    Permissions = tabledata "IRS 1099 Form Box" = R,
                tabledata "IRS 1099 Vendor Form Box Setup" = RIM;

    var
        VendorTaxBatchNameTxt: Label 'GPVENDTAX', Locked = true;
        VendorTaxNoSeriesTxt: Label 'VENDTAX', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        NoSeriesDescriptionTxt: Label 'GP Vendor 1099', Locked = true;
        BoxMappingNotFoundMsg: Label 'No 1099 box could be found with the current configuration. (1099 Type: %1, Box No. %2, Year: %3)', Comment = '%1 = 1099 Type, %2 = 1099 Box Number, %3 = Tax year';
        DefaultPayablesAccountCode: Code[20];
        PostingDate: Date;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; var HideDialog: Boolean)
    begin
        HideDialog := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeShowPostResultMessage', '', false, false)]
    local procedure OnBeforeShowPostResultMessage(var GenJnlLine: Record "Gen. Journal Line"; TempJnlBatchName: Code[10]; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    trigger OnRun()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if not GPCompanyAdditionalSettings.GetMigrateVendor1099Enabled() then
            exit;

        UpdateAllVendorTaxInfo();
    end;

    local procedure UpdateAllVendorTaxInfo()
    begin
        Initialize();
        UpdateVendorTaxInfo();
        CleanUp();
    end;

    local procedure Initialize()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        HelperFunctions: Codeunit "Helper Functions";
        CurrentYear: Integer;
    begin
        CreateMappingsIfNeeded();

        GPCompanyAdditionalSettings.GetSingleInstance();
        CurrentYear := System.Date2DMY(Today(), 3);

        // If the configured tax year is less than the minimum supported year (example: 0), default it to the current year
        if (GPCompanyAdditionalSettings."1099 Tax Year" < GPVendor1099MappingHelpers.GetMinimumSupportedTaxYear()) then begin
            GPCompanyAdditionalSettings."1099 Tax Year" := CurrentYear;
            GPCompanyAdditionalSettings.Modify();
        end;

        if GPCompanyAdditionalSettings."1099 Tax Year" = CurrentYear then
            PostingDate := Today()
        else
            PostingDate := System.DMY2Date(31, 12, GPCompanyAdditionalSettings."1099 Tax Year");

        CreateNoSeriesIfNeeded();
        DefaultPayablesAccountCode := HelperFunctions.GetPostingAccountNumber('PayablesAccount');
        DataMigrationFacadeHelper.CreateGeneralJournalBatchIfNeeded(VendorTaxBatchNameTxt, '', '');
        DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(SourceCodeTxt);
    end;

    local procedure UpdateVendorTaxInfo()
    var
        GPPM00200: Record "GP PM00200";
    begin
        GPPM00200.SetRange(TEN99TYPE, 2, 5);
        if not GPPM00200.FindSet() then
            exit;

        repeat
            ProcessVendorTaxInfo(GPPM00200);
        until GPPM00200.Next() = 0;
    end;

    local procedure ProcessVendorTaxInfo(var GPPM00200: Record "GP PM00200")
    var
        Vendor: Record Vendor;
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        IRS1099Code: Code[10];
    begin
        if not Vendor.Get(GPPM00200.VENDORID) then
            exit;

        if VendorAlreadyHasIRS1099CodeAssigned(Vendor) then begin
            LogVendorSkipped(Vendor."No.");
            exit;
        end;

        IRS1099Code := GPVendor1099MappingHelpers.GetIRS1099BoxCode(System.Date2DMY(System.Today(), 3), GPPM00200.TEN99TYPE, GPPM00200.TEN99BOXNUMBER);
        if IRS1099Code <> '' then
            AssignIRS1099CodeToVendor(Vendor, IRS1099Code);

        if GPPM00200.TXIDNMBR <> '' then
            Vendor.Validate("Federal ID No.", GPPM00200.TXIDNMBR.TrimEnd());

        if (IRS1099Code <> '') or (GPPM00200.TXIDNMBR <> '') then begin
            Vendor.Validate("Tax Identification Type", Vendor."Tax Identification Type"::"Legal Entity");
            if Vendor.Modify() then
                AddVendor1099Values(Vendor)
            else
                LogLastError(Vendor."No.");
        end else
            LogVendorSkipped(Vendor."No.");
    end;

    local procedure VendorAlreadyHasIRS1099CodeAssigned(var Vendor: Record Vendor): Boolean
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        GPCloudMigrationUS: Codeunit "GP Cloud Migration US";
    begin
#if not CLEAN25
#pragma warning disable AL0432
        if not GPCloudMigrationUS.IsIRSFormsFeatureEnabled() then
            exit(Vendor."IRS 1099 Code" <> '');
#pragma warning restore AL0432
#endif
        GPCompanyAdditionalSettings.GetSingleInstance();
        if IRS1099VendorFormBoxSetup.Get(Format(GPCompanyAdditionalSettings.Get1099TaxYear()), Vendor."No.") then
            exit(true);
    end;

    local procedure AssignIRS1099CodeToVendor(var Vendor: Record Vendor; IRS1099Code: Code[10]): Boolean
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        IRS1099FormBox: Record "IRS 1099 Form Box";
        GPCloudMigrationUS: Codeunit "GP Cloud Migration US";
    begin
#if not CLEAN25
#pragma warning disable AL0432
        if not GPCloudMigrationUS.IsIRSFormsFeatureEnabled() then begin
            Vendor.Validate("IRS 1099 Code", IRS1099Code);
            exit(true);
        end;
#pragma warning restore AL0432
#endif
        IRS1099FormBox.SetRange("No.", IRS1099Code);
        if not IRS1099FormBox.FindFirst() then
            exit(false);

        GPCompanyAdditionalSettings.GetSingleInstance();
        IRS1099VendorFormBoxSetup.Validate("Period No.", Format(GPCompanyAdditionalSettings.Get1099TaxYear()));
        IRS1099VendorFormBoxSetup.Validate("Vendor No.", Vendor."No.");
        IRS1099VendorFormBoxSetup.Validate("Form No.", IRS1099FormBox."Form No.");
        IRS1099VendorFormBoxSetup.Validate("Form Box No.", IRS1099Code);
        IRS1099VendorFormBoxSetup.Insert(true);

        exit(true);
    end;

    local procedure AddVendor1099Values(var Vendor: Record Vendor)
    var
        InvoiceGenJournalLine: Record "Gen. Journal Line";
        PaymentGenJournalLine: Record "Gen. Journal Line";
        NoSeries: Codeunit "No. Series";
        VendorYear1099AmountDictionary: Dictionary of [Code[10], Decimal];
        IRS1099Code: Code[10];
        TaxAmount: Decimal;
        VendorPayablesAccountCode: Code[20];
        InvoiceDocumentNo: Code[20];
        PaymentDocumentNo: Code[20];
        InvoiceExternalDocumentNo: Code[35];
        PaymentExternalDocumentNo: Code[35];
        InvoiceCreated: Boolean;
        PaymentCreated: Boolean;
    begin
        BuildVendor1099Entries(Vendor."No.", VendorYear1099AmountDictionary);
        if VendorYear1099AmountDictionary.Count() = 0 then
            exit;

        VendorPayablesAccountCode := GetPostingAccountNo(Vendor);
        if VendorPayablesAccountCode = '' then begin
            LogErrorMessage(Vendor."No.", 'No payables account found.');
            exit;
        end;

        foreach IRS1099Code in VendorYear1099AmountDictionary.Keys() do begin
            TaxAmount := VendorYear1099AmountDictionary.Get(IRS1099Code);

            if TaxAmount > 0 then begin
                // Invoice
                InvoiceExternalDocumentNo := CopyStr(Vendor."No." + '-' + IRS1099Code + '-INV', 1, MaxStrLen(InvoiceExternalDocumentNo));
                InvoiceDocumentNo := NoSeries.GetNextNo(VendorTaxNoSeriesTxt);
                InvoiceCreated := CreateGeneralJournalLine(InvoiceGenJournalLine,
                                    Vendor."No.",
                                    "Gen. Journal Document Type"::Invoice,
                                    InvoiceDocumentNo,
                                    IRS1099Code,
                                    Vendor."No.",
                                    -TaxAmount,
                                    VendorPayablesAccountCode,
                                    IRS1099Code,
                                    InvoiceExternalDocumentNo);

                // Payment
                PaymentExternalDocumentNo := CopyStr(Vendor."No." + '-' + IRS1099Code + '-PMT', 1, MaxStrLen(PaymentExternalDocumentNo));
                PaymentDocumentNo := NoSeries.GetNextNo(VendorTaxNoSeriesTxt);
                PaymentCreated := CreateGeneralJournalLine(PaymentGenJournalLine,
                                    Vendor."No.",
                                    "Gen. Journal Document Type"::Payment,
                                    PaymentDocumentNo,
                                    IRS1099Code,
                                    Vendor."No.",
                                    TaxAmount,
                                    VendorPayablesAccountCode,
                                    IRS1099Code,
                                    PaymentExternalDocumentNo);

                if InvoiceCreated and PaymentCreated then begin
                    InvoiceGenJournalLine.SendToPosting(Codeunit::"Gen. Jnl.-Post");
                    PaymentGenJournalLine.SendToPosting(Codeunit::"Gen. Jnl.-Post");
                    ApplyEntries(Vendor."No.", InvoiceDocumentNo, PaymentDocumentNo, InvoiceExternalDocumentNo);
                end;
            end;
        end;
    end;

    local procedure GetPostingAccountNo(var Vendor: Record Vendor): Code[20]
    var
        VendorPostingGroup: Record "Vendor Posting Group";
        GLAccount: Record "G/L Account";
    begin
        if Vendor."Vendor Posting Group" = '' then
            exit(DefaultPayablesAccountCode);

        if VendorPostingGroup.Get(Vendor."Vendor Posting Group") then
            if VendorPostingGroup."Payables Account" <> '' then
                if GLAccount.Get(VendorPostingGroup."Payables Account") then
                    exit(GLAccount."No.");

        exit('');
    end;

    local procedure BuildVendor1099Entries(VendorNo: Code[20]; var VendorYear1099AmountDictionary: Dictionary of [Code[10], Decimal])
    var
        GPPM00204: Record "GP PM00204";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        TaxYear: Integer;
        IRS1099Code: Code[10];
        TaxAmount: Decimal;
    begin
        TaxYear := GPCompanyAdditionalSettings.Get1099TaxYear();
        GPPM00204.SetRange(VENDORID, VendorNo);
        GPPM00204.SetRange(YEAR1, TaxYear);
        GPPM00204.SetFilter(TEN99AMNT, '>0');
        if GPPM00204.FindSet() then
            repeat
                IRS1099Code := GPVendor1099MappingHelpers.GetIRS1099BoxCode(TaxYear, GPPM00204.TEN99TYPE, GPPM00204.TEN99BOXNUMBER);
                if IRS1099Code <> '' then begin
                    if VendorYear1099AmountDictionary.Get(IRS1099Code, TaxAmount) then
                        VendorYear1099AmountDictionary.Set(IRS1099Code, TaxAmount + GPPM00204.TEN99AMNT)
                    else
                        VendorYear1099AmountDictionary.Add(IRS1099Code, GPPM00204.TEN99AMNT);
                end else
                    LogVendor1099DetailSkipped(VendorNo, GPPM00204.TEN99TYPE, GPPM00204.TEN99BOXNUMBER, TaxYear, IRS1099Code);
            until GPPM00204.Next() = 0;
    end;

    local procedure CreateGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]; DocumentType: enum "Gen. Journal Document Type"; DocumentNo: Code[20];
        Description: Text[50]; AccountNo: Code[20]; Amount: Decimal; BalancingAccount: Code[20]; IRS1099Code: Code[10]; ExternalDocumentNo: Code[35]): boolean
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLineCurrent: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        IRS1099FormBox: Record "IRS 1099 Form Box";
        GPCloudMigrationUS: Codeunit "GP Cloud Migration US";
        LineNum: Integer;
    begin
        GenJournalBatch.Get(CreateGenJournalTemplateIfNeeded(VendorTaxBatchNameTxt), VendorTaxBatchNameTxt);

        GenJournalLineCurrent.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLineCurrent.SetRange("Journal Batch Name", GenJournalBatch.Name);
        if GenJournalLineCurrent.FindLast() then
            LineNum := GenJournalLineCurrent."Line No." + 10000
        else
            LineNum := 10000;

        GenJournalTemplate.Get(GenJournalBatch."Journal Template Name");

        Clear(GenJournalLine);
        GenJournalLine.SetHideValidation(true);
        GenJournalLine.Validate("Source Code", GenJournalTemplate."Source Code");
        GenJournalLine.Validate("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.Validate("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.Validate("Line No.", LineNum);
        GenJournalLine.Validate("Account Type", "Gen. Journal Account Type"::Vendor);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate(Description, Description);
        GenJournalLine.Validate("Document Date", PostingDate);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Due Date", PostingDate);
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Validate("Amount (LCY)", Amount);
        GenJournalLine.Validate("Currency Code", '');
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", BalancingAccount);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::" ");
        GenJournalLine.Validate("Bal. Gen. Bus. Posting Group", '');
        GenJournalLine.Validate("Bal. Gen. Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Bus. Posting Group", '');
#if not CLEAN25
#pragma warning disable AL0432
        GenJournalLine.Validate("IRS 1099 Code", IRS1099Code);
#pragma warning restore AL0432
#endif
        GenJournalLine.Validate("Document Type", DocumentType);
        GenJournalLine.Validate("Source Code", SourceCodeTxt);
        GenJournalLine.Validate("External Document No.", ExternalDocumentNo);

        if GPCloudMigrationUS.IsIRSFormsFeatureEnabled() then begin
            GPCompanyAdditionalSettings.GetSingleInstance();
            GenJournalLine.Validate("IRS 1099 Reporting Period", Format(GPCompanyAdditionalSettings.Get1099TaxYear()));

            IRS1099FormBox.SetRange("No.", IRS1099Code);
            if IRS1099FormBox.FindFirst() then
                GenJournalLine.Validate("IRS 1099 Form No.", IRS1099FormBox."Form No.");

            GenJournalLine.Validate("IRS 1099 Form Box No.", IRS1099Code);
            GenJournalLine.Validate("IRS 1099 Reporting Amount", Amount);
        end;

        if GenJournalLine.Insert(true) then
            exit(true)
        else
            LogLastError(VendorNo);

        exit(false);
    end;

    local procedure CreateGenJournalTemplateIfNeeded(GenJournalBatchCode: Code[10]): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        GenJournalTemplate.SetRange(Recurring, false);
        if not GenJournalTemplate.FindFirst() then begin
            Clear(GenJournalTemplate);
            GenJournalTemplate.Validate(Name, GenJournalBatchCode);
            GenJournalTemplate.Validate(Type, GenJournalTemplate.Type::General);
            GenJournalTemplate.Validate(Recurring, false);
            GenJournalTemplate.Insert(true);
        end;
        exit(GenJournalTemplate.Name);
    end;

    local procedure ApplyEntries(VendorNo: Code[20]; InvoiceDocumentNo: Code[20]; PaymentDocumentNo: Code[20]; ExternalDocumentNo: Code[35])
    var
        PaymentVendorLedgerEntry: Record "Vendor Ledger Entry";
        InvoiceVendorLedgerEntry: Record "Vendor Ledger Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
    begin
        PaymentVendorLedgerEntry.SetRange("Vendor No.", VendorNo);
        PaymentVendorLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Payment);
        PaymentVendorLedgerEntry.SetRange("Document No.", PaymentDocumentNo);
        if PaymentVendorLedgerEntry.FindFirst() then begin
            InvoiceVendorLedgerEntry.SetRange("Vendor No.", VendorNo);
            InvoiceVendorLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
            InvoiceVendorLedgerEntry.SetRange("Document No.", InvoiceDocumentNo);

            if InvoiceVendorLedgerEntry.FindFirst() then begin
                PaymentVendorLedgerEntry.CalcFields(Amount);
                InvoiceVendorLedgerEntry.CalcFields(Amount);

                InvoiceVendorLedgerEntry.Validate("Applying Entry", true);
                InvoiceVendorLedgerEntry.Validate("Applies-to ID", PaymentVendorLedgerEntry."Document No.");
                InvoiceVendorLedgerEntry.CalcFields("Remaining Amount");
                InvoiceVendorLedgerEntry.Validate("Amount to Apply", InvoiceVendorLedgerEntry.Amount);
                Codeunit.Run(Codeunit::"Vend. Entry-Edit", InvoiceVendorLedgerEntry);

                VendEntrySetApplID.SetApplId(PaymentVendorLedgerEntry, InvoiceVendorLedgerEntry, PaymentVendorLedgerEntry."Document No.");

                ApplyUnapplyParameters."Account Type" := "Gen. Journal Account Type"::Vendor;
                ApplyUnapplyParameters."Account No." := VendorNo;
                ApplyUnapplyParameters."Document Type" := InvoiceVendorLedgerEntry."Document Type";
                ApplyUnapplyParameters."Document No." := InvoiceVendorLedgerEntry."Document No.";
                ApplyUnapplyParameters."Posting Date" := PostingDate;
                ApplyUnapplyParameters."External Document No." := ExternalDocumentNo;
                VendEntryApplyPostedEntries.Apply(InvoiceVendorLedgerEntry, ApplyUnapplyParameters);
            end;
        end;
    end;

    local procedure CreateNoSeriesIfNeeded()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get(VendorTaxNoSeriesTxt) then begin
            NoSeries."Code" := VendorTaxNoSeriesTxt;
            NoSeries.Description := NoSeriesDescriptionTxt;
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := false;
            NoSeries.Insert();

            NoSeriesLine."Series Code" := VendorTaxNoSeriesTxt;
            NoSeriesLine."Starting No." := 'VT000001';
            NoSeriesLine."Ending No." := 'VT999999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Open := true;
            NoSeriesLine.Insert();
        end;
    end;

    local procedure CleanUp()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Batch Name", VendorTaxBatchNameTxt);
        GenJournalLine.SetFilter("Account No.", '<>%1', '');
        if (not GenJournalLine.IsEmpty()) then
            exit;

        Clear(GenJournalLine);
        GenJournalLine.SetRange("Journal Batch Name", VendorTaxBatchNameTxt);
        GenJournalLine.SetRange("Account No.", '');
        if not GenJournalLine.IsEmpty() then
            GenJournalLine.DeleteAll();

        GenJournalBatch.SetRange(Name, VendorTaxBatchNameTxt);
        if GenJournalBatch.FindFirst() then begin
            GenJournalBatch.Delete();

            if (GenJournalTemplate.Get(VendorTaxBatchNameTxt)) then
                GenJournalTemplate.Delete();
        end;
    end;

    local procedure LogLastError(VendorNo: Code[20])
    var
        GP1099MigrationLog: Record "GP 1099 Migration Log";
    begin
        GP1099MigrationLog."Vendor No." := VendorNo;
        GP1099MigrationLog.IsError := true;
        GP1099MigrationLog."Error Code" := CopyStr(GetLastErrorCode(), 1, MaxStrLen(GP1099MigrationLog."Error Code"));
        GP1099MigrationLog.SetErrorMessage(GetLastErrorCallStack());
        GP1099MigrationLog.Insert();
        ClearLastError();
    end;

    local procedure LogErrorMessage(VendorNo: Code[20]; ErrorMsg: Text)
    var
        GP1099MigrationLog: Record "GP 1099 Migration Log";
    begin
        GP1099MigrationLog."Vendor No." := VendorNo;
        GP1099MigrationLog.IsError := true;
        GP1099MigrationLog.SetErrorMessage(ErrorMsg);
        GP1099MigrationLog.Insert();
        ClearLastError();
    end;

    local procedure LogVendorSkipped(VendorNo: Code[20])
    var
        GP1099MigrationLog: Record "GP 1099 Migration Log";
    begin
        GP1099MigrationLog."Vendor No." := VendorNo;
        GP1099MigrationLog.WasSkipped := true;
        GP1099MigrationLog.Insert();
    end;

    local procedure LogVendor1099DetailSkipped(VendorNo: Code[20]; GP1099Type: Integer; GP1099BoxNo: Integer; TaxYear: Integer; BCIRS1099Code: Code[10])
    var
        GP1099MigrationLog: Record "GP 1099 Migration Log";
        SkippedReasonMsg: Text;
    begin
        GP1099MigrationLog."Vendor No." := VendorNo;
        GP1099MigrationLog.WasSkipped := true;
        GP1099MigrationLog."GP 1099 Type" := GP1099Type;
        GP1099MigrationLog."GP 1099 Box No." := GP1099BoxNo;
        GP1099MigrationLog."BC IRS 1099 Code" := BCIRS1099Code;

        SkippedReasonMsg := StrSubstNo(BoxMappingNotFoundMsg, GP1099Type, GP1099BoxNo, TaxYear);
        GP1099MigrationLog.SetErrorMessage(SkippedReasonMsg);
        GP1099MigrationLog.Insert();
    end;

    local procedure CreateMappingsIfNeeded()
    begin
        Install2022Mappings();
    end;

    local procedure Install2022Mappings()
    var
        SupportedTaxYear: Record "Supported Tax Year";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        TaxYear: Integer;
    begin
        TaxYear := 2022;

        if SupportedTaxYear.Get(TaxYear) then
            exit;

        GPVendor1099MappingHelpers.InsertSupportedTaxYear(TaxYear);

        // DIV
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 1, 'DIV-01-A');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 2, 'DIV-01-B');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 3, 'DIV-02-A');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 4, 'DIV-02-B');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 5, 'DIV-02-C');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 6, 'DIV-02-D');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 17, 'DIV-02-E');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 18, 'DIV-02-F');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 7, 'DIV-03');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 8, 'DIV-04');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 9, 'DIV-05');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 10, 'DIV-06');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 11, 'DIV-07');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 12, 'DIV-09');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 13, 'DIV-10');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 14, 'DIV-12');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 2, 15, 'DIV-13');

        // INT
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 1, 'INT-01');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 2, 'INT-02');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 3, 'INT-03');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 4, 'INT-04');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 5, 'INT-05');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 6, 'INT-06');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 7, 'INT-08');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 8, 'INT-09');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 9, 'INT-10');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 10, 'INT-11');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 11, 'INT-12');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 3, 12, 'INT-13');

        // MISC
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 1, 'MISC-01');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 2, 'MISC-02');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 3, 'MISC-03');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 4, 'MISC-04');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 5, 'MISC-05');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 6, 'MISC-06');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 7, 'MISC-08');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 8, 'MISC-09');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 9, 'MISC-10');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 15, 'MISC-11');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 10, 'MISC-12');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 11, 'MISC-14');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 12, 'MISC-15');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 4, 13, 'MISC-16');

        // NEC
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 5, 1, 'NEC-01');
        GPVendor1099MappingHelpers.InsertMapping(TaxYear, 5, 2, 'NEC-04');
    end;
}