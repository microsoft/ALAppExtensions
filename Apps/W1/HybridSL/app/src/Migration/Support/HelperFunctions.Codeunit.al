// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Payables;
using System.Integration;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Costing;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Inventory.Tracking;
using Microsoft.Finance.GeneralLedger.Journal;
using System.Reflection;
using Microsoft.Utilities;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Journal;
using Microsoft.Finance.Consolidation;
using Microsoft.Inventory.Location;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Inventory.Posting;

codeunit 42023 "SL Helper Functions"
{
    Access = Internal;
    Permissions = tabledata "Dimension Set Entry" = rimd,
                    tabledata "G/L Account" = rimd,
                    tabledata "G/L Entry" = rimd,
                    tabledata Customer = rimd,
                    tabledata "Cust. Ledger Entry" = rimd,
                    tabledata Dimension = rimd,
                    tabledata "Dimension Value" = rimd,
                    tabledata "Detailed Cust. Ledg. Entry" = rimd,
                    tabledata Vendor = rimd,
                    tabledata "Vendor Ledger Entry" = rimd,
                    tabledata "Detailed Vendor Ledg. Entry" = rimd,
                    tabledata "Data Migration Status" = rimd,
                    tabledata Item = rimd,
                    tabledata "Item Ledger Entry" = rimd,
                    tabledata "Avg. Cost Adjmt. Entry Point" = rimd,
                    tabledata "Value Entry" = rimd,
                    tabledata "Item Unit of Measure" = rimd,
                    tabledata "Payment Terms" = rimd,
                    tabledata "Payment Term Translation" = rimd,
                    tabledata "Data Migration Entity" = rimd,
                    tabledata "Item Tracking Code" = rimd,
                    tabledata "Gen. Journal Line" = rimd,
                    tabledata "G/L - Item Ledger Relation" = rimd,
                    tabledata "G/L Register" = rimd;

    var
        SLConfiguration: Record "SL Migration Config";
        PeriodTxt: Label 'Period';
        PostingGroupCodeTxt: Label 'SL', Locked = true;
        CustomerBatchNameTxt: Label 'SLCUST', Locked = true;
        VendorBatchNameTxt: Label 'SLVEND', Locked = true;
        MigrationTypeTxt: Label 'Dynamics SL';
        CloudMigrationTok: Label 'CloudMigration', Locked = true;
        GeneralTemplateNameTxt: Label 'GENERAL', Locked = true;
        MigrationLogAreaBatchPostingTxt: Label 'Batch Posting', Locked = true;

    internal procedure GetPostingAccountNumber(AccountToGet: Text): Code[20]
    var
        SLAccountStagingSetup: Record "SL Account Staging Setup";
    begin
        if not SLAccountStagingSetup.FindFirst() then
            exit('');

        case AccountToGet of
            'SalesAccount':
                exit(SLAccountStagingSetup.SalesAccount);
            'SalesLineDiscAccount':
                exit(SLAccountStagingSetup.SalesLineDiscAccount);
            'SalesInvDiscAccount':
                exit(SLAccountStagingSetup.SalesInvDiscAccount);
            'SalesPmtDiscDebitAccount':
                exit(SLAccountStagingSetup.SalesPmtDiscDebitAccount);
            'PurchAccount':
                exit(SLAccountStagingSetup.PurchAccount);
            'PurchInvDiscAccount':
                exit(SLAccountStagingSetup.PurchInvDiscAccount);
            'COGSAccount':
                exit(SLAccountStagingSetup.COGSAccount);
            'InventoryAdjmtAccount':
                exit(SLAccountStagingSetup.InventoryAdjmtAccount);
            'SalesCreditMemoAccount':
                exit(SLAccountStagingSetup.SalesCreditMemoAccount);
            'PurchPmtDiscDebitAcc':
                exit(SLAccountStagingSetup.PurchPmtDiscDebitAcc);
            'PurchPrepaymentsAccount':
                exit(SLAccountStagingSetup.PurchPrepaymentsAccount);
            'PurchaseVarianceAccount':
                exit(SLAccountStagingSetup.PurchaseVarianceAccount);
            'InventoryAccount':
                exit(SLAccountStagingSetup.InventoryAccount);
            'ReceivablesAccount':
                exit(SLAccountStagingSetup.ReceivablesAccount);
            'ServiceChargeAccount':
                exit(SLAccountStagingSetup.ServiceChargeAccount);
            'PaymentDiscDebitAccount':
                exit(SLAccountStagingSetup.PurchPmtDiscDebitAccount);
            'PayablesAccount':
                exit(SLAccountStagingSetup.PayablesAccount);
            'PurchServiceChargeAccount':
                exit(SLAccountStagingSetup.PurchServiceChargeAccount);
            'PurchPaymentDiscDebitAccount':
                exit(SLAccountStagingSetup.PurchPmtDiscDebitAccount);
        end;
    end;

    internal procedure GetMigrationTypeTxt(): Text[250]
    begin
        exit(CopyStr(MigrationTypeTxt, 1, MaxStrLen(MigrationTypeTxt)));
    end;

    internal procedure GetNumberOfAccounts(): Integer;
    var
        MigrationSlAccount: Record "SL Account Staging";
    begin
        exit(MigrationSlAccount.Count());
    end;

    internal procedure GetNumberOfCustomers(): Integer;
    var
        SLCustomer: Record "SL Customer";
        SLCompanyAdditonalSettings: Record "SL Company Additional Settings";
    begin
        if not SLCompanyAdditonalSettings.GetReceivablesModuleEnabled() then
            exit(0);

        SLCustomer.SetFilter(Status, '<>%1', 'I');
        if SLCompanyAdditonalSettings.GetMigrateInactiveCustomers() then
            SLCustomer.SetFilter(Status, '*');

        if not SLCustomer.FindSet() then
            exit(0);

        exit(SLCustomer.Count());
    end;

    internal procedure GetNumberOfItems(): Integer;
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLInventory: Record "SL Inventory";
    begin
        if not SLCompanyAdditionalSettings.GetInventoryModuleEnabled() then
            exit(0);

        SLInventory.SetFilter(TranStatusCode, '<>%1&<>%2', 'IN', 'DE');
        if SLCompanyAdditionalSettings."Migrate Inactive Items" and SLCompanyAdditionalSettings."Migrate Discontinued Items" then
            SLInventory.SetFilter(TranStatusCode, '*');
        if SLCompanyAdditionalSettings."Migrate Inactive Items" and not SLCompanyAdditionalSettings."Migrate Discontinued Items" then
            SLInventory.SetFilter(TranStatusCode, '<>%1', 'DE');
        if not SLCompanyAdditionalSettings."Migrate Inactive Items" and SLCompanyAdditionalSettings."Migrate Discontinued Items" then
            SLInventory.SetFilter(TranStatusCode, '<>%1', 'IN');

        if not SLInventory.FindSet() then
            exit(0);

        exit(SLInventory.Count());
    end;

    internal procedure GetNumberOfVendors(): Integer;
    var
        SLVendor: Record "SL Vendor";
        SLCompanyAdditonalSettings: Record "SL Company Additional Settings";
    begin
        if not SLCompanyAdditonalSettings.GetPayablesModuleEnabled() then
            exit(0);

        SLVendor.SetFilter(Status, '<>%1', 'I');
        if SLCompanyAdditonalSettings.GetMigrateInactiveVendors() then
            SLVendor.SetFilter(Status, '*');

        if not SLVendor.FindSet() then
            exit(0);

        exit(SLVendor.Count());
    end;

    internal procedure NameFlip(Value: Text): Text
    var
        LastChar: Integer;
        TildeChar: Integer;
        FirstName: Text;
        LastName: Text;
    begin
        TildeChar := StrPos(Value, '~');
        if TildeChar > 0 then begin
            LastChar := StrLen(Value.TrimEnd());
            FirstName := CopyStr(Value, TildeChar + 1, LastChar - TildeChar);
            LastName := CopyStr(Value, 1, TildeChar - 1);
            Value := FirstName + ' ' + LastName;
        end;
        exit(Value.TrimEnd());
    end;

    internal procedure ConvertAccountCategory(MigrationSLAccount: Record "SL Account Staging"): Option
    var
        AccountCategoryType: Option ,Assets,Liabilities,Equity,Income,"Cost of Goods Sold",Expense;
    begin
        case MigrationSLAccount.AccountCategory of
            1:
                exit(AccountCategoryType::Assets);
            2:
                exit(AccountCategoryType::Liabilities);
            4:
                exit(AccountCategoryType::Income);
            6:
                exit(AccountCategoryType::Expense);
        end;
    end;

    internal procedure ConvertDebitCreditType(MigrationSLAccount: Record "SL Account Staging"): Option
    var
        DebitCreditType: Option Both,Debit,Credit;
    begin
        if MigrationSLAccount.DebitCredit = 0 then
            exit(DebitCreditType::Both);

        exit(DebitCreditType::Both);
    end;

    internal procedure ConvertIncomeBalanceType(MigrationSLAccount: Record "SL Account Staging"): Option
    var
        IncomeBalanceType: Option "Income Statement","Balance Sheet";
    begin
        if MigrationSLAccount.IncomeBalance then
            exit(IncomeBalanceType::"Balance Sheet");

        exit(IncomeBalanceType::"Income Statement");
    end;

    internal procedure ResetAdjustforPaymentInGLSetup(var Flag: Boolean);
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Reset();
        if GeneralLedgerSetup.FindFirst() then
            if Flag then begin
                Flag := false;
                GeneralLedgerSetup."Adjust for Payment Disc." := false;
                GeneralLedgerSetup.Modify();
            end else
                if not GeneralLedgerSetup."Adjust for Payment Disc." then begin
                    Flag := true;
                    GeneralLedgerSetup."Adjust for Payment Disc." := true;
                    GeneralLedgerSetup.Modify();
                end;
    end;

    internal procedure CreateDimensions()
    var
        SLSegments: Record "SL Segments";
        Dimension: Record Dimension;
    begin
        SLSegments.Reset();
        if not SLSegments.FindSet() then
            exit;

        repeat
            if not Dimension.Get(SLSegments.Id) then begin
                Dimension.Init();
                Dimension.Validate(Code, CheckDimensionName(SLSegments.Id));
                Dimension.Validate(Name, SLSegments.Name);
                Dimension.Validate("Code Caption", SLSegments.CodeCaption);
                Dimension.Validate("Filter Caption", SLSegments.FilterCaption);
                Dimension.Insert();
                Commit();
            end;
        until SLSegments.Next() = 0;

        CreateDimensionValues();
        Session.LogMessage('0000BBF', 'Created Dimensions', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        SetDimensionsCreated();
    end;

    internal procedure CheckDimensionName(Name: Text[20]): Text[21]
    var
        GLAccount: Record "G/L Account";
        BusinessUnit: Record "Business Unit";
        Item: Record Item;
        Location: Record Location;
    begin
        if ((UpperCase(Name) = UpperCase(GLAccount.TableCaption)) or
            (UpperCase(Name) = UpperCase(BusinessUnit.TableCaption)) or
            (UpperCase(Name) = UpperCase(Item.TableCaption)) or
            (UpperCase(Name) = UpperCase(Location.TableCaption)) or
            (UpperCase(Name) = UpperCase(PeriodTxt))) then
            exit(Name + 's');

        exit(Name);
    end;

    internal procedure CreateDimensionValues()
    var
        SLCodes: Record "SL Codes";
        DimensionValue: Record "Dimension Value";
    begin
        if not SLCodes.FindSet() then
            exit;

        repeat
            if not DimensionValue.Get(CheckDimensionName(SLCodes.Id), SLCodes.Name) then begin
                DimensionValue.Init();
                DimensionValue.Validate("Dimension Code", CheckDimensionName(SLCodes.Id));
                DimensionValue.Validate(Code, SLCodes.Name);
                DimensionValue.Validate(Name, SLCodes.Description);
                DimensionValue.Insert();
                Commit();
            end;
        until SLCodes.Next() = 0;
    end;

    internal procedure GetTelemetryCategory(): Text
    begin
        exit(CloudMigrationTok);
    end;

    internal procedure SetDimensionsCreated()
    begin
        SLConfiguration.GetSingleInstance();
        SLConfiguration."Dimensions Created" := true;
        SLConfiguration.Modify();
    end;

    internal procedure PostGLTransactions();
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalBatch: Record "Item Journal Batch";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        DurationAsInt: BigInteger;
        SkipPosting: Boolean;
        StartTime: DateTime;
        FinishedTelemetryTxt: Label 'Posting GL transactions finished; Duration: %1', Comment = '%1 - The time taken', Locked = true;
        JournalBatchName: Text;
    begin
        StartTime := CurrentDateTime();
        Session.LogMessage('00007GJ', 'Posting GL transactions started.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());

        SkipPosting := SLCompanyAdditionalSettings.GetSkipAllPosting();
        OnSkipPostingGLAccounts(SkipPosting);
        if SkipPosting then
            exit;

        // Item batches
        SkipPosting := SLCompanyAdditionalSettings.GetSkipPostingItemBatches();
        OnSkipPostingItemBatches(SkipPosting);
        if not SkipPosting then
            if ItemJournalBatch.FindSet() then
                repeat
                    ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
                    ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                    ItemJournalLine.SetFilter("Item No.", '<>%1', '');
                    if not ItemJournalLine.IsEmpty() then
                        SafePostItemBatch(ItemJournalBatch);
                until ItemJournalBatch.Next() = 0;
        // Account batches
        SkipPosting := SLCompanyAdditionalSettings.GetSkipPostingAccountBatches();
        OnSkipPostingAccountBatches(SkipPosting);
        if not SkipPosting then begin
            // Post the Account batches
            GenJournalBatch.Reset();
            GenJournalBatch.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalBatch.SetFilter(Name, PostingGroupCodeTxt + '*');
            if GenJournalBatch.FindSet() then
                repeat
                    if (GenJournalBatch.Name <> CustomerBatchNameTxt) and (GenJournalBatch.Name <> VendorBatchNameTxt) then begin
                        JournalBatchName := GenJournalBatch.Name;
                        GenJournalLine.Reset();
                        GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
                        if not GenJournalLine.IsEmpty() then
                            SafePostGLBatch(CopyStr(JournalBatchName, 1, 10));
                    end;
                until GenJournalBatch.Next() = 0;
        end;

        // Customer batches
        SkipPosting := SLCompanyAdditionalSettings.GetSkipPostingCustomerBatches();
        OnSkipPostingCustomerBatches(SkipPosting);
        if not SkipPosting then begin
            // Post the Customer Batch, if created...
            JournalBatchName := CustomerBatchNameTxt;
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
            if not GenJournalLine.IsEmpty() then
                SafePostGLBatch(CopyStr(JournalBatchName, 1, 10));
        end;

        // Vendor batches
        SkipPosting := SLCompanyAdditionalSettings.GetSkipPostingVendorBatches();
        OnSkipPostingVendorBatches(SkipPosting);
        if not SkipPosting then begin
            // Post the Vendor Batch, if created...
            JournalBatchName := VendorBatchNameTxt;
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
            if not GenJournalLine.IsEmpty() then
                SafePostGLBatch(CopyStr(JournalBatchName, 1, 10));
        end;
        RemoveBatches();
        DurationAsInt := CurrentDateTime() - StartTime;
        Session.LogMessage('00007GK', StrSubstNo(FinishedTelemetryTxt, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
    end;

    internal procedure SafePostItemBatch(ItemJournalBatch: Record "Item Journal Batch")
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        if ItemJournalLine.FindFirst() then begin
            // Commit is required to safely handle errors that may occur during posting.
            Commit();
            if not Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJournalLine) then
                LogWarningAndClearLastError(ItemJournalBatch.Name);
        end;
    end;

    internal procedure SafePostGLBatch(JournalBatchName: Code[10])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if GenJournalLine.FindFirst() then begin
            // Commit is required to safely handle errors that may occur during posting.
            Commit();
            if not Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJournalLine) then
                LogWarningAndClearLastError(JournalBatchName);
        end;
    end;

    internal procedure RemoveBatches();
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SkipPosting: Boolean;
        JournalBatchName: Text;
    begin
        SkipPosting := SLCompanyAdditionalSettings.GetSkipAllPosting();
        OnSkipPostingGLAccounts(SkipPosting);
        if SkipPosting then
            exit;
        // Account Batches
        SkipPosting := SLCompanyAdditionalSettings.GetSkipPostingAccountBatches();
        OnSkipPostingAccountBatches(SkipPosting);
        if not SkipPosting then begin
            // GL
            GenJournalBatch.Reset();
            GenJournalBatch.SetRange("Journal Template Name", GeneralTemplateNameTxt);

            if GenJournalBatch.FindSet() then
                repeat
                    if StrPos(GenJournalBatch.Name, PostingGroupCodeTxt) = 1 then
                        if (GenJournalBatch.Name <> CustomerBatchNameTxt) and (GenJournalBatch.Name <> VendorBatchNameTxt) then
                            if not GLBatchHasLines(GeneralTemplateNameTxt, GenJournalBatch.Name, GenJournalLine."Account Type"::"G/L Account") then begin
                                GenJournalLine.Reset();
                                GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                                GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
                                GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::"G/L Account");
                                GenJournalLine.SetRange("Account No.", '');
                                if GenJournalLine.Count() <= 1 then begin
                                    GenJournalLine.DeleteAll();
                                    GenJournalBatch.Delete();
                                end
                            end;
                until GenJournalBatch.Next() = 0;
        end;

        // Customer Batch
        SkipPosting := SLCompanyAdditionalSettings.GetSkipPostingCustomerBatches();
        OnSkipPostingCustomerBatches(SkipPosting);
        if not SkipPosting then begin
            JournalBatchName := CustomerBatchNameTxt;
            if not GLBatchHasLines(GeneralTemplateNameTxt, CopyStr(JournalBatchName, 1, MaxStrLen(CustomerBatchNameTxt)), GenJournalLine."Account Type"::Customer) then begin
                GenJournalLine.Reset();
                GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
                GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Customer);
                GenJournalLine.SetRange("Account No.", '');
                if GenJournalLine.Count() <= 1 then begin
                    GenJournalLine.DeleteAll();
                    if GenJournalBatch.Get(GeneralTemplateNameTxt, JournalBatchName) then
                        GenJournalBatch.Delete();
                end;
            end;
        end;
        // Vendor Batch
        SkipPosting := SLCompanyAdditionalSettings.GetSkipPostingVendorBatches();
        OnSkipPostingVendorBatches(SkipPosting);
        if not SkipPosting then begin
            JournalBatchName := VendorBatchNameTxt;
            if not GLBatchHasLines(GeneralTemplateNameTxt, CopyStr(JournalBatchName, 1, MaxStrLen(VendorBatchNameTxt)), GenJournalLine."Account Type"::Vendor) then begin
                GenJournalLine.Reset();
                GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
                GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Vendor);
                GenJournalLine.SetRange("Account No.", '');
                if GenJournalLine.Count() <= 1 then begin
                    GenJournalLine.DeleteAll();
                    if GenJournalBatch.Get(GeneralTemplateNameTxt, JournalBatchName) then
                        GenJournalBatch.Delete();
                end;
            end;
        end;
        // Item batches
        SkipPosting := SLCompanyAdditionalSettings.GetSkipPostingItemBatches();
        OnSkipPostingItemBatches(SkipPosting);
        if not SkipPosting then
            if ItemJournalBatch.FindSet() then
                repeat
                    ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
                    ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                    ItemJournalLine.SetFilter("Item No.", '<>%1', '');
                    if ItemJournalLine.IsEmpty() then
                        ItemJournalBatch.Delete();
                until ItemJournalBatch.Next() = 0;
    end;

    internal procedure LogWarningAndClearLastError(ContextValue: Text[50])
    var
        SLMigrationWarnings: Record "SL Migration Warnings";
        WarningText: Text[500];
    begin
        WarningText := CopyStr(GetLastErrorText(false), 1, MaxStrLen(WarningText));
        SLMigrationWarnings.InsertWarning(MigrationLogAreaBatchPostingTxt, ContextValue, WarningText);
        ClearLastError();
    end;

    internal procedure GLBatchHasLines(TemplateName: Code[10]; BatchName: Code[10]; AccountType: Enum "Gen. Journal Account Type"): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", TemplateName);
        GenJournalLine.SetRange("Journal Batch Name", BatchName);
        GenJournalLine.SetRange("Account Type", AccountType);
        GenJournalLine.SetFilter("Account No.", '<>%1', '');
        exit(not GenJournalLine.IsEmpty());
    end;

    internal procedure SetGlobalDimensions(GlobalDim1: Code[20]; GlobalDim2: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not GeneralLedgerSetup.IsEmpty() then
            GeneralLedgerSetup.Get();

        CheckPluralization(GlobalDim1);
        CheckPluralization(GlobalDim2);

        if GlobalDim1 <> '' then begin
            GeneralLedgerSetup."Global Dimension 1 Code" := GlobalDim1;
            GeneralLedgerSetup."Shortcut Dimension 1 Code" := GlobalDim1;
        end;

        if GlobalDim2 <> '' then begin
            GeneralLedgerSetup."Global Dimension 2 Code" := GlobalDim2;
            GeneralLedgerSetup."Shortcut Dimension 2 Code" := GlobalDim2;
        end;

        if (GlobalDim1 <> '') or (GlobalDim2 <> '') then
            GeneralLedgerSetup.Modify();

        SetShorcutDimenions();
    end;

    internal procedure CheckPluralization(var GlobalDim: Code[20])
    var
        Dim: Code[21];
    begin
        if GlobalDim in ['G/L ACCOUNT', 'BUSINESS UNIT', 'ITEM', 'LOCATION', 'PERIOD'] then begin
            Dim := GlobalDim + 'S';
            GlobalDim := CopyStr(Dim, 1, 20);
        end;
    end;

    internal procedure SetShorcutDimenions()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SLSegments: Record "SL Segments";
        Modified: Boolean;
        i: Integer;
    begin
        i := 1;
        Modified := false;
        GeneralLedgerSetup.Get();
        SLSegments.SetCurrentKey(SLSegments.SegmentNumber);
        SLSegments.Ascending(true);
        if SLSegments.FindSet() then
            repeat
                if (SLSegments.Id <> GeneralLedgerSetup."Global Dimension 1 Code") and (SLSegments.Id <> GeneralLedgerSetup."Global Dimension 2 Code") then begin
                    case i of
                        1:
                            GeneralLedgerSetup."Shortcut Dimension 3 Code" := SLSegments.Id;
                        2:
                            GeneralLedgerSetup."Shortcut Dimension 4 Code" := SLSegments.Id;
                        3:
                            GeneralLedgerSetup."Shortcut Dimension 5 Code" := SLSegments.Id;
                        4:
                            GeneralLedgerSetup."Shortcut Dimension 6 Code" := SLSegments.Id;
                        5:
                            GeneralLedgerSetup."Shortcut Dimension 7 Code" := SLSegments.Id;
                        6:
                            GeneralLedgerSetup."Shortcut Dimension 8 Code" := SLSegments.Id;
                    end;
                    Modified := true;
                    i := i + 1;
                end;
            until SLSegments.Next() = 0;
        SLSegments.Reset();
        if Modified then
            GeneralLedgerSetup.Modify();
    end;

    internal procedure UpdateGlobalDimensionNo()
    var
        DimensionValue: Record "Dimension Value";
    begin
        if DimensionValue.FindSet() then
            repeat
                DimensionValue."Global Dimension No." := GetGlobalDimensionNo(DimensionValue."Dimension Code");
                DimensionValue.Modify();
            until DimensionValue.Next() = 0;
    end;

    internal procedure GetGlobalDimensionNo(DimensionCode: Code[20]): Integer
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        case DimensionCode of
            GeneralLedgerSetup."Global Dimension 1 Code":
                exit(1);
            GeneralLedgerSetup."Global Dimension 2 Code":
                exit(2);
            GeneralLedgerSetup."Shortcut Dimension 3 Code":
                exit(3);
            GeneralLedgerSetup."Shortcut Dimension 4 Code":
                exit(4);
            GeneralLedgerSetup."Shortcut Dimension 5 Code":
                exit(5);
            GeneralLedgerSetup."Shortcut Dimension 6 Code":
                exit(6);
            GeneralLedgerSetup."Shortcut Dimension 7 Code":
                exit(7);
            GeneralLedgerSetup."Shortcut Dimension 8 Code":
                exit(8);
            else
                exit(0);
        end;
    end;

    internal procedure SetProcessesRunning(IsRunning: Boolean)
    var
        SLCmpnyMigratnSettings: Record "SL Company Migration Settings";
    begin
        SLCmpnyMigratnSettings.SetRange(Replicate, true);
        SLCmpnyMigratnSettings.SetRange(Name, CompanyName());
        if SLCmpnyMigratnSettings.FindFirst() then begin
            SLCmpnyMigratnSettings.ProcessesAreRunning := IsRunning;
            SLCmpnyMigratnSettings.Modify();
        end;
    end;

    internal procedure CreateItemTrackingCodes()
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        ItemTrackingCode.Init();
        ItemTrackingCode.Code := 'LOTRCVDEXP';
        ItemTrackingCode.Description := 'Lot When Received, Expiration';
        ItemTrackingCode."Man. Warranty Date Entry Reqd." := false;
        ItemTrackingCode."Man. Expir. Date Entry Reqd." := true;
        ItemTrackingCode."Strict Expiration Posting" := false;
        ItemTrackingCode."Strict Expiration Posting" := false;
        ItemTrackingCode."SN Specific Tracking" := false;
        ItemTrackingCode."SN Info. Inbound Must Exist" := false;
        ItemTrackingCode."SN Info. Outbound Must Exist" := false;
        ItemTrackingCode."SN Warehouse Tracking" := false;
        ItemTrackingCode."SN Purchase Inbound Tracking" := false;
        ItemTrackingCode."SN Purchase Outbound Tracking" := false;
        ItemTrackingCode."SN Sales Inbound Tracking" := false;
        ItemTrackingCode."SN Sales Outbound Tracking" := false;
        ItemTrackingCode."SN Pos. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."SN Pos. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."SN Neg. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."SN Neg. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."SN Transfer Tracking" := false;
        ItemTrackingCode."SN Manuf. Inbound Tracking" := false;
        ItemTrackingCode."SN Manuf. Outbound Tracking" := false;
        ItemTrackingCode."SN Assembly Inbound Tracking" := false;
        ItemTrackingCode."SN Assembly Outbound Tracking" := false;
        ItemTrackingCode."Lot Specific Tracking" := true;
        ItemTrackingCode."Lot Info. Inbound Must Exist" := false;
        ItemTrackingCode."Lot Info. Outbound Must Exist" := false;
        ItemTrackingCode."Lot Warehouse Tracking" := false;
        ItemTrackingCode."Lot Purchase Inbound Tracking" := true;
        ItemTrackingCode."Lot Purchase Outbound Tracking" := true;
        ItemTrackingCode."Lot Sales Inbound Tracking" := true;
        ItemTrackingCode."Lot Sales Outbound Tracking" := true;
        ItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."Lot Pos. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."Lot Neg. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."Lot Neg. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."Lot Transfer Tracking" := true;
        ItemTrackingCode."Lot Manuf. Inbound Tracking" := true;
        ItemTrackingCode."Lot Manuf. Outbound Tracking" := true;
        ItemTrackingCode."Lot Assembly Inbound Tracking" := true;
        ItemTrackingCode."Lot Assembly Outbound Tracking" := true;

        ItemTrackingCode.Insert(true);

        ItemTrackingCode.Init();
        ItemTrackingCode.Code := 'LOTRCVD';
        ItemTrackingCode.Description := 'Lot When Received';
        ItemTrackingCode."Man. Warranty Date Entry Reqd." := false;
        ItemTrackingCode."Man. Expir. Date Entry Reqd." := false;
        ItemTrackingCode."Strict Expiration Posting" := false;
        ItemTrackingCode."Strict Expiration Posting" := false;
        ItemTrackingCode."SN Specific Tracking" := false;
        ItemTrackingCode."SN Info. Inbound Must Exist" := false;
        ItemTrackingCode."SN Info. Outbound Must Exist" := false;
        ItemTrackingCode."SN Warehouse Tracking" := false;
        ItemTrackingCode."SN Purchase Inbound Tracking" := false;
        ItemTrackingCode."SN Purchase Outbound Tracking" := false;
        ItemTrackingCode."SN Sales Inbound Tracking" := false;
        ItemTrackingCode."SN Sales Outbound Tracking" := false;
        ItemTrackingCode."SN Pos. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."SN Pos. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."SN Neg. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."SN Neg. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."SN Transfer Tracking" := false;
        ItemTrackingCode."SN Manuf. Inbound Tracking" := false;
        ItemTrackingCode."SN Manuf. Outbound Tracking" := false;
        ItemTrackingCode."SN Assembly Inbound Tracking" := false;
        ItemTrackingCode."SN Assembly Outbound Tracking" := false;
        ItemTrackingCode."Lot Specific Tracking" := true;
        ItemTrackingCode."Lot Info. Inbound Must Exist" := false;
        ItemTrackingCode."Lot Info. Outbound Must Exist" := false;
        ItemTrackingCode."Lot Warehouse Tracking" := false;
        ItemTrackingCode."Lot Purchase Inbound Tracking" := true;
        ItemTrackingCode."Lot Purchase Outbound Tracking" := true;
        ItemTrackingCode."Lot Sales Inbound Tracking" := true;
        ItemTrackingCode."Lot Sales Outbound Tracking" := true;
        ItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."Lot Pos. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."Lot Neg. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."Lot Neg. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."Lot Transfer Tracking" := true;
        ItemTrackingCode."Lot Manuf. Inbound Tracking" := true;
        ItemTrackingCode."Lot Manuf. Outbound Tracking" := true;
        ItemTrackingCode."Lot Assembly Inbound Tracking" := true;
        ItemTrackingCode."Lot Assembly Outbound Tracking" := true;

        ItemTrackingCode.Insert(true);

        ItemTrackingCode.Init();
        ItemTrackingCode.Code := 'LOTUSED';
        ItemTrackingCode.Description := 'Lot When Used';
        ItemTrackingCode."Man. Warranty Date Entry Reqd." := false;
        ItemTrackingCode."Man. Expir. Date Entry Reqd." := false;
        ItemTrackingCode."Strict Expiration Posting" := false;
        ItemTrackingCode."Strict Expiration Posting" := false;
        ItemTrackingCode."SN Specific Tracking" := false;
        ItemTrackingCode."SN Info. Inbound Must Exist" := false;
        ItemTrackingCode."SN Info. Outbound Must Exist" := false;
        ItemTrackingCode."SN Warehouse Tracking" := false;
        ItemTrackingCode."SN Purchase Inbound Tracking" := false;
        ItemTrackingCode."SN Purchase Outbound Tracking" := false;
        ItemTrackingCode."SN Sales Inbound Tracking" := false;
        ItemTrackingCode."SN Sales Outbound Tracking" := false;
        ItemTrackingCode."SN Pos. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."SN Pos. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."SN Neg. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."SN Neg. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."SN Transfer Tracking" := false;
        ItemTrackingCode."SN Manuf. Inbound Tracking" := false;
        ItemTrackingCode."SN Manuf. Outbound Tracking" := false;
        ItemTrackingCode."SN Assembly Inbound Tracking" := false;
        ItemTrackingCode."SN Assembly Outbound Tracking" := false;
        ItemTrackingCode."Lot Specific Tracking" := false;
        ItemTrackingCode."Lot Info. Inbound Must Exist" := false;
        ItemTrackingCode."Lot Info. Outbound Must Exist" := false;
        ItemTrackingCode."Lot Warehouse Tracking" := false;
        ItemTrackingCode."Lot Purchase Inbound Tracking" := false;
        ItemTrackingCode."Lot Purchase Outbound Tracking" := false;
        ItemTrackingCode."Lot Sales Inbound Tracking" := false;
        ItemTrackingCode."Lot Sales Outbound Tracking" := true;
        ItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."Lot Pos. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."Lot Neg. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."Lot Neg. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."Lot Transfer Tracking" := false;
        ItemTrackingCode."Lot Manuf. Inbound Tracking" := false;
        ItemTrackingCode."Lot Manuf. Outbound Tracking" := true;
        ItemTrackingCode."Lot Assembly Inbound Tracking" := false;
        ItemTrackingCode."Lot Assembly Outbound Tracking" := true;

        ItemTrackingCode.Insert(true);

        ItemTrackingCode.Init();
        ItemTrackingCode.Code := 'SERRCVDEXP';
        ItemTrackingCode.Description := 'SN When Received, Expiration';
        ItemTrackingCode."Man. Warranty Date Entry Reqd." := false;
        ItemTrackingCode."Man. Expir. Date Entry Reqd." := true;
        ItemTrackingCode."Strict Expiration Posting" := false;
        ItemTrackingCode."SN Specific Tracking" := true;
        ItemTrackingCode."SN Info. Inbound Must Exist" := false;
        ItemTrackingCode."SN Info. Outbound Must Exist" := false;
        ItemTrackingCode."SN Warehouse Tracking" := false;
        ItemTrackingCode."SN Purchase Inbound Tracking" := true;
        ItemTrackingCode."SN Purchase Outbound Tracking" := true;
        ItemTrackingCode."SN Sales Inbound Tracking" := true;
        ItemTrackingCode."SN Sales Outbound Tracking" := true;
        ItemTrackingCode."SN Pos. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."SN Pos. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."SN Neg. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."SN Neg. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."SN Transfer Tracking" := true;
        ItemTrackingCode."SN Manuf. Inbound Tracking" := true;
        ItemTrackingCode."SN Manuf. Outbound Tracking" := true;
        ItemTrackingCode."SN Assembly Inbound Tracking" := true;
        ItemTrackingCode."SN Assembly Outbound Tracking" := true;
        ItemTrackingCode."Lot Specific Tracking" := false;
        ItemTrackingCode."Lot Info. Inbound Must Exist" := false;
        ItemTrackingCode."Lot Info. Outbound Must Exist" := false;
        ItemTrackingCode."Lot Warehouse Tracking" := false;
        ItemTrackingCode."Lot Purchase Inbound Tracking" := false;
        ItemTrackingCode."Lot Purchase Outbound Tracking" := false;
        ItemTrackingCode."Lot Sales Inbound Tracking" := false;
        ItemTrackingCode."Lot Sales Outbound Tracking" := false;
        ItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."Lot Pos. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."Lot Neg. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."Lot Neg. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."Lot Transfer Tracking" := false;
        ItemTrackingCode."Lot Manuf. Inbound Tracking" := false;
        ItemTrackingCode."Lot Manuf. Outbound Tracking" := false;
        ItemTrackingCode."Lot Assembly Inbound Tracking" := false;
        ItemTrackingCode."Lot Assembly Outbound Tracking" := false;

        ItemTrackingCode.Insert(true);

        ItemTrackingCode.Init();
        ItemTrackingCode.Code := 'SERRCVD';
        ItemTrackingCode.Description := 'SN When Received';
        ItemTrackingCode."Man. Warranty Date Entry Reqd." := false;
        ItemTrackingCode."Man. Expir. Date Entry Reqd." := false;
        ItemTrackingCode."Strict Expiration Posting" := false;
        ItemTrackingCode."Strict Expiration Posting" := false;
        ItemTrackingCode."SN Specific Tracking" := true;
        ItemTrackingCode."SN Info. Inbound Must Exist" := false;
        ItemTrackingCode."SN Info. Outbound Must Exist" := false;
        ItemTrackingCode."SN Warehouse Tracking" := false;
        ItemTrackingCode."SN Purchase Inbound Tracking" := true;
        ItemTrackingCode."SN Purchase Outbound Tracking" := true;
        ItemTrackingCode."SN Sales Inbound Tracking" := true;
        ItemTrackingCode."SN Sales Outbound Tracking" := true;
        ItemTrackingCode."SN Pos. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."SN Pos. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."SN Neg. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."SN Neg. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."SN Transfer Tracking" := true;
        ItemTrackingCode."SN Manuf. Inbound Tracking" := true;
        ItemTrackingCode."SN Manuf. Outbound Tracking" := true;
        ItemTrackingCode."SN Assembly Inbound Tracking" := true;
        ItemTrackingCode."SN Assembly Outbound Tracking" := true;
        ItemTrackingCode."Lot Specific Tracking" := false;
        ItemTrackingCode."Lot Info. Inbound Must Exist" := false;
        ItemTrackingCode."Lot Info. Outbound Must Exist" := false;
        ItemTrackingCode."Lot Warehouse Tracking" := false;
        ItemTrackingCode."Lot Purchase Inbound Tracking" := false;
        ItemTrackingCode."Lot Purchase Outbound Tracking" := false;
        ItemTrackingCode."Lot Sales Inbound Tracking" := false;
        ItemTrackingCode."Lot Sales Outbound Tracking" := false;
        ItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."Lot Pos. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."Lot Neg. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."Lot Neg. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."Lot Transfer Tracking" := false;
        ItemTrackingCode."Lot Manuf. Inbound Tracking" := false;
        ItemTrackingCode."Lot Manuf. Outbound Tracking" := false;
        ItemTrackingCode."Lot Assembly Inbound Tracking" := false;
        ItemTrackingCode."Lot Assembly Outbound Tracking" := false;

        ItemTrackingCode.Insert(true);

        ItemTrackingCode.Init();
        ItemTrackingCode.Code := 'SERUSED';
        ItemTrackingCode.Description := 'SN When Used';
        ItemTrackingCode."Man. Warranty Date Entry Reqd." := false;
        ItemTrackingCode."Man. Expir. Date Entry Reqd." := false;
        ItemTrackingCode."Strict Expiration Posting" := false;
        ItemTrackingCode."SN Specific Tracking" := false;
        ItemTrackingCode."SN Info. Inbound Must Exist" := false;
        ItemTrackingCode."SN Info. Outbound Must Exist" := false;
        ItemTrackingCode."SN Warehouse Tracking" := false;
        ItemTrackingCode."SN Purchase Inbound Tracking" := false;
        ItemTrackingCode."SN Purchase Outbound Tracking" := false;
        ItemTrackingCode."SN Sales Inbound Tracking" := false;
        ItemTrackingCode."SN Sales Outbound Tracking" := true;
        ItemTrackingCode."SN Pos. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."SN Pos. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."SN Neg. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."SN Neg. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."SN Transfer Tracking" := false;
        ItemTrackingCode."SN Manuf. Inbound Tracking" := false;
        ItemTrackingCode."SN Manuf. Outbound Tracking" := true;
        ItemTrackingCode."SN Assembly Inbound Tracking" := false;
        ItemTrackingCode."SN Assembly Outbound Tracking" := true;
        ItemTrackingCode."Lot Specific Tracking" := false;
        ItemTrackingCode."Lot Info. Inbound Must Exist" := false;
        ItemTrackingCode."Lot Info. Outbound Must Exist" := false;
        ItemTrackingCode."Lot Warehouse Tracking" := false;
        ItemTrackingCode."Lot Purchase Inbound Tracking" := false;
        ItemTrackingCode."Lot Purchase Outbound Tracking" := false;
        ItemTrackingCode."Lot Sales Inbound Tracking" := false;
        ItemTrackingCode."Lot Sales Outbound Tracking" := false;
        ItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."Lot Pos. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."Lot Neg. Adjmt. Inb. Tracking" := false;
        ItemTrackingCode."Lot Neg. Adjmt. Outb. Tracking" := false;
        ItemTrackingCode."Lot Transfer Tracking" := false;
        ItemTrackingCode."Lot Manuf. Inbound Tracking" := false;
        ItemTrackingCode."Lot Manuf. Outbound Tracking" := false;
        ItemTrackingCode."Lot Assembly Inbound Tracking" := false;
        ItemTrackingCode."Lot Assembly Outbound Tracking" := false;

        ItemTrackingCode.Insert(true);
        SetItemTrackingCodesCreated();
    end;

    internal procedure SetItemTrackingCodesCreated()
    begin
        SLConfiguration.GetSingleInstance();
        SLConfiguration."Item Tracking Codes Created" := true;
        SLConfiguration.Modify();
    end;

    internal procedure CreateLocations()
    var
        SLSite: Record "SL Site";
        Location: Record Location;
    begin
        if SLSite.FindSet() then
            repeat
                Location.Init();
                Location.Code := Text.CopyStr(SLSite.SiteId, 1, 10);
                Location.Name := SLSite.Name;
                Location.Address := SLSite.Addr1;
                Location."Address 2" := Text.CopyStr(SLSite.Addr2, 1, 50);
                Location.City := Text.CopyStr(SLSite.City, 1, 30);
                Location."Phone No." := SLSite.Phone;
                Location."Fax No." := SLSite.Fax;
                Location."Post Code" := SLSite.Zip;
                Location.Insert(true);
            until SLSite.Next() = 0;
        Session.LogMessage('0000BK6', 'Created Locations', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        SetLocationsCreated();
    end;

    internal procedure SetLocationsCreated()
    begin
        SLConfiguration.GetSingleInstance();
        SLConfiguration."Locations Created" := true;
        SLConfiguration.Modify();
    end;

    internal procedure CheckAndLogErrors()
    var
        LastError: Text;
    begin
        LastError := GetLastErrorText(false);
        if LastError = '' then
            exit;

        LogError(LastError);
        Commit();
    end;

    internal procedure LogError(LastErrorMessage: Text)
    var
        ExistingDataMigrationError: Record "Data Migration Error";
        DataMigrationError: Record "Data Migration Error";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if LastErrorMessage = '' then
            exit;

        if ExistingDataMigrationError.FindLast() then;
        DataMigrationError.Id := ExistingDataMigrationError.Id + 1;
        DataMigrationError.Insert();
        DataMigrationError."Last Record Under Processing" := CopyStr(DataMigrationErrorLogging.GetLastRecordUnderProcessing(), 1, MaxStrLen(DataMigrationError."Last Record Under Processing"));
        DataMigrationError.SetLastRecordUnderProcessingLog(DataMigrationErrorLogging.GetFullListOfLastRecordsUnderProcessingAsText());

        DataMigrationError."Error Message" := CopyStr(LastErrorMessage, 1, MaxStrLen(DataMigrationError."Error Message"));
        DataMigrationError."Migration Type" := GetMigrationTypeTxt();

        DataMigrationError.SetFullExceptionMessage(GetLastErrorText());
        DataMigrationError.SetExceptionCallStack(GetLastErrorCallStack());

        DataMigrationErrorLogging.ClearLastRecordUnderProcessing();
    end;

    internal procedure GetLastError()
    begin
        SLConfiguration.GetSingleInstance();
        SLConfiguration."Last Error Message" := CopyStr(GetLastErrorText(), 1, 250);
        SLConfiguration.Modify();
    end;

    internal procedure CheckMigrationStatus()
    begin
        SLConfiguration.GetSingleInstance();
        if not SLConfiguration."PreMigration Cleanup Completed" then begin
            CreateDataMigrationErrorRecord('PreMigration cleanup not completed.');
            exit;
        end;

        if not SLConfiguration."Dimensions Created" then
            CreateDataMigrationErrorRecord('Dimensions not created.');
        if not SLConfiguration."Payment Terms Created" then
            CreateDataMigrationErrorRecord('Payment Terms not created');
        if not SLConfiguration."Item Tracking Codes Created" then
            CreateDataMigrationErrorRecord('Item Tracking Codes not created');
        if not SLConfiguration."Locations Created" then
            CreateDataMigrationErrorRecord('Locations not created.');
    end;

    internal procedure CreateDataMigrationErrorRecord(ErrorMessage: Text[250])
    var
        DataMigrationError: Record "Data Migration Error";
    begin
        DataMigrationError.Init();
        DataMigrationError."Migration Type" := MigrationTypeTxt;
        DataMigrationError."Scheduled For Retry" := false;
        DataMigrationError."Error Message" := ErrorMessage;
        DataMigrationError.Insert();
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSkipPostingGLAccounts(var SkipPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSkipPostingItemBatches(var SkipPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSkipPostingAccountBatches(var SkipPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSkipPostingCustomerBatches(var SkipPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSkipPostingVendorBatches(var SkipPosting: Boolean)
    begin
    end;
}