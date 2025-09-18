// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Customer;

codeunit 47018 "SL Customer Migrator"
{
    Access = Internal;

    var
        ARSetupIDTxt: Label 'AR', Locked = true;
        CustomerBatchNameTxt: Label 'SLCUST', Locked = true;
        PostingGroupCodeTxt: Label 'SL', Locked = true;
        SLPrefixTxt: Label 'SL', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        StatusInactiveTxt: Label 'I', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", OnMigrateCustomer, '', true, true)]
    local procedure OnMigrateCustomer(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId)
    begin
        MigrateCustomer(Sender, RecordIdToMigrate);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", OnMigrateCustomerPostingGroups, '', true, true)]
    local procedure OnMigrateCustomerPostingGroups(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    begin
        MigrateCustomerPostingGroups(Sender, RecordIdToMigrate, ChartOfAccountsMigrated);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", OnMigrateCustomerTransactions, '', true, true)]
    local procedure OnMigrateCustomerTransactions(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    begin
        MigrateCustomerTransactions(Sender, RecordIdToMigrate, ChartOfAccountsMigrated);
    end;

    internal procedure MigrateCustomerDetails(SLCustomer: Record "SL Customer"; CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade"; SLARSetup: Record "SL ARSetup")
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLSalesTax: Record "SL SalesTax";
        SLSOAddress: Record "SL SOAddress";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        Country: Code[10];
        ShipViaID: Code[10];
        Address1: Text[50];
        Address2: Text[50];
        BillName: Text[50];
        CustomerName: Text[50];
        CustomerBlocked: Boolean;
        ContactAddressFormatToSet: Option First,"After Company Name",Last;
        AddressFormatToSet: Option "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
        SLTaxTypeGroupTxt: Label 'G', Locked = true;
    begin
        if SLCustomer.Status = StatusInactiveTxt then
            if SLCompanyAdditionalSettings.Get(CompanyName()) then
                if not SLCompanyAdditionalSettings."Migrate Inactive Customers" then begin
                    DecrementMigratedCount();
                    exit;
                end else
                    CustomerBlocked := true;

        if not CustomerDataMigrationFacade.CreateCustomerIfNeeded(SLCustomer.CustId, CopyStr(SLHelperFunctions.NameFlip(SLCustomer.Name), 1, MaxStrLen(CustomerName))) then
            exit;

        if CustomerBlocked then
            CustomerDataMigrationFacade.SetBlocked("Customer Blocked"::All);

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLCustomer.RecordId));

        if (SLCustomer.Country <> '') then begin
            Country := SLCustomer.Country;
            CustomerDataMigrationFacade.CreateCountryIfNeeded(Country, Country, AddressFormatToSet::"Post Code+City", ContactAddressFormatToSet::"After Company Name");
        end;

        if (SLCustomer.Zip.TrimEnd() <> '') and (SLCustomer.City.TrimEnd() <> '') then
            CustomerDataMigrationFacade.CreatePostCodeIfNeeded(SLCustomer.Zip,
                SLCustomer.City, SLCustomer.State, Country);

        CustomerDataMigrationFacade.SetAddress(CopyStr(SLCustomer.Addr1, 1, MaxStrLen(Address1)),
            CopyStr(SLCustomer.Addr2, 1, MaxStrLen(Address2)), Country, SLCustomer.Zip,
            SLCustomer.City);

        CustomerDataMigrationFacade.SetContact(SLCustomer.Attn);
        CustomerDataMigrationFacade.SetPhoneNo(SLCustomer.Phone);
        CustomerDataMigrationFacade.SetFaxNo(SLCustomer.Fax);

        if SLCompanyAdditionalSettings.GetGLModuleEnabled() then begin
            CustomerDataMigrationFacade.CreatePostingSetupIfNeeded(PostingGroupCodeTxt, 'Migrated from SL', SLARSetup.ArAcct);
            CustomerDataMigrationFacade.SetCustomerPostingGroup(CopyStr(PostingGroupCodeTxt, 1, MaxStrLen(PostingGroupCodeTxt)));
            CustomerDataMigrationFacade.SetGenBusPostingGroup(CopyStr(PostingGroupCodeTxt, 1, MaxStrLen(PostingGroupCodeTxt)));
        end;

        if (SLCustomer.SlsperId.TrimEnd() <> '') then begin
            CustomerDataMigrationFacade.CreateSalespersonPurchaserIfNeeded(SLCustomer.SlsperId, '', '', '');
            CustomerDataMigrationFacade.SetSalesPersonCode(SLCustomer.SlsperId);
        end;

        if (SLCustomer.DfltShipToId.TrimEnd() <> '') then begin
            if SLSOAddress.Get(SLCustomer.CustId, SLCustomer.DfltShipToId) then
                ShipViaID := CopyStr(SLSOAddress.ShipViaID, 1, MaxStrLen(ShipViaID));

            CustomerDataMigrationFacade.CreateShipmentMethodIfNeeded(ShipViaID, '');
            CustomerDataMigrationFacade.SetShipmentMethodCode(ShipViaID);
        end;

        CustomerDataMigrationFacade.SetName2(CopyStr(SLHelperFunctions.NameFlip(SLCustomer.BillName), 1, MaxStrLen(BillName)));

        if (SLCustomer.Territory <> '') then begin
            CustomerDataMigrationFacade.CreateTerritoryCodeIfNeeded(SLCustomer.Territory, '');
            CustomerDataMigrationFacade.SetTerritoryCode(SLCustomer.Territory);
        end;

        CustomerDataMigrationFacade.SetCreditLimitLCY(SLCustomer.CrLmt);

        if (SLCustomer.TaxID00.TrimEnd() <> '') then
            if SLSalesTax.Get(SLTaxTypeGroupTxt, SLCustomer.TaxID00) then begin
                CustomerDataMigrationFacade.CreateTaxAreaIfNeeded(SLSalesTax.TaxId, SLSalesTax.Descr);
                CustomerDataMigrationFacade.SetTaxAreaCode(SLSalesTax.TaxId);
                CustomerDataMigrationFacade.SetTaxLiable(true);
            end;

        CustomerDataMigrationFacade.ModifyCustomer(true);

        MigrateCustomerAddresses(SLCustomer);
    end;

    internal procedure MigrateCustomerAddresses(SLCustomer: Record "SL Customer")
    var
        SLSOAddress: Record "SL SOAddress";
    begin
        SLSOAddress.SetRange(CustId, SLCustomer.CustId);
        if SLSOAddress.FindSet() then
            repeat
                SLSOAddress.MoveStagingData();
            until SLSOAddress.Next() = 0;
    end;

    internal procedure DecrementMigratedCount()
    var
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
    begin
        DataMigrationStatusFacade.IncrementMigratedRecordCount(SLHelperFunctions.GetMigrationTypeTxt(), Database::Customer, -1);
    end;

    internal procedure MigrateCustomer(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        SLCustomer: Record "SL Customer";
        SLARSetup: Record "SL ARSetup";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"SL Customer" then
            exit;

        SLCompanyAdditionalSettings.Get(CompanyName);
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetReceivablesModuleEnabled() then
            exit;

        SLCustomer.Get(RecordIdToMigrate);
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));
        SLARSetup.Get(ARSetupIDTxt);
        MigrateCustomerDetails(SLCustomer, Sender, SLARSetup);
    end;

    internal procedure MigrateCustomerPostingGroups(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLCustClass: Record "SL CustClass";
        SLCustomer: Record "SL Customer";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        ClassID: Text[6];
    begin
        if not ChartOfAccountsMigrated then
            exit;
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetMigrateCustomerClasses() then
            exit;
        if RecordIdToMigrate.TableNo() <> Database::"SL Customer" then
            exit;

        SLCustomer.Get(RecordIdToMigrate);
        if SLcustomer.Status = StatusInactiveTxt then
            if not SLCompanyAdditionalSettings."Migrate Inactive Customers" then
                exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));
        ClassID := SLCustomer.ClassId;
        if ClassID.TrimEnd() = '' then
            exit;
        SLCustClass.Get(ClassID);

        Sender.CreatePostingSetupIfNeeded(SLCustClass.ClassId, SLCustClass.Descr, SLCustClass.ARAcct);
        Sender.SetCustomerPostingGroup(SLCustClass.ClassId);
        Sender.ModifyCustomer(true);
    end;

    internal procedure MigrateCustomerTransactions(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        SLARDoc: Record "SL ARDoc Buffer";
        SLARSetup: Record "SL ARSetup";
        SLCustomer: Record "SL Customer";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        BalancingAccount: Code[20];
        DocTypeToSet: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo";
        GLDocNbr: Text[20];
        ARDocTypeCashSaleTxt: Label 'CS', Locked = true;
        ARDocTypeCreditMemoTxt: Label 'CM', Locked = true;
        ARDocTypeDebitMemoTxt: Label 'DM', Locked = true;
        ARDocTypeFinanceChargeTxt: Label 'FI', Locked = true;
        ARDocTypeInvoiceTxt: Label 'IN', Locked = true;
        ARDocTypeNSFCheckChargeTxt: Label 'NC', Locked = true;
        ARDocTypeNSFReversalTxt: Label 'NS', Locked = true;
        ARDocTypePaymentTxt: Label 'PA', Locked = true;
        ARDocTypePaymentPrepaymentTxt: Label 'PP', Locked = true;
        ARDocTypeSmallBalanceTxt: Label 'SB', Locked = true;
        ARDocTypeSmallCreditTxt: Label 'SC', Locked = true;
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"SL Customer" then
            exit;

        SLCompanyAdditionalSettings.Get(CompanyName);
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetReceivablesModuleEnabled() then
            exit;
        if SLCompanyAdditionalSettings.GetMigrateOnlyReceivablesMaster() then
            exit;
        if not SLCustomer.Get(RecordIdToMigrate) then
            exit;
        if not SLARSetup.Get(ARSetupIDTxt) then
            exit;

        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)), '', '');
        SLARDoc.SetRange(CpnyID, CompanyName);
        SLARDoc.SetRange(CustId, SLCustomer.CustId);
        SLARDoc.SetFilter(DocType, '%1|%2|%3|%4|%5', ARDocTypeInvoiceTxt, ARDocTypeCashSaleTxt, ARDocTypeDebitMemoTxt, ARDocTypeSmallCreditTxt, ARDocTypeNSFCheckChargeTxt);  //Invoices
        SLARDoc.SetFilter(DocBal, '<>%1', 0);
        if SLARDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLARDoc.RecordId));
                GLDocNbr := SLPrefixTxt + SLARDoc.RefNbr;
                BalancingAccount := SLARSetup.ArAcct;

                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)),
                    GLDocNbr,
                    SLARDoc.DocDesc,
                    SLARDoc.DocDate,
                    SLARDoc.DueDate,
                    SLARDoc.DocBal,
                    SLARDoc.DocBal,
                    '',
                    BalancingAccount
                );
                Sender.SetGeneralJournalLineDocumentType(DocTypeToSet::Invoice);
                DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                if (SLARDoc.SlsperId.TrimEnd() <> '') then begin
                    Sender.CreateSalespersonPurchaserIfNeeded(SLARDoc.SlsperId, '', '', '');
                    Sender.SetGeneralJournalLineSalesPersonCode(SLARDoc.SlsperId);
                end;
                if SLARDoc.OrdNbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLARDoc.OrdNbr);

                // Temporary code to set the Due Date on Invoices until the Payment Terms migration is implemented.
                GenJournalLine.SetRange("Journal Batch Name", CustomerBatchNameTxt);
                GenJournalLine.SetRange("Document No.", GLDocNbr);
                if GenJournalLine.FindLast() then begin
                    GenJournalLine."Due Date" := SLARDoc.DueDate;
                    GenJournalLine.Modify();
                end;
            until SLARDoc.Next() = 0;

        SLARDoc.Reset();
        SLARDoc.SetRange(CpnyID, CompanyName);
        SLARDoc.SetRange(CustId, SLCustomer.CustId);
        SLARDoc.SetFilter(DocType, '%1|%2', ARDocTypePaymentTxt, ARDocTypePaymentPrepaymentTxt);  //Payments
        SLARDoc.SetFilter(DocBal, '<>%1', 0);
        if SLARDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLARDoc.RecordId));
                GLDocNbr := SLPrefixTxt + SLARDoc.RefNbr;
                BalancingAccount := SLARSetup.ArAcct;

                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)),
                    GLDocNbr,
                    SLARDoc.DocDesc,
                    SLARDoc.DocDate,
                    SLARDoc.DocDate,
                    (SLARDoc.DocBal * -1),
                    (SLARDoc.DocBal * -1),
                    '',
                    BalancingAccount
                );
                Sender.SetGeneralJournalLineDocumentType(DocTypeToSet::Payment);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                if (SLARDoc.SlsperId.TrimEnd() <> '') then begin
                    Sender.CreateSalespersonPurchaserIfNeeded(SLARDoc.SlsperId, '', '', '');
                    Sender.SetGeneralJournalLineSalesPersonCode(SLARDoc.SlsperId);
                end;
                if SLARDoc.OrdNbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLARDoc.OrdNbr);
            until SLARDoc.Next() = 0;

        SLARDoc.Reset();
        SLARDoc.SetRange(CpnyID, CompanyName);
        SLARDoc.SetRange(CustId, SLCustomer.CustId);
        SLARDoc.SetFilter(DocType, '%1|%2|%3', ARDocTypeCreditMemoTxt, ARDocTypeSmallBalanceTxt, ARDocTypeNSFReversalTxt);  //Credit Memos
        SLARDoc.SetFilter(DocBal, '<>%1', 0);
        if SLARDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLARDoc.RecordId));
                GLDocNbr := SLPrefixTxt + SLARDoc.RefNbr;
                BalancingAccount := SLARSetup.ArAcct;

                if SLARDoc.DocType = ARDocTypeCreditMemoTxt then
                    Sender.CreateGeneralJournalLine(
                        CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)),
                        GLDocNbr,
                        SLARDoc.DocDesc,
                        SLARDoc.DocDate,
                        SLARDoc.DueDate,
                        (SLARDoc.DocBal * -1),
                        (SLARDoc.DocBal * -1),
                        '',
                        BalancingAccount
                    )
                else
                    Sender.CreateGeneralJournalLine(
                        CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)),
                        GLDocNbr,
                        SLARDoc.DocDesc,
                        SLARDoc.DocDate,
                        SLARDoc.DocDate,
                        (SLARDoc.DocBal * -1),
                        (SLARDoc.DocBal * -1),
                        '',
                        BalancingAccount
                    );
                Sender.SetGeneralJournalLineDocumentType(DocTypeToSet::"Credit Memo");
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                if (SLARDoc.SlsperId.TrimEnd() <> '') then begin
                    Sender.CreateSalespersonPurchaserIfNeeded(SLARDoc.SlsperId, '', '', '');
                    Sender.SetGeneralJournalLineSalesPersonCode(SLARDoc.SlsperId);
                end;
                if SLARDoc.OrdNbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLARDoc.OrdNbr);

                // Temporary code to set the Due Date on Credit Memos until the Payment Terms migration is implemented.
                if SLARDoc.DocType = ARDocTypeCreditMemoTxt then begin
                    GenJournalLine.SetRange("Journal Batch Name", CustomerBatchNameTxt);
                    GenJournalLine.SetRange("Document No.", GLDocNbr);
                    if GenJournalLine.FindLast() then begin
                        GenJournalLine."Due Date" := SLARDoc.DueDate;
                        GenJournalLine.Modify();
                    end;
                end;
            until SLARDoc.Next() = 0;

        SLARDoc.Reset();
        SLARDoc.SetRange(CpnyID, CompanyName);
        SLARDoc.SetRange(CustId, SLCustomer.CustId);
        SLARDoc.SetRange(DocType, ARDocTypeFinanceChargeTxt);  // Finance Charge
        SLARDoc.SetFilter(DocBal, '<>%1', 0);
        if SLARDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLARDoc.RecordId));
                GLDocNbr := SLPrefixTxt + SLARDoc.RefNbr;
                BalancingAccount := SLARSetup.ArAcct;

                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)),
                    GLDocNbr,
                    SLARDoc.DocDesc,
                    SLARDoc.DocDate,
                    SLARDoc.DueDate,
                    SLARDoc.DocBal,
                    SLARDoc.DocBal,
                    '',
                    BalancingAccount
                );
                Sender.SetGeneralJournalLineDocumentType(DocTypeToSet::"Finance Charge Memo");
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                if (SLARDoc.SlsperId.TrimEnd() <> '') then begin
                    Sender.CreateSalespersonPurchaserIfNeeded(SLARDoc.SlsperId, '', '', '');
                    Sender.SetGeneralJournalLineSalesPersonCode(SLARDoc.SlsperId);
                end;
                if SLARDoc.OrdNbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLARDoc.OrdNbr);

                // Temporary code to set the Due Date on Finance Charge Memos until the Payment Terms migration is implemented.
                GenJournalLine.SetRange("Journal Batch Name", CustomerBatchNameTxt);
                GenJournalLine.SetRange("Document No.", GLDocNbr);
                if GenJournalLine.FindLast() then begin
                    GenJournalLine."Due Date" := SLARDoc.DueDate;
                    GenJournalLine.Modify();
                end;
            until SLARDoc.Next() = 0;
    end;
}