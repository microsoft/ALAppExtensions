// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.Bank.Reconciliation;
using Microsoft.EServices.EDocument;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using System.IO;
using System.Utilities;

codeunit 6156 "E-Doc. DED PEPPOL Pre-Mapping"
{
    Access = Internal;
    TableNo = "Data Exch.";
    Permissions = tabledata "E-Document" = m;

    var
        TempIntegerHeaderRecords: Record "Integer" temporary;
        TempIntegerLineRecords: Record "Integer" temporary;
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        CurrencyCodeMissingErr: Label 'The currency code is missing on the electronic document.';
        CurrencyCodeDifferentErr: Label 'The currency code %1 must not be different from the currency code %2 on the electronic document.', Comment = '%1 currency code (e.g. GBP), %2 the document currency code (e.g. DKK)';
        ItemCurrencyCodeDifferentErr: Label 'The currency code %1 on invoice line no. %2 must not be different from the currency code %3 on the electronic document.', Comment = '%1 Invoice line currency code (e.g. GBP), %2 invoice line no. (e.g. 2), %3 document currency code (e.g. DKK)';
        BuyFromVendorNotFoundErr: Label 'Cannot find buy-from vendor ''%1'' based on the vendor''s GLN %2 or VAT registration number %3 on the electronic document. Make sure that a card for the vendor exists with the corresponding GLN or VAT Registration No.', Comment = '%1 Vendor name (e.g. London Postmaster), %2 Vendor''s GLN (13 digit number), %3 Vendor''s VAT Registration Number';
        PayToVendorNotFoundErr: Label 'Cannot find pay-to vendor ''%1'' based on the vendor''s GLN %2 or VAT registration number %3 on the electronic document. Make sure that a card for the vendor exists with the corresponding GLN or VAT Registration No.', Comment = '%1 Vendor name (e.g. London Postmaster), %2 Vendor''s GLN (13 digit number), %3 Vendor''s VAT Registration Number';
        FieldMustHaveAValueErr: Label 'You must specify a value for field ''%1''.', Comment = '%1 - field caption';
        DocumentTypeUnknownErr: Label 'You must make a new entry in the %1 of the %2 window, and enter ''%3'' or ''%4'' in the %5 field. Then, you must map it to the %6 field in the %7 table.', Comment = '%1 - Column Definitions (page caption),%2 - Data Exchange Definition (page caption),%3 - invoice (option caption),%4 - credit memo (option caption),%5 - Constant (field name),%6 - Document Type (field caption),%7 - Purchase Header (table caption)';
        YouMustFirstPostTheRelatedInvoiceErr: Label 'The electronic document references invoice %1 from the vendor. You must post related purchase invoice %2 before you create a new purchase document from this electronic document.', Comment = '%1 - vendor invoice no.,%2 posted purchase invoice no.';
        UnableToFindRelatedInvoiceErr: Label 'The electronic document references invoice %1 from the vendor, but no purchase invoice exists for %1.', Comment = '%1 - vendor invoice no.';
        UnableToFindTotalAmountErr: Label 'The electronic document has no total amount excluding VAT.';
        UnableToFindAppropriateAccountErr: Label 'Cannot find an appropriate G/L account for the line with description ''%1''. Choose the Map Text to Account button, and then map the core part of ''%1'' to the relevant G/L account.', Comment = '%1 - arbitrary text';
        InvoiceChargeHasNoReasonErr: Label 'Invoice charge on the e-document has no reason code.';

    trigger OnRun()
    var
        BuyFromVendorNo: Code[20];
        PayToVendorNo: Code[20];
        ParentRecNo: Integer;
        CurrRecNo: Integer;
    begin
        ParentRecNo := 0;
        FindDistinctRecordNos(TempIntegerHeaderRecords, Rec."Entry No.", Database::"Purchase Header", ParentRecNo);
        if not TempIntegerHeaderRecords.FindSet() then
            exit;

        repeat
            CurrRecNo := TempIntegerHeaderRecords.Number;

            ValidateCurrency(Rec."Entry No.", CurrRecNo);
            SetDocumentType(Rec."Entry No.", ParentRecNo, CurrRecNo);

            BuyFromVendorNo := FindBuyFromVendor(Rec."Entry No.", CurrRecNo);
            PayToVendorNo := FindPayToVendor(Rec."Entry No.", CurrRecNo);
            FindInvoiceToApplyTo(Rec."Entry No.", CurrRecNo);

            PersistHeaderData(Rec."Entry No.", BuyFromVendorNo, PayToVendorNo);

            ProcessLines(Rec."Entry No.", CurrRecNo, BuyFromVendorNo);

            ApplyInvoiceCharges(Rec."Entry No.");
        until TempIntegerHeaderRecords.Next() = 0;
    end;

    local procedure ValidateCurrency(EntryNo: Integer; RecordNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GLSetup: Record "General Ledger Setup";
        DocumentCurrency: Text;
        IsLCY: Boolean;
    begin
        GLSetup.Get();
        if GLSetup."LCY Code" = '' then
            LogErrorMessage(EntryNo, GLSetup, GLSetup.FieldNo("LCY Code"),
              StrSubstNo(FieldMustHaveAValueErr, GLSetup.FieldCaption("LCY Code")));

        DocumentCurrency := IntermediateDataImport.GetEntryValue(EntryNo, Database::"Purchase Header", PurchaseHeader.FieldNo("Currency Code"), 0, RecordNo);
        if DocumentCurrency = '' then begin
            LogSimpleErrorMessage(EntryNo, CurrencyCodeMissingErr);
            exit;
        end;

        IsLCY := DocumentCurrency = GLSetup."LCY Code";
        // If LCY Currency wont be in Currency table
        if IsLCY then begin
            // Update Document Currency
            IntermediateDataImport.Value := '';
            IntermediateDataImport.Modify();
        end;

        // Ensure the currencies all match the same document currency
        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Tax Area Code"));
        IntermediateDataImport.SetFilter(Value, '<>%1', DocumentCurrency);
        if IntermediateDataImport.FindFirst() then
            LogSimpleErrorMessage(EntryNo, StrSubstNo(CurrencyCodeDifferentErr, IntermediateDataImport.Value, DocumentCurrency));

        // Clear the additional currency values on header
        IntermediateDataImport.SetRange(Value);
        IntermediateDataImport.DeleteAll();

        // check currency on the lines
        IntermediateDataImport.SetRange("Table ID", Database::"Purchase Line");
        IntermediateDataImport.SetRange("Field ID", PurchaseLine.FieldNo("Currency Code"));
        IntermediateDataImport.SetRange("Record No.");
        IntermediateDataImport.SetRange("Parent Record No.", RecordNo);
        IntermediateDataImport.SetFilter(Value, '<>%1', DocumentCurrency);
        if IntermediateDataImport.FindFirst() then
            LogSimpleErrorMessage(EntryNo, StrSubstNo(ItemCurrencyCodeDifferentErr, IntermediateDataImport.Value, IntermediateDataImport."Record No.", DocumentCurrency));

        // Clear the additional currency values on lines
        IntermediateDataImport.SetRange(Value);
        IntermediateDataImport.DeleteAll();
    end;

    local procedure PersistHeaderData(EntryNo: Integer; BuyFromVendorNo: Code[20]; PayToVendorNo: Code[20])
    var
        DataExch: Record "Data Exch.";
        EDocument: Record "E-Document";
        RecRef: RecordRef;
    begin
        DataExch.Get(EntryNo);
        RecRef := DataExch."Related Record".GetRecord();
        RecRef.SetTable(EDocument);
        EDocument.SetRecFilter();
        EDocument.FindFirst();

        if PayToVendorNo <> '' then
            EDocument.Validate("Bill-to/Pay-to No.", PayToVendorNo)
        else
            EDocument.Validate("Bill-to/Pay-to No.", BuyFromVendorNo);

        EDocument.Modify();
    end;

    local procedure FindBuyFromVendor(EntryNo: Integer; RecordNo: Integer): Code[20]
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        EmptyVendor: Record Vendor;
        DataExch: Record "Data Exch.";
        VendorBankAccount: Record "Vendor Bank Account";
        GLN: Text;
        BuyFromName: Text;
        BuyFromAddress: Text;
        BuyFromPhoneNo: Text;
        VatRegNo: Text;
        VendorIdText: Text;
        VendorNoText: Text;
        VendorNo: Code[20];
        VendorIBAN: Code[50];
        VendorBankBranchNo: Text[20];
        VendorBankAccountNo: Text[30];
    begin
        VendorIdText := IntermediateDataImport.GetEntryValue(EntryNo, Database::Vendor, Vendor.FieldNo(SystemId), 0, RecordNo);
        VendorNo := EDocumentImportHelper.FindVendorById(VendorIdText);
        if VendorNo <> '' then
            exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));

        VendorNoText := IntermediateDataImport.GetEntryValue(EntryNo, Database::Vendor, Vendor.FieldNo("No."), 0, RecordNo);
        VendorNo := EDocumentImportHelper.FindVendorByNo(CopyStr(VendorNoText, 1, MaxStrLen(PurchaseHeader."Buy-from Vendor No.")));
        if VendorNo <> '' then
            exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));

        // Get phone no, Name, Address
        BuyFromPhoneNo := IntermediateDataImport.GetEntryValue(EntryNo, Database::Vendor, Vendor.FieldNo("Phone No."), 0, RecordNo);

        if IntermediateDataImport.FindEntry(EntryNo, Database::"Purchase Header", PurchaseHeader.FieldNo("Buy-from Vendor Name"), 0, RecordNo) then
            BuyFromName := IntermediateDataImport.Value;

        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Buy-from Address"));
        if IntermediateDataImport.FindFirst() then
            BuyFromAddress := IntermediateDataImport.Value;

        // Lookup GLN
        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Buy-from Vendor No."));
        if IntermediateDataImport.FindFirst() then
            if IntermediateDataImport.Value <> '' then begin
                GLN := IntermediateDataImport.Value;
                VendorNo := EDocumentImportHelper.FindVendorByGLN(GLN);
                if VendorNo <> '' then
                    exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));
            end;

        Vendor.Reset();
        Vendor.SetCurrentKey(Blocked);
        VatRegNo := '';
        // Lookup VAT Reg No
        IntermediateDataImport.SetRange("Table ID", Database::Vendor);
        IntermediateDataImport.SetRange("Field ID", Vendor.FieldNo("VAT Registration No."));

        if IntermediateDataImport.FindFirst() then begin
            if (IntermediateDataImport.Value = '') and (GLN = '') then begin
                if IntermediateDataImport.FindEntry(EntryNo, Database::"Vendor Bank Account", VendorBankAccount.FieldNo(IBAN), 0, RecordNo) then
                    VendorIBAN := CopyStr(IntermediateDataImport.Value, 1, MaxStrLen(VendorIBAN));

                IntermediateDataImport.SetRange("Field ID", VendorBankAccount.FieldNo("Bank Branch No."));
                if IntermediateDataImport.FindFirst() then
                    VendorBankBranchNo := CopyStr(IntermediateDataImport.Value, 1, MaxStrLen(VendorBankBranchNo));

                IntermediateDataImport.SetRange("Field ID", VendorBankAccount.FieldNo("Bank Account No."));
                if IntermediateDataImport.FindFirst() then
                    VendorBankAccountNo := CopyStr(IntermediateDataImport.Value, 1, MaxStrLen(VendorBankAccountNo));

                VendorNo := EDocumentImportHelper.FindVendorByBankAccount(VendorIBAN, VendorBankBranchNo, VendorBankAccountNo);
                if VendorNo <> '' then
                    exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));

                VendorNo := EDocumentImportHelper.FindVendorByPhoneNo(BuyFromPhoneNo);
                if VendorNo <> '' then
                    exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));

                VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(BuyFromName, BuyFromAddress);
                if VendorNo <> '' then
                    exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));
            end;
            VatRegNo := IntermediateDataImport.Value;
            VendorNo := EDocumentImportHelper.FindVendorByVATRegistrationNo(VatRegNo);
            if VendorNo <> '' then
                exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));
        end;

        if (VatRegNo = '') and (GLN = '') then begin
            VendorNo := EDocumentImportHelper.FindVendorByBankAccount(VendorIBAN, VendorBankBranchNo, VendorBankAccountNo);
            if VendorNo <> '' then
                exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));

            VendorNo := EDocumentImportHelper.FindVendorByPhoneNo(BuyFromPhoneNo);
            if VendorNo <> '' then
                exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));

            VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(BuyFromName, BuyFromAddress);
            if VendorNo <> '' then
                exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));
        end;

        DataExch.Get(EntryNo);
        LogErrorMessage(EntryNo, EmptyVendor, EmptyVendor.FieldNo(Name), StrSubstNo(BuyFromVendorNotFoundErr, BuyFromName, GLN, VatRegNo));
        exit('');
    end;

    local procedure FindPayToVendor(EntryNo: Integer; RecordNo: Integer): Code[20]
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        EmptyVendor: Record Vendor;
        DataExch: Record "Data Exch.";
        GLN: Text;
        VatRegNo: Text;
        PayToName: Text;
        PayToAddress: Text;
        VendorNo: Code[20];
    begin
        if IntermediateDataImport.FindEntry(EntryNo, Database::"Purchase Header", PurchaseHeader.FieldNo("Pay-to Name"), 0, RecordNo) then
            PayToName := IntermediateDataImport.Value;

        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Pay-to Address"));
        if IntermediateDataImport.FindFirst() then
            PayToAddress := IntermediateDataImport.Value;

        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("VAT Registration No."));
        if IntermediateDataImport.FindFirst() then
            VatRegNo := IntermediateDataImport.Value;

        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Pay-to Vendor No."));
        if IntermediateDataImport.FindFirst() then
            GLN := IntermediateDataImport.Value;

        if (VatRegNo = '') and (GLN = '') then begin
            if PayToName <> '' then begin
                VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(PayToName, PayToAddress);
                if VendorNo <> '' then
                    exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));
            end;
            exit;
        end;

        // Lookup GLN
        VendorNo := EDocumentImportHelper.FindVendorByGLN(GLN);
        if VendorNo <> '' then
            exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));

        // Lookup VAT Reg No
        VendorNo := EDocumentImportHelper.FindVendorByVATRegistrationNo(VatRegNo);
        if VendorNo <> '' then
            exit(UpdateIntermediateRecord(IntermediateDataImport, EntryNo, RecordNo, VendorNo));

        DataExch.Get(EntryNo);
        LogErrorMessage(EntryNo, EmptyVendor, EmptyVendor.FieldNo(Name), StrSubstNo(PayToVendorNotFoundErr, PayToName, GLN, VatRegNo));
        exit('');
    end;

    local procedure UpdateIntermediateRecord(var IntermediateDataImport: Record "Intermediate Data Import"; EntryNo: Integer; RecordNo: Integer; VendorNo: Code[20]): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, Database::"Purchase Header", PurchaseHeader.FieldNo("Buy-from Vendor No."), 0, RecordNo, VendorNo);
        exit(VendorNo);
    end;

    local procedure FindInvoiceToApplyTo(EntryNo: Integer; RecordNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        VendorInvoiceNo: Text;
        AppliesToDocTypeAsInteger: Integer;
    begin
        VendorInvoiceNo := IntermediateDataImport.GetEntryValue(EntryNo, Database::"Purchase Header", PurchaseHeader.FieldNo("Applies-to Doc. No."), 0, RecordNo);
        if VendorInvoiceNo = '' then
            exit;

        // Find a posted purchase invoice that has the specified Vendor Invoice No.
        PurchInvHeader.SetRange("Vendor Invoice No.", VendorInvoiceNo);
        if PurchInvHeader.FindFirst() then begin
            AppliesToDocTypeAsInteger := PurchaseHeader."Applies-to Doc. Type"::Invoice.AsInteger();
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, Database::"Purchase Header",
              PurchaseHeader.FieldNo("Applies-to Doc. Type"), 0, RecordNo, Format(AppliesToDocTypeAsInteger));
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, Database::"Purchase Header",
              PurchaseHeader.FieldNo("Applies-to Doc. No."), 0, RecordNo, PurchInvHeader."No.");
            exit;
        end;

        // No posted purchase invoice has the specified Vendor Invoice No.
        // This is an error - the user first needs to post the related invoice before importing this document.
        // If we can find an unposted invoice with this Vendor Invoice No. we will link to it in the error message.
        PurchaseHeader.SetRange("Vendor Invoice No.", VendorInvoiceNo);
        if PurchaseHeader.FindFirst() then begin
            LogErrorMessage(EntryNo, PurchaseHeader, PurchaseHeader.FieldNo("No."),
              StrSubstNo(YouMustFirstPostTheRelatedInvoiceErr, VendorInvoiceNo, PurchaseHeader."No."));
            exit;
        end;

        // No purchase invoice (posted or not) has the specified Vendor Invoice No.
        // This is an error - the user needs to create and post the related invoice before importing this document.
        LogErrorMessage(
          EntryNo, PurchInvHeader, PurchInvHeader.FieldNo("No."), StrSubstNo(UnableToFindRelatedInvoiceErr, VendorInvoiceNo));
    end;

    local procedure ProcessLines(EntryNo: Integer; HeaderRecordNo: Integer; VendorNo: Code[20])
    begin
        FindDistinctRecordNos(TempIntegerLineRecords, EntryNo, Database::"Purchase Line", HeaderRecordNo);
        if not TempIntegerLineRecords.FindSet() then begin
            InsertLineForTotalDocumentAmount(EntryNo, HeaderRecordNo, 1, VendorNo);
            exit;
        end;
    end;

    local procedure InsertLineForTotalDocumentAmount(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        IntermediateDataImport: Record "Intermediate Data Import";
        LineDescription: Text[250];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertLineForTotalDocumentAmount(EntryNo, IsHandled);
        if IsHandled then
            exit;

        if not Vendor.Get(VendorNo) then
            exit;

        LineDescription := IntermediateDataImport.GetEntryValue(
            EntryNo, Database::"Purchase Header", PurchaseHeader.FieldNo("Buy-from Vendor Name"), 0, HeaderRecordNo);
        if LineDescription = '' then
            LineDescription := Vendor.Name;
        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, Database::"Purchase Line",
            PurchaseLine.FieldNo(Description), HeaderRecordNo, RecordNo, LineDescription);
        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, Database::"Purchase Line",
            PurchaseLine.FieldNo(Quantity), HeaderRecordNo, RecordNo, '1');
        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, Database::"Purchase Line",
            PurchaseLine.FieldNo("Direct Unit Cost"), HeaderRecordNo, RecordNo, GetTotalAmountExclVAT(EntryNo, HeaderRecordNo));
        FindGLAccountForLine(EntryNo, HeaderRecordNo, RecordNo, VendorNo);
    end;

    local procedure GetTotalAmountExclVAT(EntryNo: Integer; HeaderRecordNo: Integer): Text[250]
    var
        PurchaseHeader: Record "Purchase Header";
        IntermediateDataImport: Record "Intermediate Data Import";
    begin
        if not IntermediateDataImport.FindEntry(EntryNo, Database::"Purchase Header", PurchaseHeader.FieldNo(Amount), 0, HeaderRecordNo) then begin
            LogSimpleErrorMessage(EntryNo, UnableToFindTotalAmountErr);
            exit('');
        end;
        exit(IntermediateDataImport.Value);
    end;

    local procedure FindGLAccountForLine(EntryNo: Integer; HeaderRecordNo: Integer; RecordNo: Integer; VendorNo: Code[20]): Boolean
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        GLAccountNo: Code[20];
        LineDescription: Text[250];
        LineDirectUnitCostTxt: Text;
        LineDirectUnitCost: Decimal;
    begin
        LineDescription := IntermediateDataImport.GetEntryValue(EntryNo, Database::"Purchase Line", PurchaseLine.FieldNo(Description), HeaderRecordNo, RecordNo);
        LineDirectUnitCostTxt :=
          IntermediateDataImport.GetEntryValue(EntryNo, Database::"Purchase Line", PurchaseLine.FieldNo("Direct Unit Cost"), HeaderRecordNo, RecordNo);
        if LineDirectUnitCostTxt <> '' then
            Evaluate(LineDirectUnitCost, LineDirectUnitCostTxt, 9);
        GLAccountNo := FindAppropriateGLAccount(EntryNo, HeaderRecordNo, LineDescription, LineDirectUnitCost, VendorNo);

        if GLAccountNo <> '' then begin
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, Database::"Purchase Line", PurchaseLine.FieldNo("No."),
              HeaderRecordNo, RecordNo, GLAccountNo);
            IntermediateDataImport.InsertOrUpdateEntry(EntryNo, Database::"Purchase Line", PurchaseLine.FieldNo(Type),
              HeaderRecordNo, RecordNo, Format(PurchaseLine.Type::"G/L Account", 0, 9));
        end;

        exit(GLAccountNo <> '');
    end;

    local procedure FindDistinctRecordNos(var TempInteger: Record "Integer" temporary; DataExchEntryNo: Integer; TableID: Integer; ParentRecNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        CurrRecNo: Integer;
    begin
        CurrRecNo := -1;
        Clear(TempInteger);
        TempInteger.DeleteAll();

        IntermediateDataImport.SetRange("Data Exch. No.", DataExchEntryNo);
        IntermediateDataImport.SetRange("Table ID", TableID);
        IntermediateDataImport.SetRange("Parent Record No.", ParentRecNo);
        IntermediateDataImport.SetCurrentKey("Record No.");
        if not IntermediateDataImport.FindSet() then
            exit;

        repeat
            if CurrRecNo <> IntermediateDataImport."Record No." then begin
                CurrRecNo := IntermediateDataImport."Record No.";
                Clear(TempInteger);
                TempInteger.Number := CurrRecNo;
                TempInteger.Insert();
            end;
        until IntermediateDataImport.Next() = 0;
    end;

    local procedure ApplyInvoiceCharges(DataExchEntryNo: Integer)
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        IntermediateDataImport, IntermediateDataImport2, IntermediateDataImport3 : Record "Intermediate Data Import";
        ItemCharge: Record "Item Charge";
        PlaceholderPurchaseLine: Record "Purchase Line";
        InvoiceChargeAmount: Decimal;
        InvoiceChargeReason: Text[100];
        RecordNo: Integer;
    begin
        RecordNo := 1;
        IntermediateDataImport3.SetRange("Data Exch. No.", DataExchEntryNo);
        IntermediateDataImport3.SetRange("Table ID", Database::"Purchase Line");
        if IntermediateDataImport3.FindLast() then
            RecordNo += IntermediateDataImport3."Record No.";

        IntermediateDataImport.SetRange("Data Exch. No.", DataExchEntryNo);
        IntermediateDataImport.SetRange("Table ID", Database::"Item Charge Assignment (Purch)");
        IntermediateDataImport.SetRange("Field ID", ItemChargeAssignmentPurch.FieldNo("Amount to Assign"));
        IntermediateDataImport.SetRange("Parent Record No.", 0);
        IntermediateDataImport.SetFilter(Value, '<>%1', '');

        if not IntermediateDataImport.FindSet() then
            exit;

        IntermediateDataImport2.SetRange("Data Exch. No.", IntermediateDataImport."Data Exch. No.");
        IntermediateDataImport2.SetRange("Table ID", Database::"Item Charge");
        IntermediateDataImport2.SetRange("Field ID", ItemCharge.FieldNo(Description));
        IntermediateDataImport2.SetRange("Record No.", IntermediateDataImport."Record No.");
        IntermediateDataImport2.SetRange("Parent Record No.", 0);
        IntermediateDataImport2.SetFilter(Value, '<>%1', '');

        if not IntermediateDataImport2.FindSet() then
            Error(InvoiceChargeHasNoReasonErr);

        repeat
            Evaluate(InvoiceChargeAmount, IntermediateDataImport.Value, 9);
            InvoiceChargeReason := CopyStr(IntermediateDataImport2.Value, 1, MaxStrLen(PlaceholderPurchaseLine.Description));
            if InvoiceChargeReason = '' then
                Error(InvoiceChargeHasNoReasonErr);
            IntermediateDataImport2.Next();

            IntermediateDataImport3.Init();
            IntermediateDataImport3."Data Exch. No." := DataExchEntryNo;
            IntermediateDataImport3."Parent Record No." := 1;
            IntermediateDataImport3."Record No." := RecordNo;
            IntermediateDataImport3."Table ID" := Database::"Purchase Line";

            InsertChargeLineField(IntermediateDataImport3, false, PlaceholderPurchaseLine.FieldNo(Quantity), '1');
            InsertChargeLineField(IntermediateDataImport3, false, PlaceholderPurchaseLine.FieldNo(Description), InvoiceChargeReason);
            InsertChargeLineField(IntermediateDataImport3, true, PlaceholderPurchaseLine.FieldNo("Direct Unit Cost"), Format(InvoiceChargeAmount));
            InsertChargeLineField(IntermediateDataImport3, true, PlaceholderPurchaseLine.FieldNo(Amount), Format(InvoiceChargeAmount));
            InsertChargeLineField(IntermediateDataImport3, true, PlaceholderPurchaseLine.FieldNo("Quantity (Base)"), '1');

            RecordNo += 1;
        until IntermediateDataImport.Next() = 0;
    end;

    local procedure InsertChargeLineField(var IntermediateDataImport: Record "Intermediate Data Import"; ValidateOnly: Boolean; FieldNo: Integer; FieldValue: Text)
    begin
        IntermediateDataImport.ID := 0;
        IntermediateDataImport."Validate Only" := ValidateOnly;
        IntermediateDataImport."Field ID" := FieldNo;
        IntermediateDataImport.Value := CopyStr(FieldValue, 1, MaxStrLen(IntermediateDataImport.Value));
        IntermediateDataImport.Insert();
    end;

    local procedure LogErrorMessage(EntryNo: Integer; RelatedRec: Variant; FieldNo: Integer; Message: Text)
    var
        ErrorMessage: Record "Error Message";
        DataExch: Record "Data Exch.";
    begin
        DataExch.Get(EntryNo);
        ErrorMessage.SetContext(DataExch."Related Record");
        ErrorMessage.LogMessage(RelatedRec, FieldNo, ErrorMessage."Message Type"::Error, Message);
    end;

    local procedure LogSimpleErrorMessage(EntryNo: Integer; Message: Text)
    var
        ErrorMessage: Record "Error Message";
        DataExch: Record "Data Exch.";
    begin
        DataExch.Get(EntryNo);
        ErrorMessage.SetContext(DataExch."Related Record");
        ErrorMessage.LogSimpleMessage(ErrorMessage."Message Type"::Error, Message);
    end;

    local procedure SetDocumentType(EntryNo: Integer; ParentRecNo: Integer; CurrRecNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseHeader: Record "Purchase Header";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DocumentType: Text[250];
    begin
        DataExch.Get(EntryNo);
        DataExchDef.Get(DataExch."Data Exch. Def Code");

        if not IntermediateDataImport.FindEntry(EntryNo, Database::"Purchase Header", PurchaseHeader.FieldNo("Document Type"), ParentRecNo, CurrRecNo) then
            LogErrorMessage(EntryNo, DataExchDef, DataExchDef.FieldNo(Code),
              ConstructDocumenttypeUnknownErr());

        case UpperCase(IntermediateDataImport.Value) of
            GetDocumentTypeOptionString(PurchaseHeader."Document Type"::Invoice.AsInteger()),
            GetDocumentTypeOptionCaption(PurchaseHeader."Document Type"::Invoice.AsInteger()),
            'INVOICE':
                DocumentType := Format(PurchaseHeader."Document Type"::Invoice, 0, 9);
            GetDocumentTypeOptionString(PurchaseHeader."Document Type"::"Credit Memo".AsInteger()),
            GetDocumentTypeOptionCaption(PurchaseHeader."Document Type"::"Credit Memo".AsInteger()),
            'CREDIT NOTE':
                DocumentType := Format(PurchaseHeader."Document Type"::"Credit Memo", 0, 9);
            else
                LogErrorMessage(EntryNo, DataExchDef, DataExchDef.FieldNo(Code),
                  ConstructDocumenttypeUnknownErr());
        end;

        IntermediateDataImport.InsertOrUpdateEntry(EntryNo, Database::"Purchase Header",
          PurchaseHeader.FieldNo("Document Type"), ParentRecNo, CurrRecNo,
          DocumentType);
    end;

    procedure GetDocumentTypeOptionString(OptionIndex: Integer): Text[250]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderRecRef: RecordRef;
        DocumentTypeFieldRef: FieldRef;
    begin
        PurchaseHeaderRecRef.Open(Database::"Purchase Header");
        DocumentTypeFieldRef := PurchaseHeaderRecRef.Field(PurchaseHeader.FieldNo("Document Type"));
        exit(CopyStr(UpperCase(SelectStr(OptionIndex + 1, DocumentTypeFieldRef.OptionMembers)), 1, 250));
    end;

    procedure GetDocumentTypeOptionCaption(OptionIndex: Integer): Text[250]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderRecRef: RecordRef;
        DocumentTypeFieldRef: FieldRef;
    begin
        PurchaseHeaderRecRef.Open(Database::"Purchase Header");
        DocumentTypeFieldRef := PurchaseHeaderRecRef.Field(PurchaseHeader.FieldNo("Document Type"));
        exit(CopyStr(UpperCase(SelectStr(OptionIndex + 1, DocumentTypeFieldRef.OptionCaption)), 1, 250));
    end;

    procedure ConstructDocumenttypeUnknownErr(): Text
    var
        PurchaseHeader: Record "Purchase Header";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchColDefPart: Page "Data Exch Col Def Part";
        DataExchDefCard: Page "Data Exch Def Card";
    begin
        exit(StrSubstNo(DocumentTypeUnknownErr,
            DataExchColDefPart.Caption,
            DataExchDefCard.Caption,
            GetDocumentTypeOptionCaption(PurchaseHeader."Document Type"::Invoice.AsInteger()),
            GetDocumentTypeOptionCaption(PurchaseHeader."Document Type"::"Credit Memo".AsInteger()),
            DataExchColumnDef.FieldCaption(Constant),
            PurchaseHeader.FieldCaption("Document Type"),
            PurchaseHeader.TableCaption()));
    end;

    procedure FindAppropriateGLAccount(EntryNo: Integer; HeaderRecordNo: Integer; LineDescription: Text[250]; LineDirectUnitCost: Decimal; VendorNo: Code[20]): Code[20]
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        TextToAccountMapping: Record "Text-to-Account Mapping";
        PurchaseHeader: Record "Purchase Header";
        IntermediateDataImport: Record "Intermediate Data Import";
        DocumentTypeTxt: Text;
        DocumentType: Enum "Gen. Journal Document Type";
        DefaultGLAccount: Code[20];
        CountOfResult: Integer;
    begin
        DocumentTypeTxt := IntermediateDataImport.GetEntryValue(
            EntryNo, Database::"Purchase Header", PurchaseHeader.FieldNo("Document Type"), 0, HeaderRecordNo);
        if not Evaluate(DocumentType, DocumentTypeTxt) then
            exit('');

        CountOfResult := TextToAccountMapping.SearchEnteriesInText(TextToAccountMapping, LineDescription, VendorNo);
        if CountOfResult = 1 then
            exit(FindCorrectAccountFromMapping(TextToAccountMapping, LineDirectUnitCost, DocumentType));
        if CountOfResult > 1 then begin
            LogErrorMessage(EntryNo, TextToAccountMapping, TextToAccountMapping.FieldNo("Mapping Text"),
              StrSubstNo(UnableToFindAppropriateAccountErr, LineDescription));
            exit('');
        end;

        if VendorNo <> '' then begin
            CountOfResult := TextToAccountMapping.SearchEnteriesInText(TextToAccountMapping, LineDescription, '');
            if CountOfResult = 1 then
                exit(FindCorrectAccountFromMapping(TextToAccountMapping, LineDirectUnitCost, DocumentType));
            if CountOfResult > 1 then begin
                LogErrorMessage(EntryNo, TextToAccountMapping, TextToAccountMapping.FieldNo("Mapping Text"),
                  StrSubstNo(UnableToFindAppropriateAccountErr, LineDescription));
                exit('');
            end;
        end;

        // if you don't find any suggestion in Text-to-Account Mapping, then look in the Purchases & Payables table
        PurchasesPayablesSetup.Get();
        case DocumentType of
            "Gen. Journal Document Type"::Invoice:
                if LineDirectUnitCost >= 0 then
                    DefaultGLAccount := PurchasesPayablesSetup."Debit Acc. for Non-Item Lines"
                else
                    DefaultGLAccount := PurchasesPayablesSetup."Credit Acc. for Non-Item Lines";
            "Gen. Journal Document Type"::"Credit Memo":
                if LineDirectUnitCost >= 0 then
                    DefaultGLAccount := PurchasesPayablesSetup."Credit Acc. for Non-Item Lines"
                else
                    DefaultGLAccount := PurchasesPayablesSetup."Debit Acc. for Non-Item Lines";
        end;
        if DefaultGLAccount = '' then
            LogErrorMessage(EntryNo, TextToAccountMapping, TextToAccountMapping.FieldNo("Mapping Text"),
              StrSubstNo(UnableToFindAppropriateAccountErr, LineDescription));
        exit(DefaultGLAccount)
    end;

    local procedure FindCorrectAccountFromMapping(TextToAccountMapping: Record "Text-to-Account Mapping"; LineDirectUnitCost: Decimal; DocumentType: Enum "Gen. Journal Document Type"): Code[20]
    begin
        case DocumentType of
            "Gen. Journal Document Type"::Invoice:
                begin
                    if (LineDirectUnitCost >= 0) and (TextToAccountMapping."Debit Acc. No." <> '') then
                        exit(TextToAccountMapping."Debit Acc. No.");
                    if (LineDirectUnitCost < 0) and (TextToAccountMapping."Credit Acc. No." <> '') then
                        exit(TextToAccountMapping."Credit Acc. No.");
                end;
            "Gen. Journal Document Type"::"Credit Memo":
                begin
                    if (LineDirectUnitCost >= 0) and (TextToAccountMapping."Credit Acc. No." <> '') then
                        exit(TextToAccountMapping."Credit Acc. No.");
                    if (LineDirectUnitCost < 0) and (TextToAccountMapping."Debit Acc. No." <> '') then
                        exit(TextToAccountMapping."Debit Acc. No.");
                end;
        end
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertLineForTotalDocumentAmount(EntryNo: Integer; var IsHandled: Boolean)
    begin
    end;
}