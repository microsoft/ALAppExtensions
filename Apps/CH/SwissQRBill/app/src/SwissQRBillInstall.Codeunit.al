﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.EServices.EDocument;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using System.Environment;
using System.Privacy;
using System.Upgrade;

codeunit 11517 "Swiss QR-Bill Install"
{
    Subtype = Install;

    var
        DefaultIBANLbl: Label 'DEFAULT IBAN';
        DefaultQRIBANLbl: Label 'DEFAULT QR-IBAN';

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then
            MoveOldTables();

        OnCompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    var
        NewDefaultBillInfoFormatCode: Code[20];
        NewDefaultLayoutCode: Code[20];
    begin
        NewDefaultBillInfoFormatCode := InitQRBillingInfoFormat();
        NewDefaultLayoutCode := InitQRBillLayouts(NewDefaultBillInfoFormatCode);
        InitQRBillSetup(NewDefaultLayoutCode);
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure InitializeDone(): boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure InitQRBillSetup(NewDefaultLayoutCode: Code[20])
    var
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
    begin
        with SwissQRBillSetup do
            if IsEmpty() then begin
                "Address Type" := "Address Type"::Structured;
                if NewDefaultLayoutCode <> '' then
                    "Default Layout" := NewDefaultLayoutCode;
                InitDefaultJournalSetup();

                Insert();
            end;
    end;

    local procedure InitQRBillLayouts(NewDefaultBillInfoFormatCode: Code[20]): Code[20]
    var
        SwissQRBillLayout: Record "Swiss QR-Bill Layout";
    begin
        with SwissQRBillLayout do
            if IsEmpty() then begin
                InitQRBillLayout(
                    COPYSTR(DefaultIBANLbl, 1, 20),
                    "IBAN Type"::IBAN, "Payment Reference Type"::"Creditor Reference (ISO 11649)", NewDefaultBillInfoFormatCode);
                InitQRBillLayout(
                    COPYSTR(DefaultQRIBANLbl, 1, 20),
                    "IBAN Type"::"QR-IBAN", "Payment Reference Type"::"QR Reference", NewDefaultBillInfoFormatCode);
                exit(COPYSTR(DefaultQRIBANLbl, 1, 20));
            end;
    end;

    local procedure InitQRBillLayout(LayoutCode: Code[20]; IBANType: Enum "Swiss QR-Bill IBAN Type"; PaymentReferenceType: Enum "Swiss QR-Bill Payment Reference Type";
                                                                             AddInfoFormat: Code[20])
    var
        SwissQRBillLayout: Record "Swiss QR-Bill Layout";
    begin
        with SwissQRBillLayout do begin
            Code := LayoutCode;
            "IBAN Type" := IBANType;
            "Payment Reference Type" := PaymentReferenceType;
            "Billing Information" := AddInfoFormat;
            Insert();
        end;
    end;

    local procedure InitQRBillingInfoFormat(): Code[20]
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
    begin
        with SwissQRBillBillingInfo do
            if IsEmpty() then begin
                InitDefault();
                Insert();
                exit(Code);
            end;
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        IncomingDocument: Record "Incoming Document";
        CompanyInformation: Record "Company Information";
        PaymentMethod: Record "Payment Method";
        PurchaseHeader: Record "Purchase Header";
        Company: Record Company;
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Swiss QR-Bill Setup");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Swiss QR-Bill Buffer");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Swiss QR-Bill Billing Info");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Swiss QR-Bill Billing Detail");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Swiss QR-Bill Layout");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Swiss QR-Bill Setup");
        DataClassificationMgt.SetFieldToNormal(Database::"Company Information", CompanyInformation.FieldNo("Swiss QR-Bill IBAN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Swiss QR-Bill IBAN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Payment Method", PaymentMethod.FieldNo("Swiss QR-Bill Layout"));
        DataClassificationMgt.SetFieldToNormal(Database::"Payment Method", PaymentMethod.FieldNo("Swiss QR-Bill Bank Account No."));

        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Unstr. Message"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Bill Info"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Reference Type"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Reference No."));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Vendor Address 1"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Vendor Address 2"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Vendor City"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Vendor Post Code"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Vendor Country"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Debitor Name"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Debitor Address1"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Debitor Address2"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Debitor City"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Debitor PostCode"));
        DataClassificationMgt.SetFieldToNormal(Database::"Incoming Document", IncomingDocument.FieldNo("Swiss QR-Bill Debitor Country"));

        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Swiss QR-Bill"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Swiss QR-Bill Amount"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Swiss QR-Bill Bill Info"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Swiss QR-Bill Currency"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Swiss QR-Bill Has Zero Amount"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Swiss QR-Bill IBAN"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Swiss QR-Bill Unstr. Message"));

        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Swiss QR-Bill"));
    end;

    local procedure MoveOldTables()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        UpgradeTag.SetAllUpgradeTags();
    end;
}
