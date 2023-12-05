// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Service.History;
using System.Globalization;
using System.Utilities;

table 11510 "Swiss QR-Bill Buffer"
{
    Caption = 'QR-Bill Buffer';
    DataClassification = CustomerContent;
    Permissions = TableData "Sales Invoice Header" = rm,
                  TableData "Cust. Ledger Entry" = rm;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; IBAN; Code[50])
        {
            Caption = 'IBAN';
        }
        field(3; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(4; Currency; Code[10])
        {
            Caption = 'Currency';
            TableRelation = Currency where("ISO Code" = filter('CHF' | 'EUR'));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                Currency := SwissQRBillMgt.GetCurrency(Currency);
            end;
        }
        field(5; "Payment Reference Type"; Enum "Swiss QR-Bill Payment Reference Type")
        {
            Caption = 'Reference Type';

            trigger OnValidate()
            begin
                case "Payment Reference Type" of
                    "Payment Reference Type"::"Creditor Reference (ISO 11649)":
                        TestField("IBAN Type", "IBAN Type"::IBAN);
                    "Payment Reference Type"::"QR Reference":
                        TestField("IBAN Type", "IBAN Type"::"QR-IBAN");
                end;
                if not "Source Record Printed" then
                    Validate("Payment Reference", GetReferenceNo(false));
            end;
        }
        field(6; "Payment Reference"; Code[50])
        {
            Caption = 'Payment Reference';
            Editable = false;

            trigger OnValidate()
            begin
                "Payment Reference" := SwissQRBillMgt.FormatPaymentReference("Payment Reference Type", "Payment Reference");
            end;
        }
        field(7; "Unstructured Message"; Text[140])
        {
            Caption = 'Unstructured Message';
        }
        field(8; "Billing Information"; Text[140])
        {
            Caption = 'Billing Information';
        }
        field(9; "Alt. Procedure Name 1"; Text[10])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                if "Alt. Procedure Name 1" = '' then
                    "Alt. Procedure Value 1" := '';
            end;
        }
        field(10; "Alt. Procedure Value 1"; Text[100])
        {
            Caption = 'Value';
        }
        field(11; "Alt. Procedure Name 2"; Text[10])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                if "Alt. Procedure Name 2" = '' then
                    "Alt. Procedure Value 2" := '';
            end;
        }
        field(12; "Alt. Procedure Value 2"; Text[100])
        {
            Caption = 'Value';
        }
        field(14; "IBAN Type"; enum "Swiss QR-Bill IBAN Type")
        {
            Caption = 'IBAN Type';

            trigger OnValidate()
            begin
                ValidateIBAN();
                case "IBAN Type" of
                    "IBAN Type"::IBAN:
                        Validate("Payment Reference Type", "Payment Reference Type"::"Creditor Reference (ISO 11649)");
                    "IBAN Type"::"QR-IBAN":
                        Validate("Payment Reference Type", "Payment Reference Type"::"QR Reference");
                end;
            end;
        }
        field(15; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language where("Windows Language ID" = filter(1033 | 2055 | 4108 | 2064));
        }
        field(16; "Format Region"; Text[80])
        {
            Caption = 'Format Region';
            TableRelation = "Language Selection"."Language Tag";
        }
        field(20; "Creditor Address Type"; Enum "Swiss QR-Bill Address Type")
        {
            Caption = 'Address Type';
        }
        field(21; "Creditor Name"; Text[70])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                if "Creditor Name" = '' then begin
                    "Creditor Street Or AddrLine1" := '';
                    "Creditor BuildNo Or AddrLine2" := '';
                    "Creditor Postal Code" := '';
                    "Creditor City" := '';
                    "Creditor Country" := '';
                end;
            end;
        }
        field(22; "Creditor Street Or AddrLine1"; Text[70])
        {
            Caption = 'Street Or Address Line 1';

            trigger OnValidate()
            begin
                TestField("Creditor Name");
            end;
        }
        field(23; "Creditor BuildNo Or AddrLine2"; Text[70])
        {
            Caption = 'Building Number Or Address Line 2';

            trigger OnValidate()
            begin
                TestField("Creditor Name");
            end;
        }
        field(24; "Creditor Postal Code"; Code[16])
        {
            Caption = 'Postal Code';
            TableRelation = if ("Creditor Country" = const('')) "Post Code"
            else
            "Post Code" where("Country/Region Code" = field("Creditor Country"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                TestField("Creditor Name");
            end;
        }
        field(25; "Creditor City"; Text[30])
        {
            Caption = 'City';
            TableRelation = if ("Creditor Country" = const('')) "Post Code".City
            else
            "Post Code".City where("Country/Region Code" = field("Creditor Country"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                TestField("Creditor Name");
            end;
        }
        field(26; "Creditor Country"; Code[2])
        {
            Caption = 'Country';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                TestField("Creditor Name");
            end;
        }
        field(30; "UCreditor Address Type"; Enum "Swiss QR-Bill Address Type")
        {
            Caption = 'Address Type';
        }
        field(31; "UCreditor Name"; Text[70])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                if "UCreditor Name" = '' then begin
                    "UCreditor Street Or AddrLine1" := '';
                    "UCreditor BuildNo Or AddrLine2" := '';
                    "UCreditor Postal Code" := '';
                    "UCreditor City" := '';
                    "UCreditor Country" := '';
                end;
            end;
        }
        field(32; "UCreditor Street Or AddrLine1"; Text[70])
        {
            Caption = 'Street Or Address Line 1';

            trigger OnValidate()
            begin
                TestField("UCreditor Name");
            end;
        }
        field(33; "UCreditor BuildNo Or AddrLine2"; Text[70])
        {
            Caption = 'Building Number Or Address Line 2';

            trigger OnValidate()
            begin
                TestField("UCreditor Name");
            end;
        }
        field(34; "UCreditor Postal Code"; Code[16])
        {
            Caption = 'Postal Code';
            TableRelation = if ("UCreditor Country" = const('')) "Post Code"
            else
            "Post Code" where("Country/Region Code" = field("UCreditor Country"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                TestField("UCreditor Name");
            end;
        }
        field(35; "UCreditor City"; Text[30])
        {
            Caption = 'City';
            TableRelation = if ("UCreditor Country" = const('')) "Post Code".City
            else
            "Post Code".City where("Country/Region Code" = field("UCreditor Country"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                TestField("UCreditor Name");
            end;
        }
        field(36; "UCreditor Country"; Code[2])
        {
            Caption = 'Country';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                TestField("UCreditor Name");
            end;
        }
        field(40; "UDebtor Address Type"; Enum "Swiss QR-Bill Address Type")
        {
            Caption = 'Address Type';
        }
        field(41; "UDebtor Name"; Text[70])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                if "UDebtor Name" = '' then begin
                    "UDebtor Street Or AddrLine1" := '';
                    "UDebtor BuildNo Or AddrLine2" := '';
                    "UDebtor Postal Code" := '';
                    "UDebtor City" := '';
                    "UDebtor Country" := '';
                end;
            end;
        }
        field(42; "UDebtor Street Or AddrLine1"; Text[70])
        {
            Caption = 'Street Or Address Line 1';

            trigger OnValidate()
            begin
                TestField("UDebtor Name");
            end;
        }
        field(43; "UDebtor BuildNo Or AddrLine2"; Text[70])
        {
            Caption = 'Building Number Or Address Line 2';

            trigger OnValidate()
            begin
                TestField("UDebtor Name");
            end;
        }
        field(44; "UDebtor Postal Code"; Code[16])
        {
            Caption = 'Postal Code';
            TableRelation = if ("UDebtor Country" = const('')) "Post Code"
            else
            "Post Code" where("Country/Region Code" = field("UDebtor Country"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                TestField("UDebtor Name");
            end;
        }
        field(45; "UDebtor City"; Text[30])
        {
            Caption = 'City';
            TableRelation = if ("UDebtor Country" = const('')) "Post Code".City
            else
            "Post Code".City where("Country/Region Code" = field("UDebtor Country"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                TestField("UDebtor Name");
            end;
        }
        field(46; "UDebtor Country"; Code[2])
        {
            Caption = 'Country';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                TestField("UDebtor Name");
            end;
        }
        field(100; "QR-Code Image"; Media)
        {
            Caption = 'QR-Code Image';
        }
        field(102; "File Name"; Text[250])
        {
            Caption = 'QR-Bill PDF File Name';
        }
        field(104; "QR-Bill Layout"; Code[20])
        {
            Caption = 'QR-Bill Layout';
            TableRelation = "Swiss QR-Bill Layout";

            trigger OnValidate()
            begin
                LoadLayout("QR-Bill Layout");
            end;
        }
        field(105; "Source Record Printed"; Boolean)
        {
            Caption = 'Source Record Printed';
        }
        field(106; "Customer Ledger Entry No."; Integer)
        {
            Caption = 'Customer Ledger Entry';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        SourceDocRecRef: RecordRef;

    procedure AddBufferRecord(SourceSwissQRBillBuffer: Record "Swiss QR-Bill Buffer")
    begin
        "Entry No." += 1;
        TransferFields(SourceSwissQRBillBuffer, false);
        Insert();
    end;

    procedure InitBuffer(QRBillLayoutCode: Code[20])
    var
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
    begin
        Init();
        Currency := SwissQRBillMgt.GetCurrency('');
        SwissQRBillSetup.Get();
        "Creditor Address Type" := SwissQRBillSetup."Address Type";
        "UCreditor Address Type" := SwissQRBillSetup."Address Type";
        "UDebtor Address Type" := SwissQRBillSetup."Address Type";
        LoadLayout(QRBillLayoutCode);
        "File Name" := 'QR-Bill.pdf';
        "Language Code" := SwissQRBillMgt.GetLanguageCodeENU();
        "Format Region" := '';
    end;

    internal procedure SetQRCodeImage(TempBlob: Codeunit "Temp Blob")
    var
        InStream: InStream;
    begin
        Clear("QR-Code Image");
        TempBlob.CreateInStream(InStream);
        "QR-Code Image".ImportStream(InStream, 'Swiss QR-Code Image');
    end;

    internal procedure SetCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        TempCustomer: Record Customer temporary;
    begin
        CompanyInformation.Get();
        TempCustomer.Name := CompanyInformation.Name;
        TempCustomer.Address := CompanyInformation.Address;
        TempCustomer."Address 2" := CompanyInformation."Address 2";
        TempCustomer."Post Code" := CompanyInformation."Post Code";
        TempCustomer.City := CompanyInformation.City;
        TempCustomer."Country/Region Code" := CompanyInformation."Country/Region Code";
        SetCreditorInfo(TempCustomer);
    end;

    local procedure ValidateIBAN()
    var
        CompanyInformation: Record "Company Information";
    begin
        OnBeforeValidateIBAN(IBAN);
        CompanyInformation.Get();
        if "IBAN Type" = "IBAN Type"::"QR-IBAN" then begin
            CompanyInformation.TestField("Swiss QR-Bill IBAN");
            IBAN := SwissQRBillMgt.FormatIBAN(CompanyInformation."Swiss QR-Bill IBAN");
        end else begin
            CompanyInformation.TestField(IBAN);
            IBAN := SwissQRBillMgt.FormatIBAN(CompanyInformation.IBAN);
        end;
        OnAfterValidateIBAN(IBAN);
    end;

    local procedure ValidateBankAccountIBAN(BankAccountNo: Code[20])
    var
        BankAccount: Record "Bank Account";
    begin
        if BankAccount.Get(BankAccountNo) then
            if "IBAN Type" = "IBAN Type"::"QR-IBAN" then begin
                BankAccount.TestField("Swiss QR-Bill IBAN");
                IBAN := SwissQRBillMgt.FormatIBAN(BankAccount."Swiss QR-Bill IBAN");
            end else begin
                BankAccount.TestField(IBAN);
                IBAN := SwissQRBillMgt.FormatIBAN(BankAccount.IBAN);
            end;
    end;

    internal procedure SetCreditorInfo(Customer: Record Customer)
    begin
        "Creditor Name" := CopyStr(Customer.Name, 1, MaxStrLen("Creditor Name"));
        "Creditor Street Or AddrLine1" := CopyStr(Customer.Address, 1, MaxStrLen("Creditor Street Or AddrLine1"));
        "Creditor BuildNo Or AddrLine2" := CopyStr(Customer."Address 2", 1, MaxStrLen("Creditor BuildNo Or AddrLine2"));
        "Creditor Postal Code" := CopyStr(Customer."Post Code", 1, MaxStrLen("Creditor Postal Code"));
        "Creditor City" := Customer.City;
        "Creditor Country" := CopyStr(Customer."Country/Region Code", 1, MaxStrLen("Creditor Country"));
    end;

    internal procedure SetUltimateCreditorInfo(Customer: Record Customer)
    begin
        "UCreditor Name" := CopyStr(Customer.Name, 1, MaxStrLen("Creditor Name"));
        "UCreditor Street Or AddrLine1" := CopyStr(Customer.Address, 1, MaxStrLen("Creditor Street Or AddrLine1"));
        "UCreditor BuildNo Or AddrLine2" := CopyStr(Customer."Address 2", 1, MaxStrLen("Creditor BuildNo Or AddrLine2"));
        "UCreditor Postal Code" := CopyStr(Customer."Post Code", 1, MaxStrLen("Creditor Postal Code"));
        "UCreditor City" := Customer.City;
        "UCreditor Country" := CopyStr(Customer."Country/Region Code", 1, MaxStrLen("Creditor Country"));
    end;

    internal procedure SetUltimateDebitorInfo(Customer: Record Customer)
    begin
        "UDebtor Name" := CopyStr(Customer.Name, 1, MaxStrLen("Creditor Name"));
        "UDebtor Street Or AddrLine1" := CopyStr(Customer.Address, 1, MaxStrLen("Creditor Street Or AddrLine1"));
        "UDebtor BuildNo Or AddrLine2" := CopyStr(Customer."Address 2", 1, MaxStrLen("Creditor BuildNo Or AddrLine2"));
        "UDebtor Postal Code" := CopyStr(Customer."Post Code", 1, MaxStrLen("Creditor Postal Code"));
        "UDebtor City" := Customer.City;
        "UDebtor Country" := CopyStr(Customer."Country/Region Code", 1, MaxStrLen("Creditor Country"));
        "Format Region" := Customer."Format Region";

        SetLanguageCode(Customer."Language Code");
    end;

    internal procedure SetUltimateDebitorInfo(DocumentRecRef: RecordRef)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        BillToName: Text[100];
        BillToAddress: Text[100];
        BillToAddress2: Text[50];
        BillToPostCode: Code[20];
        BillToCity: Text[30];
        BillToCountryRegion: Code[10];
        LanguageCode: Code[10];
        FormatRegion: Text[80];
    begin
        case DocumentRecRef.Number of
            Database::"Sales Invoice Header":
                begin
                    DocumentRecRef.SetTable(SalesInvoiceHeader);
                    BillToName := SalesInvoiceHeader."Bill-to Name";
                    BillToAddress := SalesInvoiceHeader."Bill-to Address";
                    BillToAddress2 := SalesInvoiceHeader."Bill-to Address 2";
                    BillToPostCode := SalesInvoiceHeader."Bill-to Post Code";
                    BillToCity := SalesInvoiceHeader."Bill-to City";
                    BillToCountryRegion := SalesInvoiceHeader."Bill-to Country/Region Code";
                    LanguageCode := SalesInvoiceHeader."Language Code";
                    FormatRegion := SalesInvoiceHeader."Format Region";
                end;
            Database::"Service Invoice Header":
                begin
                    DocumentRecRef.SetTable(ServiceInvoiceHeader);
                    BillToName := ServiceInvoiceHeader."Bill-to Name";
                    BillToAddress := ServiceInvoiceHeader."Bill-to Address";
                    BillToAddress2 := ServiceInvoiceHeader."Bill-to Address 2";
                    BillToPostCode := ServiceInvoiceHeader."Bill-to Post Code";
                    BillToCity := ServiceInvoiceHeader."Bill-to City";
                    BillToCountryRegion := ServiceInvoiceHeader."Bill-to Country/Region Code";
                    LanguageCode := ServiceInvoiceHeader."Language Code";
                    FormatRegion := ServiceInvoiceHeader."Format Region";
                end;
        end;
        "UDebtor Name" := CopyStr(BillToName, 1, MaxStrLen("Creditor Name"));
        "UDebtor Street Or AddrLine1" := CopyStr(BillToAddress, 1, MaxStrLen("Creditor Street Or AddrLine1"));
        "UDebtor BuildNo Or AddrLine2" := CopyStr(BillToAddress2, 1, MaxStrLen("Creditor BuildNo Or AddrLine2"));
        "UDebtor Postal Code" := CopyStr(BillToPostCode, 1, MaxStrLen("Creditor Postal Code"));
        "UDebtor City" := BillToCity;
        "UDebtor Country" := CopyStr(BillToCountryRegion, 1, MaxStrLen("Creditor Country"));
        "Format Region" := FormatRegion;

        SetLanguageCode(LanguageCode);
    end;

    procedure GetCreditorInfo(var Customer: Record Customer): Boolean
    begin
        if "Creditor Name" = '' then
            exit(false);

        Customer.Name := "Creditor Name";
        Customer.Address := "Creditor Street Or AddrLine1";
        Customer."Address 2" := CopyStr("Creditor BuildNo Or AddrLine2", 1, MaxStrLen(Customer."Address 2"));
        Customer."Post Code" := "Creditor Postal Code";
        Customer.City := "Creditor City";
        Customer."Country/Region Code" := "Creditor Country";
        exit(true);
    end;

    internal procedure GetUltimateCreditorInfo(var Customer: Record Customer): Boolean
    begin
        if "UCreditor Name" = '' then
            exit(false);

        Customer.Name := "UCreditor Name";
        Customer.Address := "UCreditor Street Or AddrLine1";
        Customer."Address 2" := CopyStr("UCreditor BuildNo Or AddrLine2", 1, MaxStrLen(Customer."Address 2"));
        Customer."Post Code" := "UCreditor Postal Code";
        Customer.City := "UCreditor City";
        Customer."Country/Region Code" := "UCreditor Country";
        exit(true);
    end;

    procedure GetUltimateDebitorInfo(var Customer: Record Customer): Boolean
    begin
        if "UDebtor Name" = '' then
            exit(false);

        Customer.Name := "UDebtor Name";
        Customer.Address := "UDebtor Street Or AddrLine1";
        Customer."Address 2" := CopyStr("UDebtor BuildNo Or AddrLine2", 1, MaxStrLen(Customer."Address 2"));
        Customer."Post Code" := "UDebtor Postal Code";
        Customer.City := "UDebtor City";
        Customer."Country/Region Code" := "UDebtor Country";
        exit(true);
    end;

    local procedure SetLanguageCode(LanguageCode: Code[10])
    var
        Language: Codeunit Language;
        LanguageId: Integer;
    begin
        LanguageId := Language.GetLanguageId(LanguageCode);
        case true of
            SwissQRBillMgt.GetLanguagesIdDEU().Contains(Format(LanguageId)):
                "Language Code" := Language.GetLanguageCode(SwissQRBillMgt.GetLanguageIdDEU());
            SwissQRBillMgt.GetLanguagesIdFRA().Contains(Format(LanguageId)):
                "Language Code" := Language.GetLanguageCode(SwissQRBillMgt.GetLanguageIdFRA());
            SwissQRBillMgt.GetLanguagesIdITA().Contains(Format(LanguageId)):
                "Language Code" := Language.GetLanguageCode(SwissQRBillMgt.GetLanguageIdITA());
            else
                "Language Code" := Language.GetLanguageCode(SwissQRBillMgt.GetLanguageIdENU());
        end;
    end;

    internal procedure LoadLayout(QRBillLayoutCode: Code[20])
    var
        SwissQRBillLayout: Record "Swiss QR-Bill Layout";
        OldLayoutCode: Code[20];
    begin
        OldLayoutCode := "QR-Bill Layout";

        if QRBillLayoutCode <> '' then
            "QR-Bill Layout" := QRBillLayoutCode
        else
            if "QR-Bill Layout" = '' then
                "QR-Bill Layout" := GetDefaultLayoutCode();
        SwissQRBillLayout.Get("QR-Bill Layout");

        if (OldLayoutCode <> "QR-Bill Layout") or (xRec."QR-Bill Layout" <> "QR-Bill Layout") then begin
            if not "Source Record Printed" then begin
                "IBAN Type" := SwissQRBillLayout."IBAN Type";
                Validate("Payment Reference Type", SwissQRBillLayout."Payment Reference Type");
            end;
            ValidateIBAN();
            SetCompanyInformation();
            LoadAdditionalInformation(SwissQRBillLayout);
        end;
    end;

    local procedure GetDefaultLayoutCode(): Code[20]
    var
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
    begin
        SwissQRBillSetup.Get();
        SwissQRBillSetup.TestField("Default Layout");
        exit(SwissQRBillSetup."Default Layout");
    end;

    procedure CheckLimitForUnstrAndBillInfoText()
    var
        UnstrMessageLen: Integer;
        BillInfoTextLen: Integer;
        MaxStrLength: Integer;
    begin
        UnstrMessageLen := StrLen("Unstructured Message");
        BillInfoTextLen := StrLen("Billing Information");
        MaxStrLength := MaxStrLen("Billing Information");

        if UnstrMessageLen + BillInfoTextLen > MaxStrLength then
            if MaxStrLength - BillInfoTextLen - 3 > 0 then
                "Unstructured Message" :=
                    CopyStr(
                        CopyStr("Unstructured Message", 1, MaxStrLength - BillInfoTextLen - 3) + '...',
                        1, MaxStrLen("Unstructured Message"))
            else
                "Unstructured Message" := '';
    end;

    internal procedure InitSourceRecord(RecRef: RecordRef)
    begin
        SourceDocRecRef := RecRef;
    end;

    procedure SetSourceRecord(CustomerLedgerEntryNo: Integer)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentMethod: Record "Payment Method";
        SwissQRBillLayout: Record "Swiss QR-Bill Layout";
        Customer: Record Customer;
    begin
        CustLedgerEntry.Get(CustomerLedgerEntryNo);
        "Customer Ledger Entry No." := CustLedgerEntry."Entry No.";
        "Source Record Printed" := CustLedgerEntry."Payment Reference" <> '';
        CustLedgerEntry.CalcFields(Amount);
        Amount := CustLedgerEntry.Amount;
        Currency := SwissQRBillMgt.GetCurrency(CustLedgerEntry."Currency Code");
        Validate("Payment Reference", CustLedgerEntry."Payment Reference");
        if "Payment Reference" <> '' then
            if StrLen(DelChr("Payment Reference")) = 27 then
                Validate("IBAN Type", "IBAN Type"::"QR-IBAN")
            else
                Validate("IBAN Type", "IBAN Type"::"IBAN");

        if CustLedgerEntry."Payment Method Code" <> '' then
            if PaymentMethod.Get(CustLedgerEntry."Payment Method Code") then;

        LoadLayout(PaymentMethod."Swiss QR-Bill Layout");
        SwissQRBillLayout.Get("QR-Bill Layout");

        if SourceDocRecRef.Number in [Database::"Sales Invoice Header", Database::"Service Invoice Header"] then
            SetUltimateDebitorInfo(SourceDocRecRef)
        else
            if CustLedgerEntry."Customer No." <> '' then
                if Customer.Get(CustLedgerEntry."Customer No.") then
                    SetUltimateDebitorInfo(Customer);

        LoadSourceRecordBillingInformation(SwissQRBillLayout);
        if PaymentMethod."Swiss QR-Bill Bank Account No." <> '' then
            ValidateBankAccountIBAN(PaymentMethod."Swiss QR-Bill Bank Account No.");
    end;

    local procedure LoadAdditionalInformation(SwissQRBillLayout: Record "Swiss QR-Bill Layout")
    begin
        "Billing Information" := '';
        "Unstructured Message" := SwissQRBillLayout."Unstr. Message";
        LoadSourceRecordBillingInformation(SwissQRBillLayout);
        "Alt. Procedure Name 1" := SwissQRBillLayout."Alt. Procedure Name 1";
        "Alt. Procedure Value 1" := SwissQRBillLayout."Alt. Procedure Value 1";
        "Alt. Procedure Name 2" := SwissQRBillLayout."Alt. Procedure Name 2";
        "Alt. Procedure Value 2" := SwissQRBillLayout."Alt. Procedure Value 2";
    end;

    local procedure LoadSourceRecordBillingInformation(SwissQRBillLayout: Record "Swiss QR-Bill Layout")
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
    begin
        if "Customer Ledger Entry No." <> 0 then
            if SwissQRBillLayout."Billing Information" <> '' then
                if SwissQRBillBillingInfo.Get(SwissQRBillLayout."Billing Information") then
                    "Billing Information" := SwissQRBillBillingInfo.GetBillingInformation("Customer Ledger Entry No.");
    end;

    procedure PrepareForPrint()
    begin
        CheckAppendFileNameExt();
        if not "Source Record Printed" then begin
            Validate("Payment Reference", GetReferenceNo(true));
            UpdateSourceRecordReferenceNo();
        end;
        Modify();
    end;

    local procedure CheckAppendFileNameExt()
    begin
        if StrLen("File Name") > 3 then
            if CopyStr("File Name", StrLen("File Name") - 3, 4) <> '.pdf' then
                "File Name" += '.pdf';
    end;

    local procedure UpdateSourceRecordReferenceNo()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        if "Customer Ledger Entry No." <> 0 then
            if CustLedgerEntry.Get("Customer Ledger Entry No.") then begin
                if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice then
                    case true of
                        SalesInvoiceHeader.Get(CustLedgerEntry."Document No."):
                            begin
                                SalesInvoiceHeader."Payment Reference" := DelChr("Payment Reference");
                                SalesInvoiceHeader.Modify();
                            end;
                        SwissQRBillMgt.FindServiceInvoiceFromLedgerEntry(ServiceInvoiceHeader, CustLedgerEntry):
                            begin
                                ServiceInvoiceHeader."Payment Reference" := DelChr("Payment Reference");
                                ServiceInvoiceHeader.Modify();
                            end;
                    end;
                CustLedgerEntry."Payment Reference" :=
                    CopyStr(DelChr("Payment Reference"), 1, MaxStrLen(CustLedgerEntry."Payment Reference"));
                CustLedgerEntry.Modify();
                "Source Record Printed" := true;
            end;
    end;

    local procedure GetReferenceNo(UpdateLastUsed: Boolean) Result: Code[50]
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetReferenceNo(Rec, UpdateLastUsed, Result, IsHandled);
        if IsHandled then
            exit(Result);

        Result := SwissQRBillMgt.GetNextReferenceNo("Payment Reference Type", UpdateLastUsed);
    end;

    internal procedure EnableEditingOfAlreadyPrinted()
    begin
        "Source Record Printed" := false;
        Validate("Payment Reference", GetReferenceNo(false));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateIBAN(var IBAN: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetReferenceNo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"; UpdateLastUsed: Boolean; var Result: Code[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateIBAN(var IBAN: Code[50])
    begin
    end;
}
