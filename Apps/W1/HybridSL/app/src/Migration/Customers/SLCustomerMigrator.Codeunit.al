// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;

codeunit 47018 "SL Customer Migrator"
{
    Access = Internal;

    var
        PostingGroupCodeTxt: Label 'SL', Locked = true;
        CustomerBatchNameTxt: Label 'SLCUST', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        StatusInactiveTxt: Label 'I', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", OnMigrateCustomer, '', true, true)]
    local procedure OnMigrateCustomer(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId)
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
        SLARSetup.Get('AR');
        MigrateCustomerDetails(SLCustomer, Sender, SLARSetup);
        MigrateCustomerAddresses(SLCustomer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", OnMigrateCustomerTransactions, '', true, true)]
    local procedure OnMigrateCustomerTransactions(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        SLARDoc: Record "SL ARDoc";
        SLARSetup: Record "SL ARSetup";
        SLCustomer: Record "SL Customer";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PaymentTermsFormula: DateFormula;
        BalancingAccount: Code[20];
        DocTypeToSet: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo";
        GLDocNbr: Text[20];
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

        SLCustomer.Get(RecordIdToMigrate);
        SLARSetup.Get('AR');

        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)), '', '');
        SLARDoc.SetRange(CpnyID, CompanyName);
        SLARDoc.SetRange(CustId, SLCustomer.CustId);
        SLARDoc.SetFilter(DocType, '%1|%2|%3|%4|%5', 'IN', 'CS', 'DM', 'SC', 'NC');  //Invoice
        SLARDoc.SetFilter(DocBal, '<>%1', 0);
        if SLARDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLARDoc.RecordId));

                GLDocNbr := 'SL' + SLARDoc.RefNbr;
                BalancingAccount := SLARSetup.ArAcct;

                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)),
                    GLDocNbr,
                    SLARDoc.DocDesc,
                    DT2Date(SLARDoc.DocDate),
                    0D,
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
                if (SLARDoc.Terms.TrimEnd() <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(SLARDoc.Terms, SLARDoc.Terms, PaymentTermsFormula);
                    Sender.SetGeneralJournalLinePaymentTerms(SLARDoc.Terms);
                end;
                if SLARDoc.OrdNbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLARDoc.OrdNbr);
            until SLARDoc.Next() = 0;

        SLARDoc.Reset();
        SLARDoc.SetRange(CpnyID, CompanyName);
        SLARDoc.SetRange(CustId, SLCustomer.CustId);
        SLARDoc.SetFilter(DocType, '%1|%2', 'PA', 'PP');  //Payment
        SLARDoc.SetFilter(DocBal, '<>%1', 0);
        if SLARDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLARDoc.RecordId));

                GLDocNbr := 'SL' + SLARDoc.RefNbr;
                BalancingAccount := SLARSetup.ArAcct;

                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)),
                    GLDocNbr,
                    SLARDoc.DocDesc,
                    DT2Date(SLARDoc.DocDate),
                    DT2Date(SLARDoc.DocDate),
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
                if (SLARDoc.Terms.TrimEnd() <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(SLARDoc.Terms, SLARDoc.Terms, PaymentTermsFormula);
                    Sender.SetGeneralJournalLinePaymentTerms(SLARDoc.Terms);
                end;
                if SLARDoc.OrdNbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLARDoc.OrdNbr);
            until SLARDoc.Next() = 0;

        SLARDoc.Reset();
        SLARDoc.SetRange(CpnyID, CompanyName);
        SLARDoc.SetRange(CustId, SLCustomer.CustId);
        SLARDoc.SetFilter(DocType, '%1|%2|%3', 'CM', 'SB', 'NS');  //Credit Memo
        SLARDoc.SetFilter(DocBal, '<>%1', 0);
        if SLARDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLARDoc.RecordId));

                GLDocNbr := 'SL' + SLARDoc.RefNbr;
                BalancingAccount := SLARSetup.ArAcct;

                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)),
                    GLDocNbr,
                    SLARDoc.DocDesc,
                    DT2Date(SLARDoc.DocDate),
                    DT2Date(SLARDoc.DueDate),
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
                if (SLARDoc.Terms.TrimEnd() <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(SLARDoc.Terms, SLARDoc.Terms, PaymentTermsFormula);
                    Sender.SetGeneralJournalLinePaymentTerms(SLARDoc.Terms);
                end;
                if SLARDoc.OrdNbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLARDoc.OrdNbr);
            until SLARDoc.Next() = 0;

        SLARDoc.Reset();
        SLARDoc.SetRange(CpnyID, CompanyName);
        SLARDoc.SetRange(CustId, SLCustomer.CustId);
        SLARDoc.SetRange(DocType, 'FI');  // Finance Charge
        SLARDoc.SetFilter(DocBal, '<>%1', 0);
        if SLARDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLARDoc.RecordId));

                GLDocNbr := 'SL' + SLARDoc.RefNbr;
                BalancingAccount := SLARSetup.ArAcct;

                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, MaxStrLen(CustomerBatchNameTxt)),
                    GLDocNbr,
                    SLARDoc.DocDesc,
                    DT2Date(SLARDoc.DocDate),
                    DT2Date(SLARDoc.DocDate),
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
                if (SLARDoc.Terms.TrimEnd() <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(SLARDoc.Terms, SLARDoc.Terms, PaymentTermsFormula);
                    Sender.SetGeneralJournalLinePaymentTerms(SLARDoc.Terms);
                end;
                if SLARDoc.OrdNbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLARDoc.OrdNbr);
            until SLARDoc.Next() = 0;
    end;

    internal procedure MigrateCustomerDetails(SLCustomer: Record "SL Customer"; CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade"; SLARSetup: Record "SL ARSetup")
    var
        CompanyInformation: Record "Company Information";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLSOAddress: Record "SL SOAddress";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PaymentTermsFormula: DateFormula;
        Country: Code[10];
        ShipViaID: Code[10];
        ContactAddressFormatToSet: Option First,"After Company Name",Last;
        AddressFormatToSet: Option "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
    begin
        if not CustomerDataMigrationFacade.CreateCustomerIfNeeded(SLCustomer.CustId, CopyStr(SLHelperFunctions.NameFlip(SLCustomer.Name), 1, 50)) then
            exit;

        if SLCustomer.Status = StatusInactiveTxt then
            if SLCompanyAdditionalSettings.Get(CompanyName()) then
                if not SLCompanyAdditionalSettings."Migrate Inactive Customers" then begin
                    DecrementMigratedCount();
                    exit;
                end;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLCustomer.RecordId));

        if (SLCustomer.Country <> '') then begin
            Country := SLCustomer.Country;
            CustomerDataMigrationFacade.CreateCountryIfNeeded(Country, Country, AddressFormatToSet::"Post Code+City", ContactAddressFormatToSet::"After Company Name");
        end else begin
            CompanyInformation.Get();
            Country := CompanyInformation."Country/Region Code";
        end;

        if (SLCustomer.Zip.TrimEnd() <> '') and (SLCustomer.City.TrimEnd() <> '') then
            CustomerDataMigrationFacade.CreatePostCodeIfNeeded(SLCustomer.Zip,
                SLCustomer.City, SLCustomer.State, Country);

        CustomerDataMigrationFacade.SetAddress(CopyStr(SLCustomer.Addr1, 1, 50),
            CopyStr(SLCustomer.Addr2, 1, 50), Country, SLCustomer.Zip,
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

        if (SLCustomer.Terms <> '') then begin
            Evaluate(PaymentTermsFormula, '');
            CustomerDataMigrationFacade.CreatePaymentTermsIfNeeded(SLCustomer.Terms, SLCustomer.Terms, PaymentTermsFormula);
            CustomerDataMigrationFacade.SetPaymentTermsCode(SLCustomer.Terms);
        end;

        CustomerDataMigrationFacade.SetName2(CopyStr(SLHelperFunctions.NameFlip(SLCustomer.BillName), 1, 50));

        if (SLCustomer.Territory <> '') then begin
            CustomerDataMigrationFacade.CreateTerritoryCodeIfNeeded(SLCustomer.Territory, '');
            CustomerDataMigrationFacade.SetTerritoryCode(SLCustomer.Territory);
        end;

        CustomerDataMigrationFacade.SetCreditLimitLCY(SLCustomer.CrLmt);

        CustomerDataMigrationFacade.ModifyCustomer(true);
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
}