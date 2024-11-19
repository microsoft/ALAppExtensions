namespace Microsoft.SubscriptionBilling;


using System.Utilities;
using System.EMail;
using System.Environment.Configuration;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Pricing;
using Microsoft.CRM.Contact;
using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Outlook;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;

table 8057 "Service Object"
{
    Caption = 'Service Object';
    DataClassification = CustomerContent;
    DataCaptionFields = "No.", Description;
    LookupPageId = "Service Objects";
    DrillDownPageId = "Service Objects";
    Access = Internal;

    fields
    {
        field(2; "End-User Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                if ("End-User Customer No." <> xRec."End-User Customer No.") and
                   (xRec."End-User Customer No." <> '')
                then begin
                    if HideValidationDialog or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := ConfirmManagement.GetResponse(StrSubstNo(ConfirmChangeQst, EndUserCustomerTxt), false);
                    if Confirmed then begin
                        if "End-User Customer No." = '' then begin
                            Init();
                            OnValidateEndUserCustomerNoAfterInit(Rec, xRec);
                            GetCustomerServiceContractSetup();
                            "No. Series" := xRec."No. Series";
                            exit;
                        end;
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                GetCust("End-User Customer No.");

                CopyEndUserCustomerAddressFieldsFromCustomer(Cust);

                Validate("Ship-to Code", Cust."Ship-to Code");
                if Cust."Bill-to Customer No." <> '' then
                    Validate("Bill-to Customer No.", Cust."Bill-to Customer No.")
                else begin
                    if "Bill-to Customer No." = "End-User Customer No." then
                        SkipBillToContact := true;
                    Validate("Bill-to Customer No.", "End-User Customer No.");
                    SkipBillToContact := false;
                end;

                if not SkipEndUserContact then
                    UpdateEndUserCont("End-User Customer No.");

                if (xRec."End-User Customer No." <> '') and (xRec."End-User Customer No." <> "End-User Customer No.") then
                    RecallModifyAddressNotification(GetModifyCustomerAddressNotificationId());
                "Customer Price Group" := Cust."Customer Price Group";
                if "End-User Customer No." <> xRec."End-User Customer No." then begin
                    TestIfServiceCommitmentsAreLinkedToContracts();
                    RecalculateServiceCommitments(FieldCaption("End-User Customer No."), false);
                end;
            end;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GetCustomerServiceContractSetup();
                    NoSeries.TestManual(ServiceContractSetup."Service Object Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(4; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            NotBlank = true;
            TableRelation = Customer;

            trigger OnValidate()
            begin
                BilltoCustomerNoChanged := xRec."Bill-to Customer No." <> "Bill-to Customer No.";
                if BilltoCustomerNoChanged then
                    if xRec."Bill-to Customer No." <> '' then begin
                        if HideValidationDialog or not GuiAllowed then
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

                if BilltoCustomerNoChanged then
                    RecalculateServiceCommitments(FieldCaption("Bill-to Customer No."), false);

                if (xRec."End-User Customer No." = "End-User Customer No.") and
                   (xRec."Bill-to Customer No." <> "Bill-to Customer No.")
                then
                    BilltoCustomerNoChanged := false;

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
            //This property is currently not supported
            //TestTableRelation = false;
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
        field(12; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("End-User Customer No."));
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                ShipToAddr: Record "Ship-to Address";
            begin
                if "Ship-to Code" <> '' then begin
                    ShipToAddr.Get("End-User Customer No.", "Ship-to Code");
                    SetShipToCustomerAddressFieldsFromShipToAddr(ShipToAddr);
                end else
                    if "End-User Customer No." <> '' then begin
                        GetCust("End-User Customer No.");
                        CopyShipToCustomerAddressFieldsFromCustomer(Cust);
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
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item where("Service Commitment Option" = filter("Sales with Service Commitment" | "Service Commitment Item" | "Invoicing Item"));

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "Item No." <> '' then begin
                    Item.Get("Item No.");
                    Description := Item.Description;
                    Validate("Unit of Measure", Item."Sales Unit of Measure");
                    if "Serial No." <> '' then
                        Validate("Quantity Decimal", 1);
                    InsertServiceCommitmentsFromStandardServCommPackages();
                end;
            end;
        }
        field(21; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                CheckIfUpdateRequiredOnBillingLinesNeeded();
            end;
        }
        field(23; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';

            trigger OnValidate()
            begin
                if ("Quantity Decimal" <> 1) and ("Serial No." <> '') then
                    Error(SerialQtyErr);
                Rec.ArchiveServiceCommitments();
            end;
        }
        field(24; Version; Text[100])
        {
            Caption = 'Version';
        }
        field(25; "Key"; Text[100])
        {
            Caption = 'Key';
        }
        field(26; "Provision Start Date"; Date)
        {
            Caption = 'Provision Start Date';
        }
        field(27; "Provision End Date"; Date)
        {
            Caption = 'Provision End Date';
        }
        field(28; "Quantity Decimal"; Decimal)
        {
            Caption = 'Quantity';
            InitValue = 1;
            NotBlank = true;

            trigger OnValidate()
            begin
                if "Quantity Decimal" <= 0 then
                    Error(QtyZeroOrNegativeErr);
                if ("Quantity Decimal" <> 1) and ("Serial No." <> '') then
                    Error(SerialQtyErr);
                Rec.ArchiveServiceCommitments();
                if "Quantity Decimal" <> xRec."Quantity Decimal" then
                    RecalculateServiceCommitments(FieldCaption("Quantity Decimal"), true);
            end;
        }
        field(34; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(79; "End-User Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Customer.Name;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                LookupEndUserCustomerName();
            end;

            trigger OnValidate()
            var
                Customer: Record Customer;
                SalesHeader: Record "Sales Header";
            begin
                OnBeforeValidateEndUserCustomerName(Rec, Customer);

                if SalesHeader.ShouldSearchForCustomerByName("End-User Customer No.") then
                    Validate("End-User Customer No.", Customer.GetCustNo("End-User Customer Name"));
            end;
        }
        field(80; "End-User Customer Name 2"; Text[50])
        {
            Caption = 'Customer Name 2';
            DataClassification = EndUserIdentifiableInformation;
        }

        field(81; "End-User Address"; Text[100])
        {
            Caption = 'Address';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyCustomerAddress();
            end;
        }
        field(82; "End-User Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyCustomerAddress();
            end;
        }
        field(83; "End-User City"; Text[30])
        {
            Caption = 'City';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("End-User Country/Region Code" = const('')) "Post Code".City
            else
            if ("End-User Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("End-User Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                EndUserCity: Text;
                EndUserCounty: Text;
            begin
                EndUserCity := "End-User City";
                EndUserCounty := "End-User County";
                PostCode.LookupPostCode(EndUserCity, "End-User Post Code", EndUserCounty, "End-User Country/Region Code");
                "End-User City" := CopyStr(EndUserCity, 1, MaxStrLen("End-User City"));
                "End-User County" := CopyStr(EndUserCounty, 1, MaxStrLen("End-User County"));
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(
                  "End-User City", "End-User Post Code", "End-User County", "End-User Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
                ModifyCustomerAddress();
            end;
        }
        field(84; "End-User Contact"; Text[100])
        {
            Caption = 'Contact';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin
                if "End-User Customer No." = '' then
                    exit;

                Contact.FilterGroup(2);
                LookupContact("End-User Customer No.", "End-User Contact No.", Contact);
                if Page.RunModal(0, Contact) = Action::LookupOK then
                    Validate("End-User Contact No.", Contact."No.");
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

        field(88; "End-User Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("End-User Country/Region Code" = const('')) "Post Code"
            else
            if ("End-User Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("End-User Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                EndUserCity: Text;
                EndUserCounty: Text;
            begin
                OnBeforeLookupEndUserPostCode(Rec, PostCode);

                EndUserCity := "End-User City";
                EndUserCounty := "End-User County";
                PostCode.LookupPostCode(EndUserCity, "End-User Post Code", EndUserCounty, "End-User Country/Region Code");
                "End-User City" := CopyStr(EndUserCity, 1, MaxStrLen("End-User City"));
                "End-User County" := CopyStr(EndUserCounty, 1, MaxStrLen("End-User County"));
            end;

            trigger OnValidate()
            begin
                OnBeforeValidateEndUserPostCode(Rec, PostCode);

                PostCode.ValidatePostCode(
                  "End-User City", "End-User Post Code", "End-User County", "End-User Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
                ModifyCustomerAddress();
            end;
        }
        field(89; "End-User County"; Text[30])
        {
            CaptionClass = '5,1,' + "End-User Country/Region Code";
            Caption = 'County';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyCustomerAddress();
            end;
        }
        field(90; "End-User Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
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
        field(94; "Customer Reference"; Text[35])
        {
            Caption = 'Customer Reference';
        }
        field(95; "Archived Service Commitments"; Boolean)
        {
            Caption = 'Archived Service Commitments';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist("Service Commitment Archive" where("Service Object No." = field("No.")));
        }
        field(96; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));

            trigger OnValidate()
            begin
                Rec.ArchiveServiceCommitments();
                if Rec."Variant Code" <> xRec."Variant Code" then
                    RecalculateServiceCommitments(FieldCaption("Variant Code"), false);
            end;
        }
        field(107; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(171; "End-User Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = EndUserIdentifiableInformation;
            ExtendedDatatype = PhoneNo;
        }
        field(172; "End-User E-Mail"; Text[80])
        {
            Caption = 'Email';
            DataClassification = EndUserIdentifiableInformation;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "End-User E-Mail" = '' then
                    exit;
                MailManagement.CheckValidEmailAddresses("End-User E-Mail");
            end;
        }
        field(173; "End-User Fax No."; Text[30])
        {
            Caption = 'Fax No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(200; "Planned Serv. Comm. exists"; Boolean)
        {
            Caption = 'Planned Service Commitment exists';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Planned Service Commitment" where("Service Object No." = field("No.")));
        }
        field(5052; "End-User Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
            begin
                if "End-User Customer No." <> '' then
                    if Cont.Get("End-User Contact No.") then
                        Cont.SetRange("Company No.", Cont."Company No.")
                    else
                        if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Customer, "End-User Customer No.") then
                            Cont.SetRange("Company No.", ContBusinessRelation."Contact No.")
                        else
                            Cont.SetRange("No.", '');

                if "End-User Contact No." <> '' then
                    if Cont.Get("End-User Contact No.") then;
                if Page.RunModal(0, Cont) = Action::LookupOK then begin
                    xRec := Rec;
                    Validate("End-User Contact No.", Cont."No.");
                end;
            end;

            trigger OnValidate()
            var
                Cont: Record Contact;
                IsHandled: Boolean;
            begin
                if "End-User Contact No." <> '' then
                    if Cont.Get("End-User Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric();

                if ("End-User Contact No." <> xRec."End-User Contact No.") and
                   (xRec."End-User Contact No." <> '')
                then begin
                    IsHandled := false;
                    OnBeforeConfirmEndUserContactNoChange(Rec, xRec, CurrFieldNo, Confirmed, IsHandled);
                    if not IsHandled then
                        if HideValidationDialog or not GuiAllowed then
                            Confirmed := true
                        else
                            Confirmed := ConfirmManagement.GetResponse(StrSubstNo(ConfirmChangeQst, FieldCaption("End-User Contact No.")), false);
                    if Confirmed then begin
                        if InitFromContact("End-User Contact No.", "End-User Customer No.") then
                            exit;
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                if ("End-User Customer No." <> '') and ("End-User Contact No." <> '') then
                    CheckContactRelatedToCustomerCompany("End-User Contact No.", "End-User Customer No.", CurrFieldNo);

                UpdateEndUserCust("End-User Contact No.");
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
                        if HideValidationDialog or (not GuiAllowed) then
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
        field(5425; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        InitInsert();
    end;

    trigger OnDelete()
    var
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentArchive: Record "Service Commitment Archive";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
    begin
        ServiceCommitment.SetRange("Service Object No.", "No.");
        if not ServiceCommitment.IsEmpty() then
            Error(ServiceCommitmentExistsErr, "No.", ServiceCommitment.TableCaption);

        ServiceCommitmentArchive.SetRange("Service Object No.", Rec."No.");
        ServiceCommitmentArchive.DeleteAll(true);

        TestUpdateRequiredOnBillingLines();

        ContractsGeneralMgt.DeleteDocumentAttachmentForNo(Database::"Service Object", Rec."No.");
    end;

    trigger OnModify()
    begin
        CheckIfUpdateRequiredOnBillingLinesNeeded();
        UpdateCustomerContractLineServiceObjectDescription();
        UpdateVendorContractLineServiceObjectDescription();
        TestIfServiceCommitmentsAreLinkedToContracts();
    end;

    var
        ServiceContractSetup: Record "Service Contract Setup";
        Cust: Record Customer;
        PostCode: Record "Post Code";
        NoSeries: Codeunit "No. Series";
        ConfirmManagement: Codeunit "Confirm Management";
        Confirmed: Boolean;
        BilltoCustomerNoChanged: Boolean;
        SkipEndUserContact: Boolean;
        SkipBillToContact: Boolean;
        SkipInsertServiceCommitments: Boolean;
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        QtyZeroOrNegativeErr: Label 'The quantity cannot be zero or negative.';
        EndUserCustomerTxt: Label 'End-User Customer';
        BillToCustomerTxt: Label 'Bill-to Customer';
        SerialQtyErr: Label 'Only service objects with quantity 1 may have a serial number.';
        ServiceObjectAlreadyExistErr: Label 'Service object %1 already exists.';
        ModifyCustomerAddressNotificationLbl: Label 'Update the address';
        ModifyCustomerAddressNotificationMsg: Label 'The address you entered for %1 is different from the customer''s existing address.', Comment = '%1=customer name';
        DontShowAgainActionLbl: Label 'Don''t show again';
        ContactRelatedToDifferentCompanyErr: Label 'Contact %1 %2 is related to a different company than customer %3.';
        ContactNotRelatedToCustomerErr: Label 'Contact %1 %2 is not related to customer %3.';
        ContactIsNotRelatedToAnyCustomerErr: Label 'Contact %1 %2 is not related to a customer.';
        ConfirmEmptyEmailQst: Label 'Contact %1 has no email address specified. The value in the Email field for the End User, %2, will be deleted. Do you want to continue?', Comment = '%1 - Contact No., %2 - Email';
        ServiceCommitmentExistsErr: Label 'Cannot delete %1 while %2 exists.';
        ModifyEndUserCustomerAddressNotificationNameTxt: Label 'Update Sell-to Customer Address';
        ModifyEndUserCustomerAddressNotificationDescriptionTxt: Label 'Warn if the sell-to address on service object is different from the customer''s existing address.';
        ModifyBillToCustomerAddressNotificationNameTxt: Label 'Update Bill-to Customer Address';
        ModifyBillToCustomerAddressNotificationDescriptionTxt: Label 'Warn if the bill-to address on service object is different from the customer''s existing address.';
        EndUserCustomerChangeNotAllowedErr: Label 'The End-User cannot be changed because at least one service is already linked to a contract.';
        EndUserCustomerChangeQst: Label 'By changing the End-User, the customer price group also changes. This will subsequently delete the services and replace them with the standard services of the item. Do you want to continue?';
        UpdateExchangeRatesInServiceMsg: Label 'If you want to update the exchange rates in the services, specify the key date and start the processing with OK.';
        SerialNoLbl: Label 'Serial No.: %1';
        PrimaryAttributeTxt: Label 'Primary Attribute';

    protected var
        CalledFromExtendContract: Boolean;
        UnitPrice: Decimal;
        UnitCost: Decimal;
        HideValidationDialog: Boolean;

    local procedure InitInsert()
    var
        ServiceObject: Record "Service Object";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitInsert(Rec, xRec, IsHandled);
        if not IsHandled then
            if "No." = '' then begin
                GetCustomerServiceContractSetup();
                ServiceContractSetup.TestField("Service Object Nos.");
                "No. Series" := ServiceContractSetup."Service Object Nos.";
                if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                    "No. Series" := xRec."No. Series";
                "No." := NoSeries.GetNextNo("No. Series");
                ServiceObject.ReadIsolation(IsolationLevel::ReadUncommitted);
                ServiceObject.SetLoadFields("No.");
                while ServiceObject.Get("No.") do
                    "No." := NoSeries.GetNextNo("No. Series");
            end;
    end;

    local procedure GetCustomerServiceContractSetup()
    begin
        ServiceContractSetup.Get();
        OnAfterGetCustomerServiceContractSetup(Rec, ServiceContractSetup, CurrFieldNo);
    end;

    procedure GetHideValidationDialog(): Boolean
    begin
        exit(HideValidationDialog);
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure GetCust(CustNo: Code[20])
    var
    begin
        if not (CustNo = '') then begin
            if CustNo <> Cust."No." then
                Cust.Get(CustNo);
        end else
            Clear(Cust);
    end;

    local procedure CopyEndUserCustomerAddressFieldsFromCustomer(var EndUserCustomer: Record Customer)
    begin
        "End-User Customer Name" := Cust.Name;
        "End-User Customer Name 2" := Cust."Name 2";

        if EndUserCustomerIsReplaced() or ShouldCopyAddressFromEndUserCustomer(EndUserCustomer) then begin
            "End-User Address" := EndUserCustomer.Address;
            "End-User Address 2" := EndUserCustomer."Address 2";
            "End-User City" := EndUserCustomer.City;
            "End-User Post Code" := EndUserCustomer."Post Code";
            "End-User County" := EndUserCustomer.County;
            "End-User Country/Region Code" := EndUserCustomer."Country/Region Code";
            "End-User Phone No." := EndUserCustomer."Phone No.";
            "End-User E-Mail" := EndUserCustomer."E-Mail";
            "End-User Fax No." := EndUserCustomer."Fax No.";
        end;
        if not SkipEndUserContact then
            "End-User Contact" := EndUserCustomer.Contact;

        OnAfterCopyEndUserCustomerAddressFieldsFromCustomer(Rec, EndUserCustomer, CurrFieldNo);
    end;

    local procedure CopyShipToCustomerAddressFieldsFromCustomer(var EndUserCustomer: Record Customer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyShipToCustomerAddressFieldsFromCustomer(Rec, EndUserCustomer, IsHandled);
        if IsHandled then
            exit;

        "Ship-to Name" := Cust.Name;
        "Ship-to Name 2" := Cust."Name 2";
        if EndUserCustomerIsReplaced() or ShipToAddressEqualsOldEndUserAddress() then begin
            "Ship-to Address" := EndUserCustomer.Address;
            "Ship-to Address 2" := EndUserCustomer."Address 2";
            "Ship-to City" := EndUserCustomer.City;
            "Ship-to Post Code" := EndUserCustomer."Post Code";
            "Ship-to County" := EndUserCustomer.County;
            Validate("Ship-to Country/Region Code", EndUserCustomer."Country/Region Code");
        end;
        "Ship-to Contact" := Cust.Contact;

        OnAfterCopyShipToCustomerAddressFieldsFromCustomer(Rec, EndUserCustomer);
    end;

    internal procedure AssistEdit(OldServiceObject: Record "Service Object"): Boolean
    var
        ServiceObject: Record "Service Object";
        ServiceObject2: Record "Service Object";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssistEdit(Rec, OldServiceObject, IsHandled);
        if IsHandled then
            exit;

        ServiceObject.Copy(Rec);
        GetCustomerServiceContractSetup();
        ServiceContractSetup.TestField("Service Object Nos.");
        if NoSeries.LookupRelatedNoSeries(ServiceContractSetup."Customer Contract Nos.", OldServiceObject."No. Series", ServiceObject."No. Series") then begin
            ServiceObject."No." := NoSeries.GetNextNo(ServiceObject."No. Series");
            if ServiceObject2.Get(ServiceObject."No.") then
                Error(ServiceObjectAlreadyExistErr, ServiceObject."No.");
            Rec := ServiceObject;
            exit(true);
        end;
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
            if Contact.Get(ContactNo) then
                Contact.SetRange("Company No.", Contact."Company No.");
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

        OnAfterSetFieldsBilltoCustomer(Rec, BillToCustomer);
    end;

    local procedure ShouldCopyAddressFromEndUserCustomer(EndUserCustomer: Record Customer): Boolean
    begin
        exit((not HasEndUserAddress()) and EndUserCustomer.HasAddress());
    end;

    local procedure ShouldCopyAddressFromBillToCustomer(BillToCustomer: Record Customer): Boolean
    begin
        exit((not HasBillToAddress()) and BillToCustomer.HasAddress());
    end;

    local procedure EndUserCustomerIsReplaced(): Boolean
    begin
        exit((xRec."End-User Customer No." <> '') and (xRec."End-User Customer No." <> "End-User Customer No."));
    end;

    local procedure BillToCustomerIsReplaced(): Boolean
    begin
        exit((xRec."Bill-to Customer No." <> '') and (xRec."Bill-to Customer No." <> "Bill-to Customer No."));
    end;

    local procedure ShipToAddressEqualsOldEndUserAddress(): Boolean
    begin
        exit(IsShipToAddressEqualToEndUserAddress(xRec, Rec));
    end;

    local procedure IsShipToAddressEqualToEndUserAddress(ServiceObjectWithEndUser: Record "Service Object"; ServiceObjectWithShipTo: Record "Service Object"): Boolean
    var
        Result: Boolean;
    begin
        Result :=
          (ServiceObjectWithEndUser."End-User Address" = ServiceObjectWithShipTo."Ship-to Address") and
          (ServiceObjectWithEndUser."End-User Address 2" = ServiceObjectWithShipTo."Ship-to Address 2") and
          (ServiceObjectWithEndUser."End-User City" = ServiceObjectWithShipTo."Ship-to City") and
          (ServiceObjectWithEndUser."End-User County" = ServiceObjectWithShipTo."Ship-to County") and
          (ServiceObjectWithEndUser."End-User Post Code" = ServiceObjectWithShipTo."Ship-to Post Code") and
          (ServiceObjectWithEndUser."End-User Country/Region Code" = ServiceObjectWithShipTo."Ship-to Country/Region Code") and
          (ServiceObjectWithEndUser."End-User Contact" = ServiceObjectWithShipTo."Ship-to Contact");

        OnAfterIsShipToAddressEqualToEndUserAddress(ServiceObjectWithEndUser, ServiceObjectWithShipTo, Result);
        exit(Result);
    end;

    internal procedure CopyEndUserAddressToShipToAddress()
    begin
        "Ship-to Address" := "End-User Address";
        "Ship-to Address 2" := "End-User Address 2";
        "Ship-to City" := "End-User City";
        "Ship-to Contact" := "End-User Contact";
        "Ship-to Country/Region Code" := "End-User Country/Region Code";
        "Ship-to County" := "End-User County";
        "Ship-to Post Code" := "End-User Post Code";

        OnAfterCopyEndUserAddressToShipToAddress(Rec);
    end;

    internal procedure CopyEndUserAddressToBillToAddress()
    begin
        if "Bill-to Customer No." = "End-User Customer No." then begin
            "Bill-to Address" := "End-User Address";
            "Bill-to Address 2" := "End-User Address 2";
            "Bill-to Post Code" := "End-User Post Code";
            "Bill-to Country/Region Code" := "End-User Country/Region Code";
            "Bill-to City" := "End-User City";
            "Bill-to County" := "End-User County";
            OnAfterCopyEndUserAddressToBillToAddress(Rec);
        end;
    end;

    local procedure HasEndUserAddress(): Boolean
    begin
        case true of
            "End-User Address" <> '':
                exit(true);
            "End-User Address 2" <> '':
                exit(true);
            "End-User City" <> '':
                exit(true);
            "End-User Country/Region Code" <> '':
                exit(true);
            "End-User County" <> '':
                exit(true);
            "End-User Post Code" <> '':
                exit(true);
            "End-User Contact" <> '':
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

    local procedure ModifyBillToCustomerAddress()
    var
        Customer: Record Customer;
    begin
        if ("Bill-to Customer No." <> "End-User Customer No.") and Customer.Get("Bill-to Customer No.") then
            if HasBillToAddress() and HasDifferentBillToAddress(Customer) then
                ShowModifyAddressNotification(GetModifyBillToCustomerAddressNotificationId(),
                  ModifyCustomerAddressNotificationLbl, ModifyCustomerAddressNotificationMsg,
                  'CopyBillToCustomerAddressFieldsFromServiceObject', "Bill-to Customer No.",
                  "Bill-to Name", FieldName("Bill-to Customer No."));
    end;

    local procedure ModifyCustomerAddress()
    var
        Customer: Record Customer;
    begin
        if Customer.Get("End-User Customer No.") and HasEndUserAddress() and HasDifferentEndUserAddress(Customer) then
            ShowModifyAddressNotification(GetModifyCustomerAddressNotificationId(),
              ModifyCustomerAddressNotificationLbl, ModifyCustomerAddressNotificationMsg,
              'CopySellToCustomerAddressFieldsFromServiceObject', "End-User Customer No.",
              "End-User Customer Name", FieldName("End-User Customer No."));
    end;

    local procedure HasDifferentEndUserAddress(Customer: Record Customer): Boolean
    begin
        exit(("End-User Address" <> Customer.Address) or
          ("End-User Address 2" <> Customer."Address 2") or
          ("End-User City" <> Customer.City) or
          ("End-User Country/Region Code" <> Customer."Country/Region Code") or
          ("End-User County" <> Customer.County) or
          ("End-User Post Code" <> Customer."Post Code") or
          ("End-User Contact" <> Customer.Contact));
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
        ModifyCustomerAddressNotification.AddAction(NotificationLbl, Codeunit::"Service Object Notifications", NotificationFunctionTok);
        ModifyCustomerAddressNotification.AddAction(
          DontShowAgainActionLbl, Codeunit::"Service Object Notifications", 'ServiceObjectHideNotificationForCurrentUser');
        ModifyCustomerAddressNotification.Scope := NotificationScope::LocalScope;
        ModifyCustomerAddressNotification.SetData(FieldName("No."), "No.");
        ModifyCustomerAddressNotification.SetData(CustomerNumberFieldName, CustomerNumber);
        NotificationLifecycleMgt.SendNotification(ModifyCustomerAddressNotification, RecordId);
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

    local procedure UpdateEndUserCont(CustomerNo: Code[20])
    var
        ContBusRel: Record "Contact Business Relation";
        OfficeContact: Record Contact;
        OfficeMgt: Codeunit "Office Management";
        OldHideValidationDialog: Boolean;
    begin
        if OfficeMgt.GetContact(OfficeContact, CustomerNo) then begin
            OldHideValidationDialog := HideValidationDialog;
            HideValidationDialog := true;
            UpdateEndUserCust(OfficeContact."No.");
            HideValidationDialog := OldHideValidationDialog;
        end else
            if Cust.Get(CustomerNo) then begin
                if Cust."Primary Contact No." <> '' then
                    "End-User Contact No." := Cust."Primary Contact No."
                else begin
                    ContBusRel.Reset();
                    ContBusRel.SetCurrentKey("Link to Table", "No.");
                    ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                    ContBusRel.SetRange("No.", "End-User Customer No.");
                    if ContBusRel.FindFirst() then
                        "End-User Contact No." := ContBusRel."Contact No."
                    else
                        "End-User Contact No." := '';
                end;
                "End-User Contact" := Cust.Contact;
            end;
        if "End-User Contact No." <> '' then
            if OfficeContact.Get("End-User Contact No.") then
                OfficeContact.CheckIfPrivacyBlockedGeneric();

        OnAfterUpdateEndUserCont(Rec, Cust, OfficeContact);
    end;

    local procedure UpdateEndUserCust(ContactNo: Code[20])
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Customer: Record Customer;
        Cont: Record Contact;
        ContactBusinessRelationFound: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeUpdateEndUserCust(Rec, Cont, Customer, ContactNo);

        if not Cont.Get(ContactNo) then begin
            "End-User Contact" := '';
            exit;
        end;
        "End-User Contact No." := Cont."No.";

        if Cont.Type = Cont.Type::Person then
            ContactBusinessRelationFound := ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Customer, Cont."No.");
        if not ContactBusinessRelationFound then begin
            IsHandled := false;
            OnUpdateEndUserCustOnBeforeFindContactBusinessRelation(Cont, ContBusinessRelation, ContactBusinessRelationFound, IsHandled);
            if not IsHandled then
                ContactBusinessRelationFound :=
                    ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Customer, Cont."Company No.");
        end;

        if ContactBusinessRelationFound then begin
            if ("End-User Customer No." <> '') and ("End-User Customer No." <> ContBusinessRelation."No.") then
                Error(ContactNotRelatedToCustomerErr, Cont."No.", Cont.Name, "End-User Customer No.");

            if "End-User Customer No." = '' then begin
                SkipEndUserContact := true;
                Validate("End-User Customer No.", ContBusinessRelation."No.");
                SkipEndUserContact := false;
            end;
            if (Cont."E-Mail" = '') and ("End-User E-Mail" <> '') and GuiAllowed then begin
                if ConfirmManagement.GetResponse(StrSubstNo(ConfirmEmptyEmailQst, Cont."No.", "End-User E-Mail"), false) then
                    Validate("End-User E-Mail", Cont."E-Mail");
            end else
                Validate("End-User E-Mail", Cont."E-Mail");
            Validate("End-User Phone No.", Cont."Phone No.");
            Validate("End-User Fax No.", Cont."Fax No.");
        end else begin
            IsHandled := false;
            OnUpdateEndUserCustOnBeforeContactIsNotRelatedToAnyCustomerErr(Rec, Cont, ContBusinessRelation, IsHandled);
            if not IsHandled then
                Error(ContactIsNotRelatedToAnyCustomerErr, Cont."No.", Cont.Name);

            "End-User Contact" := Cont.Name;
        end;

        if (Cont.Type = Cont.Type::Company) and Customer.Get("End-User Customer No.") then
            "End-User Contact" := Customer.Contact
        else
            if Cont.Type = Cont.Type::Company then
                "End-User Contact" := ''
            else
                "End-User Contact" := Cont.Name;

        if ("End-User Customer No." = "Bill-to Customer No.") or
           ("Bill-to Customer No." = '')
        then
            Validate("Bill-to Contact No.", "End-User Contact No.");

        OnAfterUpdateEndUserCust(Rec, Cont);
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
            OnUpdateBillToCustOnBeforeContactIsNotRelatedToAnyCustomerErr(Rec, Cont, ContBusinessRelation, IsHandled);
            if not IsHandled then
                Error(ContactIsNotRelatedToAnyCustomerErr, Cont."No.", Cont.Name);
        end;

        OnAfterUpdateBillToCust(Rec, Cont);
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
        exit('579790FF-5EC1-4CE5-BD6E-C7D9CA7B14C2');
    end;

    internal procedure GetModifyBillToCustomerAddressNotificationId(): Guid
    begin
        exit('D5A69922-51FB-49A8-A9FF-0B0FA378F228');
    end;

    internal procedure DontNotifyCurrentUserAgain(NotificationID: Guid)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(NotificationID) then
            case NotificationID of
                GetModifyCustomerAddressNotificationId():
                    MyNotifications.InsertDefault(NotificationID, ModifyEndUserCustomerAddressNotificationNameTxt,
                      ModifyEndUserCustomerAddressNotificationDescriptionTxt, false);
                GetModifyBillToCustomerAddressNotificationId():
                    MyNotifications.InsertDefault(NotificationID, ModifyBillToCustomerAddressNotificationNameTxt,
                      ModifyBillToCustomerAddressNotificationDescriptionTxt, false);
            end;
    end;

    local procedure InitFromContact(ContactNo: Code[20]; CustomerNo: Code[20]): Boolean
    begin
        if (ContactNo = '') and (CustomerNo = '') then begin
            Init();
            GetCustomerServiceContractSetup();
            "No. Series" := xRec."No. Series";
            OnInitFromContactOnAfterInitNoSeries(Rec, xRec);
            exit(true);
        end;
    end;

    local procedure CheckContactRelatedToCustomerCompany(ContactNo: Code[20]; CustomerNo: Code[20]; CurrFieldNo: Integer)
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

    internal procedure LookupEndUserCustomerName(): Boolean
    var
        Customer: Record Customer;
    begin
        if "End-User Customer No." <> '' then
            Customer.Get("End-User Customer No.");

        if Customer.SelectCustomer(Customer) then begin
            "End-User Customer Name" := Customer.Name;
            Validate("End-User Customer No.", Customer."No.");
            exit(true);
        end;
    end;

    internal procedure CalculateShipToBillToOptions(var ShipToOptions: Option "Default (End-User Address)","Alternate Shipping Address","Custom Address"; var BillToOptions: Option "Default (Customer)","Another Customer","Custom Address"; ServiceObject: Record "Service Object")
    var
        ShipToNameEqualsEndUserName: Boolean;
    begin
        ShipToNameEqualsEndUserName :=
          (ServiceObject."Ship-to Name" = ServiceObject."End-User Customer Name") and (ServiceObject."Ship-to Name 2" = ServiceObject."End-User Customer Name 2");

        case true of
            (ServiceObject."Ship-to Code" = '') and ShipToNameEqualsEndUserName and ShipToAddressEqualsEndUserAddress():
                ShipToOptions := ShipToOptions::"Default (End-User Address)";
            (ServiceObject."Ship-to Code" = '') and
          (not ShipToNameEqualsEndUserName or not ShipToAddressEqualsEndUserAddress()):
                ShipToOptions := ShipToOptions::"Custom Address";
            ServiceObject."Ship-to Code" <> '':
                ShipToOptions := ShipToOptions::"Alternate Shipping Address";
        end;

        case true of
            (ServiceObject."Bill-to Customer No." = ServiceObject."End-User Customer No.") and BillToAddressEqualsEndUserAddress():
                BillToOptions := BillToOptions::"Default (Customer)";
            (ServiceObject."Bill-to Customer No." = ServiceObject."End-User Customer No.") and (not BillToAddressEqualsEndUserAddress()):
                BillToOptions := BillToOptions::"Custom Address";
            ServiceObject."Bill-to Customer No." <> ServiceObject."End-User Customer No.":
                BillToOptions := BillToOptions::"Another Customer";
        end;

        OnAfterCalculateShipToBillToOptions(ShipToOptions, BillToOptions, ServiceObject);
    end;

    local procedure ShipToAddressEqualsEndUserAddress(): Boolean
    begin
        exit(IsShipToAddressEqualToEndUserAddress(Rec, Rec));
    end;

    local procedure BillToAddressEqualsEndUserAddress(): Boolean
    begin
        exit(IsBillToAddressEqualToEndUserAddress(Rec, Rec));
    end;

    local procedure IsBillToAddressEqualToEndUserAddress(ServiceObjectWithEndUser: Record "Service Object"; ServiceObjectWithBillTo: Record "Service Object"): Boolean
    begin
        if (ServiceObjectWithEndUser."End-User Address" = ServiceObjectWithBillTo."Bill-to Address") and
           (ServiceObjectWithEndUser."End-User Address 2" = ServiceObjectWithBillTo."Bill-to Address 2") and
           (ServiceObjectWithEndUser."End-User City" = ServiceObjectWithBillTo."Bill-to City") and
           (ServiceObjectWithEndUser."End-User County" = ServiceObjectWithBillTo."Bill-to County") and
           (ServiceObjectWithEndUser."End-User Post Code" = ServiceObjectWithBillTo."Bill-to Post Code") and
           (ServiceObjectWithEndUser."End-User Country/Region Code" = ServiceObjectWithBillTo."Bill-to Country/Region Code") and
           (ServiceObjectWithEndUser."End-User Contact No." = ServiceObjectWithBillTo."Bill-to Contact No.") and
           (ServiceObjectWithEndUser."End-User Contact" = ServiceObjectWithBillTo."Bill-to Contact")
        then
            exit(true);
    end;

    local procedure InsertServiceCommitmentsFromStandardServCommPackages()
    begin
        if SkipInsertServiceCommitments then
            exit;
        Rec.Modify(false);
        InsertServiceCommitmentsFromStandardServCommPackages(0D)
    end;

    internal procedure InsertServiceCommitmentsFromStandardServCommPackages(ServiceAndCalculationStartDate: Date)
    var
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        PackageFilter: Text;
    begin
        PackageFilter := ItemServCommitmentPackage.GetPackageFilterForItem(Rec."Item No.", Rec."No.");
        if PackageFilter = '' then
            ItemServCommitmentPackage.SetRange(Code, '')
        else
            ItemServCommitmentPackage.SetFilter(Code, PackageFilter);
        ItemServCommitmentPackage.FilterAllStandardPackageFilterForItem(Rec."Item No.", Rec."Customer Price Group");

        if ItemServCommitmentPackage.FindSet() then begin
            repeat
                ServiceCommitmentPackage.Get(ItemServCommitmentPackage.Code);
                ServiceCommitmentPackage.Mark(true);
            until ItemServCommitmentPackage.Next() = 0;
            ServiceCommitmentPackage.MarkedOnly(true);
            InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);
        end;
    end;

    internal procedure InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate: Date; var ServiceCommitmentPackage: Record "Service Commitment Package")
    begin
        InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, 0D, ServiceCommitmentPackage, false);
    end;

    internal procedure InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate: Date; ServiceEndDate: Date; var ServiceCommitmentPackage: Record "Service Commitment Package"; UsageBasedBillingPackageLinesOnly: Boolean)
    var
        ServiceCommitment: Record "Service Commitment";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        Item: Record Item;
    begin
        Item.Get("Item No.");
        if ServiceCommitmentPackage.FindSet() then
            repeat
                ServiceCommPackageLine.SetRange("Package Code", ServiceCommitmentPackage.Code);
                if UsageBasedBillingPackageLinesOnly then
                    ServiceCommPackageLine.SetRange("Usage Based Billing", true);
                if ServiceCommPackageLine.FindSet() then
                    repeat
                        ServiceCommitment.Init();
                        ServiceCommitment."Service Object No." := "No.";
                        ServiceCommitment."Entry No." := 0;
                        ServiceCommitment."Package Code" := ServiceCommitmentPackage.Code;
                        ServiceCommitment.Template := ServiceCommPackageLine.Template;
                        ServiceCommitment.Description := ServiceCommPackageLine.Description;
                        ServiceCommitment."Invoicing via" := ServiceCommPackageLine."Invoicing via";
                        if Item.IsServiceCommitmentItem() then
                            ServiceCommitment."Invoicing Item No." := Item."No."
                        else
                            ServiceCommitment."Invoicing Item No." := ServiceCommPackageLine."Invoicing Item No.";
                        ServiceCommitment."Customer Price Group" := ServiceCommitmentPackage."Price Group";

                        if ServiceAndCalculationStartDate <> 0D then
                            ServiceCommitment.Validate("Service Start Date", ServiceAndCalculationStartDate)
                        else
                            if Format(ServiceCommPackageLine."Service Comm. Start Formula") <> '' then
                                ServiceCommitment.Validate("Service Start Date", CalcDate(ServiceCommPackageLine."Service Comm. Start Formula", WorkDate()))
                            else
                                ServiceCommitment.Validate("Service Start Date", WorkDate());

                        ServiceCommitment.Validate("Extension Term", ServiceCommPackageLine."Extension Term");
                        ServiceCommitment.Validate("Notice Period", ServiceCommPackageLine."Notice Period");
                        ServiceCommitment.Validate("Initial Term", ServiceCommPackageLine."Initial Term");

                        if ServiceEndDate <> 0D then
                            ServiceCommitment."Service End Date" := ServiceEndDate
                        else
                            ServiceCommitment.CalculateInitialServiceEndDate();
                        ServiceCommitment.CalculateInitialCancellationPossibleUntilDate();
                        ServiceCommitment.CalculateInitialTermUntilDate();
                        ServiceCommitment.ClearTerminationPeriodsWhenServiceEnded();
                        ServiceCommitment.UpdateNextBillingDate(ServiceCommitment."Service Start Date" - 1);

                        ServiceCommitment.Partner := ServiceCommPackageLine.Partner;
                        case ServiceCommitment.Partner of
                            Enum::"Service Partner"::Customer:
                                if CalledFromExtendContract then
                                    ServiceCommitment."Calculation Base Amount" := UnitPrice
                                else
                                    if Rec."End-User Customer No." = '' then
                                        ServiceCommitment."Calculation Base Amount" := Item."Unit Price"
                                    else
                                        ServiceCommitment.CalculateCalculationBaseAmount();
                            Enum::"Service Partner"::Vendor:
                                if CalledFromExtendContract then
                                    ServiceCommitment."Calculation Base Amount" := UnitCost
                                else
                                    ServiceCommitment."Calculation Base Amount" := Item."Unit Cost";
                        end;
                        ServiceCommitment."Billing Base Period" := ServiceCommPackageLine."Billing Base Period";
                        ServiceCommitment.Validate("Price Binding Period", ServiceCommPackageLine."Price Binding Period");
                        ServiceCommitment.SetLCYFields(ServiceCommitment.Price, ServiceCommitment."Service Amount", ServiceCommitment."Discount Amount", ServiceCommitment."Calculation Base Amount");
                        ServiceCommitment.Validate("Calculation Base %", ServiceCommPackageLine."Calculation Base %");
                        ServiceCommitment.Validate("Billing Rhythm", ServiceCommPackageLine."Billing Rhythm");
                        ServiceCommitment.Validate(Discount, ServiceCommPackageLine.Discount);
                        ServiceCommitment."Period Calculation" := ServiceCommPackageLine."Period Calculation";
                        ServiceCommitment.SetDefaultDimensionFromItem(Rec."Item No.");
                        ServiceCommitment."Usage Based Billing" := ServiceCommPackageLine."Usage Based Billing";
                        ServiceCommitment."Usage Based Pricing" := ServiceCommPackageLine."Usage Based Pricing";
                        ServiceCommitment."Pricing Unit Cost Surcharge %" := ServiceCommPackageLine."Pricing Unit Cost Surcharge %";
                        OnBeforeInsertServiceCommitmentFromServiceCommitmentPackageLine(ServiceCommitment, ServiceCommPackageLine);
                        ServiceCommitment.Insert(false);
                        OnAfterInsertServiceCommitmentFromServCommPackage(ServiceCommitment, ServiceCommitmentPackage, ServiceCommPackageLine);
                    until ServiceCommPackageLine.Next() = 0;
            until ServiceCommitmentPackage.Next() = 0;
    end;

    internal procedure OpenServiceObjectCard(ServiceObjectNo: Code[20])
    var
        ServiceObject: Record "Service Object";
    begin
        if ServiceObjectNo = '' then
            exit;

        ServiceObject.Get(ServiceObjectNo);
        Page.RunModal(Page::"Service Object", ServiceObject);
    end;

    local procedure ServiceCommitmentsExist(): Boolean
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", "No.");
        exit(not ServiceCommitment.IsEmpty);
    end;

    local procedure RecalculateServiceCommitments(ChangedFieldName: Text; SkipArchiving: Boolean)
    var
        ServiceCommitment: Record "Service Commitment";
        IsHandled: Boolean;
    begin
        if not ServiceCommitmentsExist() then
            exit;

        IsHandled := false;
        OnBeforeRecalculateLines(Rec, xRec, ChangedFieldName, IsHandled);
        if IsHandled then
            exit;

        IsHandled := false;
        OnRecalculateLinesOnBeforeConfirm(Rec, xRec, ChangedFieldName, HideValidationDialog, Confirmed, IsHandled);
        if not IsHandled then
            if HideValidationDialog or not GuiAllowed() then
                Confirmed := true
            else
                Confirmed := ConfirmManagement.GetResponse(GetRecalculateLinesDialog(ChangedFieldName), false);

        if Confirmed then begin
            Modify();
            ServiceCommitment.SetRange("Service Object No.", "No.");
            if ServiceCommitment.FindSet() then
                repeat
                    if FieldCaption("Quantity Decimal") <> ChangedFieldName then
                        ServiceCommitment.CalculateCalculationBaseAmount();
                    ServiceCommitment.Validate("Calculation Base Amount");
                    if SkipArchiving then
                        ServiceCommitment.SetSkipArchiving(true);
                    ServiceCommitment.Modify(true);
                until ServiceCommitment.Next() = 0;
        end else
            if (not Confirmed) and (FieldCaption("Variant Code") = ChangedFieldName) then
                Modify()
            else
                Error('');
    end;

    internal procedure UpdateServicesDates()
    var
        ServiceCommitment: Record "Service Commitment";
        ReferenceDateForComparison: Date;
        LastServiceEndDate: Date;
        ServiceCommitmentUpdated: Boolean;
        SkipProvisionEndDateUpdate: Boolean;
    begin
        LastServiceEndDate := 0D;
        ServiceCommitment.SetRange("Service Object No.", "No.");
        if ServiceCommitment.FindSet() then
            repeat
                if (ServiceCommitment."Service End Date" <> 0D) and (Today() > ServiceCommitment."Service End Date") and ServiceCommitment.IsFullyInvoiced() then begin
                    ServiceCommitment."Cancellation Possible Until" := 0D;
                    ServiceCommitment."Term Until" := 0D;
                    ServiceCommitment.Closed := true;
                    ServiceCommitment.Modify(false);
                    case ServiceCommitment.Partner of
                        ServiceCommitment.Partner::Customer:
                            CloseOpenCustomerContractLines(ServiceCommitment);
                        ServiceCommitment.Partner::Vendor:
                            CloseOpenVendorContractLines(ServiceCommitment);
                    end;
                    if ServiceCommitment."Service End Date" > LastServiceEndDate then
                        LastServiceEndDate := ServiceCommitment."Service End Date";
                end else begin
                    SkipProvisionEndDateUpdate := true;
                    ReferenceDateForComparison := ServiceCommitment.GetReferenceDate();
                    if (Today() > ReferenceDateForComparison) and (ReferenceDateForComparison <> 0D) then
                        repeat
                            if ServiceCommitment.UpdateTermUntilUsingExtensionTerm() or ServiceCommitment.UpdateCancellationPossibleUntil() then begin
                                ServiceCommitment.Modify(false);
                                ServiceCommitmentUpdated := true;
                                ReferenceDateForComparison := ServiceCommitment.GetReferenceDate();
                            end else
                                ServiceCommitmentUpdated := false;
                        until (Today() <= ReferenceDateForComparison) or not ServiceCommitmentUpdated;
                end;
            until ServiceCommitment.Next() = 0;
        if not SkipProvisionEndDateUpdate then
            "Provision End Date" := LastServiceEndDate;
    end;

    local procedure CloseOpenCustomerContractLines(ServiceCommitment: Record "Service Commitment")
    var
        CustomerContractLine: Record "Customer Contract Line";
    begin
        CustomerContractLine.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
        CustomerContractLine.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
        CustomerContractLine.SetRange("Closed", false);
        CustomerContractLine.ModifyAll("Closed", true, true);
    end;

    local procedure CloseOpenVendorContractLines(ServiceCommitment: Record "Service Commitment")
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        VendorContractLine.SetRange("Contract Line Type", VendorContractLine."Contract Line Type"::"Service Commitment");
        VendorContractLine.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
        VendorContractLine.SetRange("Closed", false);
        VendorContractLine.ModifyAll("Closed", true, false);
    end;

    local procedure UpdateCustomerContractLineServiceObjectDescription()
    var
        CustomerContractLine: Record "Customer Contract Line";
    begin
        if not xRec.Get("No.") then
            exit;
        if Description = xRec.Description then
            exit;
        CustomerContractLine.SetRange("Service Object No.", Rec."No.");
        CustomerContractLine.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
        CustomerContractLine.ModifyAll("Service Object Description", Rec.Description, false);
    end;

    local procedure UpdateVendorContractLineServiceObjectDescription()
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        if not xRec.Get("No.") then
            exit;
        if Description = xRec.Description then
            exit;
        VendorContractLine.SetRange("Service Object No.", Rec."No.");
        VendorContractLine.SetRange("Contract Line Type", VendorContractLine."Contract Line Type"::"Service Commitment");
        VendorContractLine.ModifyAll("Service Object Description", Rec.Description, false);
    end;

    local procedure TestIfServiceCommitmentsAreLinkedToContracts()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        if Rec."No." = '' then
            exit;
        xRec.Get(Rec."No.");
        if Rec."Customer Price Group" = xRec."Customer Price Group" then
            exit;

        ServiceCommitment.SetRange("Service Object No.", Rec."No.");
        ServiceCommitment.SetFilter("Contract No.", '<>%1', '');
        if ((xRec."End-User Customer No." <> '') and (not ServiceCommitment.IsEmpty())) then
            Error(EndUserCustomerChangeNotAllowedErr);

        ServiceCommitment.SetRange("Contract No.");
        if ServiceCommitment.IsEmpty() then
            exit;

        Confirmed := true;
        if not HideValidationDialog and GuiAllowed then
            Confirmed := ConfirmManagement.GetResponse(EndUserCustomerChangeQst, true);

        if Confirmed then
            RecreateServiceCommitments()
        else
            Error('');
    end;

    local procedure RecreateServiceCommitments()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommitment.SetRange("Service Object No.", Rec."No.");
        ServiceCommitment.DeleteAll(false);
        InsertServiceCommitmentsFromStandardServCommPackages();
    end;

    internal procedure UpdateAmountsOnServiceCommitmentsBasedOnExchangeRates()
    var
        ServiceCommitment: Record "Service Commitment";
        CurrencyFactor: Decimal;
        CurrencyFactorDate: Date;
    begin
        if not ServiceCommitment.OpenExchangeSelectionPage(CurrencyFactorDate, CurrencyFactor, Rec.GetCurrencyCodeFromCustomerServiceCommitment(), UpdateExchangeRatesInServiceMsg, true) then
            Error('');

        ServiceCommitment.SetRange("Service Object No.", Rec."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        ServiceCommitment.UpdateCurrencyDataOnServiceCommitments(ServiceCommitment, CurrencyFactor, CurrencyFactorDate, '', false);
    end;

    internal procedure GetCurrencyCodeFromCustomerServiceCommitment(): Code[10]
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommitment.SetRange("Service Object No.", Rec."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        ServiceCommitment.SetFilter("Currency Code", '<>%1', '');
        if ServiceCommitment.FindFirst() then
            exit(ServiceCommitment."Currency Code");
    end;

    internal procedure FilterServiceCommitmentsWithoutContract(var ServiceCommitment: Record "Service Commitment")
    begin
        ServiceCommitment.SetRange("Service Object No.", Rec."No.");
        ServiceCommitment.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitment.SetFilter("Contract No.", '%1', '');
    end;

    procedure InsertFromItemNoAndSelltoCustomerNo(var ServiceObject: Record "Service Object"; ItemNo: Code[20]; SourceQuantity: Decimal; SellToCustomerNo: Code[20]; ProvisionStartDate: Date)
    var
        Item: Record Item;
    begin
        if ItemNo = '' then
            exit;
        Item.Get(ItemNo);
        ServiceObject.Init();
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject."Item No." := ItemNo;
        ServiceObject.Description := Item.Description;
        ServiceObject."Unit of Measure" := Item."Base Unit of Measure";
        ServiceObject."Quantity Decimal" := SourceQuantity;
        ServiceObject.Validate("End-User Customer No.", SellToCustomerNo);
        ServiceObject.Validate("Provision Start Date", ProvisionStartDate);
        ServiceObject.Insert(true);
    end;

    internal procedure SetUnitPriceAndUnitCostFromExtendContract(NewUnitPrice: Decimal; NewUnitCost: Decimal)
    begin
        CalledFromExtendContract := true;
        UnitPrice := NewUnitPrice;
        UnitCost := NewUnitCost;
    end;

    internal procedure ResetCalledFromExtendContract()
    begin
        CalledFromExtendContract := false;
        UnitPrice := 0;
        UnitCost := 0;
    end;

    internal procedure ArchiveServiceCommitments()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommitment.SetRange("Service Object No.", Rec."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment.ArchiveServiceCommitmentFromServiceObject(xRec, Rec);
            until ServiceCommitment.Next() = 0;
    end;

    local procedure CheckIfUpdateRequiredOnBillingLinesNeeded()
    begin
        if xRec.Get(Rec."No.") then
            if xRec.Description <> Rec.Description then
                TestUpdateRequiredOnBillingLines();
    end;

    local procedure TestUpdateRequiredOnBillingLines()
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetRange("Service Object No.", Rec."No.");
        if BillingLine.FindSet() then
            repeat
                BillingLine.Validate("Update Required", true);
                BillingLine.Modify(false);
            until BillingLine.Next() = 0;
    end;

    internal procedure GetSerialNoDescription(): Text
    begin
        Rec.TestField("Serial No.");
        exit(StrSubstNo(SerialNoLbl, Rec."Serial No."));
    end;

    internal procedure SkipInsertServiceCommitmentsFromStandardServCommPackages(Skip: Boolean)
    begin
        SkipInsertServiceCommitments := Skip;
    end;

    local procedure GetRecalculateLinesDialog(ChangedFieldName: Text): Text
    var
        RecalculateLinesQst: Label 'If you change %1, the existing service commitments prices will be recalculated.\\Do you want to continue?', Comment = '%1: FieldCaption';
        RecalculateLinesFromVariantCodeQst: Label 'The %1 has been changed.\\Do you want to update the price and description?';
    begin
        case ChangedFieldName of
            Rec.FieldName(Rec."Variant Code"):
                exit(StrSubstNo(RecalculateLinesFromVariantCodeQst, ChangedFieldName));
            else
                exit(StrSubstNo(RecalculateLinesQst, ChangedFieldName));
        end;

    end;

    [InternalEvent(false, false)]
    local procedure OnAfterIsShipToAddressEqualToEndUserAddress(EndUserServiceObject: Record "Service Object"; ShipToServiceObject: Record "Service Object"; var Result: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterGetCustomerServiceContractSetup(ServiceObject: Record "Service Object"; var ServiceContractSetup: Record "Service Contract Setup"; CalledByFieldNo: Integer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterSetFieldsBilltoCustomer(var ServiceObject: Record "Service Object"; Customer: Record Customer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyEndUserAddressToBillToAddress(var ServiceObject: Record "Service Object")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyEndUserCustomerAddressFieldsFromCustomer(var ServiceObject: Record "Service Object"; EndUserCustomer: Record Customer; CurrentFieldNo: Integer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyShipToCustomerAddressFieldsFromCustomer(var ServiceObject: Record "Service Object"; EndUserCustomer: Record Customer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr(var ServiceObject: Record "Service Object"; ShipToAddress: Record "Ship-to Address")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyEndUserAddressToShipToAddress(var ServiceObject: Record "Service Object")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeAssistEdit(var ServiceObject: Record "Service Object"; OldServiceObject: Record "Service Object"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeConfirmBillToContactNoChange(var ServiceObject: Record "Service Object"; xServiceObject: Record "Service Object"; CurrentFieldNo: Integer; var Confirmed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeConfirmEndUserContactNoChange(var ServiceObject: Record "Service Object"; xServiceObject: Record "Service Object"; CurrentFieldNo: Integer; var Confirmed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCopyShipToCustomerAddressFieldsFromCustomer(var ServiceObject: Record "Service Object"; Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCopyShipToCustomerAddressFieldsFromShipToAddr(var ServiceObject: Record "Service Object"; ShipToAddress: Record "Ship-to Address"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInitInsert(var ServiceObject: Record "Service Object"; xServiceObject: Record "Service Object"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeLookupBillToPostCode(var ServiceObject: Record "Service Object"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeLookupEndUserPostCode(var ServiceObject: Record "Service Object"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeLookupShipToPostCode(var ServiceObject: Record "Service Object"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateBillToPostCode(var ServiceObject: Record "Service Object"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateEndUserPostCode(var ServiceObject: Record "Service Object"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateShipToPostCode(var ServiceObject: Record "Service Object"; var PostCodeRec: Record "Post Code")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeUpdateEndUserCust(var ServiceObject: Record "Service Object"; var Contact: Record Contact; var Customer: Record Customer; ContactNo: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnInitFromContactOnAfterInitNoSeries(var ServiceObject: Record "Service Object"; var xServiceObject: Record "Service Object")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnValidateEndUserCustomerNoAfterInit(var ServiceObject: Record "Service Object"; var xServiceObject: Record "Service Object")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateBillToCont(var ServiceObject: Record "Service Object"; Customer: Record Customer; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateBillToCust(var ServiceObject: Record "Service Object"; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateEndUserCont(var ServiceObject: Record "Service Object"; Customer: Record Customer; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateEndUserCust(var ServiceObject: Record "Service Object"; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateBillToCustomerName(var ServiceObject: Record "Service Object"; var Customer: Record Customer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateEndUserCustomerName(var ServiceObject: Record "Service Object"; var Customer: Record Customer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUpdateEndUserCustOnBeforeContactIsNotRelatedToAnyCustomerErr(var ServiceObject: Record "Service Object"; Contact: Record Contact; var ContactBusinessRelation: Record "Contact Business Relation"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUpdateBillToCustOnBeforeContactIsNotRelatedToAnyCustomerErr(var ServiceObject: Record "Service Object"; Contact: Record Contact; var ContactBusinessRelation: Record "Contact Business Relation"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUpdateBillToCustOnBeforeFindContactBusinessRelation(Contact: Record Contact; var ContBusinessRelation: Record "Contact Business Relation"; var ContactBusinessRelationFound: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnUpdateEndUserCustOnBeforeFindContactBusinessRelation(Cont: Record Contact; var ContBusinessRelation: Record "Contact Business Relation"; var ContactBusinessRelationFound: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnValidateBillToCustomerNoOnAfterConfirmed(var ServiceObject: Record "Service Object")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeUpdateBillToCust(var ServiceObject: Record "Service Object"; ContactNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCheckContactRelatedToCustomerCompany(ServiceObject: Record "Service Object"; CurrFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCalculateShipToBillToOptions(var ShipToOptions: Option "Default (End-User Address)","Alternate Shipping Address","Custom Address"; var BillToOptions: Option "Default (Customer)","Another Customer","Custom Address"; ServiceObject: Record "Service Object")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeRecalculateLines(var ServiceObject: Record "Service Object"; xServiceObject: Record "Service Object"; ChangedFieldName: Text; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnRecalculateLinesOnBeforeConfirm(var ServiceObject: Record "Service Object"; xServiceObject: Record "Service Object"; ChangedFieldName: Text; HideValidationDialog: Boolean; var Confirmed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInsertServiceCommitmentFromServiceCommitmentPackageLine(var ServiceCommitment: Record "Service Commitment"; ServiceCommPackageLine: Record "Service Comm. Package Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInsertServiceCommitmentFromServCommPackage(var ServiceCommitment: Record "Service Commitment"; ServiceCommitmentPackage: Record "Service Commitment Package"; ServiceCommPackageLine: Record "Service Comm. Package Line")
    begin
    end;

    internal procedure SetPrimaryAttributeValueAndCaption(var PrimaryAttributeValue: Text[250]; var PrimaryAttributeValueCaption: Text)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        TempItemAttributeValue: Record "Item Attribute Value" temporary;
        ItemAttributeValue: Record "Item Attribute Value";
    begin
        PrimaryAttributeValue := '';
        PrimaryAttributeValueCaption := PrimaryAttributeTxt;
        if Rec."No." = '' then
            exit;

        ItemAttributeValueMapping.SetRange("Table ID", Database::"Service Object");
        ItemAttributeValueMapping.SetRange("No.", Rec."No.");
        if ItemAttributeValueMapping.FindSet() then
            repeat
                ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
                TempItemAttributeValue.TransferFields(ItemAttributeValue);
                TempItemAttributeValue.Primary := ItemAttributeValueMapping.Primary;
                TempItemAttributeValue.Insert(false);
            until ItemAttributeValueMapping.Next() = 0;
        TempItemAttributeValue.SetRange(Primary, true);
        if not TempItemAttributeValue.IsEmpty() then begin
            TempItemAttributeValue.FindFirst();
            PrimaryAttributeValue := TempItemAttributeValue.GetValueInCurrentLanguage();
            PrimaryAttributeValueCaption := TempItemAttributeValue.GetAttributeNameInCurrentLanguage();
        end;
    end;

    internal procedure GetPrimaryAttributeValue() PrimaryAttributeValue: Text[250]
    var
        PrimaryAttributeValueCaption: Text;
    begin
        Rec.SetPrimaryAttributeValueAndCaption(PrimaryAttributeValue, PrimaryAttributeValueCaption);
    end;

}
