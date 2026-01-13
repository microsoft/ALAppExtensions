// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Vendor;
using System.EMail;

codeunit 47021 "SL Vendor Migrator"
{
    Access = Internal;

    var
        APSetupIDTxt: Label 'AP', Locked = true;
        PostingGroupCodeTxt: Label 'SL', Locked = true;
        SLPrefixTxt: Label 'SL', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        StatusInactiveTxt: Label 'I', Locked = true;
        VendorBatchNameTxt: Label 'SLVEND', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", OnMigrateVendor, '', true, true)]
    local procedure OnMigrateVendor(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId)
    begin
        MigrateVendor(Sender, RecordIdToMigrate);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", OnMigrateVendorPostingGroups, '', true, true)]
    local procedure OnMigrateVendorPostingGroups(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    begin
        MigrateVendorPostingGroups(Sender, RecordIdToMigrate, ChartOfAccountsMigrated);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", OnMigrateVendorTransactions, '', true, true)]
    local procedure OnMigrateVendorTransactions(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    begin
        MigrateVendorTransactions(Sender, RecordIdToMigrate, ChartOfAccountsMigrated);
    end;

    internal procedure MigrateVendor(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId)
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

        Clear(SLVendor);
        SLVendor.Get(RecordIdToMigrate);
        SLAPSetup.Get(APSetupIDTxt);
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));

        MigrateVendorDetails(SLVendor, Sender, SLAPSetup);
        MigrateVendorAddresses(SLVendor);
    end;

    internal procedure MigrateVendorDetails(SLVendor: Record "SL Vendor"; VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade"; SLAPSetup: Record "SL APSetup")
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLSalesTax: Record "SL SalesTax";
        VendorPostingGroup: Record "Vendor Posting Group";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        Country: Code[10];
        ContactAddressFormatToSet: Option First,"After Company Name",Last;
        AddressFormatToSet: Option "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
        VendorName: Text[50];
        VendorName2: Text[50];
        Address1: Text[50];
        Address2: Text[50];
        VendorBlocked: Boolean;
        SLTaxTypeGroupTxt: Label 'G', Locked = true;
    begin
        if SLVendor.Status = StatusInactiveTxt then
            if SLCompanyAdditionalSettings.Get(CompanyName()) then
                if not SLCompanyAdditionalSettings."Migrate Inactive Vendors" then begin
                    DecrementMigratedCount();
                    exit;
                end else
                    VendorBlocked := true;

        if not VendorDataMigrationFacade.CreateVendorIfNeeded(SLVendor.VendId, CopyStr(SLHelperFunctions.NameFlip(SLVendor.Name), 1, MaxStrLen(VendorName))) then
            exit;

        if VendorBlocked then
            VendorDataMigrationFacade.SetBlocked("Vendor Blocked"::All);

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLVendor.RecordID));

        if (SLVendor.Country.TrimEnd() <> '') then begin
            Country := CopyStr(SLVendor.Country.TrimEnd(), 1, MaxStrLen(Country));
            VendorDataMigrationFacade.CreateCountryIfNeeded(Country, Country, AddressFormatToSet::"Post Code+City", ContactAddressFormatToSet::"After Company Name");
        end;

        if (SLVendor.Zip.TrimEnd() <> '') and (SLVendor.City.TrimEnd() <> '') then
            VendorDataMigrationFacade.CreatePostCodeIfNeeded(SLVendor.Zip, SLVendor.City, SLVendor.State, Country);

        Address1 := CopyStr(SLVendor.Addr1, 1, MaxStrLen(Address1));
        Address2 := CopyStr(SLVendor.Addr2, 1, MaxStrLen(Address2));
#pragma warning disable AA0139
        VendorDataMigrationFacade.SetAddress(Address1.TrimEnd(), Address2.TrimEnd(), SLVendor.Country.TrimEnd(), SLVendor.Zip.TrimEnd(), SLVendor.City.TrimEnd());
        VendorDataMigrationFacade.SetContact(SLVendor.Attn.TrimEnd());
        VendorDataMigrationFacade.SetPhoneNo(SLVendor.Phone.TrimEnd());
        VendorDataMigrationFacade.SetFaxNo(SLVendor.Fax.TrimEnd());
        VendorDataMigrationFacade.SetEmail(SLVendor.EMailAddr.TrimEnd());
        VendorDataMigrationFacade.SetVATRegistrationNo(SLVendor.TaxRegNbr.TrimEnd());
