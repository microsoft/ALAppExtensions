// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Utilities;
using System.IO;

codeunit 6109 "E-Document Import Helper"
{
    /// <summary>
    /// Use it to check, resolve and update unit of measure information for the imported document line.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempDocumentLine">Imported document line.</param>
    /// <returns>True if successful.</returns>
    procedure ResolveUnitOfMeasureFromDataImport(var EDocument: Record "E-Document"; var TempDocumentLine: RecordRef): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        UOMCodeFieldRef: FieldRef;
    begin
        case TempDocumentLine.Number of
            Database::"Purchase Line":
                UOMCodeFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Unit of Measure Code"));
        end;

        if Format(UOMCodeFieldRef.Value()) = '' then begin
            UOMCodeFieldRef.Value('');
            exit(true);
        end;

        UnitOfMeasure.SetRange(Code, CopyStr(UOMCodeFieldRef.Value(), 1, MaxStrLen(UnitOfMeasure.Code)));
        if UnitOfMeasure.FindFirst() then begin
            UOMCodeFieldRef.Value(UnitOfMeasure.Code);
            exit(true);
        end;

        UnitOfMeasure.SetRange(Code);
        UnitOfMeasure.SetRange("International Standard Code", CopyStr(UOMCodeFieldRef.Value(), 1, MaxStrLen(UnitOfMeasure."International Standard Code")));
        if UnitOfMeasure.FindFirst() then begin
            UOMCodeFieldRef.Value(UnitOfMeasure.Code);
            exit(true);
        end;

        UnitOfMeasure.SetRange("International Standard Code");
        UnitOfMeasure.SetRange(Description, UOMCodeFieldRef.Value());
        if UnitOfMeasure.FindFirst() then begin
            UOMCodeFieldRef.Value(UnitOfMeasure.Code);
            exit(true);
        end;

        EDocErrorHelper.LogErrorMessage(EDocument, UnitOfMeasure, UnitOfMeasure.FieldNo(Code), StrSubstNo(UOMNotFoundErr, UOMCodeFieldRef.Value()));
        exit(false);
    end;

    /// <summary>
    /// Use it to find an item by reference and update item information for the imported document line.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempDocumentLine">Imported document line.</param>
    /// <returns>True if successful.</returns>
    procedure FindItemReferenceForLine(var EDocument: Record "E-Document"; var TempDocumentLine: RecordRef): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        ItemReference: Record "Item Reference";
        Vendor: Record Vendor;
        UOMCodeFieldRef, ItemRefFieldRef, TypeFieldRef, NoFieldRef : FieldRef;
    begin
        case TempDocumentLine.Number of
            Database::"Purchase Line":
                begin
                    if not Vendor.Get(EDocument."Bill-to/Pay-to No.") then
                        exit(false);

                    ItemRefFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Item Reference No."));
                    TypeFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo(Type));
                    NoFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("No."));
                    UOMCodeFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Unit of Measure Code"));

                    ItemReference.SetRange("Reference Type", "Item Reference Type"::Vendor);
                    ItemReference.SetRange("Reference Type No.", Vendor."No.");
                end;
        end;

        ItemReference.SetRange("Reference No.", CopyStr(ItemRefFieldRef.Value(), 1, MaxStrLen(ItemReference."Reference No.")));

        if not FindMatchingItemReference(ItemReference, UOMCodeFieldRef.Value()) then
            exit(false);

        TypeFieldRef.Value(Format(PurchaseLine.Type::Item, 0, 9));
        NoFieldRef.Value(Format(ItemReference."Item No.", 0, 9));

        ResolveUnitOfMeasureFromItemReference(ItemReference, EDocument, TempDocumentLine);
        exit(true);
    end;

    /// <summary>
    /// Use it to find an item by GTIN and update item information for the imported document line.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempDocumentLine">Imported document line.</param>
    /// <returns>True if successful.</returns>
    procedure FindItemForLine(var EDocument: Record "E-Document"; var TempDocumentLine: RecordRef): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        TypeFieldRef, NoFieldRef : FieldRef;
        GTIN: Text;
    begin
        case TempDocumentLine.Number of
            Database::"Purchase Line":
                begin
                    TypeFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo(Type));
                    NoFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("No."));
                end;
        end;

        GTIN := NoFieldRef.Value;
        if GTIN = '' then
            exit(false);

        Item.SetRange(GTIN, GTIN);
        if not Item.FindFirst() then
            exit(false);

        TypeFieldRef.Value(Format(PurchaseLine.Type::Item, 0, 9));
        NoFieldRef.Value(Format(Item."No.", 0, 9));

        ResolveUnitOfMeasureFromItem(Item, EDocument, TempDocumentLine);
        exit(true);
    end;

    /// <summary>
    /// Use it to find a G/L account by imported text in Text-to-Account Mapping and update account information for the imported document line.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempDocumentLine">Imported document line.</param>
    /// <returns>True if successful.</returns>
    procedure FindGLAccountForLine(var EDocument: Record "E-Document"; var TempDocumentLine: RecordRef): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        TypeFieldRef, NoFieldRef, ItemRefNoFieldRef : FieldRef;
        GLAccountNo: Code[20];
        LineDescription: Text[250];
        LineDirectUnitCost: Decimal;
    begin
        case TempDocumentLine.Number of
            Database::"Purchase Line":
                begin
                    TypeFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo(Type));
                    NoFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("No."));
                    ItemRefNoFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Item Reference No."));
                    LineDescription := TempDocumentLine.Field(PurchaseLine.FieldNo(Description)).Value();
                    LineDirectUnitCost := TempDocumentLine.Field(PurchaseLine.FieldNo("Direct Unit Cost")).Value();
                end;
        end;

        GLAccountNo := FindAppropriateGLAccount(EDocument, TempDocumentLine, LineDescription, LineDirectUnitCost);

        if GLAccountNo <> '' then begin
            NoFieldRef.Value(GLAccountNo);
            TypeFieldRef.Value(Format(PurchaseLine.Type::"G/L Account", 0, 9));
            ItemRefNoFieldRef.Value('');
        end;

        exit(GLAccountNo <> '');
    end;

    /// <summary>
    /// Use it to log an error if an item or a G/L account is not found for the imported document line.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempDocumentLine">Imported document line.</param>
    /// <returns>True if successful.</returns>
    procedure LogErrorIfItemNotFound(var EDocument: Record "E-Document"; var TempDocumentLine: RecordRef): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        GTIN, ItemName, VendorItemNo : Text[250];
    begin
        case TempDocumentLine.Number of
            Database::"Purchase Line":
                begin
                    GTIN := TempDocumentLine.Field(PurchaseLine.FieldNo("No.")).Value();
                    VendorItemNo := TempDocumentLine.Field(PurchaseLine.FieldNo("Item Reference No.")).Value();
                    ItemName := TempDocumentLine.Field(PurchaseLine.FieldNo(Description)).Value();
                end;
        end;

        if (GTIN <> '') and (VendorItemNo <> '') then begin
            EDocErrorHelper.LogErrorMessage(EDocument, Item, Item.FieldNo("No."), StrSubstNo(ItemNotFoundErr, ItemName, EDocument."Bill-to/Pay-to No.", VendorItemNo, GTIN));
            exit(false);
        end;

        if GTIN <> '' then begin
            EDocErrorHelper.LogErrorMessage(EDocument, Item, Item.FieldNo("No."), StrSubstNo(ItemNotFoundByGTINErr, ItemName, GTIN));
            exit(false);
        end;

        if VendorItemNo <> '' then begin
            EDocErrorHelper.LogErrorMessage(EDocument, Item, Item.FieldNo("No."), StrSubstNo(ItemNotFoundByVendorItemNoErr, ItemName, EDocument."Bill-to/Pay-to No.", VendorItemNo));
            exit(false);
        end;

        exit(true);
    end;

    /// <summary>
    /// Use it to validate discount for the imported document line.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempDocumentLine">Imported document line.</param>
    procedure ValidateLineDiscount(var EDocument: Record "E-Document"; var TempDocumentLine: RecordRef)
    var
        PurchaseLine: Record "Purchase Line";
        LineDirectUnitCostFieldRef, LineQuantityFieldRef, LineAmountFieldRef, LineDiscountAmountFieldRef : FieldRef;
        LineDirectUnitCost: Decimal;
        LineAmount: Decimal;
        LineQuantity: Decimal;
        LineDiscountAmount: Decimal;
    begin
        case TempDocumentLine.Number of
            Database::"Purchase Line":
                begin
                    LineDirectUnitCostFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Direct Unit Cost"));
                    LineQuantityFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo(Quantity));
                    LineAmountFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo(Amount));
                    LineDiscountAmountFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Line Discount Amount"));
                end;
        end;

        LineDirectUnitCost := LineDirectUnitCostFieldRef.Value();
        LineQuantity := LineQuantityFieldRef.Value();
        LineAmount := LineAmountFieldRef.Value();

        LineDiscountAmount := (LineQuantity * LineDirectUnitCost) - LineAmount;

        LineDiscountAmountFieldRef.Value(Format(LineDiscountAmount, 0, 9));
    end;

    /// <summary>
    /// Use it to check if receiving company information is in line with Company Information.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    procedure ValidateReceivingCompanyInfo(EDocument: Record "E-Document")
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        if (EDocument."Receiving Company GLN" = '') and (EDocument."Receiving Company VAT Reg. No." = '') then begin
            ValidateReceivingCompanyInfoByNameAndAddress(EDocument);
            exit;
        end;

        if (CompanyInformation.GLN = '') and (CompanyInformation."VAT Registration No." = '') then
            EDocErrorHelper.LogErrorMessage(EDocument, CompanyInformation, CompanyInformation.FieldNo(GLN), MissingCompanyInfoSetupErr);

        if EDocument."Receiving Company GLN" <> '' then
            if not (CompanyInformation.GLN in ['', EDocument."Receiving Company GLN"]) then
                EDocErrorHelper.LogErrorMessage(EDocument, CompanyInformation, CompanyInformation.FieldNo(GLN), StrSubstNo(InvalidCompanyInfoGLNErr, EDocument."Receiving Company GLN"));

        if not (ExtractVatRegNo(CompanyInformation."VAT Registration No.", '') in ['', ExtractVatRegNo(EDocument."Receiving Company VAT Reg. No.", '')]) then
            EDocErrorHelper.LogErrorMessage(EDocument, CompanyInformation, CompanyInformation.FieldNo("VAT Registration No."), StrSubstNo(InvalidCompanyInfoVATRegNoErr, EDocument."Receiving Company VAT Reg. No."));
    end;

    /// <summary>
    /// Use it to check if receiving company name and address is in line with Company Information.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    procedure ValidateReceivingCompanyInfoByNameAndAddress(EDocument: Record "E-Document")
    var
        CompanyInfo: Record "Company Information";
        RecordMatchMgt: Codeunit "Record Match Mgt.";
        CompanyName: Text;
        CompanyAddr: Text;
        NameNearness: Integer;
        AddressNearness: Integer;
    begin
        CompanyInfo.Get();
        CompanyName := CompanyInfo.Name;
        CompanyAddr := CompanyInfo.Address;

        NameNearness := RecordMatchMgt.CalculateStringNearness(CompanyName, EDocument."Receiving Company Name", MatchThreshold(), NormalizingFactor());
        AddressNearness := RecordMatchMgt.CalculateStringNearness(CompanyAddr, EDocument."Receiving Company Address", MatchThreshold(), NormalizingFactor());

        if (EDocument."Receiving Company Name" <> '') and (NameNearness < RequiredNearness()) then
            EDocErrorHelper.LogErrorMessage(EDocument, CompanyInfo, CompanyInfo.FieldNo(Name), StrSubstNo(InvalidCompanyInfoNameErr, EDocument."Receiving Company Name"));

        if (EDocument."Receiving Company Address" <> '') and (AddressNearness < RequiredNearness()) then
            EDocErrorHelper.LogErrorMessage(EDocument, CompanyInfo, CompanyInfo.FieldNo(Address), StrSubstNo(InvalidCompanyInfoAddressErr, EDocument."Receiving Company Address"));
    end;

    /// <summary>
    /// Use it to apply invoice discount for the imported document.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempDocumentHeader">Imported document header.</param>
    /// <param name="DocumentHeader">Created document header.</param>
    procedure ApplyInvoiceDiscount(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var DocumentHeader: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        InvoiceDiscountAmount: Decimal;
        InvDiscBaseAmount: Decimal;
    begin
        case TempDocumentHeader.Number of
            Database::"Purchase Header":
                begin
                    DocumentHeader.SetTable(PurchaseHeader);
                    InvoiceDiscountAmount := TempDocumentHeader.Field(PurchaseHeader.FieldNo("Invoice Discount Value")).Value();
                    if InvoiceDiscountAmount = 0 then
                        exit;

                    if InvoiceDiscountAmount > 0 then begin
                        PurchLine.SetRange("Document No.", PurchaseHeader."No.");
                        PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
                        PurchLine.CalcVATAmountLines(0, PurchaseHeader, PurchLine, TempVATAmountLine);
                        InvDiscBaseAmount := TempVATAmountLine.GetTotalInvDiscBaseAmount(false, PurchaseHeader."Currency Code");

                        if PurchCalcDiscByType.InvoiceDiscIsAllowed(PurchaseHeader."Invoice Disc. Code") and (InvDiscBaseAmount <> 0) then
                            PurchCalcDiscByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, PurchaseHeader)
                        else
                            EDocErrorHelper.LogErrorMessage(EDocument, PurchaseHeader, PurchaseHeader.FieldNo("No."), StrSubstNo(UnableToApplyDiscountErr, InvoiceDiscountAmount));
                    end;
                end;
        end;
    end;

    /// <summary>
    /// Use it to verify compare imported document totals with created docuemnt totals.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempDocumentHeader">Imported document header.</param>
    /// <param name="DocumentHeader">Created document header.</param>
    procedure VerifyTotal(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var DocumentHeader: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
        TempTotalPurchaseLine: Record "Purchase Line" temporary;
        CurrentPurchaseLine: Record "Purchase Line";
        DocumentTotals: Codeunit "Document Totals";
        AmountIncludingVATFromFile: Decimal;
        VATAmount: Decimal;
    begin
        case TempDocumentHeader.Number of
            Database::"Purchase Header":
                begin
                    DocumentHeader.SetTable(PurchaseHeader);
                    AmountIncludingVATFromFile := TempDocumentHeader.Field(PurchaseHeader.FieldNo("Amount Including VAT")).Value();
                    if AmountIncludingVATFromFile = 0 then
                        exit;

                    VATAmount := 0;
                    TempTotalPurchaseLine.Init();
                    CurrentPurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                    CurrentPurchaseLine.SetRange("Document No.", PurchaseHeader."No.");

                    // calculate totals and compare them with values from the incoming document
                    if CurrentPurchaseLine.FindFirst() then begin
                        DocumentTotals.PurchaseCalculateTotalsWithInvoiceRounding(CurrentPurchaseLine, VATAmount, TempTotalPurchaseLine);

                        if AmountIncludingVATFromFile <> TempTotalPurchaseLine."Amount Including VAT" then
                            EDocErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(TotalsMismatchErr, TempTotalPurchaseLine."Amount Including VAT", AmountIncludingVATFromFile));
                    end;
                end;
        end;
    end;

    /// <summary>
    /// Use it to find a vendor by number, GLN or VAT registration number.
    /// </summary>
    /// <param name="VendorNoText">Vendor's number.</param>
    /// <param name="GLN">Vendor's GLN.</param>
    /// <param name="VATRegistrationNo">Vendor's VAT registration number.</param>
    /// <returns>Vendor number if exists or empty string.</returns>
    procedure FindVendor(VendorNoText: Code[20]; GLN: Code[13]; VATRegistrationNo: Text[20]): Code[20]
    var
        VendorNo: Code[20];
    begin
        VendorNo := FindVendorByNo(VendorNoText);
        if VendorNo <> '' then
            exit(VendorNo);

        VendorNo := FindVendorByGLN(GLN);
        if VendorNo <> '' then
            exit(VendorNo);

        VendorNo := FindVendorByVATRegistrationNo(VATRegistrationNo);
        if VendorNo <> '' then
            exit(VendorNo);
    end;

    /// <summary>
    /// Use it to find a vendor by Id.
    /// </summary>
    /// <param name="VendorIdText">Vendor's Id.</param>
    /// <returns>Vendor number if exists or empty string.</returns>
    procedure FindVendorById(VendorIdText: Text): Code[20]
    var
        Vendor: Record Vendor;
        VendorId: Guid;
    begin
        if VendorIdText = '' then
            exit('');

        if not Evaluate(VendorId, VendorIdText, 9) then
            exit('');

        if Vendor.GetBySystemId(VendorId) then
            exit(Vendor."No.");
    end;

    /// <summary>
    /// Use it to find a vendor by number.
    /// </summary>
    /// <param name="VendorNoText">Vendor's number.</param>
    /// <returns>Vendor number if exists or empty string.</returns>
    procedure FindVendorByNo(VendorNoText: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        if VendorNoText = '' then
            exit('');

        if Vendor.Get(VendorNoText) then
            exit(Vendor."No.");
    end;

    /// <summary>
    /// Use it to find a vendor by GLN.
    /// </summary>
    /// <param name="GLN">Vendor's GLN.</param>
    /// <returns>Vendor number if exists or empty string.</returns>
    procedure FindVendorByGLN(GLN: Code[13]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        if GLN = '' then
            exit('');

        Vendor.SetRange(GLN, GLN);
        if Vendor.FindFirst() then
            exit(Vendor."No.");
    end;

    /// <summary>
    /// Use it to find a vendor by VAT registration number.
    /// </summary>
    /// <param name="VATRegistrationNo">Vendor's VAT registration number.</param>
    /// <returns>Vendor number if exists or empty string.</returns>
    procedure FindVendorByVATRegistrationNo(VATRegistrationNo: Text[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        if VATRegistrationNo = '' then
            exit('');

        Vendor.SetLoadFields("VAT Registration No.", "Country/Region Code");
        Vendor.SetFilter("VAT Registration No.", StrSubstNo(VATRegistrationNoFilterTxt, CopyStr(VATRegistrationNo, 1, MaxStrLen(VATRegistrationNo))));
        if Vendor.FindSet() then
            repeat
                if ExtractVatRegNo(Vendor."VAT Registration No.", Vendor."Country/Region Code") = ExtractVatRegNo(VATRegistrationNo, Vendor."Country/Region Code") then
                    exit(Vendor."No.");
            until Vendor.Next() = 0;
    end;

    /// <summary>
    /// Use it to find a vendor by phone number.
    /// </summary>
    /// <param name="PhoneNo">Vendor's Phone number.</param>
    /// <returns>Vendor number if exists or empty string.</returns>
    procedure FindVendorByPhoneNo(PhoneNo: Text): Code[20]
    var
        Vendor: Record Vendor;
        RecordMatchMgt: Codeunit "Record Match Mgt.";
        PhoneNoNearness: Integer;
    begin
        if PhoneNo = '' then
            exit('');

        PhoneNo := DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '0123456789'));

        Vendor.SetCurrentKey(Blocked);
        Vendor.SetLoadFields("Phone No.");
        if Vendor.FindSet() then
            repeat
                PhoneNoNearness := RecordMatchMgt.CalculateStringNearness(PhoneNo, Vendor."Phone No.", MatchThreshold(), NormalizingFactor());
                if PhoneNoNearness >= RequiredNearness() then
                    exit(Vendor."No.");
            until Vendor.Next() = 0;
    end;

    /// <summary>
    /// Use it to find a vendor by name and address.
    /// </summary>
    /// <param name="VendorName">Vendor's name.</param>
    /// <param name="VendorAddress">Vendor's address.</param>
    /// <returns>Vendor number if exists or empty string.</returns>
    procedure FindVendorByNameAndAddress(VendorName: Text; VendorAddress: Text): Code[20]
    var
        Vendor: Record Vendor;
        RecordMatchMgt: Codeunit "Record Match Mgt.";
        NameNearness: Integer;
        AddressNearness: Integer;
    begin
        Vendor.SetCurrentKey(Blocked);
        Vendor.SetLoadFields(Name, Address);
        if Vendor.FindSet() then
            repeat
                NameNearness := RecordMatchMgt.CalculateStringNearness(VendorName, Vendor.Name, MatchThreshold(), NormalizingFactor());
                if VendorAddress = '' then
                    AddressNearness := RequiredNearness()
                else
                    AddressNearness := RecordMatchMgt.CalculateStringNearness(VendorAddress, Vendor.Address, MatchThreshold(), NormalizingFactor());
                if (NameNearness >= RequiredNearness()) and (AddressNearness >= RequiredNearness()) then
                    exit(Vendor."No.");
            until Vendor.Next() = 0;
    end;

    /// <summary>
    /// Use it to find a vendor by IBAN, vendor bank branch number and vendor bank account number.
    /// </summary>
    /// <param name="VendorIBAN">Vendor's IBAN.</param>
    /// <param name="VendorBankBranchNo">Vendor's bank account branch number.</param>
    /// <param name="VendorBankAccountNo">Vendor's bank account number.</param>
    /// <returns>Vendor number if exists or empty string.</returns>
    procedure FindVendorByBankAccount(VendorIBAN: Code[50]; VendorBankBranchNo: Text[20]; VendorBankAccountNo: Text[30]): Code[20]
    var
        VendorBankAccount: Record "Vendor Bank Account";
        VendorNo: Code[20];
    begin
        if VendorIBAN <> '' then begin
            VendorBankAccount.SetRange(IBAN, VendorIBAN);
            VendorNo := TryFindLeastBlockedVendorNoByVendorBankAcc(VendorBankAccount);
        end;

        if (VendorNo = '') and (VendorBankBranchNo <> '') and (VendorBankAccountNo <> '') then begin
            VendorBankAccount.Reset();
            VendorBankAccount.SetRange("Bank Branch No.", VendorBankBranchNo);
            VendorBankAccount.SetRange("Bank Account No.", VendorBankAccountNo);
            VendorNo := TryFindLeastBlockedVendorNoByVendorBankAcc(VendorBankAccount);
        end;

        if VendorNo <> '' then
            exit(VendorNo);
    end;

    /// <summary>
    /// Use it to get a vendor by number, or rise an error if vendor does not exist
    /// </summary>
    /// <param name="VendorNo">Vendor's number</param>
    /// <returns>Vendor record if exists or error.</returns>
    procedure GetVendor(var EDocument: Record "E-Document"; VendorNo: Code[20]) Vendor: Record Vendor
    begin
        if not Vendor.Get(VendorNo) then
            EDocErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(VendorNotFoundErr, EDocument."Bill-to/Pay-to Name"));
    end;

    /// <summary>
    /// Use it to process imported E-Document
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="CreateJnlLine">If processing should create journal line</param>
    procedure ProcessDocument(var EDocument: Record "E-Document"; CreateJnlLine: Boolean)
    var
    begin
        EDocumentImport.ProcessDocument(EDocument, CreateJnlLine);
    end;

    /// <summary>
    /// Use it to set hide dialogs when importing E-Document.
    /// </summary>
    /// <param name="Hide">Hide or show the dialog.</param>
    procedure SetHideDialogs(Hide: Boolean)
    begin
        EDocumentImport.SetHideDialogs(Hide);
    end;

    local procedure TryFindLeastBlockedVendorNoByVendorBankAcc(var VendorBankAccount: record "Vendor Bank Account"): Code[20]
    var
        Vendor: Record Vendor;
        NonBlockedVendorNo: Code[20];
        BlockedPaymentVendorNo: Code[20];
        BlockedAllVendorNo: Code[20];
    begin
        BlockedAllVendorNo := '';
        BlockedPaymentVendorNo := '';
        if VendorBankAccount.FindSet() then
            repeat
                if Vendor.Get(VendorBankAccount."Vendor No.") then begin
                    if Vendor.Blocked = "Vendor Blocked"::" " then
                        NonBlockedVendorNo := Vendor."No.";

                    if (Vendor.Blocked = "Vendor Blocked"::Payment) and (BlockedPaymentVendorNo = '') then
                        BlockedPaymentVendorNo := Vendor."No.";

                    if (Vendor.Blocked = "Vendor Blocked"::All) and (BlockedAllVendorNo = '') then
                        BlockedAllVendorNo := Vendor."No.";
                end;
            until (VendorBankAccount.Next() = 0) or (NonBlockedVendorNo <> '');

        if NonBlockedVendorNo <> '' then
            exit(NonBlockedVendorNo);
        if BlockedPaymentVendorNo <> '' then
            exit(BlockedPaymentVendorNo);
        if BlockedAllVendorNo <> '' then
            exit(BlockedAllVendorNo);

        exit('');
    end;

    internal procedure ProcessFieldNoValidate(RecRef: RecordRef; FieldNo: Integer; Value: Text[250])
    var
        FieldRef: FieldRef;
    begin
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Value(Value);
    end;

    internal procedure ProcessField(EDocument: Record "E-Document"; RecRef: RecordRef; FieldNo: Integer; Value: Text[250])
    var
        FieldRef: FieldRef;
    begin
        FieldRef := RecRef.Field(FieldNo);
        SetFieldValue(EDocument, FieldRef, Value);
    end;

    internal procedure GetCurrencyRoundingPrecision(CurrencyCode: Code[10]): Decimal
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        AmountRoundingPrecision: Decimal;
    begin
        GeneralLedgerSetup.Get();
        AmountRoundingPrecision := GeneralLedgerSetup."Amount Rounding Precision";
        if CurrencyCode <> '' then
            if Currency.Get(CurrencyCode) then
                AmountRoundingPrecision := Currency."Amount Rounding Precision";

        exit(AmountRoundingPrecision);
    end;

    local procedure FindAppropriateGLAccount(var EDocument: Record "E-Document"; var SourceRecRef: RecordRef; LineDescription: Text[250]; LineDirectUnitCost: Decimal): Code[20]
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        TextToAccountMapping: Record "Text-to-Account Mapping";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentTypeTxt: Text;
        DocumentType: Enum "Gen. Journal Document Type";
        DefaultGLAccount: Code[20];
        CountOfResult: Integer;
    begin
        case SourceRecRef.Number of
            Database::"Purchase Line":
                DocumentTypeTxt := SourceRecRef.Field(PurchaseLine.FieldNo("Document Type")).Value();
            Database::"Purchase Header":
                DocumentTypeTxt := SourceRecRef.Field(PurchaseHeader.FieldNo("Document Type")).Value();
        end;

        if not Evaluate(DocumentType, DocumentTypeTxt) then
            exit('');

        CountOfResult := TextToAccountMapping.SearchEnteriesInText(TextToAccountMapping, LineDescription, EDocument."Bill-to/Pay-to No.");
        if CountOfResult = 1 then
            exit(FindCorrectAccountFromMapping(TextToAccountMapping, LineDirectUnitCost, DocumentType));
        if CountOfResult > 1 then begin
            EDocErrorHelper.LogErrorMessage(EDocument, TextToAccountMapping, TextToAccountMapping.FieldNo("Mapping Text"), StrSubstNo(UnableToFindAppropriateAccountErr, LineDescription));
            exit('');
        end;

        if EDocument."Bill-to/Pay-to No." <> '' then begin
            CountOfResult := TextToAccountMapping.SearchEnteriesInText(TextToAccountMapping, LineDescription, '');
            if CountOfResult = 1 then
                exit(FindCorrectAccountFromMapping(TextToAccountMapping, LineDirectUnitCost, DocumentType));
            if CountOfResult > 1 then begin
                EDocErrorHelper.LogErrorMessage(EDocument, TextToAccountMapping, TextToAccountMapping.FieldNo("Mapping Text"), StrSubstNo(UnableToFindAppropriateAccountErr, LineDescription));
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
            EDocErrorHelper.LogErrorMessage(EDocument, TextToAccountMapping, TextToAccountMapping.FieldNo("Mapping Text"), StrSubstNo(UnableToFindAppropriateAccountErr, LineDescription));

        exit(DefaultGLAccount)
    end;

    local procedure FindMatchingItemReference(var ItemReference: Record "Item Reference"; ImportedUnitCode: Code[10]): Boolean
    begin
        if not ItemReference.FindFirst() then
            exit(false);

        ItemReference.SetRange("Unit of Measure", ImportedUnitCode);
        if ItemReference.FindSet() then
            repeat
                if ItemReference.HasValidUnitOfMeasure() then
                    exit(true);
            until ItemReference.Next() = 0;

        ItemReference.SetRange("Unit of Measure", '');
        if ItemReference.FindSet() then
            repeat
                if ItemReference.HasValidUnitOfMeasure() then
                    exit(true);
            until ItemReference.Next() = 0;

        ItemReference.SetRange("Unit of Measure");
        exit(ItemReference.FindFirst());
    end;

    local procedure ResolveUnitOfMeasureFromItemReference(var ItemReference: Record "Item Reference"; var EDocument: Record "E-Document"; var TempDocumentLine: RecordRef): Boolean
    var
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        UOMCodeFieldRef, LineNoFieldRef : FieldRef;
        ResolvedUnitCode: Code[10];
    begin
        case TempDocumentLine.Number of
            Database::"Purchase Line":
                begin
                    LineNoFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Line No."));
                    UOMCodeFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Unit of Measure Code"));
                end;
        end;

        ResolvedUnitCode := ItemReference."Unit of Measure";
        if ResolvedUnitCode = '' then begin
            Item.Get(ItemReference."Item No.");
            exit(ResolveUnitOfMeasureFromItem(Item, EDocument, TempDocumentLine));
        end;

        if not (Format(UOMCodeFieldRef.Value()) in ['', ResolvedUnitCode]) then begin
            EDocErrorHelper.LogErrorMessage(EDocument, ItemReference, ItemReference.FieldNo("Unit of Measure"), StrSubstNo(UOMConflictWithItemRefErr, UOMCodeFieldRef.Value(), LineNoFieldRef.Value(), UnitCodeToString(ResolvedUnitCode)));
            exit(false);
        end;

        if not ItemReference.HasValidUnitOfMeasure() then begin
            EDocErrorHelper.LogErrorMessage(EDocument, ItemReference, ItemReference.FieldNo("Unit of Measure"), StrSubstNo(UOMConflictItemRefWithItemErr, UnitCodeToString(ResolvedUnitCode)));
            exit(false);
        end;

        InsertOrUpdateUnitOfMeasureCode(TempDocumentLine, ResolvedUnitCode);
        exit(true);
    end;


    local procedure ResolveUnitOfMeasureFromItem(var Item: Record Item; var EDocument: Record "E-Document"; var TempDocumentLine: RecordRef): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        UOMCodeFieldRef, LineNoFieldRef : FieldRef;
        ResolvedUnitCode: Code[10];
    begin
        case TempDocumentLine.Number of
            Database::"Purchase Line":
                begin
                    LineNoFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Line No."));
                    UOMCodeFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Unit of Measure Code"));
                    ResolvedUnitCode := Item."Purch. Unit of Measure";
                end;
        end;

        if ResolvedUnitCode = '' then
            ResolvedUnitCode := Item."Base Unit of Measure";

        if not (Format(UOMCodeFieldRef.Value()) in ['', ResolvedUnitCode]) then begin
            EDocErrorHelper.LogErrorMessage(EDocument, Item, Item.FieldNo("Base Unit of Measure"), StrSubstNo(UOMConflictWithItemErr, UOMCodeFieldRef.Value(), LineNoFieldRef.Value, UnitCodeToString(ResolvedUnitCode)));
            exit(false);
        end;

        InsertOrUpdateUnitOfMeasureCode(TempDocumentLine, ResolvedUnitCode);
        exit(true);
    end;

    local procedure InsertOrUpdateUnitOfMeasureCode(var TempDocumentLine: RecordRef; UnitCode: Code[10])
    var
        PurchaseLine: Record "Purchase Line";
        UOMCodeFieldRef: FieldRef;
    begin
        case TempDocumentLine.Number of
            Database::"Purchase Line":
                UOMCodeFieldRef := TempDocumentLine.Field(PurchaseLine.FieldNo("Unit of Measure Code"));
        end;

        UOMCodeFieldRef.Value(UnitCode);
    end;

    local procedure UnitCodeToString(UnitCode: Code[10]): Text
    begin
        if UnitCode <> '' then
            exit(UnitCode);
        exit(NotSpecifiedUnitOfMeasureTxt);
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

    local procedure ExtractVatRegNo(VatRegNo: Text; CountryRegionCode: Text): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        if CountryRegionCode = '' then begin
            CompanyInformation.Get();
            CountryRegionCode := CompanyInformation."Country/Region Code";
        end;
        VatRegNo := UpperCase(VatRegNo);
        VatRegNo := DelChr(VatRegNo, '=', DelChr(VatRegNo, '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'));
        if StrPos(VatRegNo, UpperCase(CountryRegionCode)) = 1 then
            VatRegNo := DelStr(VatRegNo, 1, StrLen(CountryRegionCode));
        exit(VatRegNo);
    end;

    local procedure SetFieldValue(EDocument: Record "E-Document"; var FieldRef: FieldRef; Value: Text[250])
    var
        ConfigValidateManagement: Codeunit "Config. Validate Management";
        ErrorText: Text;
    begin
        TruncateValueToFieldLength(FieldRef, Value);
        ErrorText := ConfigValidateManagement.EvaluateValueWithValidate(FieldRef, Value, false);
        if ErrorText <> '' then
            EDocErrorHelper.LogSimpleErrorMessage(EDocument, ErrorText);
    end;

    local procedure TruncateValueToFieldLength(FieldRef: FieldRef; var Value: Text[250])
    begin
        if FieldRef.Type in [FieldType::Code, FieldType::Text] then
            Value := CopyStr(Value, 1, FieldRef.Length);
    end;

    local procedure NormalizingFactor(): Integer
    begin
        exit(100)
    end;

    local procedure MatchThreshold(): Integer
    begin
        exit(4)
    end;

    local procedure RequiredNearness(): Integer
    begin
        exit(95)
    end;

    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentImport: Codeunit "E-Doc. Import";
        UOMNotFoundErr: Label 'Cannot find unit of measure %1. Make sure that the unit of measure exists.', Comment = '%1 International Standard Code or Code or Description for Unit of Measure';
        UOMConflictWithItemRefErr: Label 'Unit of measure %1 on electronic document line %2 does not match unit of measure %3 in the item reference.  Make sure that a card for the item with the specified unit of measure exists with the corresponding item reference.', Comment = '%1 imported unit code, %2 document line number (e.g. 2), %3 Item Reference unit code';
        UOMConflictItemRefWithItemErr: Label 'Unit of measure %1 in the item reference is not in the list of units of measure for the corresponding item. Make sure that a unit of measure of item reference is in the list of units of measure for the corresponding item.', Comment = '%1 item reference unit code';
        UOMConflictWithItemErr: Label 'Unit of measure %1 on electronic document line %2 does not match purchase unit of measure %3 on the item card.  Make sure that a card for the item with the specified unit of measure exists with the corresponding item reference.', Comment = '%1 imported unit code, %2 document line number (e.g. 2), %3 Item unit code';
        UnableToFindAppropriateAccountErr: Label 'Cannot find an appropriate G/L account for the line with description ''%1''. Choose the Map Text to Account button, and then map the core part of ''%1'' to the relevant G/L account.', Comment = '%1 - arbitrary text';
        ItemNotFoundErr: Label 'Cannot find item ''%1'' based on the vendor %2 item number %3 or GTIN %4 on the electronic document. Make sure that a card for the item exists with the corresponding item reference or GTIN.', Comment = '%1 Vendor item name (e.g. Bicycle - may be another language),%2 Vendor''''s number,%3 Vendor''''s item number, %4 item bar code (GTIN)';
        ItemNotFoundByGTINErr: Label 'Cannot find item ''%1'' based on GTIN %2 on the electronic document. Make sure that a card for the item exists with the corresponding GTIN.', Comment = '%1 Vendor item name (e.g. Bicycle - may be another language),%2 item bar code (GTIN)';
        ItemNotFoundByVendorItemNoErr: Label 'Cannot find item ''%1'' based on the vendor %2 item number %3 on the electronic document. Make sure that a card for the item exists with the corresponding item reference.', Comment = '%1 Vendor item name (e.g. Bicycle - may be another language),%2 Vendor''''s number,%3 Vendor''''s item number';
        MissingCompanyInfoSetupErr: Label 'You must fill either GLN or VAT Registration No. in the Company Information window.';
        InvalidCompanyInfoGLNErr: Label 'The customer''s GLN %1 on the electronic document does not match the GLN in the Company Information window.', Comment = '%1 = GLN (13 digit number)';
        InvalidCompanyInfoVATRegNoErr: Label 'The customer''s VAT registration number %1 on the electronic document does not match the VAT Registration No. in the Company Information window.', Comment = '%1 VAT Registration Number (format could be AB###### or ###### or AB##-##-###)';
        InvalidCompanyInfoNameErr: Label 'The customer name ''%1'' on the electronic document does not match the name in the Company Information window.', Comment = '%1 = customer name';
        InvalidCompanyInfoAddressErr: Label 'The customer''s address ''%1'' on the electronic document does not match the Address in the Company Information window.', Comment = '%1 = customer address, street name';
        UnableToApplyDiscountErr: Label 'The invoice discount of %1 cannot be applied. Invoice discount must be allowed on at least one invoice line and invoice total must not be 0.', Comment = '%1 - a decimal number';
        TotalsMismatchErr: Label 'The total amount %1 on the created document is different than the total amount %2 in the electronic document.', Comment = '%1 total amount, %2 expected total amount';
        VendorNotFoundErr: Label 'Cannot find vendor ''%1'' based on the vendor''s name, address or VAT registration number on the electronic document. Make sure that a card for the vendor exists with the corresponding name, address or VAT Registration No.', Comment = '%1 Vendor name (e.g. London Postmaster)';
        NotSpecifiedUnitOfMeasureTxt: Label '<NONE>';
        VATRegistrationNoFilterTxt: Label '*%1', Comment = '%1 - Filter value', Locked = true;
}
