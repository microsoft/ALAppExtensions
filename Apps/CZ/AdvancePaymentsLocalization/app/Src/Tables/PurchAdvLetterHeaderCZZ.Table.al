// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.BankAccount;
#if not CLEAN25
using Microsoft.Bank.Documents;
#endif
using Microsoft.Bank.Setup;
using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.EServices.EDocument;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.BatchProcessing;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Reporting;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Utilities;
using System.Automation;
using System.Globalization;
using System.Reflection;
using System.Security.User;
using System.Utilities;

table 31008 "Purch. Adv. Letter Header CZZ"
{
    Caption = 'Purchase Advance Letter Header';
    DataClassification = CustomerContent;
    LookupPageId = "Purch. Advance Letters CZZ";
    DataCaptionFields = "Advance Letter Code", "No.";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NoSeries: Codeunit "No. Series";
            begin
                if "No." <> xRec."No." then begin
                    GetSetup();
                    NoSeries.TestManual(AdvanceLetterTemplateCZZ."Advance Letter Document Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(5; "Advance Letter Code"; Code[20])
        {
            Caption = 'Advance Letter Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Advance Letter Template CZZ" where("Sales/Purchase" = const(Purchase));
            NotBlank = true;
        }
        field(10; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            NotBlank = true;

            trigger OnValidate()
            var
                Confirmed: Boolean;
            begin
                TestStatusOpen();
                if xRec."Pay-to Vendor No." <> "Pay-to Vendor No." then
                    if xRec."Pay-to Vendor No." = '' then
                        InitRecord()
                    else begin
                        if HideValidationDialog or (not GuiAllowed) then
                            Confirmed := true
                        else
                            Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Pay-to Vendor No."));
                        if not Confirmed then
                            "Pay-to Vendor No." := xRec."Pay-to Vendor No.";
                    end;

                GetVendor("Pay-to Vendor No.");
                Vendor.TestField("Vendor Posting Group");
                "Pay-to Name" := Vendor.Name;
                "Pay-to Name 2" := Vendor."Name 2";
                CopyPayToVendorAddressFieldsFromVendor(Vendor, false);
                if not SkipPayToContact then
                    "Pay-to Contact" := Vendor.Contact;
                "Payment Terms Code" := Vendor."Payment Terms Code";
                "Payment Method Code" := Vendor."Payment Method Code";
                GetSetup();
                if AdvanceLetterTemplateCZZ."VAT Bus. Posting Group" <> '' then
                    "VAT Bus. Posting Group" := AdvanceLetterTemplateCZZ."VAT Bus. Posting Group"
                else
                    "VAT Bus. Posting Group" := Vendor."VAT Bus. Posting Group";
                "VAT Country/Region Code" := Vendor."Country/Region Code";
                "VAT Registration No." := Vendor."VAT Registration No.";
                "Currency Code" := Vendor."Currency Code";
                "Language Code" := Vendor."Language Code";
                "Format Region" := Vendor."Format Region";
                SetPurchaserCode(Vendor."Purchaser Code", "Purchaser Code");
                Validate("Payment Terms Code");
                Validate("Payment Method Code");
                Validate("VAT Bus. Posting Group");
                Validate("Currency Code");

                Validate("Bank Account Code", Vendor."Preferred Bank Account Code");
                "Registration No." := Vendor.GetRegistrationNoTrimmedCZL();
                "Tax Registration No." := Vendor."Tax Registration No. CZL";
                "Responsibility Center" := UserSetupManagement.GetRespCenter(1, Vendor."Responsibility Center");

                CreateDimFromDefaultDim(Rec.FieldNo("Pay-to Vendor No."));

                SetPurchaserCode(Vendor."Purchaser Code", "Purchaser Code");

                Validate("Payment Terms Code");
                Validate("Payment Method Code");
                Validate("Currency Code");

                if not SkipPayToContact then
                    UpdatePayToCont("Pay-to Vendor No.");
            end;
        }
        field(11; "Pay-to Name"; Text[100])
        {
            Caption = 'Pay-to Name';
            DataClassification = CustomerContent;
            TableRelation = Vendor.Name;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                Vendor2: Record Vendor;
            begin
                if "Pay-to Vendor No." <> '' then
                    Vendor2.Get("Pay-to Vendor No.");

                if Vendor2.SelectVendor(Vendor2) then begin
                    xRec := Rec;
                    "Pay-to Name" := Vendor2.Name;
                    Validate("Pay-to Vendor No.", Vendor2."No.");
                end;
            end;

            trigger OnValidate()
            var
                Vendor2: Record Vendor;
            begin
                if ShouldSearchForVendorByName("Pay-to Vendor No.") then
                    Validate("Pay-to Vendor No.", Vendor2.GetVendorNo("Pay-to Name"));
            end;
        }
        field(12; "Pay-to Name 2"; Text[50])
        {
            Caption = 'Pay-to Name 2';
            DataClassification = CustomerContent;
        }
        field(13; "Pay-to Address"; Text[100])
        {
            Caption = 'Pay-to Address';
            DataClassification = CustomerContent;

        }
        field(14; "Pay-to Address 2"; Text[50])
        {
            Caption = 'Pay-to Address 2';
            DataClassification = CustomerContent;
        }
        field(15; "Pay-to City"; Text[30])
        {
            Caption = 'Pay-to City';
            DataClassification = CustomerContent;
            TableRelation = if ("Pay-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Pay-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Pay-to Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                PayToCity: Text;
                PayToCounty: Text;
            begin
                PayToCity := "Pay-to City";
                PayToCounty := "Pay-to County";
                PostCode.LookupPostCode(PayToCity, "Pay-to Post Code", PayToCounty, "Pay-to Country/Region Code");
                "Pay-to City" := CopyStr(PayToCity, 1, MaxStrLen("Pay-to City"));
                "Pay-to County" := CopyStr(PayToCounty, 1, MaxStrLen("Pay-to County"));
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(
                  "Pay-to City", "Pay-to Post Code", "Pay-to County", "Pay-to Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(16; "Pay-to Post Code"; Code[20])
        {
            Caption = 'Pay-to Post Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                PayToCity: Text;
                PayToCounty: Text;
            begin
                PayToCity := "Pay-to City";
                PayToCounty := "Pay-to County";
                PostCode.LookupPostCode(PayToCity, "Pay-to Post Code", PayToCounty, "Pay-to Country/Region Code");
                "Pay-to City" := CopyStr(PayToCity, 1, MaxStrLen("Pay-to City"));
                "Pay-to County" := CopyStr(PayToCounty, 1, MaxStrLen("Pay-to County"));
            end;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(
                  "Pay-to City", "Pay-to Post Code", "Pay-to County", "Pay-to Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(17; "Pay-to County"; Text[30])
        {
            Caption = 'Pay-to County';
            CaptionClass = '5,6,' + "Pay-to Country/Region Code";
            DataClassification = CustomerContent;
        }
        field(18; "Pay-to Country/Region Code"; Code[10])
        {
            Caption = 'Pay-to Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(19; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
        }
        field(20; "Pay-to Contact"; Text[100])
        {
            Caption = 'Pay-to Contact';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin
                TestStatusOpen();

                Contact.FilterGroup(2);
                LookupContact("Pay-to Vendor No.", "Pay-to Contact No.", Contact);
                if Page.RunModal(0, Contact) = Action::LookupOK then
                    Validate("Pay-to Contact No.", Contact."No.");
                Contact.FilterGroup(0);
            end;
        }
        field(21; "Pay-to Contact No."; Code[20])
        {
            Caption = 'Pay-to Contact No.';
            DataClassification = CustomerContent;
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
            begin
                if "Pay-to Vendor No." <> '' then
                    if Cont.Get("Pay-to Contact No.") then
                        Cont.SetRange("Company No.", Cont."Company No.")
                    else
                        if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Vendor, "Pay-to Vendor No.") then
                            Cont.SetRange("Company No.", ContBusinessRelation."Contact No.")
                        else
                            Cont.SetRange("No.", '');

                if "Pay-to Contact No." <> '' then
                    if Cont.Get("Pay-to Contact No.") then;
                if Page.RunModal(0, Cont) = Action::LookupOK then begin
                    xRec := Rec;
                    Validate("Pay-to Contact No.", Cont."No.");
                end;
            end;

            trigger OnValidate()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
                Confirmed: Boolean;
                ContactRelateErr: Label 'Contact %1 %2 is related to a different company than customer %3.', Comment = '%1 = Contact No., %2 = Contact Name, %3 = Customer No.';
            begin
                if "Pay-to Contact No." <> '' then
                    if Cont.Get("Pay-to Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric();

                if ("Pay-to Contact No." <> xRec."Pay-to Contact No.") and
                   (xRec."Pay-to Contact No." <> '')
                then begin
                    if HideValidationDialog or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Pay-to Contact No."));
                    if Confirmed then begin
                        if InitFromContact("Pay-to Contact No.", "Pay-to Vendor No.", FieldCaption("Pay-to Contact No.")) then
                            exit
                    end else begin
                        "Pay-to Contact No." := xRec."Pay-to Contact No.";
                        exit;
                    end;
                end;

                if ("Pay-to Vendor No." <> '') and ("Pay-to Contact No." <> '') then begin
                    Cont.Get("Pay-to Contact No.");
                    if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Vendor, "Pay-to Vendor No.") then
                        if ContBusinessRelation."Contact No." <> Cont."Company No." then
                            Error(ContactRelateErr, Cont."No.", Cont.Name, "Pay-to Vendor No.");
                end;

                UpdatePayToVend("Pay-to Contact No.");
            end;
        }
        field(23; "Purchaser Code"; Code[20])
        {
            Caption = 'Purchaser Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Purchaser Code"));
            end;
        }
        field(25; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(26; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(30; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                TestStatusOpen();
                if xRec."VAT Bus. Posting Group" <> "VAT Bus. Posting Group" then
                    RecreateLines(FieldCaption("VAT Bus. Posting Group"));
            end;
        }
        field(33; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnValidatePostingDateOnBeforeAssignDocumentDate(Rec, xRec, IsHandled);
                if not IsHandled then begin
                    PurchasesPayablesSetup.SetLoadFields("Link Doc. Date To Posting Date");
                    PurchasesPayablesSetup.GetRecordOnce();

                    if ("Incoming Document Entry No." = 0) and PurchasesPayablesSetup."Link Doc. Date To Posting Date" then
                        ValidateDocumentDateWithPostingDate();
                end;

                GetSetup();
                GeneralLedgerSetup.UpdateVATDate("Posting Date", Enum::"VAT Reporting Date"::"Posting Date", "VAT Date");
                Validate("VAT Date");
                GeneralLedgerSetup.UpdateOriginalDocumentVATDateCZL("Posting Date", Enum::"Default Orig.Doc. VAT Date CZL"::"Posting Date", "Original Document VAT Date");
                Validate("Original Document VAT Date");

                if "Currency Code" <> '' then begin
                    UpdateCurrencyFactor();
                    if "Currency Factor" <> xRec."Currency Factor" then
                        ConfirmCurrencyFactorUpdate();
                end;
            end;
        }
        field(34; "Advance Due Date"; Date)
        {
            Caption = 'Advance Due Date';
            DataClassification = CustomerContent;
        }
        field(35; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Payment Terms Code");

                GetSetup();
                if GeneralLedgerSetup."VAT Reporting Date" = GeneralLedgerSetup."VAT Reporting Date"::"Document Date" then
                    Validate("VAT Date", "Document Date");

                GeneralLedgerSetup.UpdateOriginalDocumentVATDateCZL("Document Date", Enum::"Default Orig.Doc. VAT Date CZL"::"Document Date", "Original Document VAT Date");
                Validate("Original Document VAT Date");
            end;
        }
        field(36; "VAT Date"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not VATReportingDateMgt.IsVATDateEnabled() then
                    TestField("VAT Date", "Posting Date");
                CheckCurrencyExchangeRate("VAT Date");
                GetSetup();
                GeneralLedgerSetup.UpdateOriginalDocumentVATDateCZL("VAT Date", Enum::"Default Orig.Doc. VAT Date CZL"::"VAT Date", "Original Document VAT Date");
                Validate("Original Document VAT Date");
            end;
        }
        field(38; "Posting Description"; Text[100])
        {
            Caption = 'Posting Description';
            DataClassification = CustomerContent;
        }
        field(39; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;
        }
        field(40; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PaymentTerms: Record "Payment Terms";
                IsHandled: Boolean;
            begin
                if ("Payment Terms Code" <> '') and ("Document Date" <> 0D) then begin
                    PaymentTerms.Get("Payment Terms Code");
                    IsHandled := false;
                    OnValidatePaymentTermsCodeOnBeforeCalcDueDate(Rec, xRec, FieldNo("Payment Terms Code"), CurrFieldNo, IsHandled);
                    if not IsHandled then
                        "Advance Due Date" := CalcDate(PaymentTerms."Due Date Calculation", "Document Date");
                    IsHandled := false;
                end else begin
                    IsHandled := false;
                    OnValidatePaymentTermsCodeOnBeforeValidateDueDateWhenBlank(Rec, xRec, CurrFieldNo, IsHandled);
                    if not IsHandled then
                        Validate("Advance Due Date", "Document Date");
                end;
            end;
        }
        field(43; "Registration No."; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(44; "Tax Registration No."; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
        field(45; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(48; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Vendor Adv. Letter No."; Code[35])
        {
            Caption = 'Vendor Advance Letter No.';
            DataClassification = CustomerContent;
        }
        field(53; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
        }
        field(55; "Bank Account Code"; Code[20])
        {
            Caption = 'Bank Account Code';
            DataClassification = CustomerContent;
            TableRelation = "Vendor Bank Account".Code where("Vendor No." = field("Pay-to Vendor No."));

            trigger OnValidate()
            var
                VendorBankAccount: Record "Vendor Bank Account";
            begin
                TestStatusOpen();

                if "Bank Account Code" = '' then begin
                    UpdateBankInfo('', '', '', '', '', '', '');
                    exit;
                end;

                TestField("Pay-to Vendor No.");
                VendorBankAccount.Get("Pay-to Vendor No.", "Bank Account Code");
                UpdateBankInfo(
                  VendorBankAccount.Code,
                  VendorBankAccount."Bank Account No.",
                  VendorBankAccount."Bank Branch No.",
                  VendorBankAccount.Name,
                  VendorBankAccount."Transit No.",
                  VendorBankAccount.IBAN,
                  VendorBankAccount."SWIFT Code");
            end;
        }
        field(56; "Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(57; "Bank Branch No."; Text[20])
        {
            Caption = 'Bank Branch No.';
            DataClassification = CustomerContent;
        }
        field(58; "Specific Symbol"; Code[10])
        {
            Caption = 'Specific Symbol';
            DataClassification = CustomerContent;
            CharAllowed = '09';
        }
        field(59; "Variable Symbol"; Code[10])
        {
            Caption = 'Variable Symbol';
            DataClassification = CustomerContent;
            CharAllowed = '09';

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(60; "Constant Symbol"; Code[10])
        {
            Caption = 'Constant Symbol';
            DataClassification = CustomerContent;
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
        }
        field(61; IBAN; Code[50])
        {
            Caption = 'IBAN';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CompanyInformation: Record "Company Information";
            begin
                CompanyInformation.CheckIBAN(IBAN);
            end;
        }
        field(62; "SWIFT Code"; Code[20])
        {
            Caption = 'SWIFT Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(63; "Bank Name"; Text[100])
        {
            Caption = 'Bank Name';
            DataClassification = CustomerContent;
        }
        field(64; "Transit No."; Text[20])
        {
            Caption = 'Transit No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(68; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            DataClassification = CustomerContent;
            TableRelation = "Responsibility Center";

            trigger OnValidate()
            var
                IdentSetUpErr: Label 'Your identification is set up to process from %1 %2 only.', Comment = '%1 = Responsibility center table caption, %2 = Responsibility center filter';
            begin
                TestStatusOpen();
                if not UserSetupManagement.CheckRespCenter(1, "Responsibility Center") then
                    Error(
                      IdentSetUpErr,
                      ResponsibilityCenter.TableCaption, UserSetupManagement.GetPurchasesFilter());

                CreateDimFromDefaultDim(Rec.FieldNo("Responsibility Center"));

                if xRec."Responsibility Center" <> "Responsibility Center" then
                    RecreateLines(FieldCaption("Responsibility Center"));
            end;
        }
        field(70; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;

            trigger OnValidate()
            begin
                if not (CurrFieldNo in [0, FieldNo("Posting Date")]) or ("Currency Code" <> xRec."Currency Code") then
                    TestStatusOpen();
                if (CurrFieldNo <> FieldNo("Currency Code")) and ("Currency Code" = xRec."Currency Code") then
                    UpdateCurrencyFactor()
                else
                    if "Currency Code" <> xRec."Currency Code" then
                        UpdateCurrencyFactor()
                    else
                        if "Currency Code" <> '' then begin
                            UpdateCurrencyFactor();
                            if "Currency Factor" <> xRec."Currency Factor" then
                                ConfirmCurrencyFactorUpdate();
                        end;
            end;
        }
        field(71; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Currency Factor" <> xRec."Currency Factor" then
                    UpdateLinesByFieldNo(FieldNo("Currency Factor"));
            end;
        }
        field(75; "VAT Country/Region Code"; Code[10])
        {
            Caption = 'VAT Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(80; Status; Enum "Advance Letter Doc. Status CZZ")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(85; "On Hold"; Code[3])
        {
            Caption = 'On Hold';
            DataClassification = CustomerContent;
        }
        field(90; "Automatic Post VAT Usage"; Boolean)
        {
            Caption = 'Automatic Post VAT Usage';
            DataClassification = CustomerContent;
        }
        field(95; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order));
        }
        field(96; "Format Region"; Text[80])
        {
            Caption = 'Format Region';
            TableRelation = "Language Selection"."Language Tag";
            DataClassification = CustomerContent;
        }
#pragma warning disable AA0232
        field(200; "Amount Including VAT"; Decimal)
#pragma warning restore AA0232
        {
            Caption = 'Amount Including VAT';
            Editable = false;
            AutoFormatExpression = "Currency Code";
            FieldClass = FlowField;
            CalcFormula = sum("Purch. Adv. Letter Line CZZ"."Amount Including VAT" where("Document No." = field("No.")));
        }
        field(201; "Amount Including VAT (LCY)"; Decimal)
        {
            Caption = 'Amount Including VAT (LCY)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Purch. Adv. Letter Line CZZ"."Amount Including VAT (LCY)" where("Document No." = field("No.")));
        }
        field(205; "To Pay"; Decimal)
        {
            Caption = 'To Pay Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum("Purch. Adv. Letter Entry CZZ".Amount where("Purch. Adv. Letter No." = field("No."), "Entry Type" = filter("Initial Entry" | Payment | Close)));
        }
        field(206; "To Pay (LCY)"; Decimal)
        {
            Caption = 'To Pay Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum("Purch. Adv. Letter Entry CZZ"."Amount (LCY)" where("Purch. Adv. Letter No." = field("No."), "Entry Type" = filter("Initial Entry" | Payment | Close)));
        }
        field(210; "To Use"; Decimal)
        {
            Caption = 'To Use Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Purch. Adv. Letter Entry CZZ".Amount where("Purch. Adv. Letter No." = field("No."), "Entry Type" = filter(Payment | Usage | Close)));
        }
        field(211; "To Use (LCY)"; Decimal)
        {
            Caption = 'To Use Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Purch. Adv. Letter Entry CZZ"."Amount (LCY)" where("Purch. Adv. Letter No." = field("No."), "Entry Type" = filter(Payment | Usage | Close | "VAT Adjustment")));
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDocDim();
            end;

            trigger OnValidate()
            begin
                DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(500; "Incoming Document Entry No."; Integer)
        {
            Caption = 'Incoming Document Entry No.';
            TableRelation = "Incoming Document";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IncomingDocument: Record "Incoming Document";
            begin
                if "Incoming Document Entry No." = xRec."Incoming Document Entry No." then
                    exit;
                if "Incoming Document Entry No." = 0 then
                    IncomingDocument.RemoveReferenceToWorkingDocument(xRec."Incoming Document Entry No.")
                else
                    IncomingDocument.SetPurchaseAdvanceCZZ(Rec);
            end;
        }
#if not CLEAN25
        field(31040; "Amount on Iss. Payment Order"; Decimal)
        {
            Caption = 'Amount on Issued Payment Order';
            FieldClass = FlowField;
            CalcFormula = sum("Iss. Payment Order Line CZB".Amount where("Purch. Advance Letter No. CZZ" = field("No.")));
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteReason = 'This field is obsolete and will be removed in a future release. The CalcSuggestedAmountToApply function should be used instead.';
            ObsoleteTag = '25.0';
        }
#endif
        field(31112; "Original Document VAT Date"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(SK1; "Pay-to Vendor No.", Status)
        {
        }
        key(SK2; "Order No.")
        {
        }
        key(SK3; "Advance Due Date")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Amount Including VAT")
        {
        }
    }

    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        Vendor: Record Vendor;
        PostCode: Record "Post Code";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ResponsibilityCenter: Record "Responsibility Center";
#if not CLEAN24
        NoSeriesManagement: Codeunit NoSeriesManagement;
#endif
        DimensionManagement: Codeunit DimensionManagement;
        UserSetupManagement: Codeunit "User Setup Management";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        HasPurchSetup: Boolean;
        HideValidationDialog: Boolean;
        SkipPayToContact: Boolean;
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        DocumentResetErr: Label 'You cannot reset %1 because the document still has one or more lines.', Comment = '%1 = a Field Caption like Bill-to Contact No.';
        DocumentDeleteErr: Label 'You cannot delete this document. Your identification is set up to process from %1 %2 only.', Comment = '%1 = table caption of responsibility center, %2 = code of responsibility center';
        PostedEntriesExistErr: Label 'You cannot delete this document because there are posted entries.';

    trigger OnInsert()
    begin
        InitInsert();

        if "Purchaser Code" = '' then
            SetDefaultPurchaser();
    end;

    trigger OnDelete()
    var
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        DocumentAttachment: Record "Document Attachment";
    begin
        if not UserSetupManagement.CheckRespCenter(1, "Responsibility Center") then
            Error(
              DocumentDeleteErr,
              ResponsibilityCenter.TableCaption(), UserSetupManagement.GetPurchasesFilter());

        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", "No.");
        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1', PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        if not PurchAdvLetterEntryCZZ.IsEmpty() then
            Error(PostedEntriesExistErr);

        PurchAdvLetterLineCZZ.SetRange("Document No.", "No.");
        if not PurchAdvLetterLineCZZ.IsEmpty() then
            PurchAdvLetterLineCZZ.DeleteAll(true);

        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", "No.");
        if not PurchAdvLetterEntryCZZ.IsEmpty() then
            PurchAdvLetterEntryCZZ.DeleteAll();

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase);
        AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", "No.");
        if not AdvanceLetterApplicationCZZ.IsEmpty() then
            AdvanceLetterApplicationCZZ.DeleteAll();

        DocumentAttachment.SetRange("Table ID", Database::"Purch. Adv. Letter Header CZZ");
        DocumentAttachment.SetRange("No.", "No.");
        if not DocumentAttachment.IsEmpty() then
            DocumentAttachment.DeleteAll();

        Validate("Incoming Document Entry No.", 0);
        DeleteRecordInApprovalRequest();
    end;

    procedure AssistEdit(): Boolean
    var
        NoSeries: Codeunit "No. Series";
    begin
        GetSetup();
        AdvanceLetterTemplateCZZ.TestField("Advance Letter Document Nos.");
        if NoSeries.LookupRelatedNoSeries(AdvanceLetterTemplateCZZ."Advance Letter Document Nos.", xRec."No. Series", "No. Series") then begin
            "No." := NoSeries.GetNextNo("No. Series");
            exit(true);
        end;
    end;

    procedure InitInsert()
    var
        NoSeries: Codeunit "No. Series";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitInsert(Rec, xRec, IsHandled);
        if not IsHandled then
            if "No." = '' then begin
                GetSetup();
                AdvanceLetterTemplateCZZ.TestField("Advance Letter Document Nos.");
#if not CLEAN24
                IsHandled := false;
                NoSeriesManagement.RaiseObsoleteOnBeforeInitSeries(AdvanceLetterTemplateCZZ."Advance Letter Document Nos.", xRec."No. Series", "Posting Date", "No.", "No. Series", IsHandled);
                if not IsHandled then begin
#endif
                    "No. Series" := AdvanceLetterTemplateCZZ."Advance Letter Document Nos.";
                    if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                        "No. Series" := xRec."No. Series";
                    "No." := NoSeries.GetNextNo("No. Series", "Posting Date");
#if not CLEAN24
                    NoSeriesManagement.RaiseObsoleteOnAfterInitSeries("No. Series", AdvanceLetterTemplateCZZ."Advance Letter Document Nos.", "Posting Date", "No.");
                end;
#endif
            end;
        OnInitInsertOnBeforeInitRecord(Rec, xRec);
        InitRecord();
    end;

    local procedure InitRecord()
    var
        AdvanceLbl: Label 'Advance Letter';
    begin
        GetSetup();

        "Automatic Post VAT Usage" := AdvanceLetterTemplateCZZ."Automatic Post VAT Document";

        if "Posting Date" = 0D then
            "Posting Date" := WorkDate();

        if PurchasesPayablesSetup."Default Posting Date" = PurchasesPayablesSetup."Default Posting Date"::"No Date" then
            "Posting Date" := 0D;

        "Document Date" := WorkDate();
        "VAT Date" := GeneralLedgerSetup.GetVATDate("Posting Date", "Document Date");
        "Original Document VAT Date" :=
            GeneralLedgerSetup.GetOriginalDocumentVATDateCZL("Posting Date", "VAT Date", "Document Date");

        "Posting Description" := AdvanceLbl + ' ' + "No.";
        "Responsibility Center" := UserSetupManagement.GetRespCenter(1, "Responsibility Center");

        OnAfterInitRecord(Rec);
    end;

    local procedure GetSetup()
    begin
        if not HasPurchSetup then begin
            PurchasesPayablesSetup.Get();
            GeneralLedgerSetup.Get();
            HasPurchSetup := true;
        end;

        if AdvanceLetterTemplateCZZ.Code <> "Advance Letter Code" then
            AdvanceLetterTemplateCZZ.Get("Advance Letter Code");
    end;

    procedure SetSecurityFilterOnRespCenter()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetSecurityFilterOnRespCenter(Rec, IsHandled);
        if IsHandled then
            exit;

        if UserSetupManagement.GetPurchasesFilter() <> '' then begin
            FilterGroup(2);
            SetRange("Responsibility Center", UserSetupManagement.GetPurchasesFilter());
            FilterGroup(0);
        end;
    end;

    procedure TestStatusOpen()
    begin
        OnBeforeTestStatusOpen(Rec);

        TestField(Status, Status::New);

        OnAfterTestStatusOpen(Rec);
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure UpdateBankInfo(BankAccountCode: Code[20]; BankAccountNo: Text[30]; BankBranchNo: Text[20]; BankName: Text[100]; TransitNo: Text[20]; IBANCode: Code[50]; SWIFTCode: Code[20])
    begin
        "Bank Account Code" := BankAccountCode;
        "Bank Account No." := BankAccountNo;
        "Bank Branch No." := BankBranchNo;
        "Bank Name" := BankName;
        "Transit No." := TransitNo;
        "IBAN" := IBANCode;
        "SWIFT Code" := SWIFTCode;
        OnAfterUpdateBankInfo(Rec);
    end;

    local procedure GetVendor(VendorNo: Code[20])
    begin
        if VendorNo <> '' then begin
            if VendorNo <> Vendor."No." then
                Vendor.Get(VendorNo);
        end else
            Clear(Vendor);
    end;

    local procedure CopyPayToVendorAddressFieldsFromVendor(var PayToVendor: Record Vendor; ForceCopy: Boolean)
    begin
        if PayToVendorIsReplaced() or ShouldCopyAddressFromPayToVendor(PayToVendor) or ForceCopy then begin
            "Pay-to Address" := PayToVendor.Address;
            "Pay-to Address 2" := PayToVendor."Address 2";
            "Pay-to City" := PayToVendor.City;
            "Pay-to Post Code" := PayToVendor."Post Code";
            "Pay-to County" := PayToVendor.County;
            "Pay-to Country/Region Code" := PayToVendor."Country/Region Code";
            OnAfterCopyPayToVendorAddressFieldsFromVendor(Rec, PayToVendor);
        end;
    end;

    local procedure PayToVendorIsReplaced(): Boolean
    begin
        exit((xRec."Pay-to Vendor No." <> '') and (xRec."Pay-to Vendor No." <> "Pay-to Vendor No."));
    end;

    local procedure ShouldCopyAddressFromPayToVendor(PayToVendor: Record Vendor): Boolean
    begin
        exit((not HasPayToAddress()) and PayToVendor.HasAddress());
    end;

    procedure CreateDimFromDefaultDim(FieldNo: Integer)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource, FieldNo);
        CreateDim(DefaultDimSource);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
        DimensionManagement.AddDimSource(DefaultDimSource, Database::Vendor, Rec."Pay-to Vendor No.", FieldNo = Rec.FieldNo("Pay-to Vendor No."));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"Salesperson/Purchaser", Rec."Purchaser Code", FieldNo = Rec.FieldNo("Purchaser Code"));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"Responsibility Center", Rec."Responsibility Center", FieldNo = Rec.FieldNo("Responsibility Center"));

        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource);
    end;

    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        SourceCodeSetup: Record "Source Code Setup";
        OldDimSetID: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDim(Rec, IsHandled);
        if IsHandled then
            exit;

        SourceCodeSetup.Get();
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" := DimensionManagement.GetRecDefaultDimID(Rec, CurrFieldNo, DefaultDimSource, SourceCodeSetup.Purchases,
                                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);

        OnAfterCreateDim(Rec, xRec, CurrFieldNo, OldDimSetID);

        if (OldDimSetID <> "Dimension Set ID") and LinesExist() then
            Modify();
    end;

    procedure HasPayToAddress(): Boolean
    begin
        case true of
            "Pay-to Address" <> '':
                exit(true);
            "Pay-to Address 2" <> '':
                exit(true);
            "Pay-to City" <> '':
                exit(true);
            "Pay-to Country/Region Code" <> '':
                exit(true);
            "Pay-to County" <> '':
                exit(true);
            "Pay-to Post Code" <> '':
                exit(true);
            "Pay-to Contact" <> '':
                exit(true);
        end;

        exit(false);
    end;

    local procedure UpdatePayToCont(VendorNo: Code[20])
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        Vendor2: Record Vendor;
        Contact: Record Contact;
    begin
        if Vendor2.Get(VendorNo) then begin
            if Vendor2."Primary Contact No." <> '' then
                "Pay-to Contact No." := Vendor2."Primary Contact No."
            else
                "Pay-to Contact No." := ContactBusinessRelation.GetContactNo(ContactBusinessRelation."Link to Table"::Vendor, "Pay-to Vendor No.");
            "Pay-to Contact" := Vendor2.Contact;
        end;

        if "Pay-to Contact No." <> '' then
            if Contact.Get("Pay-to Contact No.") then
                Contact.CheckIfPrivacyBlockedGeneric();

        OnAfterUpdatePayToCont(Rec, Vendor2, Contact);
    end;

    procedure ShouldSearchForVendorByName(VendorNo: Code[20]): Boolean
    var
        Vendor2: Record Vendor;
    begin
        if VendorNo = '' then
            exit(true);

        if not Vendor2.Get(VendorNo) then
            exit(true);

        exit(not Vendor2."Disable Search by Name");
    end;

    local procedure LookupContact(VendorNo: Code[20]; ContactNo: Code[20]; var Contact: Record Contact)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        if ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Vendor, VendorNo) then
            Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.")
        else
            Contact.SetRange("Company No.", '');
        if ContactNo <> '' then
            if Contact.Get(ContactNo) then;
    end;

    local procedure InitFromContact(ContactNo: Code[20]; VendorNo: Code[20]; ContactCaption: Text): Boolean
    begin
        if (ContactNo = '') and (VendorNo = '') then begin
            if LinesExist() then
                Error(DocumentResetErr, ContactCaption);
            Init();
            GetSetup();
            "No. Series" := xRec."No. Series";
            OnInitFromContactOnBeforeInitRecord(Rec, xRec);
            InitRecord();
            exit(true);
        end;
    end;

    local procedure UpdatePayToVend(ContactNo: Code[20])
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        Vendor2: Record Vendor;
        Contact: Record Contact;
        ContactIsNotRelatedErr: Label 'Contact %1 %2 is not related to vendor %3.', Comment = '%1 = Contact No., %2 = Contact Name, %3 = Vendor No.';
        ContactIsNotRelatedToAnyCostomerErr: Label 'Contact %1 %2 is not related to a vendor.', Comment = '%1 = Contact No., %2 = Contact Name';
    begin
        if Contact.Get(ContactNo) then begin
            "Pay-to Contact No." := Contact."No.";
            if Contact.Type = Contact.Type::Person then
                "Pay-to Contact" := Contact.Name
            else
                if Vendor2.Get("Pay-to Vendor No.") then
                    "Pay-to Contact" := Vendor2.Contact
                else
                    "Pay-to Contact" := '';
        end else begin
            "Pay-to Contact" := '';
            exit;
        end;

        if ContactBusinessRelation.FindByContact(ContactBusinessRelation."Link to Table"::Vendor, Contact."Company No.") then begin
            if "Pay-to Vendor No." = '' then begin
                SkipPayToContact := true;
                Validate("Pay-to Vendor No.", ContactBusinessRelation."No.");
                SkipPayToContact := false;
            end else
                if "Pay-to Vendor No." <> ContactBusinessRelation."No." then
                    Error(ContactIsNotRelatedErr, Contact."No.", Contact.Name, "Pay-to Vendor No.");
        end else
            Error(ContactIsNotRelatedToAnyCostomerErr, Contact."No.", Contact.Name);
        OnAfterUpdatePayToVend(Rec, Contact);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);

        OldDimSetID := "Dimension Set ID";
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "No." <> '' then
            Modify();

        if OldDimSetID <> "Dimension Set ID" then
            Modify();

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    procedure RecreateLines(ChangedFieldName: Text)
    var
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        TempPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ" temporary;
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmText: Text;
        IsHandled: Boolean;
        Confirmed: Boolean;
        RecreatePurchLinesMsg: Label 'If you change %1, the existing purchase lines will be deleted and new purchase lines based on the new information on the header will be created.\\Do you want to continue?', Comment = '%1: FieldCaption';
        RecreatePurchLinesCancelErr: Label 'You must delete the existing purchase lines before you can change %1.', Comment = '%1 - Field Name, Sample: You must delete the existing purchase lines before you can change Currency Code.';
    begin
        if not LinesExist() then
            exit;

        IsHandled := false;
        OnBeforeRecreateLinesHandler(Rec, xRec, ChangedFieldName, IsHandled);
        if IsHandled then
            exit;

        if HideValidationDialog or not GuiAllowed() then
            Confirmed := true
        else begin
            ConfirmText := StrSubstNo(RecreatePurchLinesMsg, ChangedFieldName);
            Confirmed := ConfirmManagement.GetResponseOrDefault(ConfirmText, false);
        end;

        if Confirmed then begin
            PurchAdvLetterLineCZZ.LockTable();
            Modify();
            PurchAdvLetterLineCZZ.SetRange("Document No.", "No.");
            PurchAdvLetterLineCZZ.FindSet();
            repeat
                TempPurchAdvLetterLineCZZ := PurchAdvLetterLineCZZ;
                TempPurchAdvLetterLineCZZ.Insert();
            until PurchAdvLetterLineCZZ.Next() = 0;

            PurchAdvLetterLineCZZ.DeleteAll();

            PurchAdvLetterLineCZZ."Line No." := 0;
            TempPurchAdvLetterLineCZZ.FindSet();
            repeat
                PurchAdvLetterLineCZZ.Init();
                PurchAdvLetterLineCZZ."Document No." := "No.";
                PurchAdvLetterLineCZZ."Line No." += 10000;
                PurchAdvLetterLineCZZ."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
                PurchAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", TempPurchAdvLetterLineCZZ."VAT Prod. Posting Group");
                PurchAdvLetterLineCZZ.Description := TempPurchAdvLetterLineCZZ.Description;
                PurchAdvLetterLineCZZ.Validate("Amount Including VAT", TempPurchAdvLetterLineCZZ."Amount Including VAT");
                PurchAdvLetterLineCZZ.Insert(true);
            until TempPurchAdvLetterLineCZZ.Next() = 0;

            TempPurchAdvLetterLineCZZ.DeleteAll();
        end else
            Error(RecreatePurchLinesCancelErr, ChangedFieldName);
    end;

    procedure UpdateLinesByFieldNo(ChangedFieldNo: Integer)
    var
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        "Field": Record "Field";
        IsHandled: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;

        if IsNullGuid(Rec.SystemId) then
            exit;

        IsHandled := false;
        OnBeforeUpdateLinesByFieldNo(Rec, ChangedFieldNo, xRec, IsHandled);
        if IsHandled then
            exit;

        if not LinesExist() then
            exit;

        if not Field.Get(Database::"Sales Adv. Letter Header CZZ", ChangedFieldNo) then
            Field.Get(Database::"Sales Adv. Letter Line CZZ", ChangedFieldNo);

        PurchAdvLetterLineCZZ.LockTable();
        if not Rec.Modify() then
            exit;

        PurchAdvLetterLineCZZ.Reset();
        PurchAdvLetterLineCZZ.SetRange("Document No.", "No.");
        if PurchAdvLetterLineCZZ.FindSet() then
            repeat
                IsHandled := false;
                OnBeforeLineByChangedFieldNo(Rec, PurchAdvLetterLineCZZ, ChangedFieldNo, xRec, IsHandled);
                if not IsHandled then
                    case ChangedFieldNo of
                        FieldNo("Currency Factor"):
                            PurchAdvLetterLineCZZ.Validate("Amount Including VAT");
                        else
                            OnUpdateLineByChangedFieldName(Rec, PurchAdvLetterLineCZZ, Field.FieldName, ChangedFieldNo);
                    end;
                OnUpdateLinesByFieldNoOnBeforeLineModify(PurchAdvLetterLineCZZ, ChangedFieldNo, CurrFieldNo);
                PurchAdvLetterLineCZZ.Modify(true);
            until PurchAdvLetterLineCZZ.Next() = 0;

        OnAfterUpdateLinesByFieldNo(Rec, xRec, ChangedFieldNo);
    end;

    procedure LinesExist(): Boolean
    var
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        PurchAdvLetterLineCZZ.SetRange("Document No.", "No.");
        exit(not PurchAdvLetterLineCZZ.IsEmpty());
    end;

    local procedure UpdateCurrencyFactor()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        UpdateCurrencyExchangeRates: Codeunit "Update Currency Exchange Rates";
        ConfirmManagement: Codeunit "Confirm Management";
        CurrencyDate: Date;
        Updated: Boolean;
        MissingExchangeRatesQst: Label 'There are no exchange rates for currency %1 and date %2. Do you want to add them now? Otherwise, the last change you made will be reverted.', Comment = '%1 - currency code, %2 - posting date';
    begin
        OnBeforeUpdateCurrencyFactor(Rec, Updated);
        if Updated then
            exit;

        if "Currency Code" <> '' then begin
            if "Posting Date" <> 0D then
                CurrencyDate := "Posting Date"
            else
                CurrencyDate := WorkDate();

            if UpdateCurrencyExchangeRates.ExchangeRatesForCurrencyExist(CurrencyDate, "Currency Code") then begin
                "Currency Factor" := CurrencyExchangeRate.ExchangeRate(CurrencyDate, "Currency Code");
                if "Currency Code" <> xRec."Currency Code" then
                    RecreateLines(FieldCaption("Currency Code"));
            end else
                if ConfirmManagement.GetResponseOrDefault(
                     StrSubstNo(MissingExchangeRatesQst, "Currency Code", CurrencyDate), true)
                then begin
                    Commit();
                    UpdateCurrencyExchangeRates.OpenExchangeRatesPage("Currency Code");
                    UpdateCurrencyFactor();
                end else
                    RevertCurrencyCodeAndPostingDate();
        end else begin
            "Currency Factor" := 0;
            if "Currency Code" <> xRec."Currency Code" then
                RecreateLines(FieldCaption("Currency Code"));
        end;

        OnAfterUpdateCurrencyFactor(Rec, HideValidationDialog);
    end;

    local procedure RevertCurrencyCodeAndPostingDate()
    begin
        "Currency Code" := xRec."Currency Code";
        "Posting Date" := xRec."Posting Date";
        Modify();
    end;

    local procedure ConfirmCurrencyFactorUpdate()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        Confirmed: Boolean;
        UpdateExchangeRateQst: Label 'Do you want to update the exchange rate?';
    begin
        OnBeforeConfirmUpdateCurrencyFactor(Rec, HideValidationDialog);

        if HideValidationDialog or (not GuiAllowed) then
            Confirmed := true
        else
            Confirmed := ConfirmManagement.GetResponseOrDefault(UpdateExchangeRateQst, false);
        if Confirmed then
            Validate("Currency Factor")
        else
            "Currency Factor" := xRec."Currency Factor";
    end;

    local procedure CheckCurrencyExchangeRate(CurrencyDate: Date)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CurrEchRateNotFoundErr: Label 'Currency exchange rate not found.';
    begin
        if "Currency Code" = '' then
            exit;
        CurrencyExchangeRate.SetRange("Currency Code", "Currency Code");
        CurrencyExchangeRate.SetRange("Starting Date", 0D, CurrencyDate);
        if CurrencyExchangeRate.IsEmpty() then
            Error(CurrEchRateNotFoundErr);
    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowDocDim(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimensionManagement.EditDimensionSet(
            "Dimension Set ID", "No.",
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        if OldDimSetID <> "Dimension Set ID" then
            Modify();
    end;

    procedure GetVATAmounts(var VATBaseAmount: Decimal; var VATAmount: Decimal; var VATBaseAmountLCY: Decimal; var VATAmountLCY: Decimal)
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", "No.");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ.SetRange("Auxiliary Entry", false);
        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1', PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        PurchAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Amount", "VAT Base Amount (LCY)", "VAT Amount (LCY)");
        VATBaseAmount := PurchAdvLetterEntryCZZ."VAT Base Amount";
        VATAmount := PurchAdvLetterEntryCZZ."VAT Amount";
        VATBaseAmountLCY := PurchAdvLetterEntryCZZ."VAT Base Amount (LCY)";
        VATAmountLCY := PurchAdvLetterEntryCZZ."VAT Amount (LCY)";
    end;

    local procedure SetPurchaserCode(PurchaserCodeToCheck: Code[20]; var PurchaserCodeToAssign: Code[20])
    var
        UserSetupPurchaserCode: Code[20];
    begin
        UserSetupPurchaserCode := GetUserSetupPurchaserCode();
        if PurchaserCodeToCheck <> '' then begin
            if SalespersonPurchaser.Get(PurchaserCodeToCheck) then
                if SalespersonPurchaser.VerifySalesPersonPurchaserPrivacyBlocked(SalespersonPurchaser) then begin
                    if UserSetupPurchaserCode = '' then
                        PurchaserCodeToAssign := ''
                end else
                    PurchaserCodeToAssign := PurchaserCodeToCheck;
        end else
            if UserSetupPurchaserCode = '' then
                PurchaserCodeToAssign := '';
    end;

    local procedure SetDefaultPurchaser()
    var
        UserSetupPurchaserCode: Code[20];
    begin
        UserSetupPurchaserCode := GetUserSetupPurchaserCode();
        if UserSetupPurchaserCode <> '' then
            if SalespersonPurchaser.Get(UserSetupPurchaserCode) then
                if not SalespersonPurchaser.VerifySalesPersonPurchaserPrivacyBlocked(SalespersonPurchaser) then
                    Validate("Purchaser Code", UserSetupPurchaserCode);
    end;

    local procedure GetUserSetupPurchaserCode(): Code[20]
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId) then
            exit;

        exit(UserSetup."Salespers./Purch. Code");
    end;

    procedure PrintRecords(ShowRequestPage: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePrintRecords(Rec, ShowRequestPage, IsHandled);
        if not IsHandled then
            DocumentSendingProfile.TrySendToPrinterVendor(
              DummyReportSelections.Usage::"Purchase Advance Letter CZZ".AsInteger(), Rec, FieldNo("Pay-to Vendor No."), ShowRequestPage);
    end;

    procedure PrintToDocumentAttachment()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        PurchAdvLetterHeaderCZZ.Copy(Rec);
        if PurchAdvLetterHeaderCZZ.FindSet() then
            repeat
                DoPrintToDocumentAttachment(PurchAdvLetterHeaderCZZ);
            until PurchAdvLetterHeaderCZZ.Next() = 0;
    end;

    local procedure DoPrintToDocumentAttachment(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        ReportSelections: Record "Report Selections";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDoPrintToDocumentAttachment(PurchAdvLetterHeaderCZZ, IsHandled);
        if IsHandled then
            exit;

        PurchAdvLetterHeaderCZZ.SetRecFilter();
        ReportSelections.SaveAsDocumentAttachment(
            ReportSelections.Usage::"Purchase Advance Letter CZZ".AsInteger(), PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", true);
    end;

    procedure CheckPurchaseAdvanceLetterReleaseRestrictions()
    begin
        OnCheckPurchaseAdvanceLetterReleaseRestrictions();
    end;

    procedure CheckPurchaseAdvanceLetterPostRestrictions()
    begin
        OnCheckPurchaseAdvanceLetterPostRestrictions();
    end;

    local procedure DeleteRecordInApprovalRequest()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDeleteRecordInApprovalRequest(Rec, IsHandled);
        if IsHandled then
            exit;

        ApprovalsMgmt.OnDeleteRecordInApprovalRequest(RecordId);
    end;

    procedure CollectSuggestedApplication(var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL"): Boolean
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        exit(CrossApplicationMgtCZL.CollectSuggestedApplication(Rec, CrossApplicationBufferCZL));
    end;

    procedure CollectSuggestedApplication(CalledFrom: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL"): Boolean
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        exit(CrossApplicationMgtCZL.CollectSuggestedApplication(Rec, CalledFrom, CrossApplicationBufferCZL));
    end;

    procedure CalcSuggestedAmountToApply(): Decimal
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        exit(-CrossApplicationMgtCZL.CalcSuggestedAmountToApply(Rec));
    end;

    procedure DrillDownSuggestedAmountToApply()
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        CrossApplicationMgtCZL.DrillDownSuggestedAmountToApply(Rec);
    end;

    internal procedure PerformManualRelease(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := PurchAdvLetterHeaderCZZ.Count();
        PurchAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::New);
        NoOfSkipped := NoOfSelected - PurchAdvLetterHeaderCZZ.Count();
        BatchProcessingMgt.BatchProcess(PurchAdvLetterHeaderCZZ, Codeunit::"P.Adv.Let.Doc.Man.Release CZZ", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;

    internal procedure PerformManualReopen(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := PurchAdvLetterHeaderCZZ.Count();
        PurchAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");
        NoOfSkipped := NoOfSelected - PurchAdvLetterHeaderCZZ.Count();
        BatchProcessingMgt.BatchProcess(PurchAdvLetterHeaderCZZ, Codeunit::"P.Adv.Let.Doc.Man.Reopen CZZ", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;

    local procedure ValidateDocumentDateWithPostingDate()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateDocumentDateWithPostingDate(Rec, CurrFieldNo, IsHandled, xRec);
        if IsHandled then
            exit;

        Validate("Document Date", "Posting Date");
    end;

    procedure UpdateStatus(AdvanceLetterDocStatus: Enum "Advance Letter Doc. Status CZZ")
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        PurchAdvLetterManagementCZZ.UpdateStatus(Rec, AdvanceLetterDocStatus);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePaymentTermsCodeOnBeforeCalcDueDate(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; CalledByFieldNo: Integer; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePaymentTermsCodeOnBeforeValidateDueDateWhenBlank(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitInsert(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitInsertOnBeforeInitRecord(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeTestStatusOpen(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterTestStatusOpen(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPayToVendorAddressFieldsFromVendor(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PayToVendor: Record Vendor)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDim(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDim(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; CurrentFieldNo: Integer; OldDimSetID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdatePayToCont(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; Vendor: Record Vendor; Contact: Record Contact)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitFromContactOnBeforeInitRecord(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdatePayToVend(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; Contact: Record Contact)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRecreateLinesHandler(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; ChangedFieldName: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateCurrencyFactor(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var Updated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateCurrencyFactor(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; HideValidationDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmUpdateCurrencyFactor(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var HideValidationDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowDocDim(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBankInfo(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCheckPurchaseAdvanceLetterReleaseRestrictions()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCheckPurchaseAdvanceLetterPostRestrictions()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDeleteRecordInApprovalRequest(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintRecords(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; ShowRequestPage: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateLinesByFieldNo(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; ChangedFieldNo: Integer; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLineByChangedFieldNo(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; ChangedFieldNo: Integer; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateLineByChangedFieldName(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; ChangedFieldName: Text[100]; ChangedFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateLinesByFieldNoOnBeforeLineModify(var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; ChangedFieldNo: Integer; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateLinesByFieldNo(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; ChangedFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDoPrintToDocumentAttachment(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidatePostingDateOnBeforeAssignDocumentDate(var Rec: Record "Purch. Adv. Letter Header CZZ"; var xRec: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSecurityFilterOnRespCenter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateDocumentDateWithPostingDate(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; CurrFieldNo: Integer; var IsHandled: Boolean; xPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;
}
