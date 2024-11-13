// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.Foundation.Company;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Vendor;
using System.EMail;

codeunit 47021 "SL Vendor Migrator"
{
    Access = Internal;

    var
        PostingGroupCodeTxt: Label 'SL', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        VendorBatchNameTxt: Label 'SLVEND', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", OnMigrateVendor, '', true, true)]
    local procedure OnMigrateVendor(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        SLVendor: Record "SL Vendor";
        SLAPSetup: Record "SL APSetup";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"SL Vendor" then
            exit;

        SLCompanyAdditionalSettings.Get(CompanyName);
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            exit;

        SLVendor.Get(RecordIdToMigrate);
        SLAPSetup.Get('AP');
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));

        MigrateVendorDetails(SLVendor, Sender, SLAPSetup);
        MigrateVendorAddresses(SLVendor);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", OnMigrateVendorTransactions, '', true, true)]
    local procedure OnMigrateVendorTransactions(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        SLAPDoc: Record "SL APDoc";
        SLAPSetup: Record "SL APSetup";
        SLVendor: Record "SL Vendor";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PaymentTermsFormula: DateFormula;
        BalancingAccount: Code[20];
        DocTypeToSet: Option " ",Payment,Invoice,"Credit Memo";
        GLDocNbr: Text[20];
    begin
        if not ChartOfAccountsMigrated then
            exit;
        if RecordIdToMigrate.TableNo() <> Database::"SL Vendor" then
            exit;
        SLCompanyAdditionalSettings.Get(CompanyName);
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            exit;
        if SLCompanyAdditionalSettings.GetMigrateOnlyPayablesMaster() then
            exit;

        SLVendor.Get(RecordIdToMigrate);
        SLAPSetup.Get('AP');

        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(VendorBatchNameTxt, 1, 7), '', '');
        SLAPDoc.SetRange(CpnyID, CompanyName);
        SLAPDoc.SetRange(VendId, SLVendor.VendId);
        SLAPDoc.SetRange(DocType, 'PP');  // Payment
        SLAPDoc.SetFilter(DocBal, '<>%1', 0);
        if SLAPDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLAPDoc.RecordID));

                GLDocNbr := 'SL' + SLAPDoc.RefNbr;
                BalancingAccount := SLAPSetup.APAcct;

                Sender.CreateGeneralJournalLine(
                            CopyStr(VendorBatchNameTxt, 1, 7),
                            GLDocNbr,
                            SLAPDoc.DocDesc,
                            DT2Date(SLAPDoc.DocDate),
                            0D,
                            SLAPDoc.DocBal,
                            SLAPDoc.DocBal,
                            '',
                            BalancingAccount
                        );

                Sender.SetGeneralJournalLineDocumentType(DocTypeToSet::Payment);
                DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if SLAPDoc.PONbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo('PO-' + SLAPDoc.PONbr)
                else
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLAPDoc.CpnyID + SLAPDoc.RefNbr);
            until SLAPDoc.Next() = 0;

        SLAPDoc.Reset();
        SLAPDoc.SetRange(CpnyID, CompanyName);
        SLAPDoc.SetRange(VendId, SLVendor.VendId);
        SLAPDoc.SetFilter(DocType, '%1|%2', 'VO', 'AC');  // Invoice
        SLAPDoc.SetFilter(DocBal, '<>%1', 0);
        if SLAPDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLAPDoc.RecordID));

                GLDocNbr := 'SL' + SLAPDoc.RefNbr;
                BalancingAccount := SLAPSetup.APAcct;

                Sender.CreateGeneralJournalLine(
                            CopyStr(VendorBatchNameTxt, 1, 7),
                            GLDocNbr,
                            SLAPDoc.DocDesc,
                            DT2Date(SLAPDoc.DocDate),
                            DT2Date(SLAPDoc.DueDate),
                            SLAPDoc.DocBal * -1,
                            SLAPDoc.DocBal * -1,
                            '',
                            BalancingAccount
                        );

                Sender.SetGeneralJournalLineDocumentType(DocTypeToSet::Invoice);
                DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if SLAPDoc.PONbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo('PO-' + SLAPDoc.PONbr)
                else
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLAPDoc.CpnyID + SLAPDoc.RefNbr);

                if (SLAPDoc.Terms.TrimEnd() <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(SLAPDoc.Terms, SLAPDoc.Terms, PaymentTermsFormula);
                    Sender.SetGeneralJournalLinePaymentTerms(SLAPDoc.Terms);
                end;
            until SLAPDoc.Next() = 0;

        SLAPDoc.Reset();
        SLAPDoc.SetRange(CpnyID, CompanyName);
        SLAPDoc.SetRange(VendId, SLVendor.VendId);
        SLAPDoc.SetFilter(DocType, 'AD');  // Credit Memo
        SLAPDoc.SetFilter(DocBal, '<>%1', 0);
        if SLAPDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLAPDoc.RecordID));

                GLDocNbr := 'SL' + SLAPDoc.RefNbr;
                BalancingAccount := SLAPSetup.APAcct;

                Sender.CreateGeneralJournalLine(
                            CopyStr(VendorBatchNameTxt, 1, 7),
                            GLDocNbr,
                            SLAPDoc.DocDesc,
                            DT2Date(SLAPDoc.DocDate),
                            DT2Date(SLAPDoc.DueDate),
                            SLAPDoc.DocBal,
                            SLAPDoc.DocBal,
                            '',
                            BalancingAccount
                        );

                Sender.SetGeneralJournalLineDocumentType(DocTypeToSet::"Credit Memo");
                DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if SLAPDoc.PONbr.TrimEnd() <> '' then
                    Sender.SetGeneralJournalLineExternalDocumentNo('PO-' + SLAPDoc.PONbr)
                else
                    Sender.SetGeneralJournalLineExternalDocumentNo(SLAPDoc.CpnyID + SLAPDoc.RefNbr);

                if (SLAPDoc.Terms.TrimEnd() <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(SLAPDoc.Terms, SLAPDoc.Terms, PaymentTermsFormula);
                    Sender.SetGeneralJournalLinePaymentTerms(SLAPDoc.Terms);
                end;
            until SLAPDoc.Next() = 0;
    end;

    internal procedure MigrateVendorDetails(SLVendor: Record "SL Vendor"; VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade"; SLAPSetup: Record "SL APSetup")
    var
        CompanyInformation: Record "Company Information";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        PaymentTermsFormula: DateFormula;
        Country: Code[10];
        ContactAddressFormatToSet: Option First,"After Company Name",Last;
        AddressFormatToSet: Option "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
        VendorName: Text[50];
        VendorName2: Text[50];
        Address1: Text[50];
    begin
        if not VendorDataMigrationFacade.CreateVendorIfNeeded(SLVendor.VendId, CopyStr(SLHelperFunctions.NameFlip(SLVendor.Name), 1, MaxStrLen(VendorName))) then
            exit;

        if SLVendor.Status = 'I' then
            if SLCompanyAdditionalSettings.Get(CompanyName()) then
                if not SLCompanyAdditionalSettings."Migrate Inactive Vendors" then begin
                    DecrementMigratedCount();
                    exit;
                end;

        if (SLVendor.Country.TrimEnd() <> '') then begin
            Country := SLVendor.Country;
            VendorDataMigrationFacade.CreateCountryIfNeeded(Country, Country, AddressFormatToSet::"Post Code+City", ContactAddressFormatToSet::"After Company Name");
        end else begin
            CompanyInformation.Get();
            Country := CompanyInformation."Country/Region Code";
        end;

        if (SLVendor.Zip.TrimEnd() <> '') and (SLVendor.City.TrimEnd() <> '') then
            VendorDataMigrationFacade.CreatePostCodeIfNeeded(SLVendor.Zip, SLVendor.City, SLVendor.State, Country);

        VendorDataMigrationFacade.SetAddress(CopyStr(SLVendor.Addr1, 1, MaxStrLen(Address1)), CopyStr(SLVendor.Addr2, 1, 50), SLVendor.Country, SLVendor.Zip, SLVendor.City);

        VendorDataMigrationFacade.SetContact(SLVendor.Attn);
        VendorDataMigrationFacade.SetPhoneNo(SLVendor.Phone);
        VendorDataMigrationFacade.SetFaxNo(SLVendor.Fax);

        if SLCompanyAdditionalSettings.GetGLModuleEnabled() then begin
            VendorDataMigrationFacade.CreatePostingSetupIfNeeded(PostingGroupCodeTxt, 'Migrated from SL', SLAPSetup.APAcct);
            VendorDataMigrationFacade.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, MaxStrLen(VendorPostingGroup.Code)));
            VendorDataMigrationFacade.SetGenBusPostingGroup(CopyStr(PostingGroupCodeTxt, 1, MaxStrLen(GenBusinessPostingGroup.Code)));
        end;

        if (SLVendor.Terms <> '') then begin
            Evaluate(PaymentTermsFormula, '');
            VendorDataMigrationFacade.CreatePaymentTermsIfNeeded(SLVendor.Terms, SLVendor.Terms, PaymentTermsFormula);
            VendorDataMigrationFacade.SetPaymentTermsCode(SLVendor.Terms);
        end;

        if (SLVendor.RemitName.TrimEnd() <> '') then begin
            VendorName2 := CopyStr(SLHelperFunctions.NameFlip(SLVendor.RemitName.TrimEnd()), 1, MaxStrLen(VendorName2));
            VendorDataMigrationFacade.SetName2(VendorName2);
        end;

        VendorDataMigrationFacade.ModifyVendor(true);
    end;

    internal procedure MigrateVendorAddresses(SLVendor: Record "SL Vendor")
    var
        SLPOAddress: Record "SL POAddress";
        Vendor: Record Vendor;
    begin
        if not Vendor.Get(SLVendor.VendId) then
            exit;

        SLPOAddress.SetRange(VendId, Vendor."No.");
        if SLPOAddress.FindSet() then
            repeat
                CreateOrUpdateOrderAddress(Vendor, SLPOAddress, SLPOAddress.OrdFromId);
            until SLPOAddress.Next() = 0;
    end;

    internal procedure CreateOrUpdateOrderAddress(Vendor: Record Vendor; SLPOAddress: Record "SL POAddress"; OrderAddressCode: Code[10])
    var
        OrderAddress: Record "Order Address";
        MailManagement: Codeunit "Mail Management";
    begin
        if not OrderAddress.Get(Vendor."No.", OrderAddressCode) then begin
            OrderAddress."Vendor No." := Vendor."No.";
            OrderAddress.Code := OrderAddressCode;
            OrderAddress.Insert();
        end;

        OrderAddress.Name := Vendor.Name;
        OrderAddress.Address := SLPOAddress.Addr1;
        OrderAddress."Address 2" := CopyStr(SLPOAddress.Addr2, 1, MaxStrLen(OrderAddress."Address 2"));
        OrderAddress.City := SLPOAddress.City;
        OrderAddress.Contact := SLPOAddress.Attn;
        OrderAddress."Phone No." := SLPOAddress.Phone;
        OrderAddress."Fax No." := SLPOAddress.Fax;
        OrderAddress."Post Code" := SLPOAddress.Zip;
        OrderAddress.County := SLPOAddress.State;

#pragma warning disable AA0139
        if MailManagement.ValidateEmailAddressField(SLPOAddress.EMailAddr) then
            OrderAddress."E-Mail" := SLPOAddress.EMailAddr;
#pragma warning restore AA0139

        OrderAddress.Modify();
    end;

    internal procedure DecrementMigratedCount()
    var
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
    begin
        DataMigrationStatusFacade.IncrementMigratedRecordCount(SLHelperFunctions.GetMigrationTypeTxt(), Database::Vendor, -1);
    end;
}