#pragma warning restore AA0139
        VendorDataMigrationFacade.CreatePostingSetupIfNeeded(PostingGroupCodeTxt, 'Migrated from SL', SLAPSetup.APAcct);
        VendorDataMigrationFacade.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, MaxStrLen(VendorPostingGroup.Code)));
        VendorDataMigrationFacade.SetGenBusPostingGroup(CopyStr(PostingGroupCodeTxt, 1, MaxStrLen(GenBusinessPostingGroup.Code)));

        if (SLVendor.RemitName.TrimEnd() <> '') then begin
            VendorName2 := CopyStr(SLHelperFunctions.NameFlip(SLVendor.RemitName.TrimEnd()), 1, MaxStrLen(VendorName2));
            VendorDataMigrationFacade.SetName2(VendorName2);
        end;

        if (SLVendor.TaxId00.TrimEnd() <> '') then
            if SLSalesTax.Get(SLTaxTypeGroupTxt, SLVendor.TaxId00) then begin
                VendorDataMigrationFacade.CreateTaxAreaIfNeeded(SLSalesTax.TaxId, SLSalesTax.Descr);
                VendorDataMigrationFacade.SetTaxAreaCode(SLSalesTax.TaxId);
                VendorDataMigrationFacade.SetTaxLiable(true);
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

    internal procedure MigrateVendorTransactions(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        SLAPDoc: Record "SL APDoc Buffer";
        SLAPSetup: Record "SL APSetup";
        SLVendor: Record "SL Vendor";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        GenJournalLine: Record "Gen. Journal Line";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        BalancingAccount: Code[20];
        DocTypeToSet: Option " ",Payment,Invoice,"Credit Memo";
        GLDocNbr: Text[20];
        LineDescription: Text[50];
        APDocTypeAdjustmentCreditTxt: Label 'AC', Locked = true;
        APDocTypeAdjustmentDebitTxt: Label 'AD', Locked = true;
        APDocTypePrePaymentTxt: Label 'PP', Locked = true;
        APDocTypeVoucherTxt: Label 'VO', Locked = true;
        JournalLinePOPrefixTxt: Label 'PO:', Locked = true;
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
        if not SLVendor.Get(RecordIdToMigrate) then
            exit;
        if not SLAPSetup.Get(APSetupIDTxt) then
            exit;

        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(VendorBatchNameTxt, 1, MaxStrLen(VendorBatchNameTxt)), '', '');
        SLAPDoc.SetRange(CpnyID, CompanyName);
        SLAPDoc.SetRange(VendId, SLVendor.VendId);
        SLAPDoc.SetRange(DocType, APDocTypePrePaymentTxt);  // Payment
        SLAPDoc.SetFilter(DocBal, '<>%1', 0);
        if SLAPDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLAPDoc.RecordID));
                GLDocNbr := SLPrefixTxt + SLAPDoc.RefNbr;
                BalancingAccount := SLAPSetup.APAcct;
                if SLAPDoc.PONbr.TrimEnd() <> '' then
                    if SLAPDoc.PONbr.TrimEnd() <> '*' then
                        LineDescription := JournalLinePOPrefixTxt + SLAPDoc.PONbr.TrimEnd() + '-' + SLAPDoc.DocDesc.TrimEnd()
                    else
                        LineDescription := CopyStr(SLAPDoc.DocDesc.TrimEnd(), 1, MaxStrLen(SLAPDoc.DocDesc));

                Sender.CreateGeneralJournalLine(
                            CopyStr(VendorBatchNameTxt, 1, MaxStrLen(VendorBatchNameTxt)),
                            GLDocNbr,
                            LineDescription,
                            SLAPDoc.DocDate,
                            SLAPDoc.DocDate,
                            SLAPDoc.DocBal,
                            SLAPDoc.DocBal,
                            '',
                            BalancingAccount
                        );
                Sender.SetGeneralJournalLineDocumentType(DocTypeToSet::Payment);
                DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                Sender.SetGeneralJournalLineExternalDocumentNo(SLAPDoc.RefNbr.TrimEnd() + '-' + SLAPDoc.InvcNbr.TrimEnd());
            until SLAPDoc.Next() = 0;

        SLAPDoc.Reset();
        SLAPDoc.SetRange(CpnyID, CompanyName);
        SLAPDoc.SetRange(VendId, SLVendor.VendId);
        SLAPDoc.SetFilter(DocType, '%1|%2', APDocTypeVoucherTxt, APDocTypeAdjustmentCreditTxt);  // Invoice
        SLAPDoc.SetFilter(DocBal, '<>%1', 0);
        if SLAPDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLAPDoc.RecordID));
                GLDocNbr := SLPrefixTxt + SLAPDoc.RefNbr;
                BalancingAccount := SLAPSetup.APAcct;
                if SLAPDoc.PONbr.TrimEnd() <> '' then
                    if SLAPDoc.PONbr.TrimEnd() <> '*' then
                        LineDescription := JournalLinePOPrefixTxt + SLAPDoc.PONbr.TrimEnd() + '-' + SLAPDoc.DocDesc.TrimEnd()
                    else
                        LineDescription := CopyStr(SLAPDoc.DocDesc.TrimEnd(), 1, MaxStrLen(SLAPDoc.DocDesc));

                Sender.CreateGeneralJournalLine(
                            CopyStr(VendorBatchNameTxt, 1, MaxStrLen(VendorBatchNameTxt)),
                            GLDocNbr,
                            LineDescription,
                            SLAPDoc.DocDate,
                            SLAPDoc.DueDate,
                            SLAPDoc.DocBal * -1,
                            SLAPDoc.DocBal * -1,
                            '',
                            BalancingAccount
                        );
                Sender.SetGeneralJournalLineDocumentType(DocTypeToSet::Invoice);
                DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                Sender.SetGeneralJournalLineExternalDocumentNo(SLAPDoc.RefNbr.TrimEnd() + '-' + SLAPDoc.InvcNbr.TrimEnd());

                // Temporary code to set the Due Date on Invoices until the Payment Terms migration is implemented.
                GenJournalLine.SetRange("Journal Batch Name", VendorBatchNameTxt);
                GenJournalLine.SetRange("Document No.", GLDocNbr);
                if GenJournalLine.FindLast() then begin
                    GenJournalLine."Due Date" := SLAPDoc.DueDate;
                    GenJournalLine.Modify();
                end;
            until SLAPDoc.Next() = 0;

        SLAPDoc.Reset();
        SLAPDoc.SetRange(CpnyID, CompanyName);
        SLAPDoc.SetRange(VendId, SLVendor.VendId);
        SLAPDoc.SetFilter(DocType, APDocTypeAdjustmentDebitTxt);  // Credit Memo
        SLAPDoc.SetFilter(DocBal, '<>%1', 0);
        if SLAPDoc.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLAPDoc.RecordID));
                GLDocNbr := SLPrefixTxt + SLAPDoc.RefNbr;
                BalancingAccount := SLAPSetup.APAcct;
                if SLAPDoc.PONbr.TrimEnd() <> '' then
                    if SLAPDoc.PONbr.TrimEnd() <> '*' then
                        LineDescription := JournalLinePOPrefixTxt + SLAPDoc.PONbr.TrimEnd() + '-' + SLAPDoc.DocDesc.TrimEnd()
                    else
                        LineDescription := CopyStr(SLAPDoc.DocDesc.TrimEnd(), 1, MaxStrLen(SLAPDoc.DocDesc));

                Sender.CreateGeneralJournalLine(
                            CopyStr(VendorBatchNameTxt, 1, MaxStrLen(VendorBatchNameTxt)),
                            GLDocNbr,
                            LineDescription,
                            SLAPDoc.DocDate,
                            SLAPDoc.DueDate,
                            SLAPDoc.DocBal,
                            SLAPDoc.DocBal,
                            '',
                            BalancingAccount
                        );

                Sender.SetGeneralJournalLineDocumentType(DocTypeToSet::"Credit Memo");
                DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, MaxStrLen(SourceCodeTxt)));
                Sender.SetGeneralJournalLineExternalDocumentNo(SLAPDoc.RefNbr.TrimEnd() + '-' + SLAPDoc.InvcNbr.TrimEnd());

                // Temporary code to set the Due Date on Credit Memos until the Payment Terms migration is implemented.
                GenJournalLine.SetRange("Journal Batch Name", VendorBatchNameTxt);
                GenJournalLine.SetRange("Document No.", GLDocNbr);
                if GenJournalLine.FindLast() then begin
                    GenJournalLine."Due Date" := SLAPDoc.DueDate;
                    GenJournalLine.Modify();
                end;
            until SLAPDoc.Next() = 0;
    end;

    internal procedure CreateOrUpdateOrderAddress(Vendor: Record Vendor; SLPOAddress: Record "SL POAddress"; OrderAddressCode: Code[10])
    var
        OrderAddress: Record "Order Address";
        MailManagement: Codeunit "Mail Management";
        EmailAddr: Text;
    begin
        if not OrderAddress.Get(Vendor."No.", OrderAddressCode) then begin
            Clear(OrderAddress);
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
        EmailAddr := SLPOAddress.EMailAddr;
        if MailManagement.ValidateEmailAddressField(EmailAddr) then
            OrderAddress."E-Mail" := SLPOAddress.EMailAddr;
        OrderAddress.Modify();
    end;

    internal procedure DecrementMigratedCount()
    var
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
    begin
        DataMigrationStatusFacade.IncrementMigratedRecordCount(SLHelperFunctions.GetMigrationTypeTxt(), Database::Vendor, -1);
    end;

    internal procedure MigrateVendorPostingGroups(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLVendClass: Record "SL VendClass";
        SLVendor: Record "SL Vendor";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        ClassID: Text[10];
    begin
        if not ChartOfAccountsMigrated then
            exit;
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetMigrateVendorClasses() then
            exit;
        if RecordIdToMigrate.TableNo() <> Database::"SL Vendor" then
            exit;

        SLVendor.Get(RecordIdToMigrate);
        if SLVendor.Status = StatusInactiveTxt then
            if not SLCompanyAdditionalSettings."Migrate Inactive Vendors" then
                exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));
        ClassID := SLVendor.ClassID;
        if ClassID.TrimEnd() = '' then
            exit;
        SLVendClass.Get(ClassID);

        Sender.CreatePostingSetupIfNeeded(SLVendClass.ClassID, SLVendClass.Descr, SLVendClass.APAcct);
        Sender.SetVendorPostingGroup(SLVendClass.ClassID);
        Sender.ModifyVendor(true);
    end;
}