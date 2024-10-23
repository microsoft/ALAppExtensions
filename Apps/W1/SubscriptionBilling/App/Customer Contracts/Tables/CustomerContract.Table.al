namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using System.Security.User;
using System.Reflection;
using System.Environment.Configuration;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Projects.Project.Job;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Outlook;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Currency;
using Microsoft.Bank.BankAccount;
using System.Security.AccessControl;

table 8052 "Customer Contract"
{
    Caption = 'Customer Contract';
    DataClassification = CustomerContent;
    DataCaptionFields = "No.", "Sell-to Customer Name";
    LookupPageId = "Customer Contracts";
    DrillDownPageId = "Customer Contracts";
    Access = Internal;

    fields
    {
        field(2; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                if ("Sell-to Customer No." <> xRec."Sell-to Customer No.") and
                   (xRec."Sell-to Customer No." <> '')
                then begin
                    if GetHideValidationDialog() or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := ConfirmManagement.GetResponse(StrSubstNo(ConfirmChangeQst, SellToCustomerTxt), false);
                    if Confirmed then begin
                        if "Sell-to Customer No." = '' then begin
                            Init();
                            OnValidateSellToCustomerNoAfterInit(Rec, xRec);
                            GetServiceContractSetup();
                            "No. Series" := xRec."No. Series";
                            exit;
                        end;
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                GetCust("Sell-to Customer No.");

                CopySellToCustomerAddressFieldsFromCustomer(Cust);

                if Cust."Bill-to Customer No." <> '' then
                    Validate("Bill-to Customer No.", Cust."Bill-to Customer No.")
                else begin
                    if "Bill-to Customer No." = "Sell-to Customer No." then
                        SkipBillToContact := true;
                    Validate("Bill-to Customer No.", "Sell-to Customer No.");
                    SkipBillToContact := false;
                end;

                Validate("Ship-to Code", Cust."Ship-to Code");
                if not SkipSellToContact then
                    UpdateSellToCont("Sell-to Customer No.");

                if (xRec."Sell-to Customer No." <> '') and (xRec."Sell-to Customer No." <> "Sell-to Customer No.") then
                    RecallModifyAddressNotification(GetModifyCustomerAddressNotificationId());
            end;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GetServiceContractSetup();
                    NoSeries.TestManual(ServiceContractSetup."Customer Contract Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(4; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = Customer;

            trigger OnValidate()
            begin
                if (xRec."Bill-to Customer No." <> "Bill-to Customer No.") and
                   (xRec."Bill-to Customer No." <> '')
                then begin
                    if GetHideValidationDialog() or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := ConfirmManagement.GetResponse(StrSubstNo(ConfirmChangeQst, BillToCustomerTxt), false);
                    if Confirmed then
                        OnValidateBillToCustomerNoOnAfterConfirmed(Rec)
                    else
                        "Bill-to Customer No." := xRec."Bill-to Customer No.";
                end;

                GetCust("Bill-to Customer No.");

                SetBillToCustomerAddressFieldsFromCustomer(Cust);

                CreateDim(
                  Database::Customer, "Bill-to Customer No.",
                  Database::"Salesperson/Purchaser", "Salesperson Code",
                  Database::Job, "Dimension from Job No.");

                Validate("Payment Terms Code");
                Validate("Payment Method Code");
                Validate("Currency Code");

                if not SkipBillToContact then
                    UpdateBillToCont("Bill-to Customer No.");

                if (xRec."Bill-to Customer No." <> '') and (xRec."Bill-to Customer No." <> "Bill-to Customer No.") then
                    RecallModifyAddressNotification(GetModifyBillToCustomerAddressNotificationId());
            end;
        }
        field(5; "Bill-to Name"; Text[100])
        {
            Caption = 'Bill-to Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                Customer: Record Customer;
            begin
                if "Bill-to Customer No." <> '' then
                    Customer.Get("Bill-to Customer No.");

                if Customer.SelectCustomer(Customer) then begin
                    xRec := Rec;
                    "Bill-to Name" := Customer.Name;
                    Validate("Bill-to Customer No.", Customer."No.");
                end;
            end;

            trigger OnValidate()
            var
                Customer: Record Customer;
                SalesHeader: Record "Sales Header";
            begin
                OnBeforeValidateBillToCustomerName(Rec, Customer);

                if SalesHeader.ShouldSearchForCustomerByName("Bill-to Customer No.") then
                    Validate("Bill-to Customer No.", Customer.GetCustNo("Bill-to Name"));
            end;
        }
        field(6; "Bill-to Name 2"; Text[50])
        {
            Caption = 'Bill-to Name 2';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Bill-to Address"; Text[100])
        {
            Caption = 'Bill-to Address';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyBillToCustomerAddress();
            end;
        }
        field(8; "Bill-to Address 2"; Text[50])
        {
            Caption = 'Bill-to Address 2';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyBillToCustomerAddress();
            end;
        }
        field(9; "Bill-to City"; Text[30])
        {
            Caption = 'Bill-to City';
            TableRelation = if ("Bill-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Bill-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Bill-to Country/Region Code"));
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

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
                ModifyBillToCustomerAddress();
            end;
        }
        field(10; "Bill-to Contact"; Text[100])
        {
            Caption = 'Bill-to Contact';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin
                Contact.FilterGroup(2);
                LookupContact("Bill-to Customer No.", "Bill-to Contact No.", Contact);
                if Page.RunModal(0, Contact) = Action::LookupOK then
                    Validate("Bill-to Contact No.", Contact."No.");
                Contact.FilterGroup(0);
            end;

            trigger OnValidate()
            begin
                ModifyBillToCustomerAddress();
            end;
        }
        field(11; "Your Reference"; Text[35])
        {
            Caption = 'Your Reference';
        }
        field(12; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Sell-to Customer No."));

            trigger OnValidate()
            var
                ShipToAddr: Record "Ship-to Address";
            begin
                if "Ship-to Code" <> '' then begin
                    ShipToAddr.Get("Sell-to Customer No.", "Ship-to Code");
                    SetShipToCustomerAddressFieldsFromShipToAddr(ShipToAddr);
                end else
                    if "Sell-to Customer No." <> '' then begin
                        GetCust("Sell-to Customer No.");
                        CopyShipToCustomerAddressFieldsFromCust(Cust);
                    end;
            end;
        }
        field(13; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Ship-to Name 2';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(17; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
            TableRelation = if ("Ship-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Ship-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Ship-to Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                ShipToCity: Text;
                ShipToCounty: Text;
            begin
                PostCode.LookupPostCode(ShipToCity, "Ship-to Post Code", ShipToCounty, "Ship-to Country/Region Code");
                "Ship-to City" := CopyStr(ShipToCity, 1, MaxStrLen("Ship-to City"));
                "Ship-to County" := CopyStr(ShipToCounty, 1, MaxStrLen("Ship-to County"));
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(
                  "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(18; "Ship-to Contact"; Text[100])
        {
            Caption = 'Ship-to Contact';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(23; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(29; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(30; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(32; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                if (("Currency Code" <> '') and (xRec."Currency Code" <> Rec."Currency Code")) then
                    Rec.UpdateAndRecalculateServiceCommitmentCurrencyData()
                else
                    Rec.ResetCustomerServiceCommitmentCurrencyFromLCY();
            end;
        }
        field(33; DefaultExcludeFromPriceUpdate; Boolean)
        {
            Caption = 'Default for Exclude from Price Update';
            trigger OnValidate()
            var
                ServiceCommitment: Record "Service Commitment";
            begin
                ServiceCommitment.ModifyExcludeFromPriceUpdateInAllRelatedServiceCommitments("Service Partner"::Customer, Rec."No.", Rec.DefaultExcludeFromPriceUpdate);
            end;
        }
        field(43; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            begin
                ValidateSalesPersonOnContractHeader(Rec);

                CreateDim(
                  Database::"Salesperson/Purchaser", "Salesperson Code",
                  Database::Job, "Dimension from Job No.",
                  Database::Customer, "Bill-to Customer No.");
            end;
        }
        field(79; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Customer.Name;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                LookupSellToCustomerName();
            end;

            trigger OnValidate()
            var
                Customer: Record Customer;
                SalesHeader: Record "Sales Header";
            begin
                OnBeforeValidateSellToCustomerName(Rec, Customer);

                if SalesHeader.ShouldSearchForCustomerByName("Sell-to Customer No.") then
                    Validate("Sell-to Customer No.", Customer.GetCustNo("Sell-to Customer Name"));
            end;
        }
        field(80; "Sell-to Customer Name 2"; Text[50])
        {
            Caption = 'Sell-to Customer Name 2';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(81; "Sell-to Address"; Text[100])
        {
            Caption = 'Sell-to Address';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyCustomerAddress();
            end;
        }
        field(82; "Sell-to Address 2"; Text[50])
        {
            Caption = 'Sell-to Address 2';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyCustomerAddress();
            end;
        }
        field(83; "Sell-to City"; Text[30])
        {
            Caption = 'Sell-to City';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Sell-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Sell-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Sell-to Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                SellToCity: Text;
                SellToCounty: Text;
            begin
                SellToCity := "Sell-to City";
                SellToCounty := "Sell-to County";
                PostCode.LookupPostCode(SellToCity, "Sell-to Post Code", SellToCounty, "Sell-to Country/Region Code");
                "Sell-to City" := CopyStr(SellToCity, 1, MaxStrLen("Sell-to City"));
                "Sell-to County" := CopyStr(SellToCounty, 1, MaxStrLen("Sell-to County"));
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(
                  "Sell-to City", "Sell-to Post Code", "Sell-to County", "Sell-to Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
                ModifyCustomerAddress();
            end;
        }
        field(84; "Sell-to Contact"; Text[100])
        {
            Caption = 'Sell-to Contact';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin
                if "Sell-to Customer No." = '' then
                    exit;

                Contact.FilterGroup(2);
                LookupContact("Sell-to Customer No.", "Sell-to Contact No.", Contact);
                if Page.RunModal(0, Contact) = Action::LookupOK then
                    Validate("Sell-to Contact No.", Contact."No.");
                Contact.FilterGroup(0);
            end;

            trigger OnValidate()
            begin
                ModifyCustomerAddress();
            end;
        }
        field(85; "Bill-to Post Code"; Code[20])
        {
            Caption = 'Bill-to Post Code';
            DataClassification = EndUserIdentifiableInformation;
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
                ModifyBillToCustomerAddress();
            end;
        }
        field(86; "Bill-to County"; Text[30])
        {
            CaptionClass = '5,1,' + "Bill-to Country/Region Code";
            Caption = 'Bill-to County';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyBillToCustomerAddress();
            end;
        }
        field(87; "Bill-to Country/Region Code"; Code[10])
        {
            Caption = 'Bill-to Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyBillToCustomerAddress();
            end;
        }
        field(88; "Sell-to Post Code"; Code[20])
        {
            Caption = 'Sell-to Post Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Sell-to Country/Region Code" = const('')) "Post Code"
            else
            if ("Sell-to Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Sell-to Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                SellToCity: Text;
                SellToCounty: Text;
            begin
                OnBeforeLookupSellToPostCode(Rec, PostCode);

                SellToCity := "Sell-to City";
                SellToCounty := "Sell-to County";
                PostCode.LookupPostCode(SellToCity, "Sell-to Post Code", SellToCounty, "Sell-to Country/Region Code");
                "Sell-to City" := CopyStr(SellToCity, 1, MaxStrLen("Sell-to City"));
                "Sell-to County" := CopyStr(SellToCounty, 1, MaxStrLen("Sell-to County"));
            end;

            trigger OnValidate()
            begin
                OnBeforeValidateSellToPostCode(Rec, PostCode);

                PostCode.ValidatePostCode(
                  "Sell-to City", "Sell-to Post Code", "Sell-to County", "Sell-to Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
                ModifyCustomerAddress();
            end;
        }
        field(89; "Sell-to County"; Text[30])
        {
            CaptionClass = '5,1,' + "Sell-to Country/Region Code";
            Caption = 'Sell-to County';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyCustomerAddress();
            end;
        }
        field(90; "Sell-to Country/Region Code"; Code[10])
        {
            Caption = 'Sell-to Country/Region Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                ModifyCustomerAddress();
            end;
        }
        field(91; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to Post Code';
            TableRelation = if ("Ship-to Country/Region Code" = const('')) "Post Code"
            else
            if ("Ship-to Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Ship-to Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                ShipToCity: Text;
                ShipToCounty: Text;
            begin
                OnBeforeLookupShipToPostCode(Rec, PostCode);

                PostCode.LookupPostCode(ShipToCity, "Ship-to Post Code", ShipToCounty, "Ship-to Country/Region Code");
                "Ship-to City" := CopyStr(ShipToCity, 1, MaxStrLen("Ship-to City"));
                "Ship-to County" := CopyStr(ShipToCounty, 1, MaxStrLen("Ship-to County"));

            end;

            trigger OnValidate()
            begin
                OnBeforeValidateShipToPostCode(Rec, PostCode);

                PostCode.ValidatePostCode(
                  "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(92; "Ship-to County"; Text[30])
        {
            CaptionClass = '5,1,' + "Ship-to Country/Region Code";
            Caption = 'Ship-to County';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(93; "Ship-to Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(104; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";

            trigger OnValidate()
            begin
                PaymentMethod.Init();
                if "Payment Method Code" <> '' then
                    PaymentMethod.Get("Payment Method Code");
                if PaymentMethod."Direct Debit" then
                    if "Payment Terms Code" = '' then
                        "Payment Terms Code" := PaymentMethod."Direct Debit Pmt. Terms Code";
            end;
        }
        field(107; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }

        field(200; Description; Blob)
        {
            Caption = 'Description';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDocDim();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }

        field(5052; "Sell-to Contact No."; Code[20])
        {
            Caption = 'Sell-to Contact No.';
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
            begin
                if "Sell-to Customer No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then
                        Cont.SetRange("Company No.", Cont."Company No.")
                    else
                        if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Customer, "Sell-to Customer No.") then
                            Cont.SetRange("Company No.", ContBusinessRelation."Contact No.")
                        else
                            Cont.SetRange("No.", '');

                if "Sell-to Contact No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then;
                if Page.RunModal(0, Cont) = Action::LookupOK then begin
                    xRec := Rec;
                    Validate("Sell-to Contact No.", Cont."No.");
                end;
            end;

            trigger OnValidate()
            var
                Cont: Record Contact;
                IsHandled: Boolean;
            begin
                if "Sell-to Contact No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric();

                if ("Sell-to Contact No." <> xRec."Sell-to Contact No.") and
                   (xRec."Sell-to Contact No." <> '')
                then begin
                    IsHandled := false;
                    OnBeforeConfirmSellToContactNoChange(Rec, xRec, CurrFieldNo, Confirmed, IsHandled);
                    if not IsHandled then
                        if GetHideValidationDialog() or not GuiAllowed then
                            Confirmed := true
                        else
                            Confirmed := ConfirmManagement.GetResponse(StrSubstNo(ConfirmChangeQst, FieldCaption("Sell-to Contact No.")), false);
                    if Confirmed then begin
                        if InitFromContact("Sell-to Contact No.", "Sell-to Customer No.") then
                            exit;
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                if ("Sell-to Customer No." <> '') and ("Sell-to Contact No." <> '') then
                    CheckContactRelatedToCustomerCompany("Sell-to Contact No.", "Sell-to Customer No.", CurrFieldNo);

                if "Sell-to Contact No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then
                        if ("Salesperson Code" = '') and (Cont."Salesperson Code" <> '') then
                            Validate("Salesperson Code", Cont."Salesperson Code");

                UpdateSellToCust("Sell-to Contact No.");
            end;
        }
        field(5053; "Bill-to Contact No."; Code[20])
        {
            Caption = 'Bill-to Contact No.';
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
                if Page.RunModal(0, Cont) = Action::LookupOK then begin
                    xRec := Rec;
                    Validate("Bill-to Contact No.", Cont."No.");
                end;
            end;

            trigger OnValidate()
            var
                Cont: Record Contact;
                IsHandled: Boolean;
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
                        if GetHideValidationDialog() or (not GuiAllowed) then
                            Confirmed := true
                        else
                            Confirmed := ConfirmManagement.GetResponse(StrSubstNo(ConfirmChangeQst, FieldCaption("Bill-to Contact No.")), false);
                    if Confirmed then begin
                        if InitFromContact("Bill-to Contact No.", "Bill-to Customer No.") then
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
        field(9000; "Assigned User ID"; Code[50])
        {
            Caption = 'Assigned User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(9500; Active; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
        }
        field(9501; "Contract Type"; Code[10])
        {
            TableRelation = "Contract Type";
            Caption = 'Contract Type';

            trigger onValidate()
            begin
                ClearHarmonizedBillingFields(Rec."Contract Type", xRec."Contract Type");
                SetDefaultWithoutContractDeferralsFromContractType();
            end;
        }
        field(9502; "Description Preview"; Text[100])
        {
            Caption = 'Description Preview';
        }
        field(8051; "Without Contract Deferrals"; Boolean)
        {
            Caption = 'Without Contract Deferrals';
        }
        field(8052; "Detail Overview"; Enum "Contract Detail Overview")
        {
            Caption = 'Detail Overview';
        }
        field(8053; "Billing Rhythm Filter"; DateFormula)
        {
            Caption = 'Billing Rhythm Filter';
            FieldClass = FlowFilter;
        }
        field(8054; "Dimension from Job No."; Code[20])
        {
            Caption = 'Dimension from Project No.';
            TableRelation = Job."No." where("Bill-to Customer No." = field("Bill-to Customer No."));

            trigger OnValidate()
            begin
                CreateDim(
                      Database::Job, "Dimension from Job No.",
                      Database::Customer, "Bill-to Customer No.",
                      Database::"Salesperson/Purchaser", "Salesperson Code");
            end;
        }
        field(8055; "Billing Base Date"; Date)
        {
            Caption = 'Billing Base Date';

            trigger OnValidate()
            begin
                if "Billing Base Date" = 0D then begin
                    Evaluate("Default Billing Rhythm", '');
                    ResetHarmonizedBillingFields();
                end else
                    CalculateNextBillingDates();
            end;
        }
        field(8056; "Default Billing Rhythm"; DateFormula)
        {
            Caption = 'Default Billing Rhythm';

            trigger OnValidate()
            begin
                if Format("Default Billing Rhythm") = '' then begin
                    "Billing Base Date" := 0D;
                    ResetHarmonizedBillingFields();
                end else begin
                    TestField("Billing Base Date");
                    CalculateNextBillingDates();
                end;
            end;
        }
        field(8057; "Next Billing From"; Date)
        {
            Caption = 'Next Billing From';
            Editable = false;
        }
        field(8058; "Next Billing To"; Date)
        {
            Caption = 'Next Billing To';
            Editable = false;
        }
        field(8059; "Contractor Name in coll. Inv."; Boolean)
        {
            Caption = 'Contractor Name in collective Invoice';
        }
        field(8060; "Recipient Name in coll. Inv."; Boolean)
        {
            Caption = 'Recipient Name in collective Invoice';
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Description Preview") { }
    }

    trigger OnInsert()
    begin
        InitInsert();

        SetSellToCustomerFromFilter();

        if GetFilterContNo() <> '' then
            Validate("Sell-to Contact No.", GetFilterContNo());

        if "Salesperson Code" = '' then
            SetDefaultSalesperson();

        CustContractDimensionMgt.AutomaticInsertCustomerContractDimensionValue(Rec);
        SetNameDefaultsForCollectiveInvoices();

        // Remove view filters so that the cards does not show filtered view notification
        SetView('');
    end;

    trigger OnRename()
    begin
        Error(RenameErr, TableCaption);
    end;

    trigger OnDelete()
    var
        CustomerContractLine: Record "Customer Contract Line";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
    begin
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", "No.");
        if CustomerContractLine.FindSet() then
            repeat
                CustomerContractLine.Delete(true);
            until CustomerContractLine.Next() = 0;

        ContractsGeneralMgt.DeleteDocumentAttachmentForNo(Database::"Customer Contract", Rec."No.");
    end;

    internal procedure IsContractTypeSetAsHarmonizedBilling(): Boolean
    var
        ContractType: Record "Contract Type";
    begin
        if Rec."Contract Type" = '' then
            exit;
        ContractType.Get(Rec."Contract Type");
        exit(ContractType.HarmonizedBillingCustContracts);
    end;

    var
        ServiceContractSetup: Record "Service Contract Setup";
        CustomerContractDeferral: Record "Customer Contract Deferral";
        Cust: Record Customer;
        PaymentMethod: Record "Payment Method";
        PostCode: Record "Post Code";
        Salesperson: Record "Salesperson/Purchaser";
        NoSeries: Codeunit "No. Series";
        DimMgt: Codeunit DimensionManagement;
        CustContractDimensionMgt: Codeunit "Cust. Contract Dimension Mgt.";
        ConfirmManagement: Codeunit "Confirm Management";
        ShipToAddressBuffer: Dictionary of [Code[20], Boolean];
        CurrencyFactor: Decimal;
        CurencyFactorDate: Date;
        CurrencyFactorDate: Date;
        Confirmed: Boolean;
        RenameErr: Label 'You cannot rename a %1.';
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        ContactNotRelatedToCustomerErr: Label 'Contact %1 %2 is not related to customer %3.';
        ContactRelatedToDifferentCompanyErr: Label 'Contact %1 %2 is related to a different company than customer %3.';
        ContactIsNotRelatedToAnyCustomerErr: Label 'Contact %1 %2 is not related to a customer.';
        SkipSellToContact: Boolean;
        SkipBillToContact: Boolean;
        CustomerContractAlreadyExistErr: Label 'The customer contract %1 already exists.';
        ModifyCustomerAddressNotificationLbl: Label 'Update the address';
        DontShowAgainActionLbl: Label 'Don''t show again';
        ModifyCustomerAddressNotificationMsg: Label 'The address you entered for %1 is different from the customer''s existing address.', Comment = '%1=customer name';
        SellToCustomerTxt: Label 'Sell-to Customer';
        BillToCustomerTxt: Label 'Bill-to Customer';
        ModifySellToCustomerAddressNotificationNameTxt: Label 'Update Sell-to Customer Address';
        ModifySellToCustomerAddressNotificationDescriptionTxt: Label 'Warn if the sell-to address on customer contract is different from the customer''s existing address.';
        ModifyBillToCustomerAddressNotificationNameTxt: Label 'Update Bill-to Customer Address';
        ModifyBillToCustomerAddressNotificationDescriptionTxt: Label 'Warn if the bill-to address on customer contract is different from the customer''s existing address.';
        UpdateDimensionsOnLinesQst: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        AssignServicePricesMustBeRecalculatedMsg: Label 'You added services to a contract in which a different currency is stored than in the services. The prices for the services must therefore be recalculated.';
        CurrCodeChangePricesMustBeRecalculatedMsg: Label 'If you change the currency code, the prices for existing services must be recalculated.';
        UpdatedDeferralsMsg: Label 'The dimensions in %1 deferrals have been updated.';

    protected var
        HideValidationDialog: Boolean;

    local procedure InitInsert()
    var
        CustomerContract2: Record "Customer Contract";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitInsert(Rec, xRec, IsHandled);
        if not IsHandled then
            if "No." = '' then begin
                GetServiceContractSetup();
                ServiceContractSetup.TestField("Customer Contract Nos.");
                "No. Series" := ServiceContractSetup."Customer Contract Nos.";
                if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                    "No. Series" := xRec."No. Series";
                "No." := NoSeries.GetNextNo("No. Series");
                CustomerContract2.ReadIsolation(IsolationLevel::ReadUncommitted);
                CustomerContract2.SetLoadFields("No.");
                while CustomerContract2.Get("No.") do
                    "No." := NoSeries.GetNextNo("No. Series");
            end;
        "Assigned User ID" := CopyStr(UserId(), 1, MaxStrLen("Assigned User ID"));
    end;

    local procedure SetNameDefaultsForCollectiveInvoices()
    begin
        GetServiceContractSetup();
        Rec."Contractor Name in coll. Inv." :=
            ServiceContractSetup."Origin Name collective Invoice" in
                [ServiceContractSetup."Origin Name collective Invoice"::"Sell-to Customer",
                 ServiceContractSetup."Origin Name collective Invoice"::Both];
        Rec."Recipient Name in coll. Inv." :=
            ServiceContractSetup."Origin Name collective Invoice" in
                [ServiceContractSetup."Origin Name collective Invoice"::"Ship-to Address",
                 ServiceContractSetup."Origin Name collective Invoice"::Both];
    end;

    internal procedure AssistEdit(OldCustomerContract: Record "Customer Contract"): Boolean
    var
        CustomerContract: Record "Customer Contract";
        CustomerContract2: Record "Customer Contract";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssistEdit(Rec, OldCustomerContract, IsHandled);
        if IsHandled then
            exit;

        CustomerContract.Copy(Rec);
        GetServiceContractSetup();
        ServiceContractSetup.TestField("Customer Contract Nos.");
        if NoSeries.LookupRelatedNoSeries(ServiceContractSetup."Customer Contract Nos.", OldCustomerContract."No. Series", CustomerContract."No. Series") then begin
            CustomerContract."No." := NoSeries.GetNextNo(CustomerContract."No. Series");
            if CustomerContract2.Get(CustomerContract."No.") then
                Error(CustomerContractAlreadyExistErr, CustomerContract."No.");
            Rec := CustomerContract;
            exit(true);
        end;
    end;

    local procedure GetCust(CustNo: Code[20])
    begin
        if not (CustNo = '') then begin
            if CustNo <> Cust."No." then
                Cust.Get(CustNo);
        end else
            Clear(Cust);
    end;

    local procedure GetServiceContractSetup()
    begin
        ServiceContractSetup.Get();
        OnAfterGetServiceContractSetup(Rec, ServiceContractSetup, CurrFieldNo);
    end;

    internal procedure CustomerContractLinesExists(): Boolean
    var
        CustomerContractLine: Record "Customer Contract Line";
    begin
        exit(CustomerContractLinesExists(CustomerContractLine));
    end;

    internal procedure CustomerContractLinesExists(var CustomerContractLine: Record "Customer Contract Line"): Boolean
    begin
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", Rec."No.");
        exit(not CustomerContractLine.IsEmpty());
    end;


    internal procedure NotReleasedCustomerContractDeferralsExists(): Boolean
    begin
        CustomerContractDeferral.Reset();
        CustomerContractDeferral.SetRange("Contract No.", Rec."No.");
        CustomerContractDeferral.SetRange(Released, false);
        exit(not CustomerContractDeferral.IsEmpty());
    end;

    internal procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    internal procedure GetHideValidationDialog(): Boolean
    begin
        exit(HideValidationDialog);
    end;

    local procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        OldDimSetID: Integer;
        IsHandled: Boolean;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        IsHandled := false;
        OnBeforeCreateDim(Rec, IsHandled);
        if IsHandled then
            exit;

        SourceCodeSetup.Get();

        DimMgt.AddDimSource(DefaultDimSource, Type1, No1);
        DimMgt.AddDimSource(DefaultDimSource, Type2, No2);
        DimMgt.AddDimSource(DefaultDimSource, Type3, No3);

        OnAfterCreateDimDimSource(Rec, CurrFieldNo, DefaultDimSource);

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" := DimMgt.GetRecDefaultDimID(Rec, CurrFieldNo, DefaultDimSource, SourceCodeSetup.Sales, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);

        CustContractDimensionMgt.AutomaticInsertCustomerContractDimensionValue(Rec);
        OnCreateDimOnBeforeModify(Rec, xRec, CurrFieldNo);
        if (OldDimSetID <> "Dimension Set ID") and CustomerContractLinesExists() then begin
            Modify();
            UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);

        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "No." <> '' then
            Modify();

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            if CustomerContractLinesExists() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    var
        ServiceCommitment: Record "Service Commitment";
        NewDimSetID: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        if NewParentDimSetID = OldParentDimSetID then
            exit;

        if not ConfirmManagement.GetResponse(UpdateDimensionsOnLinesQst, true) then
            exit;

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Contract No.", Rec."No.");
        if ServiceCommitment.FindSet() then
            repeat
                NewDimSetID := DimMgt.GetDeltaDimSetID(ServiceCommitment."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                if NewDimSetID <> ServiceCommitment."Dimension Set ID" then begin
                    ServiceCommitment."Dimension Set ID" := NewDimSetID;
                    DimMgt.UpdateGlobalDimFromDimSetID(
                     ServiceCommitment."Dimension Set ID", ServiceCommitment."Shortcut Dimension 1 Code", ServiceCommitment."Shortcut Dimension 2 Code");
                    ServiceCommitment.Modify(false);
                    ServiceCommitment.UpdateRelatedVendorServiceCommDimensions(OldParentDimSetID, ServiceCommitment."Dimension Set ID");
                end;
            until ServiceCommitment.Next() = 0;
    end;

    local procedure UpdateSellToCont(CustomerNo: Code[20])
    var
        ContBusRel: Record "Contact Business Relation";
        OfficeContact: Record Contact;
        OfficeMgt: Codeunit "Office Management";
    begin
        if OfficeMgt.GetContact(OfficeContact, CustomerNo) then begin
            HideValidationDialog := true;
            UpdateSellToCust(OfficeContact."No.");
            HideValidationDialog := false;
        end else
            if Cust.Get(CustomerNo) then begin
                if Cust."Primary Contact No." <> '' then
                    "Sell-to Contact No." := Cust."Primary Contact No."
                else begin
                    ContBusRel.Reset();
                    ContBusRel.SetCurrentKey("Link to Table", "No.");
                    ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                    ContBusRel.SetRange("No.", "Sell-to Customer No.");
                    if ContBusRel.FindFirst() then
                        "Sell-to Contact No." := ContBusRel."Contact No."
                    else
                        "Sell-to Contact No." := '';
                end;
                "Sell-to Contact" := Cust.Contact;
            end;
        if "Sell-to Contact No." <> '' then
            if OfficeContact.Get("Sell-to Contact No.") then
                OfficeContact.CheckIfPrivacyBlockedGeneric();

        OnAfterUpdateSellToCont(Rec, Cust, OfficeContact);
    end;

    local procedure UpdateBillToCont(CustomerNo: Code[20])
    var
        ContBusRel: Record "Contact Business Relation";
        Contact: Record Contact;
    begin
        if Cust.Get(CustomerNo) then begin
            if Cust."Primary Contact No." <> '' then
                "Bill-to Contact No." := Cust."Primary Contact No."
            else begin
                ContBusRel.Reset();
                ContBusRel.SetCurrentKey("Link to Table", "No.");
                ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                ContBusRel.SetRange("No.", "Bill-to Customer No.");
                if ContBusRel.FindFirst() then
                    "Bill-to Contact No." := ContBusRel."Contact No."
                else
                    "Bill-to Contact No." := '';
            end;
            "Bill-to Contact" := Cust.Contact;
        end;
        if "Bill-to Contact No." <> '' then
            if Contact.Get("Bill-to Contact No.") then
                Contact.CheckIfPrivacyBlockedGeneric();

        OnAfterUpdateBillToCont(Rec, Cust, Contact);
    end;

    local procedure UpdateSellToCust(ContactNo: Code[20])
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Customer: Record Customer;
        Cont: Record Contact;
        ContactBusinessRelationFound: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeUpdateSellToCust(Rec, Cont, Customer, ContactNo);

        if not Cont.Get(ContactNo) then begin
            "Sell-to Contact" := '';
            exit;
        end;
        "Sell-to Contact No." := Cont."No.";

        if Cont.Type = Cont.Type::Person then
            ContactBusinessRelationFound := ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Customer, Cont."No.");
        if not ContactBusinessRelationFound then begin
            IsHandled := false;
            OnUpdateSellToCustOnBeforeFindContactBusinessRelation(Cont, ContBusinessRelation, ContactBusinessRelationFound, IsHandled);
            if not IsHandled then
                ContactBusinessRelationFound :=
                    ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Customer, Cont."Company No.");
        end;

        if ContactBusinessRelationFound then begin
            if ("Sell-to Customer No." <> '') and ("Sell-to Customer No." <> ContBusinessRelation."No.") then
                Error(ContactNotRelatedToCustomerErr, Cont."No.", Cont.Name, "Sell-to Customer No.");

            if "Sell-to Customer No." = '' then begin
                SkipSellToContact := true;
                Validate("Sell-to Customer No.", ContBusinessRelation."No.");
                SkipSellToContact := false;
            end;
        end else begin
            IsHandled := false;
            OnUpdateSellToCustOnBeforeContactIsNotRelatedToAnyCostomerErr(Rec, Cont, ContBusinessRelation, IsHandled);
            if not IsHandled then
                Error(ContactIsNotRelatedToAnyCustomerErr, Cont."No.", Cont.Name);

            "Sell-to Contact" := Cont.Name;
        end;

        if (Cont.Type = Cont.Type::Company) and Customer.Get("Sell-to Customer No.") then
            "Sell-to Contact" := Customer.Contact
        else
            if Cont.Type = Cont.Type::Company then
                "Sell-to Contact" := ''
            else
                "Sell-to Contact" := Cont.Name;

        if ("Sell-to Customer No." = "Bill-to Customer No.") or
           ("Bill-to Customer No." = '')
        then
            Validate("Bill-to Contact No.", "Sell-to Contact No.");

        OnAfterUpdateSellToCust(Rec, Cont);
    end;

    local procedure UpdateBillToCust(ContactNo: Code[20])
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Cont: Record Contact;
        ContactBusinessRelationFound: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateBillToCust(Rec, ContactNo, IsHandled);
        if IsHandled then
            exit;

        if not Cont.Get(ContactNo) then begin
            "Bill-to Contact" := '';
            exit;
        end;
        "Bill-to Contact No." := Cont."No.";

        if Cust.Get("Bill-to Customer No.") and (Cont.Type = Cont.Type::Company) then
            "Bill-to Contact" := Cust.Contact
        else
            if Cont.Type = Cont.Type::Company then
                "Bill-to Contact" := ''
            else
                "Bill-to Contact" := Cont.Name;

        if Cont.Type = Cont.Type::Person then
            ContactBusinessRelationFound := ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Customer, Cont."No.");
        if not ContactBusinessRelationFound then begin
            IsHandled := false;
            OnUpdateBillToCustOnBeforeFindContactBusinessRelation(Cont, ContBusinessRelation, ContactBusinessRelationFound, IsHandled);
            if not IsHandled then
                ContactBusinessRelationFound :=
                    ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Customer, Cont."Company No.");
        end;
        if ContactBusinessRelationFound then begin
            if "Bill-to Customer No." = '' then begin
                SkipBillToContact := true;
                Validate("Bill-to Customer No.", ContBusinessRelation."No.");
                SkipBillToContact := false;
            end else
                if "Bill-to Customer No." <> ContBusinessRelation."No." then
                    Error(ContactNotRelatedToCustomerErr, Cont."No.", Cont.Name, "Bill-to Customer No.");
        end else begin
            IsHandled := false;
            OnUpdateBillToCustOnBeforeContactIsNotRelatedToAnyCostomerErr(Rec, Cont, ContBusinessRelation, IsHandled);
            if not IsHandled then
                Error(ContactIsNotRelatedToAnyCustomerErr, Cont."No.", Cont.Name);
        end;

        OnAfterUpdateBillToCust(Rec, Cont);
    end;

    internal procedure ShowDocDim()
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", "No.",
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            if CustomerContractLinesExists() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    local procedure GetFilterCustNo(): Code[20]
    var
        MinValue: Code[20];
        MaxValue: Code[20];
    begin
        if GetFilter("Sell-to Customer No.") <> '' then
            if TryGetFilterCustNoRange(MinValue, MaxValue) then
                if MinValue = MaxValue then
                    exit(MaxValue);
    end;

    [TryFunction]
    local procedure TryGetFilterCustNoRange(var MinValue: Code[20]; var MaxValue: Code[20])
    begin
        MinValue := GetRangeMin("Sell-to Customer No.");
        MaxValue := GetRangeMax("Sell-to Customer No.");
    end;

    local procedure GetFilterCustNoByApplyingFilter(): Code[20]
    var
        CustomerContract: Record "Customer Contract";
        MinValue: Code[20];
        MaxValue: Code[20];
    begin
        if GetFilter("Sell-to Customer No.") <> '' then begin
            CustomerContract.CopyFilters(Rec);
            CustomerContract.SetCurrentKey("Sell-to Customer No.");
            if CustomerContract.FindFirst() then
                MinValue := CustomerContract."Sell-to Customer No.";
            if CustomerContract.FindLast() then
                MaxValue := CustomerContract."Sell-to Customer No.";
            if MinValue = MaxValue then
                exit(MaxValue);
        end;
    end;

    local procedure GetFilterContNo(): Code[20]
    begin
        if GetFilter("Sell-to Contact No.") <> '' then
            if GetRangeMin("Sell-to Contact No.") = GetRangeMax("Sell-to Contact No.") then
                exit(GetRangeMax("Sell-to Contact No."));
    end;

    internal procedure SetSellToCustomerFromFilter()
    var
        SellToCustomerNo: Code[20];
    begin
        SellToCustomerNo := GetFilterCustNo();
        if SellToCustomerNo = '' then begin
            FilterGroup(2);
            SellToCustomerNo := GetFilterCustNo();
            if SellToCustomerNo = '' then
                SellToCustomerNo := GetFilterCustNoByApplyingFilter();
            FilterGroup(0);
        end;
        if SellToCustomerNo <> '' then
            Validate("Sell-to Customer No.", SellToCustomerNo);
    end;

    internal procedure CopySellToCustomerFilter()
    var
        SellToCustomerFilter: Text;
    begin
        SellToCustomerFilter := GetFilter("Sell-to Customer No.");
        if SellToCustomerFilter <> '' then begin
            FilterGroup(2);
            SetFilter("Sell-to Customer No.", SellToCustomerFilter);
            FilterGroup(0)
        end;
    end;

    local procedure HasSellToAddress(): Boolean
    begin
        case true of
            "Sell-to Address" <> '':
                exit(true);
            "Sell-to Address 2" <> '':
                exit(true);
            "Sell-to City" <> '':
                exit(true);
            "Sell-to Country/Region Code" <> '':
                exit(true);
            "Sell-to County" <> '':
                exit(true);
            "Sell-to Post Code" <> '':
                exit(true);
            "Sell-to Contact" <> '':
                exit(true);
        end;

        exit(false);
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

    local procedure CopySellToCustomerAddressFieldsFromCustomer(var SellToCustomer: Record Customer)
    begin
        "Sell-to Customer Name" := Cust.Name;
        "Sell-to Customer Name 2" := Cust."Name 2";
        if SellToCustomerIsReplaced() or ShouldCopyAddressFromSellToCustomer(SellToCustomer) then begin
            "Sell-to Address" := SellToCustomer.Address;
            "Sell-to Address 2" := SellToCustomer."Address 2";
            "Sell-to City" := SellToCustomer.City;
            "Sell-to Post Code" := SellToCustomer."Post Code";
            "Sell-to County" := SellToCustomer.County;
            "Sell-to Country/Region Code" := SellToCustomer."Country/Region Code";
        end;
        if not SkipSellToContact then
            "Sell-to Contact" := SellToCustomer.Contact;

        OnAfterCopySellToCustomerAddressFieldsFromCustomer(Rec, SellToCustomer, CurrFieldNo);
    end;

    local procedure CopyShipToCustomerAddressFieldsFromCust(var SellToCustomer: Record Customer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyShipToCustomerAddressFieldsFromCustomer(Rec, SellToCustomer, IsHandled);
        if IsHandled then
            exit;

        "Ship-to Name" := Cust.Name;
        "Ship-to Name 2" := Cust."Name 2";
        if SellToCustomerIsReplaced() or ShipToAddressEqualsOldSellToAddress() then begin
            "Ship-to Address" := SellToCustomer.Address;
            "Ship-to Address 2" := SellToCustomer."Address 2";
            "Ship-to City" := SellToCustomer.City;
            "Ship-to Post Code" := SellToCustomer."Post Code";
            "Ship-to County" := SellToCustomer.County;
            Validate("Ship-to Country/Region Code", SellToCustomer."Country/Region Code");
        end;
        "Ship-to Contact" := Cust.Contact;

        OnAfterCopyShipToCustomerAddressFieldsFromCustomer(Rec, SellToCustomer);
    end;

    local procedure SetShipToCustomerAddressFieldsFromShipToAddr(ShipToAddr: Record "Ship-to Address")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyShipToCustomerAddressFieldsFromShipToAddr(Rec, ShipToAddr, IsHandled);
        if IsHandled then
            exit;

        "Ship-to Name" := ShipToAddr.Name;
        "Ship-to Name 2" := ShipToAddr."Name 2";
        "Ship-to Address" := ShipToAddr.Address;
        "Ship-to Address 2" := ShipToAddr."Address 2";
        "Ship-to City" := ShipToAddr.City;
        "Ship-to Post Code" := ShipToAddr."Post Code";
        "Ship-to County" := ShipToAddr.County;
        Validate("Ship-to Country/Region Code", ShipToAddr."Country/Region Code");
        "Ship-to Contact" := ShipToAddr.Contact;

        OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr(Rec, ShipToAddr);
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

        "Currency Code" := BillToCustomer."Currency Code";
        SetSalespersonCode(BillToCustomer."Salesperson Code", "Salesperson Code");

        OnAfterSetFieldsBilltoCustomer(Rec, BillToCustomer);
    end;

    local procedure ShouldCopyAddressFromSellToCustomer(SellToCustomer: Record Customer): Boolean
    begin
        exit((not HasSellToAddress()) and SellToCustomer.HasAddress());
    end;

    local procedure ShouldCopyAddressFromBillToCustomer(BillToCustomer: Record Customer): Boolean
    begin
        exit((not HasBillToAddress()) and BillToCustomer.HasAddress());
    end;

    local procedure SellToCustomerIsReplaced(): Boolean
    begin
        exit((xRec."Sell-to Customer No." <> '') and (xRec."Sell-to Customer No." <> "Sell-to Customer No."));
    end;

    local procedure BillToCustomerIsReplaced(): Boolean
    begin
        exit((xRec."Bill-to Customer No." <> '') and (xRec."Bill-to Customer No." <> "Bill-to Customer No."));
    end;

    local procedure ShipToAddressEqualsOldSellToAddress(): Boolean
    begin
        exit(IsShipToAddressEqualToSellToAddress(xRec, Rec));
    end;

    local procedure IsShipToAddressEqualToSellToAddress(CustomerContractWithSellTo: Record "Customer Contract"; CustomerContractWithShipTo: Record "Customer Contract"): Boolean
    var
        Result: Boolean;
    begin
        Result :=
          (CustomerContractWithSellTo."Sell-to Address" = CustomerContractWithShipTo."Ship-to Address") and
          (CustomerContractWithSellTo."Sell-to Address 2" = CustomerContractWithShipTo."Ship-to Address 2") and
          (CustomerContractWithSellTo."Sell-to City" = CustomerContractWithShipTo."Ship-to City") and
          (CustomerContractWithSellTo."Sell-to County" = CustomerContractWithShipTo."Ship-to County") and
          (CustomerContractWithSellTo."Sell-to Post Code" = CustomerContractWithShipTo."Ship-to Post Code") and
          (CustomerContractWithSellTo."Sell-to Country/Region Code" = CustomerContractWithShipTo."Ship-to Country/Region Code") and
          (CustomerContractWithSellTo."Sell-to Contact" = CustomerContractWithShipTo."Ship-to Contact");

        OnAfterIsShipToAddressEqualToSellToAddress(CustomerContractWithSellTo, CustomerContractWithShipTo, Result);
        exit(Result);
    end;

    internal procedure IsShipToAddressEqualToServiceObjectShipToAddress(var ServiceObject: Record "Service Object"): Boolean
    var
        Result: Boolean;
    begin
        Result :=
          (Rec."Ship-to Address" = ServiceObject."Ship-to Address") and
          (Rec."Ship-to Address 2" = ServiceObject."Ship-to Address 2") and
          (Rec."Ship-to City" = ServiceObject."Ship-to City") and
          (Rec."Ship-to County" = ServiceObject."Ship-to County") and
          (Rec."Ship-to Post Code" = ServiceObject."Ship-to Post Code") and
          (Rec."Ship-to Country/Region Code" = ServiceObject."Ship-to Country/Region Code") and
          (Rec."Ship-to Contact" = ServiceObject."Ship-to Contact");

        OnAfterIsShipToAddressEqualToServiceObjectShipToAddress(Rec, ServiceObject, Result);
        exit(Result);
    end;

    internal procedure CopySellToAddressToShipToAddress()
    begin
        "Ship-to Address" := "Sell-to Address";
        "Ship-to Address 2" := "Sell-to Address 2";
        "Ship-to City" := "Sell-to City";
        "Ship-to Contact" := "Sell-to Contact";
        "Ship-to Country/Region Code" := "Sell-to Country/Region Code";
        "Ship-to County" := "Sell-to County";
        "Ship-to Post Code" := "Sell-to Post Code";

        OnAfterCopySellToAddressToShipToAddress(Rec);
    end;

    internal procedure CopySellToAddressToBillToAddress()
    begin
        if "Bill-to Customer No." = "Sell-to Customer No." then begin
            "Bill-to Address" := "Sell-to Address";
            "Bill-to Address 2" := "Sell-to Address 2";
            "Bill-to Post Code" := "Sell-to Post Code";
            "Bill-to Country/Region Code" := "Sell-to Country/Region Code";
            "Bill-to City" := "Sell-to City";
            "Bill-to County" := "Sell-to County";
            OnAfterCopySellToAddressToBillToAddress(Rec);
        end;
    end;

    local procedure InitFromContact(ContactNo: Code[20]; CustomerNo: Code[20]): Boolean
    begin
        if (ContactNo = '') and (CustomerNo = '') then begin
            Init();
            GetServiceContractSetup();
            "No. Series" := xRec."No. Series";
            OnInitFromContactOnAfterInitNoSeries(Rec, xRec);
            exit(true);
        end;
    end;

    internal procedure SetDescription(NewDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Description);
        Description.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewDescription);
        "Description Preview" := CopyStr(NewDescription, 1, MaxStrLen("Description Preview"));
        Modify();
        CustContractDimensionMgt.AutomaticInsertCustomerContractDimensionValue(Rec);
    end;

    internal procedure GetDescription(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields(Description);
        Description.CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    local procedure LookupContact(CustomerNo: Code[20]; ContactNo: Code[20]; var Contact: Record Contact)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        FilterByContactCompany: Boolean;
    begin
        if ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Customer, CustomerNo) then
            Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.")
        else
            Contact.SetRange("Company No.", '');
        if ContactNo <> '' then
            if Contact.Get(ContactNo) then
                if FilterByContactCompany then
                    Contact.SetRange("Company No.", Contact."Company No.");
    end;

    local procedure SetDefaultSalesperson()
    var
        UserSetupSalespersonCode: Code[20];
    begin
        UserSetupSalespersonCode := GetUserSetupSalespersonCode();
        if UserSetupSalespersonCode <> '' then
            if Salesperson.Get(UserSetupSalespersonCode) then
                if not Salesperson.VerifySalesPersonPurchaserPrivacyBlocked(Salesperson) then
                    Validate("Salesperson Code", UserSetupSalespersonCode);
    end;

    local procedure GetUserSetupSalespersonCode(): Code[20]
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId) then
            exit;

        exit(UserSetup."Salespers./Purch. Code");
    end;

    internal procedure SelltoCustomerNoOnAfterValidate(var CustomerContract: Record "Customer Contract"; var xCustomerContract: Record "Customer Contract")
    begin
        if CustomerContract.GetFilter("Sell-to Customer No.") = xCustomerContract."Sell-to Customer No." then
            if CustomerContract."Sell-to Customer No." <> xCustomerContract."Sell-to Customer No." then
                CustomerContract.SetRange("Sell-to Customer No.");
    end;

    local procedure ModifyBillToCustomerAddress()
    var
        Customer: Record Customer;
    begin
        if ("Bill-to Customer No." <> "Sell-to Customer No.") and Customer.Get("Bill-to Customer No.") then
            if HasBillToAddress() and HasDifferentBillToAddress(Customer) then
                ShowModifyAddressNotification(GetModifyBillToCustomerAddressNotificationId(),
                  ModifyCustomerAddressNotificationLbl, ModifyCustomerAddressNotificationMsg,
                  'CopyBillToCustomerAddressFieldsFromCustomerContract', "Bill-to Customer No.",
                  "Bill-to Name", FieldName("Bill-to Customer No."));
    end;

    local procedure ModifyCustomerAddress()
    var
        Customer: Record Customer;
    begin
        if Customer.Get("Sell-to Customer No.") and HasSellToAddress() and HasDifferentSellToAddress(Customer) then
            ShowModifyAddressNotification(GetModifyCustomerAddressNotificationId(),
              ModifyCustomerAddressNotificationLbl, ModifyCustomerAddressNotificationMsg,
              'CopyEndUserCustomerAddressFieldsFromCustomerContract', "Sell-to Customer No.",
              "Sell-to Customer Name", FieldName("Sell-to Customer No."));
    end;

    local procedure ShowModifyAddressNotification(NotificationID: Guid; NotificationLbl: Text; NotificationMsg: Text; NotificationFunctionTok: Text; CustomerNumber: Code[20]; CustomerName: Text[100]; CustomerNumberFieldName: Text)
    var
        MyNotifications: Record "My Notifications";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        PageMyNotifications: Page "My Notifications";
        ModifyCustomerAddressNotification: Notification;
    begin
        if not MyNotifications.Get(UserId, NotificationID) then
            PageMyNotifications.InitializeNotificationsWithDefaultState();

        if not MyNotifications.IsEnabled(NotificationID) then
            exit;

        ModifyCustomerAddressNotification.Id := NotificationID;
        ModifyCustomerAddressNotification.Message := NotificationMsg.Replace('%1', CustomerName);
        ModifyCustomerAddressNotification.AddAction(NotificationLbl, Codeunit::"Contract Notifications", NotificationFunctionTok);
        ModifyCustomerAddressNotification.AddAction(
          DontShowAgainActionLbl, Codeunit::"Contract Notifications", 'CustomerContractHideNotificationForCurrentUser');
        ModifyCustomerAddressNotification.Scope := NotificationScope::LocalScope;
        ModifyCustomerAddressNotification.SetData(FieldName("No."), "No.");
        ModifyCustomerAddressNotification.SetData(CustomerNumberFieldName, CustomerNumber);
        NotificationLifecycleMgt.SendNotification(ModifyCustomerAddressNotification, RecordId);
    end;

    internal procedure RecallModifyAddressNotification(NotificationID: Guid)
    var
        MyNotifications: Record "My Notifications";
        ModifyCustomerAddressNotification: Notification;
    begin
        if not MyNotifications.IsEnabled(NotificationID) then
            exit;

        ModifyCustomerAddressNotification.Id := NotificationID;
        ModifyCustomerAddressNotification.Recall();
    end;

    local procedure GetModifyCustomerAddressNotificationId(): Guid
    begin
        exit('D2EAE122-76DB-4D6D-B6ED-7A6EF9DC7F3D');
    end;

    internal procedure GetModifyBillToCustomerAddressNotificationId(): Guid
    begin
        exit('9CF909A0-8C02-4153-89FD-8E30CD413E17');
    end;

    internal procedure DontNotifyCurrentUserAgain(NotificationID: Guid)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(NotificationID) then
            case NotificationID of
                GetModifyCustomerAddressNotificationId():
                    MyNotifications.InsertDefault(NotificationID, ModifySellToCustomerAddressNotificationNameTxt,
                      ModifySellToCustomerAddressNotificationDescriptionTxt, false);
                GetModifyBillToCustomerAddressNotificationId():
                    MyNotifications.InsertDefault(NotificationID, ModifyBillToCustomerAddressNotificationNameTxt,
                      ModifyBillToCustomerAddressNotificationDescriptionTxt, false);
            end;
    end;

    local procedure HasDifferentSellToAddress(Customer: Record Customer): Boolean
    begin
        exit(("Sell-to Address" <> Customer.Address) or
          ("Sell-to Address 2" <> Customer."Address 2") or
          ("Sell-to City" <> Customer.City) or
          ("Sell-to Country/Region Code" <> Customer."Country/Region Code") or
          ("Sell-to County" <> Customer.County) or
          ("Sell-to Post Code" <> Customer."Post Code") or
          ("Sell-to Contact" <> Customer.Contact));
    end;

    local procedure HasDifferentBillToAddress(Customer: Record Customer): Boolean
    begin
        exit(("Bill-to Address" <> Customer.Address) or
          ("Bill-to Address 2" <> Customer."Address 2") or
          ("Bill-to City" <> Customer.City) or
          ("Bill-to Country/Region Code" <> Customer."Country/Region Code") or
          ("Bill-to County" <> Customer.County) or
          ("Bill-to Post Code" <> Customer."Post Code") or
          ("Bill-to Contact" <> Customer.Contact));
    end;

    local procedure SetSalespersonCode(SalesPersonCodeToCheck: Code[20]; var SalesPersonCodeToAssign: Code[20])
    var
        UserSetupSalespersonCode: Code[20];
    begin
        UserSetupSalespersonCode := GetUserSetupSalespersonCode();
        if SalesPersonCodeToCheck <> '' then begin
            if Salesperson.Get(SalesPersonCodeToCheck) then
                if Salesperson.VerifySalesPersonPurchaserPrivacyBlocked(Salesperson) then begin
                    if UserSetupSalespersonCode = '' then
                        SalesPersonCodeToAssign := ''
                end else
                    SalesPersonCodeToAssign := SalesPersonCodeToCheck;
        end else
            if UserSetupSalespersonCode = '' then
                SalesPersonCodeToAssign := '';
    end;

    local procedure ValidateSalesPersonOnContractHeader(Contract2: Record "Customer Contract")
    begin
        if Contract2."Salesperson Code" <> '' then
            if Salesperson.Get(Contract2."Salesperson Code") then
                if Salesperson.VerifySalesPersonPurchaserPrivacyBlocked(Salesperson) then
                    Error(Salesperson.GetPrivacyBlockedGenericText(Salesperson, true));
    end;

    internal procedure CheckContactRelatedToCustomerCompany(ContactNo: Code[20]; CustomerNo: Code[20]; CurrFieldNo: Integer)
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckContactRelatedToCustomerCompany(Rec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        Contact.Get(ContactNo);
        if ContBusRel.FindByRelation(ContBusRel."Link to Table"::Customer, CustomerNo) then
            if (ContBusRel."Contact No." <> Contact."Company No.") and (ContBusRel."Contact No." <> Contact."No.") then
                Error(ContactRelatedToDifferentCompanyErr, Contact."No.", Contact.Name, CustomerNo);
    end;

    internal procedure LookupSellToCustomerName(): Boolean
    var
        Customer: Record Customer;
    begin
        if "Sell-to Customer No." <> '' then
            Customer.Get("Sell-to Customer No.");

        if Customer.SelectCustomer(Customer) then begin
            "Sell-to Customer Name" := Customer.Name;
            Validate("Sell-to Customer No.", Customer."No.");
            exit(true);
        end;
    end;

    procedure CreateCustomerContractLinesFromServiceCommitments(var ServiceCommitment: Record "Service Commitment" temporary)
    var
        ServiceObject: Record "Service Object";
    begin
        ServiceCommitment.TestServiceCommitmentsCurrencyCode(ServiceCommitment);
        if (("Currency Code" <> ServiceCommitment."Currency Code") and ("Currency Code" <> '')) then
            if not ServiceCommitment.OpenExchangeSelectionPage(CurrencyFactorDate, CurrencyFactor, Rec."Currency Code", AssignServicePricesMustBeRecalculatedMsg, false) then
                Error('');

        ClearDeviatingShipToAddressNotification();
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment.TestField("Service Object No.");
                ServiceObject.Get(ServiceCommitment."Service Object No.");
                ServiceCommitment.TestField("Contract No.");
                Rec.Get(ServiceCommitment."Contract No.");

                AppendShipToAddressBufferIfShipToCodeDiffers(ServiceObject);
                CreateCustomerContractLineFromServiceCommitment(ServiceCommitment, ServiceCommitment."Contract No.");
                ServiceCommitment.Delete(false);
            until ServiceCommitment.Next() = 0;
        NotifyIfShipToAddressDiffers();
    end;

    procedure CreateCustomerContractLineFromServiceCommitment(ServiceCommitment: Record "Service Commitment"; ContractNo: Code[20])
    var
        CustomerContractLine: Record "Customer Contract Line";
        ServiceCommitment2: Record "Service Commitment";
    begin
        ServiceCommitment2.Get(ServiceCommitment."Entry No.");
        CreateCustomerContractLineFromServiceCommitment(ServiceCommitment2, ContractNo, CustomerContractLine);
    end;

    internal procedure CreateCustomerContractLineFromServiceCommitment(var ServiceCommitment: Record "Service Commitment"; ContractNo: Code[20]; var CustomerContractLine: Record "Customer Contract Line")
    var
        ServiceObject: Record "Service Object";
        CustomerContract: Record "Customer Contract";
        OldDimSetID: Integer;
        InitHarmonizedBillingFields: Boolean;
    begin
        OnBeforeCreateCustomerContractLineFromServiceCommitment(ServiceCommitment, ContractNo, CustomerContractLine);
        ServiceObject.Get(ServiceCommitment."Service Object No.");
        TestField("Sell-to Customer No.", ServiceObject."End-User Customer No.");

        CustomerContract.Get(ContractNo);

        if CustomerContract.IsContractTypeSetAsHarmonizedBilling() then
            InitHarmonizedBillingFields := true;

        CustomerContractLine.InitFromServiceCommitment(ServiceCommitment, ContractNo);
        CustomerContractLine.Insert(false);

        OldDimSetID := ServiceCommitment."Dimension Set ID";
        ServiceCommitment."Contract No." := CustomerContractLine."Contract No.";
        ServiceCommitment."Contract Line No." := CustomerContractLine."Line No.";

        ServiceCommitment.GetCombinedDimensionSetID(ServiceCommitment."Dimension Set ID", CustomerContract."Dimension Set ID");
        if "Currency Code" <> ServiceCommitment."Currency Code" then begin
            ServiceCommitment.SetCurrencyData(CurrencyFactor, CurrencyFactorDate, CustomerContract."Currency Code");
            ServiceCommitment.RecalculateAmountsFromCurrencyData();
        end;

        ServiceCommitment."Exclude from Price Update" := CustomerContract.DefaultExcludeFromPriceUpdate;
        OnBeforeModifyServiceCommitmentOnCreateCustomerContractLineFromServiceCommitment(ServiceCommitment, CustomerContractLine);
        ServiceCommitment.Modify(true);

        ServiceCommitment.UpdateRelatedVendorServiceCommDimensions(OldDimSetID, ServiceCommitment."Dimension Set ID");
        if InitHarmonizedBillingFields then begin
            CustomerContract.UpdateHarmonizedBillingFields(ServiceCommitment);
            CustomerContract.Modify(false);
        end;

        OnAfterCreateCustomerContractLineFromServiceCommitment(ServiceCommitment, CustomerContractLine);
    end;

    local procedure ClearHarmonizedBillingFields(NewContractTypeCode: Code[10]; OldContractTypeCode: Code[10])
    var
        NewContractType: Record "Contract Type";
        OldContractType: Record "Contract Type";
    begin
        if OldContractTypeCode = '' then
            exit;
        if NewContractTypeCode = '' then
            exit;
        NewContractType.Get(NewContractTypeCode);
        if NewContractType.HarmonizedBillingCustContracts then
            exit;
        OldContractType.Get(OldContractTypeCode);
        if not OldContractType.HarmonizedBillingCustContracts then
            exit;
        Rec.ResetHarmonizedBillingFields();
        Rec.Modify(false);
    end;

    internal procedure UpdateHarmonizedBillingFields(ServiceCommitment: Record "Service Commitment")
    begin
        if ((Rec."Next Billing From" <> 0D) and (Rec."Next Billing From" > ServiceCommitment."Next Billing Date")) then
            "Billing Base Date" := CalcDate('-' + Format("Default Billing Rhythm"), "Next Billing From")
        else begin
            "Billing Base Date" := ServiceCommitment."Next Billing Date";
            "Default Billing Rhythm" := ServiceCommitment."Billing Rhythm";
        end;
        CalculateNextBillingDates();
    end;

    internal procedure CalculateNextBillingDates()
    begin
        if (("Billing Base Date" = 0D) or (Format("Default Billing Rhythm") = '')) then
            exit;
        "Next Billing From" := "Billing Base Date";
        "Next Billing To" := CalcDate("Default Billing Rhythm", "Next Billing From");
        "Next Billing To" := CalcDate('<-1D>', "Next Billing To");
    end;

    internal procedure ResetHarmonizedBillingFields()
    begin
        Rec."Billing Base Date" := 0D;
        Evaluate(Rec."Default Billing Rhythm", '');
        Rec."Next Billing From" := 0D;
        Rec."Next Billing To" := 0D;
    end;

    internal procedure UpdateServicesDates()
    var
        CustomerContractLines: Record "Customer Contract Line";
        TempServiceObject: Record "Service Object" temporary;
        ServiceObject: Record "Service Object";
    begin
        CustomerContractLines.SetRange("Contract No.", Rec."No.");
        CustomerContractLines.SetRange("Contract Line Type", "Contract Line Type"::"Service Commitment");
        if CustomerContractLines.FindSet() then
            repeat
                if not TempServiceObject.Get(CustomerContractLines."Service Object No.") then begin
                    ServiceObject.Get(CustomerContractLines."Service Object No.");
                    ServiceObject.UpdateServicesDates();
                    ServiceObject.Modify(false);
                    TempServiceObject := ServiceObject;
                    TempServiceObject.Insert(false);
                end;
            until CustomerContractLines.Next() = 0;
    end;

    internal procedure UpdateAndRecalculateServiceCommitmentCurrencyData()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        if not CustomerContractLinesExists() then
            exit;
        if not ServiceCommitment.OpenExchangeSelectionPage(CurencyFactorDate, CurrencyFactor, Rec."Currency Code", CurrCodeChangePricesMustBeRecalculatedMsg, false) then
            Error('');
        ServiceCommitment.UpdateAndRecalculateServCommCurrencyFromContract(Enum::"Service Partner"::Customer, Rec."No.", CurrencyFactor, CurencyFactorDate, Rec."Currency Code");
    end;

    internal procedure ResetCustomerServiceCommitmentCurrencyFromLCY()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommitment.ResetServiceCommitmentCurrencyLCYFromContract(Enum::"Service Partner"::Customer, Rec."No.");
    end;

    internal procedure CreateBillingProposal()
    var
        BillingProposal: Codeunit "Billing Proposal";
    begin
        BillingProposal.CreateBillingProposalFromContract(Rec."No.", Rec.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
    end;

    internal procedure UpdateDimensionsInDeferrals()
    var
        ServiceCommitment: Record "Service Commitment";
        CustomerContractLine: Record "Customer Contract Line";
        DeferralCount: Integer;
    begin
        if NotReleasedCustomerContractDeferralsExists() then
            if CustomerContractLinesExists(CustomerContractLine) then begin
                CustomerContractLine.SetFilter("Service Commitment Entry No.", '<>0');
                if CustomerContractLine.FindSet() then
                    repeat
                        if ServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.") then begin
                            CustomerContractDeferral.SetRange("Contract Line No.", CustomerContractLine."Line No.");
                            CustomerContractDeferral.SetRange(Released, false);
                            DeferralCount += CustomerContractDeferral.Count;
                            CustomerContractDeferral.ModifyAll("Dimension Set ID", ServiceCommitment."Dimension Set ID", false);
                        end;
                    until CustomerContractLine.Next() = 0;
            end;
        Message(UpdatedDeferralsMsg, DeferralCount);
    end;

    internal procedure RecalculateHarmonizedBillingFieldsBasedOnNextBillingDate(DeletedCustContractLineNo: Integer)
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        if not Rec.IsContractTypeSetAsHarmonizedBilling() then
            exit;
        if not Rec.FindEarliestServiceCommitment(ServiceCommitment, DeletedCustContractLineNo) then begin
            Rec.ResetHarmonizedBillingFields();
            Rec.Modify(false);
            exit;
        end;
        Rec.UpdateHarmonizedBillingFields(ServiceCommitment);
        Rec.Modify(false);
    end;

    internal procedure FindEarliestServiceCommitment(var ServiceCommitment: Record "Service Commitment"; DeletedCustContractLineNo: Integer) ServiceCommitmentFound: Boolean
    begin
        ServiceCommitment.SetCurrentKey("Next Billing Date");
        ServiceCommitment.SetAscending("Next Billing Date", true);
        ServiceCommitment.SetRange("Contract No.", Rec."No.");
        ServiceCommitment.SetFilter("Contract Line No.", '<>%1', DeletedCustContractLineNo);
        if ServiceCommitment.FindFirst() then
            repeat
                if not ServiceCommitment.IsClosed() then
                    ServiceCommitmentFound := true;
            until (ServiceCommitmentFound = true) or (ServiceCommitment.Next() = 0);
    end;

    internal procedure IsContractEmpty(): Boolean
    var
        CustomerContractLine: Record "Customer Contract Line";
    begin
        CustomerContractLine.SetRange("Contract No.", Rec."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::"Service Commitment");
        exit(CustomerContractLine.IsEmpty());
    end;

    local procedure SetDefaultWithoutContractDeferralsFromContractType()
    var
        ContractType: Record "Contract Type";
    begin
        if not ContractType.Get(Rec."Contract Type") then
            exit;
        Rec."Without Contract Deferrals" := ContractType."Def. Without Contr. Deferrals";
    end;

    local procedure ClearDeviatingShipToAddressNotification()
    begin
        Clear(ShipToAddressBuffer);
    end;

    local procedure AppendDifferentShipToAddressNotification(ServiceObjectNo: Code[20])
    var
        DummyBool: Boolean;
    begin
        if ServiceObjectNo = '' then
            exit;
        if not ShipToAddressBuffer.Get(ServiceObjectNo, DummyBool) then
            ShipToAddressBuffer.Add(ServiceObjectNo, DummyBool);
    end;

    local procedure NotifyIfShipToAddressDiffers()
    var
        ContractNotifications: Codeunit "Contract Notifications";
        ShipToAddressDiffersNotification: Notification;
        ServiceObjectNo: Code[20];
        ServiceObjectNoFilter: Text;
        ShipToAddressDiffersMsg: Label 'For at least one Service Object, the shipment address differs from the Customer Contract it was assigned to.';
        ActionShowServiceObjectsTxt: Label 'Show Service Object(s)';
    begin
        if ShipToAddressBuffer.Count = 0 then
            exit;

        ServiceObjectNoFilter := '';
        foreach ServiceObjectNo in ShipToAddressBuffer.Keys() do begin
            if ServiceObjectNoFilter <> '' then
                ServiceObjectNoFilter += '|';
            ServiceObjectNoFilter += ServiceObjectNo;
        end;
        ShipToAddressDiffersNotification.Id := CreateGuid();
        ShipToAddressDiffersNotification.Message(ShipToAddressDiffersMsg);
        ShipToAddressDiffersNotification.Scope := NotificationScope::LocalScope;
        ShipToAddressDiffersNotification.SetData(ContractNotifications.GetDataNameServiceObjectNoFilter(), ServiceObjectNoFilter);
        ShipToAddressDiffersNotification.AddAction(ActionShowServiceObjectsTxt, Codeunit::"Contract Notifications", 'ShowServiceObjects');
        ShipToAddressDiffersNotification.Send();
    end;

    local procedure AppendShipToAddressBufferIfShipToCodeDiffers(var ServiceObject: Record "Service Object")
    begin
        if (Rec."Ship-to Code" = ServiceObject."Ship-to Code") or
             Rec.IsShipToAddressEqualToServiceObjectShipToAddress(ServiceObject)
        then
            exit;
        if not CustomerContractLinesExists() then
            exit;
        AppendDifferentShipToAddressNotification(ServiceObject."No.");
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterIsShipToAddressEqualToSellToAddress(SellToCustomerContract: Record "Customer Contract"; ShipToCustomerContract: Record "Customer Contract"; var Result: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterIsShipToAddressEqualToServiceObjectShipToAddress(CustomerContract: Record "Customer Contract"; ServiceObject: Record "Service Object"; var Result: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterGetServiceContractSetup(CustomerContract: Record "Customer Contract"; var ServiceContractSetup: Record "Service Contract Setup"; CalledByFieldNo: Integer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var CustomerContract: Record "Customer Contract"; xCustomerContract: Record "Customer Contract"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterSetFieldsBilltoCustomer(var CustomerContract: Record "Customer Contract"; Customer: Record Customer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopySellToAddressToShipToAddress(var CustomerContract: Record "Customer Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopySellToAddressToBillToAddress(var CustomerContract: Record "Customer Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyShipToCustomerAddressFieldsFromCustomer(var CustomerContract: Record "Customer Contract"; SellToCustomer: Record Customer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr(var CustomerContract: Record "Customer Contract"; ShipToAddress: Record "Ship-to Address")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopySellToCustomerAddressFieldsFromCustomer(var CustomerContract: Record "Customer Contract"; SellToCustomer: Record Customer; CurrentFieldNo: Integer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeAssistEdit(var CustomerContract: Record "Customer Contract"; OldCustomerContract: Record "Customer Contract"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeConfirmBillToContactNoChange(var CustomerContract: Record "Customer Contract"; xCustomerContract: Record "Customer Contract"; CurrentFieldNo: Integer; var Confirmed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeConfirmSellToContactNoChange(var CustomerContract: Record "Customer Contract"; xCustomerContract: Record "Customer Contract"; CurrentFieldNo: Integer; var Confirmed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInitInsert(var CustomerContract: Record "Customer Contract"; xCustomerContract: Record "Customer Contract"; var IsHandled: Boolean)
    begin
    end;


    [InternalEvent(false, false)]
    local procedure OnBeforeCopyShipToCustomerAddressFieldsFromCustomer(var CustomerContract: Record "Customer Contract"; Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCopyShipToCustomerAddressFieldsFromShipToAddr(var CustomerContract: Record "Customer Contract"; ShipToAddress: Record "Ship-to Address"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateDim(var CustomerContract: Record "Customer Contract"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeLookupBillToPostCode(var CustomerContract: Record "Customer Contract"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeLookupSellToPostCode(var CustomerContract: Record "Customer Contract"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeLookupShipToPostCode(var CustomerContract: Record "Customer Contract"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateBillToPostCode(var CustomerContract: Record "Customer Contract"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateSellToPostCode(var CustomerContract: Record "Customer Contract"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateShipToPostCode(var CustomerContract: Record "Customer Contract"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeUpdateSellToCust(var CustomerContract: Record "Customer Contract"; var Contact: Record Contact; var Customer: Record Customer; ContactNo: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateDimOnBeforeModify(var CustomerContract: Record "Customer Contract"; xCustomerContract: Record "Customer Contract"; CurrentFieldNo: Integer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnInitFromContactOnAfterInitNoSeries(var CustomerContract: Record "Customer Contract"; var xCustomerContract: Record "Customer Contract")
    begin
    end;


    [InternalEvent(false, false)]
    local procedure OnValidateSellToCustomerNoAfterInit(var CustomerContract: Record "Customer Contract"; var xCustomerContract: Record "Customer Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateBillToCont(var CustomerContract: Record "Customer Contract"; Customer: Record Customer; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateBillToCust(var CustomerContract: Record "Customer Contract"; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateSellToCont(var CustomerContract: Record "Customer Contract"; Customer: Record Customer; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateSellToCust(var CustomerContract: Record "Customer Contract"; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateBillToCustomerName(var CustomerContract: Record "Customer Contract"; var Customer: Record Customer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateSellToCustomerName(var CustomerContract: Record "Customer Contract"; var Customer: Record Customer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var CustomerContract: Record "Customer Contract"; xCustomerContract: Record "Customer Contract"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUpdateBillToCustOnBeforeContactIsNotRelatedToAnyCostomerErr(var CustomerContract: Record "Customer Contract"; Contact: Record Contact; var ContactBusinessRelation: Record "Contact Business Relation"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUpdateBillToCustOnBeforeFindContactBusinessRelation(Contact: Record Contact; var ContBusinessRelation: Record "Contact Business Relation"; var ContactBusinessRelationFound: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUpdateSellToCustOnBeforeContactIsNotRelatedToAnyCostomerErr(var CustomerContract: Record "Customer Contract"; Contact: Record Contact; var ContactBusinessRelation: Record "Contact Business Relation"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUpdateSellToCustOnBeforeFindContactBusinessRelation(Cont: Record Contact; var ContBusinessRelation: Record "Contact Business Relation"; var ContactBusinessRelationFound: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnValidateBillToCustomerNoOnAfterConfirmed(var CustomerContract: Record "Customer Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeUpdateBillToCust(var CustomerContract: Record "Customer Contract"; ContactNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCheckContactRelatedToCustomerCompany(CustomerContract: Record "Customer Contract"; CurrFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateCustomerContractLineFromServiceCommitment(var ServiceCommitment: Record "Service Commitment"; ContractNo: Code[20]; var CustomerContractLine: Record "Customer Contract Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateCustomerContractLineFromServiceCommitment(ServiceCommitment: Record "Service Commitment"; var CustomerContractLine: Record "Customer Contract Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeModifyServiceCommitmentOnCreateCustomerContractLineFromServiceCommitment(var ServiceCommitment: Record "Service Commitment"; CustomerContractLine: Record "Customer Contract Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateDimDimSource(Rec: Record "Customer Contract"; CurrFieldNo: Integer; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;
}