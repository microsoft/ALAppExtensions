// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.EServices.EDocument;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Registration;
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
using Microsoft.Projects.Project.Job;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.Automation;
using System.Globalization;
using System.Reflection;
using System.Security.User;
using System.Utilities;

table 31004 "Sales Adv. Letter Header CZZ"
{
    Caption = 'Sales Advance Letter Header';
    DataClassification = CustomerContent;
    LookupPageId = "Sales Advance Letters CZZ";
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
            TableRelation = "Advance Letter Template CZZ" where("Sales/Purchase" = const(Sales));
            NotBlank = true;
        }
        field(10; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            NotBlank = true;

            trigger OnValidate()
            var
                Confirmed: Boolean;
            begin
                TestStatusOpen();
                if xRec."Bill-to Customer No." <> "Bill-to Customer No." then
                    if xRec."Bill-to Customer No." = '' then
                        InitRecord()
                    else begin
                        if HideValidationDialog or (not GuiAllowed) then
                            Confirmed := true
                        else
                            Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Bill-to Customer No."));
                        if Confirmed then
                            OnValidateBillToCustomerNoOnAfterConfirmed(Rec)
                        else
                            "Bill-to Customer No." := xRec."Bill-to Customer No.";
                    end;

                GetCustomer("Bill-to Customer No.");
                Customer.TestField("Customer Posting Group");

                SetBillToCustomerAddressFieldsFromCustomer(Customer);

                CreateDimFromDefaultDim(Rec.FieldNo("Bill-to Customer No."));

                Validate("Payment Terms Code");
                Validate("Payment Method Code");
                Validate("VAT Bus. Posting Group");
                Validate("Currency Code");

                if not SkipBillToContact then
                    UpdateBillToCont("Bill-to Customer No.");
            end;
        }
        field(11; "Bill-to Name"; Text[100])
        {
            Caption = 'Bill-to Name';
            DataClassification = CustomerContent;
            TableRelation = Customer.Name;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                Customer2: Record Customer;
            begin
                if "Bill-to Customer No." <> '' then
                    Customer2.Get("Bill-to Customer No.");

                if Customer2.SelectCustomer(Customer2) then begin
                    xRec := Rec;
                    "Bill-to Name" := Customer2.Name;
                    Validate("Bill-to Customer No.", Customer2."No.");
                end;
            end;

            trigger OnValidate()
            var
                Customer2: Record Customer;
            begin
                OnBeforeValidateBillToCustomerName(Rec, Customer2);

                if ShouldSearchForCustomerByName("Bill-to Customer No.") then
                    Validate("Bill-to Customer No.", Customer2.GetCustNo("Bill-to Name"));
            end;
        }
        field(12; "Bill-to Name 2"; Text[50])
        {
            Caption = 'Bill-to Name 2';
            DataClassification = CustomerContent;
        }
        field(13; "Bill-to Address"; Text[100])
        {
            Caption = 'Bill-to Address';
            DataClassification = CustomerContent;

        }
        field(14; "Bill-to Address 2"; Text[50])
        {
            Caption = 'Bill-to Address 2';
            DataClassification = CustomerContent;
        }
        field(15; "Bill-to City"; Text[30])
        {
            Caption = 'Bill-to City';
            DataClassification = CustomerContent;
            TableRelation = if ("Bill-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Bill-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Bill-to Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                BillToCity: Text;
                BillToCounty: Text;
            begin
                BillToCity := "Bill-to City";
                BillToCounty := "Bill-to County";
                PostCode.LookupPostCode(BillToCity, "Bill-to Post Code", BillToCounty, "Bill-to Country/Region Code");
                "Bill-to City" := CopyStr(BillToCity, 1, MaxStrLen("Bill-to City"));
                "Bill-to County" := CopyStr(BillToCounty, 1, MaxStrLen("Bill-to County"));
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(
                  "Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(16; "Bill-to Post Code"; Code[20])
        {
            Caption = 'Bill-to Post Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                BillToCity: Text;
                BillToCounty: Text;
            begin
                OnBeforeLookupBillToPostCode(Rec, PostCode);

                BillToCity := "Bill-to City";
                BillToCounty := "Bill-to County";
                PostCode.LookupPostCode(BillToCity, "Bill-to Post Code", BillToCounty, "Bill-to Country/Region Code");
                "Bill-to City" := CopyStr(BillToCity, 1, MaxStrLen("Bill-to City"));
                "Bill-to County" := CopyStr(BillToCounty, 1, MaxStrLen("Bill-to County"));
            end;

            trigger OnValidate()
            begin
                OnBeforeValidateBillToPostCode(Rec, PostCode);

                PostCode.ValidatePostCode(
                  "Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(17; "Bill-to County"; Text[30])
        {
            Caption = 'Bill-to County';
            CaptionClass = '5,3,' + "Bill-to Country/Region Code";
            DataClassification = CustomerContent;
        }
        field(18; "Bill-to Country/Region Code"; Code[10])
        {
            Caption = 'Bill-to Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(19; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
        }
        field(20; "Bill-to Contact"; Text[100])
        {
            Caption = 'Bill-to Contact';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin
                TestStatusOpen();

                Contact.FilterGroup(2);
                LookupContact("Bill-to Customer No.", "Bill-to Contact No.", Contact);
                if Page.RunModal(0, Contact) = Action::LookupOK then
                    Validate("Bill-to Contact No.", Contact."No.");
                Contact.FilterGroup(0);
            end;
        }
        field(21; "Bill-to Contact No."; Code[20])
        {
            Caption = 'Bill-to Contact No.';
            DataClassification = CustomerContent;
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
            begin
                if "Bill-to Customer No." <> '' then
                    if Cont.Get("Bill-to Contact No.") then
                        Cont.SetRange("Company No.", Cont."Company No.")
                    else
                        if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Customer, "Bill-to Customer No.") then
                            Cont.SetRange("Company No.", ContBusinessRelation."Contact No.")
                        else
                            Cont.SetRange("No.", '');

                if "Bill-to Contact No." <> '' then
                    if Cont.Get("Bill-to Contact No.") then;
                if PAGE.RunModal(0, Cont) = ACTION::LookupOK then begin
                    xRec := Rec;
                    Validate("Bill-to Contact No.", Cont."No.");
                end;
            end;

            trigger OnValidate()
            var
                Cont: Record Contact;
                ConfirmManagement: Codeunit "Confirm Management";
                ConfirmQstTxt: Text;
                IsHandled: Boolean;
                Confirmed: Boolean;
            begin
                if "Bill-to Contact No." <> '' then
                    if Cont.Get("Bill-to Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric();

                if ("Bill-to Contact No." <> xRec."Bill-to Contact No.") and
                   (xRec."Bill-to Contact No." <> '')
                then begin
                    IsHandled := false;
                    OnBeforeConfirmBillToContactNoChange(Rec, xRec, CurrFieldNo, Confirmed, IsHandled);
                    if not IsHandled then
                        if HideValidationDialog or (not GuiAllowed) then
                            Confirmed := true
                        else begin
                            ConfirmQstTxt := StrSubstNo(ConfirmChangeQst, FieldCaption("Bill-to Contact No."));
                            Confirmed := ConfirmManagement.GetResponseOrDefault(ConfirmQstTxt, false);
                        end;
                    if Confirmed then begin
                        if InitFromContact("Bill-to Contact No.", "Bill-to Customer No.", FieldCaption("Bill-to Contact No.")) then
                            exit;
                    end else begin
                        "Bill-to Contact No." := xRec."Bill-to Contact No.";
                        exit;
                    end;
                end;

                if ("Bill-to Customer No." <> '') and ("Bill-to Contact No." <> '') then
                    CheckContactRelatedToCustomerCompany("Bill-to Contact No.", "Bill-to Customer No.", CurrFieldNo);

                UpdateBillToCust("Bill-to Contact No.");
            end;
        }
        field(23; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Salesperson Code"));
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
            begin
                SalesReceivablesSetup.SetLoadFields("Link Doc. Date To Posting Date");
                SalesReceivablesSetup.GetRecordOnce();

                if ("Incoming Document Entry No." = 0) and SalesReceivablesSetup."Link Doc. Date To Posting Date" then
                    ValidateDocumentDateWithPostingDate();

                GetSetup();
                GeneralLedgerSetup.UpdateVATDate("Posting Date", Enum::"VAT Reporting Date"::"Posting Date", "VAT Date");
                Validate("VAT Date");

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

            trigger OnValidate()
            var
                Customer: Record Customer;
                VATRegistrationLog: Record "VAT Registration Log";
                VATRegistrationNoFormat: Record "VAT Registration No. Format";
                VATRegNoSrvConfig: Record "VAT Reg. No. Srv Config";
                VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
                ResultRecRef: RecordRef;
                ApplicableCountryCode: Code[10];
                IsHandled: Boolean;
                ValidVATNoMsg: Label 'The VAT registration number is valid.';
                InvalidVatRegNoMsg: Label 'The VAT registration number is not valid. Try entering the number again.';
            begin
                IsHandled := false;
                OnBeforeValidateVATRegistrationNo(Rec, IsHandled);
                if IsHandled then
                    exit;

                "VAT Registration No." := UpperCase("VAT Registration No.");
                if "VAT Registration No." = xRec."VAT Registration No." then
                    exit;

                if not Customer.Get("Bill-to Customer No.") then
                    exit;

                if "VAT Registration No." = Customer."VAT Registration No." then
                    exit;

                if not VATRegistrationNoFormat.Test("VAT Registration No.", Customer."Country/Region Code", Customer."No.", Database::Customer) then
                    exit;

                Customer."VAT Registration No." := "VAT Registration No.";
                ApplicableCountryCode := Customer."Country/Region Code";
                if ApplicableCountryCode = '' then
                    ApplicableCountryCode := VATRegistrationNoFormat."Country/Region Code";

                if not VATRegNoSrvConfig.VATRegNoSrvIsEnabled() then begin
                    Customer.Modify(true);
                    exit;
                end;

                VATRegistrationLogMgt.CheckVIESForVATNo(ResultRecRef, VATRegistrationLog, Customer, Customer."No.",
                  ApplicableCountryCode, VATRegistrationLog."Account Type"::Customer.AsInteger());

                if VATRegistrationLog.Status = VATRegistrationLog.Status::Valid then begin
                    Message(ValidVATNoMsg);
                    Customer.Modify(true);
                end else
                    Message(InvalidVatRegNoMsg);
            end;
        }
        field(48; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Header"."No." where("Document Type" = const(Order));
        }
        field(51; "Job No."; Code[20])
        {
            Caption = 'Project No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No.";
            ToolTip = 'Specifies the project number for the sales advance document.';
            Editable = false;

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Job No."));
            end;
        }
        field(52; "Job Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Job No."));
            ToolTip = 'Specifies the project task number of the sales advance document.';
            Editable = false;

            trigger OnValidate()
            begin
                UpdateDimensionsFromJobTask();
            end;
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
            TableRelation = "Bank Account";

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
            begin
                if "Bank Account Code" = '' then begin
                    UpdateBankInfo('', '', '', '', '', '', '');
                    exit;
                end;

                BankAccount.Get("Bank Account Code");
                UpdateBankInfo(
                  BankAccount."No.",
                  BankAccount."Bank Account No.",
                  BankAccount."Bank Branch No.",
                  BankAccount.Name,
                  BankAccount."Transit No.",
                  BankAccount.IBAN,
                  BankAccount."SWIFT Code");
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
            Editable = false;
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
            Editable = false;
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
            Editable = false;
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
                if not UserSetupManagement.CheckRespCenter(0, "Responsibility Center") then
                    Error(
                      IdentSetUpErr,
                      ResponsibilityCenter.TableCaption, UserSetupManagement.GetSalesFilter());

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
                SetCompanyBankAccount();
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
        field(85; "Automatic Post VAT Document"; Boolean)
        {
            Caption = 'Automatic Post VAT Document';
            DataClassification = CustomerContent;
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
            CalcFormula = sum("Sales Adv. Letter Line CZZ"."Amount Including VAT" where("Document No." = field("No.")));
        }
        field(201; "Amount Including VAT (LCY)"; Decimal)
        {
            Caption = 'Amount Including VAT (LCY)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Sales Adv. Letter Line CZZ"."Amount Including VAT (LCY)" where("Document No." = field("No.")));
        }
        field(205; "To Pay"; Decimal)
        {
            Caption = 'To Pay Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Sales Adv. Letter Entry CZZ".Amount where("Sales Adv. Letter No." = field("No."), "Entry Type" = filter("Initial Entry" | Payment | Close)));
        }
        field(206; "To Pay (LCY)"; Decimal)
        {
            Caption = 'To Pay Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Sales Adv. Letter Entry CZZ"."Amount (LCY)" where("Sales Adv. Letter No." = field("No."), "Entry Type" = filter("Initial Entry" | Payment | Close)));
        }
        field(210; "To Use"; Decimal)
        {
            Caption = 'To Use Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum("Sales Adv. Letter Entry CZZ".Amount where("Sales Adv. Letter No." = field("No."), "Entry Type" = filter(Payment | Usage | Close)));
        }
        field(211; "To Use (LCY)"; Decimal)
        {
            Caption = 'To Use Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum("Sales Adv. Letter Entry CZZ"."Amount (LCY)" where("Sales Adv. Letter No." = field("No."), "Entry Type" = filter(Payment | Usage | Close | "VAT Adjustment")));
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
                    IncomingDocument.SetSalesAdvanceCZZ(Rec);
            end;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(SK1; "Bill-to Customer No.", Status)
        {
        }
        key(SK2; "Order No.")
        {
        }
        key(SK3; "Job No.")
        {
        }
    }

    trigger OnInsert()
    begin
        InitInsert();

        if "Salesperson Code" = '' then
            SetDefaultSalesperson();
    end;

    trigger OnDelete()
    var
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        DocumentAttachment: Record "Document Attachment";
    begin
        if not UserSetupManagement.CheckRespCenter(0, "Responsibility Center") then
            Error(
              DocumentDeleteErr,
              ResponsibilityCenter.TableCaption(), UserSetupManagement.GetSalesFilter());

        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", "No.");
        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1', SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        if not SalesAdvLetterEntryCZZ.IsEmpty() then
            Error(PostedEntriesExistErr);

        SalesAdvLetterLineCZZ.SetRange("Document No.", "No.");
        if not SalesAdvLetterLineCZZ.IsEmpty() then
            SalesAdvLetterLineCZZ.DeleteAll(true);

        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", "No.");
        if not SalesAdvLetterEntryCZZ.IsEmpty() then
            SalesAdvLetterEntryCZZ.DeleteAll();

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
        AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", "No.");
        if not AdvanceLetterApplicationCZZ.IsEmpty() then
            AdvanceLetterApplicationCZZ.DeleteAll();

        DocumentAttachment.SetRange("Table ID", Database::"Sales Adv. Letter Header CZZ");
        DocumentAttachment.SetRange("No.", "No.");
        if not DocumentAttachment.IsEmpty() then
            DocumentAttachment.DeleteAll();

        Validate("Incoming Document Entry No.", 0);
        DeleteRecordInApprovalRequest();
    end;

    var
        PostCode: Record "Post Code";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Customer: Record Customer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ResponsibilityCenter: Record "Responsibility Center";
#if not CLEAN24
        NoSeriesManagement: Codeunit NoSeriesManagement;
#endif
        DimensionManagement: Codeunit DimensionManagement;
        UserSetupManagement: Codeunit "User Setup Management";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        HideValidationDialog: Boolean;
        SkipBillToContact: Boolean;
        HasSalesSetup: Boolean;
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        DocumentResetErr: Label 'You cannot reset %1 because the document still has one or more lines.', Comment = '%1 = a Field Caption like Bill-to Contact No.';
        DocumentDeleteErr: Label 'You cannot delete this document. Your identification is set up to process from %1 %2 only.', Comment = '%1 = table caption of responsibility center, %2 = code of responsibility center';
        PostedEntriesExistErr: Label 'You cannot delete this document because there are posted entries.';

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

        "Automatic Post VAT Document" := AdvanceLetterTemplateCZZ."Automatic Post VAT Document";

        if "Posting Date" = 0D then
            "Posting Date" := WorkDate();

        if SalesReceivablesSetup."Default Posting Date" = SalesReceivablesSetup."Default Posting Date"::"No Date" then
            "Posting Date" := 0D;

        "Document Date" := WorkDate();
        "VAT Date" := GeneralLedgerSetup.GetVATDate("Posting Date", "Document Date");

        "Posting Description" := AdvanceLbl + ' ' + "No.";
        "Responsibility Center" := UserSetupManagement.GetRespCenter(0, "Responsibility Center");

        OnAfterInitRecord(Rec);
    end;

    local procedure SetDefaultSalesperson()
    var
        UserSetupSalespersonCode: Code[20];
    begin
        UserSetupSalespersonCode := GetUserSetupSalespersonCode();
        if UserSetupSalespersonCode <> '' then
            if SalespersonPurchaser.Get(UserSetupSalespersonCode) then
                if not SalespersonPurchaser.VerifySalesPersonPurchaserPrivacyBlocked(SalespersonPurchaser) then
                    Validate("Salesperson Code", UserSetupSalespersonCode);
    end;

    local procedure LookupContact(CustomerNo: Code[20]; ContactNo: Code[20]; var Contact: Record Contact)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        if ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Customer, CustomerNo) then
            Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.")
        else
            Contact.SetRange("Company No.", '');
        if ContactNo <> '' then
            if Contact.Get(ContactNo) then;
    end;

    local procedure InitFromContact(ContactNo: Code[20]; CustomerNo: Code[20]; ContactCaption: Text): Boolean
    begin
        if (ContactNo = '') and (CustomerNo = '') then begin
            if LinesExist() then
                Error(DocumentResetErr, ContactCaption);
            Init();
            GetSetup();
            "No. Series" := xRec."No. Series";
            OnInitFromContactOnBeforeInitRecord(Rec, xRec);
            InitRecord();
            OnInitFromContactOnAfterInitNoSeries(Rec, xRec);
            exit(true);
        end;
    end;

    local procedure CheckContactRelatedToCustomerCompany(ContactNo: Code[20]; CustomerNo: Code[20]; CurrFieldNo: Integer);
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        IsHandled: Boolean;
        ContactRelateErr: Label 'Contact %1 %2 is related to a different company than customer %3.', Comment = '%1 = Contact No., %2 = Contact Name, %3 = Customer No.';
    begin
        IsHandled := false;
        OnBeforeCheckContactRelatedToCustomerCompany(Rec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        Contact.Get(ContactNo);
        if ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Customer, CustomerNo) then
            if (ContactBusinessRelation."Contact No." <> Contact."Company No.") and (ContactBusinessRelation."Contact No." <> Contact."No.") then
                Error(ContactRelateErr, Contact."No.", Contact.Name, CustomerNo);
    end;

    local procedure UpdateBillToCust(ContactNo: Code[20])
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        Customer2: Record Customer;
        Contact: Record Contact;
        ContactBusinessRelationFound: Boolean;
        IsHandled: Boolean;
        ContactIsNotRelatedErr: Label 'Contact %1 %2 is not related to customer %3.', Comment = '%1 = Contact No., %2 = Contact Name, %3 = Customer No.';
        ContactIsNotRelatedToAnyCostomerErr: Label 'Contact %1 %2 is not related to a customer.', Comment = '%1 = Contact No., %2 = Contact Name';
    begin
        IsHandled := false;
        OnBeforeUpdateBillToCust(Rec, ContactNo, IsHandled);
        if IsHandled then
            exit;

        if not Contact.Get(ContactNo) then begin
            "Bill-to Contact" := '';
            exit;
        end;
        "Bill-to Contact No." := Contact."No.";

        if Customer2.Get("Bill-to Customer No.") and (Contact.Type = Contact.Type::Company) then
            "Bill-to Contact" := Customer2.Contact
        else
            if Contact.Type = Contact.Type::Company then
                "Bill-to Contact" := ''
            else
                "Bill-to Contact" := Contact.Name;

        if Contact.Type = Contact.Type::Person then
            ContactBusinessRelationFound := ContactBusinessRelation.FindByContact(ContactBusinessRelation."Link to Table"::Customer, Contact."No.");
        if not ContactBusinessRelationFound then begin
            IsHandled := false;
            OnUpdateBillToCustOnBeforeFindContactBusinessRelation(Contact, ContactBusinessRelation, ContactBusinessRelationFound, IsHandled);
            if not IsHandled then
                ContactBusinessRelationFound :=
                    ContactBusinessRelation.FindByContact(ContactBusinessRelation."Link to Table"::Customer, Contact."Company No.");
        end;
        if ContactBusinessRelationFound then begin
            if "Bill-to Customer No." = '' then begin
                SkipBillToContact := true;
                Validate("Bill-to Customer No.", ContactBusinessRelation."No.");
                SkipBillToContact := false;
            end else
                if "Bill-to Customer No." <> ContactBusinessRelation."No." then
                    Error(ContactIsNotRelatedErr, Contact."No.", Contact.Name, "Bill-to Customer No.");
        end else begin
            IsHandled := false;
            OnUpdateBillToCustOnBeforeContactIsNotRelatedToAnyCostomerErr(Rec, Contact, ContactBusinessRelation, IsHandled);
            if not IsHandled then
                Error(ContactIsNotRelatedToAnyCostomerErr, Contact."No.", Contact.Name);
        end;

        OnAfterUpdateBillToCust(Rec, Contact);
    end;

    local procedure GetSetup()
    begin
        if not HasSalesSetup then begin
            SalesReceivablesSetup.Get();
            GeneralLedgerSetup.Get();
            HasSalesSetup := true;
        end;

        if AdvanceLetterTemplateCZZ.Code <> "Advance Letter Code" then
            AdvanceLetterTemplateCZZ.Get("Advance Letter Code");
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure UpdateBankInfo(BankAccountCode: Code[20]; BankAccountNo: Text[30]; BankBranchNo: Text[20]; BankName: Text[100]; TransitNo: Text[20]; IBANCode: Code[50]; SWIFTCode: Code[20])
    begin
        "Bank Account Code" := BankAccountCode;
        "Bank Account No." := BankAccountNo;
        "Bank Branch No." := BankBranchNo;
        "Bank Name" := BankName;
        "Transit No." := TransitNo;
        IBAN := IBANCode;
        "SWIFT Code" := SWIFTCode;
        OnAfterUpdateBankInfo(Rec);
    end;

    local procedure GetCustomer(CustomerNo: Code[20])
    begin
        if CustomerNo <> '' then begin
            if CustomerNo <> Customer."No." then
                Customer.Get(CustomerNo);
        end else
            Clear(Customer);
    end;

    local procedure SetBillToCustomerAddressFieldsFromCustomer(var BillToCustomer: Record Customer)
    begin
        "Bill-to Name" := BillToCustomer.Name;
        "Bill-to Name 2" := BillToCustomer."Name 2";
        if BillToCustomerIsReplaced() or ShouldCopyAddressFromBillToCustomer(BillToCustomer) then begin
            "Bill-to Address" := BillToCustomer.Address;
            "Bill-to Address 2" := BillToCustomer."Address 2";
            "Bill-to City" := BillToCustomer.City;
            "Bill-to Post Code" := BillToCustomer."Post Code";
            "Bill-to County" := BillToCustomer.County;
            "Bill-to Country/Region Code" := BillToCustomer."Country/Region Code";
        end;
        if not SkipBillToContact then
            "Bill-to Contact" := BillToCustomer.Contact;
        "Payment Terms Code" := BillToCustomer."Payment Terms Code";
        "Payment Method Code" := BillToCustomer."Payment Method Code";
        GetSetup();
        if AdvanceLetterTemplateCZZ."VAT Bus. Posting Group" <> '' then
            "VAT Bus. Posting Group" := AdvanceLetterTemplateCZZ."VAT Bus. Posting Group"
        else
            "VAT Bus. Posting Group" := BillToCustomer."VAT Bus. Posting Group";
        "VAT Country/Region Code" := BillToCustomer."Country/Region Code";
        "VAT Registration No." := BillToCustomer."VAT Registration No.";
        "Currency Code" := BillToCustomer."Currency Code";
        "Language Code" := BillToCustomer."Language Code";
        "Format Region" := BillToCustomer."Format Region";
        SetSalespersonCode(BillToCustomer."Salesperson Code", "Salesperson Code");
        "Registration No." := BillToCustomer.GetRegistrationNoTrimmedCZL();
        "Tax Registration No." := BillToCustomer."Tax Registration No. CZL";
        "Responsibility Center" := UserSetupManagement.GetRespCenter(0, BillToCustomer."Responsibility Center");

        OnAfterSetFieldsBilltoCustomer(Rec, BillToCustomer);
    end;

    local procedure BillToCustomerIsReplaced(): Boolean
    begin
        exit((xRec."Bill-to Customer No." <> '') and (xRec."Bill-to Customer No." <> "Bill-to Customer No."));
    end;

    local procedure ShouldCopyAddressFromBillToCustomer(BillToCustomer: Record Customer): Boolean
    begin
        exit((not HasBillToAddress()) and BillToCustomer.HasAddress());
    end;

    local procedure HasBillToAddress(): Boolean
    begin
        case true of
            "Bill-to Address" <> '':
                exit(true);
            "Bill-to Address 2" <> '':
                exit(true);
            "Bill-to City" <> '':
                exit(true);
            "Bill-to Country/Region Code" <> '':
                exit(true);
            "Bill-to County" <> '':
                exit(true);
            "Bill-to Post Code" <> '':
                exit(true);
            "Bill-to Contact" <> '':
                exit(true);
        end;

        exit(false);
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

    local procedure RevertCurrencyCodeAndPostingDate()
    begin
        "Currency Code" := xRec."Currency Code";
        "Posting Date" := xRec."Posting Date";
    end;

    procedure UpdateBillToCont(CustomerNo: Code[20])
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        Customer2: Record Customer;
        Contact: Record Contact;
    begin
        if Customer2.Get(CustomerNo) then begin
            if Customer2."Primary Contact No." <> '' then
                "Bill-to Contact No." := Customer2."Primary Contact No."
            else begin
                ContactBusinessRelation.Reset();
                ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
                ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                ContactBusinessRelation.SetRange("No.", "Bill-to Customer No.");
                if ContactBusinessRelation.FindFirst() then
                    "Bill-to Contact No." := ContactBusinessRelation."Contact No."
                else
                    "Bill-to Contact No." := '';
            end;
            "Bill-to Contact" := Customer2.Contact;
        end;
        if "Bill-to Contact No." <> '' then
            if Contact.Get("Bill-to Contact No.") then
                Contact.CheckIfPrivacyBlockedGeneric();

        OnAfterUpdateBillToCont(Rec, Customer2, Contact);
    end;

    procedure ShouldSearchForCustomerByName(CustomerNo: Code[20]): Boolean
    var
        Customer2: Record Customer;
    begin
        if CustomerNo = '' then
            exit(true);

        if not Customer2.Get(CustomerNo) then
            exit(true);

        exit(not Customer2."Disable Search by Name");
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

    local procedure SetSalespersonCode(SalesPersonCodeToCheck: Code[20]; var SalesPersonCodeToAssign: Code[20])
    var
        UserSetupSalespersonCode: Code[20];
    begin
        UserSetupSalespersonCode := GetUserSetupSalespersonCode();
        if SalesPersonCodeToCheck <> '' then begin
            if SalespersonPurchaser.Get(SalesPersonCodeToCheck) then
                if SalespersonPurchaser.VerifySalesPersonPurchaserPrivacyBlocked(SalespersonPurchaser) then begin
                    if UserSetupSalespersonCode = '' then
                        SalesPersonCodeToAssign := ''
                end else
                    SalesPersonCodeToAssign := SalesPersonCodeToCheck;
        end else
            if UserSetupSalespersonCode = '' then
                SalesPersonCodeToAssign := '';
    end;

    local procedure GetUserSetupSalespersonCode(): Code[20]
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId) then
            exit;

        exit(UserSetup."Salespers./Purch. Code");
    end;

    procedure LinesExist(): Boolean
    var
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        SalesAdvLetterLineCZZ.SetRange("Document No.", "No.");
        exit(not SalesAdvLetterLineCZZ.IsEmpty());
    end;

    procedure RecreateLines(ChangedFieldName: Text)
    var
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        TempSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ" temporary;
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmText: Text;
        IsHandled: Boolean;
        Confirmed: Boolean;
        RecreateSalesLinesMsg: Label 'If you change %1, the existing sales lines will be deleted and new sales lines based on the new information on the header will be created.\\Do you want to continue?', Comment = '%1: FieldCaption';
        RecreateSalesLinesCancelErr: Label 'You must delete the existing sales lines before you can change %1.', Comment = '%1 - Field Name, Sample: You must delete the existing sales lines before you can change Currency Code.';
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
            ConfirmText := StrSubstNo(RecreateSalesLinesMsg, ChangedFieldName);
            Confirmed := ConfirmManagement.GetResponseOrDefault(ConfirmText, false);
        end;

        if Confirmed then begin
            SalesAdvLetterLineCZZ.LockTable();
            Modify();
            SalesAdvLetterLineCZZ.SetRange("Document No.", "No.");
            SalesAdvLetterLineCZZ.FindSet();
            repeat
                TempSalesAdvLetterLineCZZ := SalesAdvLetterLineCZZ;
                TempSalesAdvLetterLineCZZ.Insert();
            until SalesAdvLetterLineCZZ.Next() = 0;

            SalesAdvLetterLineCZZ.DeleteAll();

            SalesAdvLetterLineCZZ."Line No." := 0;
            TempSalesAdvLetterLineCZZ.FindSet();
            repeat
                SalesAdvLetterLineCZZ.Init();
                SalesAdvLetterLineCZZ."Document No." := "No.";
                SalesAdvLetterLineCZZ."Line No." += 10000;
                SalesAdvLetterLineCZZ."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
                SalesAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", TempSalesAdvLetterLineCZZ."VAT Prod. Posting Group");
                SalesAdvLetterLineCZZ.Description := TempSalesAdvLetterLineCZZ.Description;
                SalesAdvLetterLineCZZ.Validate("Amount Including VAT", TempSalesAdvLetterLineCZZ."Amount Including VAT");
                SalesAdvLetterLineCZZ.Insert(true);
            until TempSalesAdvLetterLineCZZ.Next() = 0;

            TempSalesAdvLetterLineCZZ.DeleteAll();
        end else
            Error(RecreateSalesLinesCancelErr, ChangedFieldName);
    end;

    procedure UpdateLinesByFieldNo(ChangedFieldNo: Integer)
    var
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
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

        SalesAdvLetterLineCZZ.LockTable();
        if not Rec.Modify() then
            exit;

        SalesAdvLetterLineCZZ.Reset();
        SalesAdvLetterLineCZZ.SetRange("Document No.", "No.");
        if SalesAdvLetterLineCZZ.FindSet() then
            repeat
                IsHandled := false;
                OnBeforeLineByChangedFieldNo(Rec, SalesAdvLetterLineCZZ, ChangedFieldNo, xRec, IsHandled);
                if not IsHandled then
                    case ChangedFieldNo of
                        FieldNo("Currency Factor"):
                            SalesAdvLetterLineCZZ.Validate("Amount Including VAT");
                        else
                            OnUpdateLineByChangedFieldName(Rec, SalesAdvLetterLineCZZ, Field.FieldName, ChangedFieldNo);
                    end;
                OnUpdateLinesByFieldNoOnBeforeLineModify(SalesAdvLetterLineCZZ, ChangedFieldNo, CurrFieldNo);
                SalesAdvLetterLineCZZ.Modify(true);
            until SalesAdvLetterLineCZZ.Next() = 0;

        OnAfterUpdateLinesByFieldNo(Rec, xRec, ChangedFieldNo);
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
        DimensionManagement.AddDimSource(DefaultDimSource, Database::Customer, Rec."Bill-to Customer No.", FieldNo = Rec.FieldNo("Bill-to Customer No."));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"Salesperson/Purchaser", Rec."Salesperson Code", FieldNo = Rec.FieldNo("Salesperson Code"));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"Responsibility Center", Rec."Responsibility Center", FieldNo = Rec.FieldNo("Responsibility Center"));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::Job, Rec."Job No.", FieldNo = Rec.FieldNo("Job No."));

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

    local procedure UpdateDimensionsFromJobTask()
    var
        SourceCodeSetup: Record "Source Code Setup";
        DimSetArrID: array[10] of Integer;
        DimValue1: Code[20];
        DimValue2: Code[20];
    begin
        SourceCodeSetup.Get();
        DimSetArrID[1] := "Dimension Set ID";
        DimSetArrID[2] :=
            DimensionManagement.CreateDimSetFromJobTaskDim("Job No.", "Job Task No.", DimValue1, DimValue2);

        "Dimension Set ID" :=
            DimensionManagement.GetCombinedDimensionSetID(
            DimSetArrID, DimValue1, DimValue2);

        "Shortcut Dimension 1 Code" := DimValue1;
        "Shortcut Dimension 2 Code" := DimValue2;
    end;

    procedure SetSecurityFilterOnRespCenter()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetSecurityFilterOnRespCenter(Rec, IsHandled);
        if IsHandled then
            exit;

        if UserSetupManagement.GetSalesFilter() <> '' then begin
            FilterGroup(2);
            SetRange("Responsibility Center", UserSetupManagement.GetSalesFilter());
            FilterGroup(0);
        end;
    end;

    procedure TestStatusOpen()
    begin
        OnBeforeTestStatusOpen(Rec);

        TestField(Status, Status::New);

        OnAfterTestStatusOpen(Rec);
    end;

    procedure GetVATAmounts(var VATBaseAmount: Decimal; var VATAmount: Decimal; var VATBaseAmountLCY: Decimal; var VATAmountLCY: Decimal)
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", "No.");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ.SetRange("Auxiliary Entry", false);
        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1', SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        SalesAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Amount", "VAT Base Amount (LCY)", "VAT Amount (LCY)");
        VATBaseAmount := SalesAdvLetterEntryCZZ."VAT Base Amount";
        VATAmount := SalesAdvLetterEntryCZZ."VAT Amount";
        VATBaseAmountLCY := SalesAdvLetterEntryCZZ."VAT Base Amount (LCY)";
        VATAmountLCY := SalesAdvLetterEntryCZZ."VAT Amount (LCY)";
    end;

    procedure PrintRecords(ShowRequestPage: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePrintRecords(DummyReportSelections, Rec, ShowRequestPage, IsHandled);
        if not IsHandled then
            DocumentSendingProfile.TrySendToPrinter(
              DummyReportSelections.Usage::"Sales Advance Letter CZZ".AsInteger(), Rec, FieldNo("Bill-to Customer No."), ShowRequestPage);
    end;

    procedure PrintToDocumentAttachment()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        SalesAdvLetterHeaderCZZ.Copy(Rec);
        if SalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                DoPrintToDocumentAttachment(SalesAdvLetterHeaderCZZ);
            until SalesAdvLetterHeaderCZZ.Next() = 0;
    end;

    local procedure DoPrintToDocumentAttachment(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        ReportSelections: Record "Report Selections";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDoPrintToDocumentAttachment(SalesAdvLetterHeaderCZZ, IsHandled);
        if IsHandled then
            exit;

        SalesAdvLetterHeaderCZZ.SetRecFilter();
        ReportSelections.SaveAsDocumentAttachment(
            ReportSelections.Usage::"Sales Advance Letter CZZ".AsInteger(), SalesAdvLetterHeaderCZZ, SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterHeaderCZZ."Bill-to Customer No.", true);
    end;

    procedure EmailRecords(ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        ReportDistributionManagement: Codeunit "Report Distribution Management";
        DocumentTypeTxt: Text[50];
        IsHandled: Boolean;
    begin
        DocumentTypeTxt := ReportDistributionManagement.GetFullDocumentTypeText(Rec);

        IsHandled := false;
        OnBeforeEmailRecords(DummyReportSelections, Rec, DocumentTypeTxt, ShowDialog, IsHandled);
        if not IsHandled then
            DocumentSendingProfile.TrySendToEMail(
              DummyReportSelections.Usage::"Sales Advance Letter CZZ".AsInteger(), Rec, FieldNo("No."), DocumentTypeTxt,
              FieldNo("Bill-to Customer No."), ShowDialog);
    end;

    procedure CheckSalesAdvanceLetterReleaseRestrictions()
    begin
        OnCheckSalesAdvanceLetterReleaseRestrictions();
    end;

    procedure CheckSalesAdvanceLetterPostRestrictions()
    begin
        OnCheckSalesAdvanceLetterPostRestrictions();
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

    local procedure SetCompanyBankAccount()
    var
        BankAccount: Record "Bank Account";
    begin
        Validate("Bank Account Code", BankAccount.GetDefaultBankAccountNoForCurrency("Currency Code"));
    end;

    internal procedure PerformManualRelease(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := SalesAdvLetterHeaderCZZ.Count();
        SalesAdvLetterHeaderCZZ.SetRange(Status, SalesAdvLetterHeaderCZZ.Status::New);
        NoOfSkipped := NoOfSelected - SalesAdvLetterHeaderCZZ.Count();
        BatchProcessingMgt.BatchProcess(SalesAdvLetterHeaderCZZ, Codeunit::"S.Adv.Let.Doc.Man.Release CZZ", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;

    internal procedure PerformManualReopen(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := SalesAdvLetterHeaderCZZ.Count();
        SalesAdvLetterHeaderCZZ.SetRange(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");
        NoOfSkipped := NoOfSelected - SalesAdvLetterHeaderCZZ.Count();
        BatchProcessingMgt.BatchProcess(SalesAdvLetterHeaderCZZ, Codeunit::"S.Adv.Let.Doc.Man.Reopen CZZ", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
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

    procedure CreateSalesAdvInvoicePaymentQRCodeString(): Text
    var
        CompanyInformation: Record "Company Information";
        IBANCode: Code[50];
        SWIFT: Code[20];
        QRCode: Text;
        InvoiceTxt: Label 'Invoice';
    begin
        if "Bank Account Code" <> '' then begin
            IBANCode := IBAN;
            SWIFT := "SWIFT Code";
        end else begin
            CompanyInformation.Get();
            IBANCode := CompanyInformation.IBAN;
            SWIFT := CompanyInformation."SWIFT Code";
            if IBAN <> '' then
                IBANCode := IBAN;
            if "SWIFT Code" <> '' then
                SWIFT := "SWIFT Code";
        end;

        CalcFields("Amount Including VAT");

        QRCode := 'SPD*1.0*';

        // ACC
        if SWIFT <> '' then
            QRCode := QRCode + 'ACC:' + IBANCode + '+' + SWIFT + '*'
        else
            QRCode := QRCode + 'ACC:' + IBANCode + '*';

        // AM
        QRCode := QRCode + 'AM:' + format("Amount Including VAT", 0, '<Precision,2:2><Standard Format,2>') + '*';

        // CC
        if "Currency Code" = '' then begin
            GetSetup();
            QRCode := QRCode + 'CC:' + UpperCase(GeneralLedgerSetup."LCY Code") + '*';
        end else
            QRCode := QRCode + 'CC:' + UpperCase("Currency Code") + '*';

        // DT
        QRCode := QRCode + 'DT:' + format("Advance Due Date", 0, '<Year4><Month,2><Day,2>') + '*';

        // MSG
        QRCode := QRCode + 'MSG:' + InvoiceTxt + ' ' + "No." + '*';

        // XVS
        QRCode := QRCode + 'X-VS:' + "Variable Symbol" + '*';

        // X-KS
        QRCode := QRCode + 'X-KS:' + "Constant Symbol" + '*';

        if IBANCode = '' then
            QRCode := '';
        OnBeforeExitSalesAdvInvoicePaymentQRCodeString(Rec, QRCode);
        exit(QRCode);
    end;

    procedure CheckPaymentQRCodePrintIBAN()
    var
        PaymentMethod: Record "Payment Method";
        CompanyInformation: Record "Company Information";
    begin
        if "Payment Method Code" = '' then
            exit;

        GetSetup();

        if not SalesReceivablesSetup."Print QR Payment CZL" then
            exit;

        PaymentMethod.Get("Payment Method Code");
        if not PaymentMethod."Print QR Payment CZL" then
            exit;

        if "Bank Account Code" = '' then begin
            CompanyInformation.Get();
            if CompanyInformation.IBAN <> '' then
                exit;
        end else
            if IBAN <> '' then
                exit;

        ConfirmCheckPaymentQRCodePrintIBAN();
    end;

    local procedure ConfirmCheckPaymentQRCodePrintIBAN()
    var
        EmptyIBANQst: Label 'Bank Account has empty IBAN, QR payment will not be printed on Sales document.\\Do you want to continue?';
    begin
        ConfirmProcess(EmptyIBANQst);
    end;

    local procedure ConfirmProcess(ConfirmQuestion: Text)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        IsHandled: Boolean;
    begin
        OnBeforeConfirmProcess(ConfirmQuestion, IsHandled);
        if IsHandled then
            exit;
        if not IsConfirmDialogAllowed() then
            exit;
        if not ConfirmManagement.GetResponse(ConfirmQuestion, false) then
            Error('');
    end;

    local procedure IsConfirmDialogAllowed() IsAllowed: Boolean
    begin
        IsAllowed := GuiAllowed();
        OnIsConfirmDialogAllowed(IsAllowed);
    end;

    procedure UpdateStatus(AdvanceLetterDocStatus: Enum "Advance Letter Doc. Status CZZ")
    var
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
    begin
        SalesAdvLetterManagementCZZ.UpdateStatus(Rec, AdvanceLetterDocStatus);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateBillToPostCode(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupBillToPostCode(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmBillToContactNoChange(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CurrentFieldNo: Integer; var Confirmed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckContactRelatedToCustomerCompany(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CurrFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateBillToCust(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; ContactNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateBillToCustOnBeforeFindContactBusinessRelation(Contact: Record Contact; var ContactBusinessRelation: Record "Contact Business Relation"; var ContactBusinessRelationFound: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateBillToCustOnBeforeContactIsNotRelatedToAnyCostomerErr(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Contact: Record Contact; var ContactBusinessRelation: Record "Contact Business Relation"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBillToCust(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Contact: Record Contact)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateBillToCustomerNoOnAfterConfirmed(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFieldsBilltoCustomer(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateCurrencyFactor(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var Updated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateCurrencyFactor(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; HideValidationDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmUpdateCurrencyFactor(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var HideValidationDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBillToCont(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Customer: Record Customer; Contact: Record Contact)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateBillToCustomerName(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePaymentTermsCodeOnBeforeCalcDueDate(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CalledByFieldNo: Integer; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePaymentTermsCodeOnBeforeValidateDueDateWhenBlank(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateVATRegistrationNo(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowDocDim(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitFromContactOnBeforeInitRecord(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitFromContactOnAfterInitNoSeries(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRecreateLinesHandler(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; ChangedFieldName: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDim(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDim(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CurrentFieldNo: Integer; OldDimSetID: Integer)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeTestStatusOpen(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterTestStatusOpen(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitInsert(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitInsertOnBeforeInitRecord(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBankInfo(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCheckSalesAdvanceLetterReleaseRestrictions()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCheckSalesAdvanceLetterPostRestrictions()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDeleteRecordInApprovalRequest(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintRecords(var ReportSelections: Record "Report Selections"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; ShowRequestPage: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEmailRecords(var ReportSelections: Record "Report Selections"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; DocTxt: Text; ShowDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateLinesByFieldNo(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; ChangedFieldNo: Integer; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLineByChangedFieldNo(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; ChangedFieldNo: Integer; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateLineByChangedFieldName(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; ChangedFieldName: Text[100]; ChangedFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateLinesByFieldNoOnBeforeLineModify(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; ChangedFieldNo: Integer; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateLinesByFieldNo(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; ChangedFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDoPrintToDocumentAttachment(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSecurityFilterOnRespCenter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateDocumentDateWithPostingDate(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; CurrFieldNo: Integer; var IsHandled: Boolean; xSalesAdvLetterHeader: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExitSalesAdvInvoicePaymentQRCodeString(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var QRCode: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmProcess(ConfirmQuestion: Text; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsConfirmDialogAllowed(var IsAllowed: Boolean)
    begin
    end;
}
