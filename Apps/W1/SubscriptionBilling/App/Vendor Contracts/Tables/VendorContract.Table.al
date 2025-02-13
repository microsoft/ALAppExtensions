namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using System.Security.User;
using System.Reflection;
using System.Environment.Configuration;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.Vendor;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Team;
using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Outlook;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Currency;
using Microsoft.Bank.BankAccount;

table 8063 "Vendor Contract"
{
    Caption = 'Vendor Contract';
    DataClassification = CustomerContent;
    DataCaptionFields = "No.", "Buy-from Vendor Name";
    LookupPageId = "Vendor Contracts";
    DrillDownPageId = "Vendor Contracts";
    Access = Internal;

    fields
    {
        field(2; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            begin
                if ("Buy-from Vendor No." <> xRec."Buy-from Vendor No.") and
                   (xRec."Buy-from Vendor No." <> '')
                then begin
                    if GetHideValidationDialog() or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := ConfirmManagement.GetResponse(StrSubstNo(ConfirmChangeQst, BuyFromVendorTxt), false);
                    if Confirmed then begin
                        if "Buy-from Vendor No." = '' then begin
                            Init();
                            GetServiceContractSetup();
                            "No. Series" := xRec."No. Series";
                            OnValidateBuyFromVendorNoAfterInit(Rec, xRec);
                        end;
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                GetVend("Buy-from Vendor No.");

                "Buy-from Vendor Name" := Vend.Name;
                "Buy-from Vendor Name 2" := Vend."Name 2";
                CopyBuyFromVendorAddressFieldsFromVendor(Vend, false);
                if not SkipBuyFromContact then
                    "Buy-from Contact" := Vend.Contact;
                OnAfterCopyBuyFromVendorFieldsFromVendor(Rec, Vend, xRec);

                if Vend."Pay-to Vendor No." <> '' then
                    Validate("Pay-to Vendor No.", Vend."Pay-to Vendor No.")
                else begin
                    if "Buy-from Vendor No." = "Pay-to Vendor No." then
                        SkipPayToContact := true;
                    Validate("Pay-to Vendor No.", "Buy-from Vendor No.");
                    SkipPayToContact := false;
                end;

                CopyPayToVendorAddressFieldsFromVendor(Vend, false);

                if not SkipBuyFromContact then
                    UpdateBuyFromCont("Buy-from Vendor No.");

                if (xRec."Buy-from Vendor No." <> '') and (xRec."Buy-from Vendor No." <> "Buy-from Vendor No.") then
                    RecallModifyAddressNotification(GetModifyVendorAddressNotificationId());
            end;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GetServiceContractSetup();
                    NoSeries.TestManual(ServiceContractSetup."Vendor Contract Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(4; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;

            trigger OnValidate()
            begin
                if (xRec."Pay-to Vendor No." <> "Pay-to Vendor No.") and
                   (xRec."Pay-to Vendor No." <> '')
                then begin
                    if GetHideValidationDialog() or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := ConfirmManagement.GetResponse(StrSubstNo(ConfirmChangeQst, PayToVendorTxt), false);
                    if not Confirmed then
                        "Pay-to Vendor No." := xRec."Pay-to Vendor No.";
                end;

                GetVend("Pay-to Vendor No.");

                "Pay-to Name" := Vend.Name;
                "Pay-to Name 2" := Vend."Name 2";
                CopyPayToVendorAddressFieldsFromVendor(Vend, false);
                if not SkipPayToContact then
                    "Pay-to Contact" := Vend.Contact;
                "Payment Terms Code" := Vend."Payment Terms Code";
                "Payment Method Code" := Vend."Payment Method Code";
                "Currency Code" := Vend."Currency Code";
                SetPurchaserCode(Vend."Purchaser Code", "Purchaser Code");
                Validate("Payment Terms Code");
                Validate("Payment Method Code");
                Validate("Currency Code");

                CreateDim(Database::Vendor, "Pay-to Vendor No.",
                          Database::"Salesperson/Purchaser", "Purchaser Code");

                if not SkipPayToContact then
                    UpdatePayToCont("Pay-to Vendor No.");

                if (xRec."Pay-to Vendor No." <> '') and (xRec."Pay-to Vendor No." <> "Pay-to Vendor No.") then
                    RecallModifyAddressNotification(GetModifyPayToVendorAddressNotificationId());
            end;
        }
        field(5; "Pay-to Name"; Text[100])
        {
            Caption = 'Pay-to Name';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Vendor.Name;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                Vendor: Record Vendor;
            begin
                if "Pay-to Vendor No." <> '' then
                    Vendor.Get("Pay-to Vendor No.");

                if Vendor.SelectVendor(Vendor) then begin
                    xRec := Rec;
                    "Pay-to Name" := Vendor.Name;
                    Validate("Pay-to Vendor No.", Vendor."No.");
                end;
            end;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if ShouldSearchForVendorByName("Pay-to Vendor No.") then
                    Validate("Pay-to Vendor No.", Vendor.GetVendorNo("Pay-to Name"));
            end;
        }
        field(6; "Pay-to Name 2"; Text[50])
        {
            Caption = 'Pay-to Name 2';
            DataClassification = EndUserIdentifiableInformation;

        }
        field(7; "Pay-to Address"; Text[100])
        {
            Caption = 'Pay-to Address';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ModifyPayToVendorAddress();
            end;
        }
        field(8; "Pay-to Address 2"; Text[50])
        {
            Caption = 'Pay-to Address 2';
            DataClassification = EndUserIdentifiableInformation;


            trigger OnValidate()
            begin
                ModifyPayToVendorAddress();
            end;
        }
        field(9; "Pay-to City"; Text[30])
        {
            Caption = 'Pay-to City';
            DataClassification = EndUserIdentifiableInformation;

            TableRelation = if ("Pay-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Pay-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Pay-to Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
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
                ModifyPayToVendorAddress();
            end;
        }
        field(10; "Pay-to Contact"; Text[100])
        {
            Caption = 'Pay-to Contact';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin
                Contact.FilterGroup(2);
                LookupContact("Pay-to Vendor No.", "Pay-to Contact No.", Contact);
                if Page.RunModal(0, Contact) = Action::LookupOK then
                    Validate("Pay-to Contact No.", Contact."No.");
                Contact.FilterGroup(0);
            end;

            trigger OnValidate()
            begin
                ModifyPayToVendorAddress();
            end;
        }
        field(11; "Your Reference"; Text[35])
        {
            Caption = 'Your Reference';
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
                if ("Currency Code" <> '') and (xRec."Currency Code" <> Rec."Currency Code") then
                    Rec.UpdateAndRecalculateServiceCommitmentCurrencyData()
                else
                    Rec.ResetVendorServiceCommitmentCurrencyFromLCY();
            end;
        }
        field(33; DefaultExcludeFromPriceUpdate; Boolean)
        {
            Caption = 'Default for Exclude from Price Update';
            trigger OnValidate()
            var
                ServiceCommitment: Record "Service Commitment";
            begin
                ServiceCommitment.ModifyExcludeFromPriceUpdateInAllRelatedServiceCommitments("Service Partner"::Vendor, Rec."No.", Rec.DefaultExcludeFromPriceUpdate);
            end;
        }
        field(43; "Purchaser Code"; Code[20])
        {
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            begin
                ValidatePurchaserOnVendorContract(Rec);
                CreateDim(Database::"Salesperson/Purchaser", "Purchaser Code",
                          Database::Vendor, "Pay-to Vendor No.");
            end;
        }
        field(79; "Buy-from Vendor Name"; Text[100])
        {
            Caption = 'Buy-from Vendor Name';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Vendor.Name;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                LookupBuyfromVendorName();
            end;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if ShouldSearchForVendorByName("Buy-from Vendor No.") then
                    Validate("Buy-from Vendor No.", Vendor.GetVendorNo("Buy-from Vendor Name"));
            end;
        }
        field(80; "Buy-from Vendor Name 2"; Text[50])
        {
            Caption = 'Buy-from Vendor Name 2';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(81; "Buy-from Address"; Text[100])
        {
            Caption = 'Buy-from Address';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                UpdatePayToAddressFromBuyFromAddress(FieldNo("Pay-to Address"));
                ModifyVendorAddress();
            end;
        }
        field(82; "Buy-from Address 2"; Text[50])
        {
            Caption = 'Buy-from Address 2';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                UpdatePayToAddressFromBuyFromAddress(FieldNo("Pay-to Address 2"));
                ModifyVendorAddress();
            end;
        }
        field(83; "Buy-from City"; Text[30])
        {
            Caption = 'Buy-from City';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Buy-from Country/Region Code" = const('')) "Post Code".City
            else
            if ("Buy-from Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Buy-from Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                BuyFromCity: Text;
                BuyFromCounty: Text;
            begin
                BuyFromCity := "Buy-from City";
                BuyFromCounty := "Buy-from County";
                PostCode.LookupPostCode(BuyFromCity, "Buy-from Post Code", BuyFromCounty, "Buy-from Country/Region Code");
                "Pay-to City" := CopyStr(BuyFromCity, 1, MaxStrLen("Buy-from City"));
                "Pay-to County" := CopyStr(BuyFromCounty, 1, MaxStrLen("Buy-from County"));
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(
                  "Buy-from City", "Buy-from Post Code", "Buy-from County", "Buy-from Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
                UpdatePayToAddressFromBuyFromAddress(FieldNo("Pay-to City"));
                ModifyVendorAddress();
            end;
        }
        field(84; "Buy-from Contact"; Text[100])
        {
            Caption = 'Buy-from Contact';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin
                if "Buy-from Vendor No." = '' then
                    exit;

                Contact.FilterGroup(2);
                LookupContact("Buy-from Vendor No.", "Buy-from Contact No.", Contact);
                if Page.RunModal(0, Contact) = Action::LookupOK then
                    Validate("Buy-from Contact No.", Contact."No.");
                Contact.FilterGroup(0);
            end;

            trigger OnValidate()
            begin
                ModifyVendorAddress();
            end;
        }
        field(85; "Pay-to Post Code"; Code[20])
        {
            Caption = 'Pay-to Post Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Pay-to Country/Region Code" = const('')) "Post Code"
            else
            if ("Pay-to Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Pay-to Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
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
                ModifyPayToVendorAddress();
            end;
        }
        field(86; "Pay-to County"; Text[30])
        {
            CaptionClass = '5,1,' + "Pay-to Country/Region Code";
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Pay-to County';

            trigger OnValidate()
            begin
                ModifyPayToVendorAddress();
            end;
        }
        field(87; "Pay-to Country/Region Code"; Code[10])
        {
            Caption = 'Pay-to Country/Region Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                ModifyPayToVendorAddress();
            end;
        }
        field(88; "Buy-from Post Code"; Code[20])
        {
            Caption = 'Buy-from Post Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Buy-from Country/Region Code" = const('')) "Post Code"
            else
            if ("Buy-from Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Buy-from Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                BuyFromCity: Text;
                BuyFromCounty: Text;
            begin
                BuyFromCity := "Buy-from City";
                BuyFromCounty := "Buy-from County";
                PostCode.LookupPostCode(BuyFromCity, "Buy-from Post Code", BuyFromCounty, "Buy-from Country/Region Code");
                "Pay-to City" := CopyStr(BuyFromCity, 1, MaxStrLen("Buy-from City"));
                "Pay-to County" := CopyStr(BuyFromCounty, 1, MaxStrLen("Buy-from County"));
            end;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(
                  "Buy-from City", "Buy-from Post Code", "Buy-from County", "Buy-from Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
                UpdatePayToAddressFromBuyFromAddress(FieldNo("Pay-to Post Code"));
                ModifyVendorAddress();
            end;
        }
        field(89; "Buy-from County"; Text[30])
        {
            CaptionClass = '5,1,' + "Buy-from Country/Region Code";
            Caption = 'Buy-from County';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                UpdatePayToAddressFromBuyFromAddress(FieldNo("Pay-to County"));
                ModifyVendorAddress();
            end;
        }
        field(90; "Buy-from Country/Region Code"; Code[10])
        {
            Caption = 'Buy-from Country/Region Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                UpdatePayToAddressFromBuyFromAddress(FieldNo("Pay-to Country/Region Code"));
                ModifyVendorAddress();
            end;
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
        field(201; "Description Preview"; Text[100])
        {
            Caption = 'Description Preview';
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
        field(5052; "Buy-from Contact No."; Code[20])
        {
            Caption = 'Buy-from Contact No.';
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
            begin
                if "Buy-from Vendor No." <> '' then
                    if Cont.Get("Buy-from Contact No.") then
                        Cont.SetRange("Company No.", Cont."Company No.")
                    else
                        if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Vendor, "Buy-from Vendor No.") then
                            Cont.SetRange("Company No.", ContBusinessRelation."Contact No.")
                        else
                            Cont.SetRange("No.", '');

                if "Buy-from Contact No." <> '' then
                    if Cont.Get("Buy-from Contact No.") then;
                if Page.RunModal(0, Cont) = Action::LookupOK then begin
                    xRec := Rec;
                    Validate("Buy-from Contact No.", Cont."No.");
                end;
            end;

            trigger OnValidate()
            var
                ContBusinessRelation: Record "Contact Business Relation";
                Cont: Record Contact;
            begin
                if "Buy-from Contact No." <> '' then
                    if Cont.Get("Buy-from Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric();

                if ("Buy-from Contact No." <> xRec."Buy-from Contact No.") and
                   (xRec."Buy-from Contact No." <> '')
                then begin
                    if GetHideValidationDialog() or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := ConfirmManagement.GetResponse(StrSubstNo(ConfirmChangeQst, FieldCaption("Buy-from Contact No.")), false);
                    if Confirmed then begin
                        if InitFromContact("Buy-from Contact No.", "Buy-from Vendor No.") then
                            exit
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                if ("Buy-from Vendor No." <> '') and ("Buy-from Contact No." <> '') then begin
                    Cont.Get("Buy-from Contact No.");
                    if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Vendor, "Buy-from Vendor No.") then
                        if ContBusinessRelation."Contact No." <> Cont."Company No." then
                            Error(ContactRelatedToDifferentCompanyErr, Cont."No.", Cont.Name, "Buy-from Vendor No.");
                end;

                UpdateBuyFromVend("Buy-from Contact No.");
            end;
        }
        field(5053; "Pay-to Contact No."; Code[20])
        {
            Caption = 'Pay-to Contact No.';
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
                ContBusinessRelation: Record "Contact Business Relation";
                Cont: Record Contact;
            begin
                if "Pay-to Contact No." <> '' then
                    if Cont.Get("Pay-to Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric();

                if ("Pay-to Contact No." <> xRec."Pay-to Contact No.") and
                   (xRec."Pay-to Contact No." <> '')
                then begin
                    if GetHideValidationDialog() or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := ConfirmManagement.GetResponse(StrSubstNo(ConfirmChangeQst, FieldCaption("Pay-to Contact No.")), false);
                    if Confirmed then begin
                        if InitFromContact("Pay-to Contact No.", "Pay-to Vendor No.") then
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
                            Error(ContactRelatedToDifferentCompanyErr, Cont."No.", Cont.Name, "Pay-to Vendor No.");
                end;

                UpdatePayToVend("Pay-to Contact No.");
            end;
        }
        field(9000; "Assigned User ID"; Code[50])
        {
            Caption = 'Assigned User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "User Setup";
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

            trigger OnValidate()
            begin
                SetDefaultWithoutContractDeferralsFromContractType();
            end;
        }
        field(8051; "Without Contract Deferrals"; Boolean)
        {
            Caption = 'Without Contract Deferrals';
        }
        field(8053; "Billing Rhythm Filter"; DateFormula)
        {
            Caption = 'Billing Rhythm Filter';
            FieldClass = FlowFilter;
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

        if GetFilter("Buy-from Vendor No.") <> '' then
            if GetRangeMin("Buy-from Vendor No.") = GetRangeMax("Buy-from Vendor No.") then
                Validate("Buy-from Vendor No.", GetRangeMin("Buy-from Vendor No."));

        if "Purchaser Code" = '' then
            SetDefaultPurchaser();

    end;

    trigger OnRename()
    begin
        Error(RenameErr, TableCaption);
    end;

    trigger OnDelete()
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        VendorContractLine.Reset();
        VendorContractLine.SetRange("Contract No.", "No.");
        if VendorContractLine.FindSet() then
            repeat
                VendorContractLine.Delete(true);
            until VendorContractLine.Next() = 0;
    end;

    var
        ServiceContractSetup: Record "Service Contract Setup";
        Vend: Record Vendor;
        VendorContractDeferral: Record "Vendor Contract Deferral";
        PaymentMethod: Record "Payment Method";
        PostCode: Record "Post Code";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        NoSeries: Codeunit "No. Series";
        DimMgt: Codeunit DimensionManagement;
        ConfirmManagement: Codeunit "Confirm Management";
        CurrencyFactorDate: Date;
        CurrencyFactor: Decimal;
        Confirmed: Boolean;
        SkipPayToContact: Boolean;
        SkipBuyFromContact: Boolean;
        RenameErr: Label 'You cannot rename a %1.';
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        ContactNotRelatedToVendorErr: Label 'Contact %1 %2 is not related to vendor %3.';
        ContactIsNotRelatedToAnyVendorErr: Label 'Contact %1 %2 is not related to a vendor.';
        BuyFromVendorTxt: Label 'Buy-from Vendor';
        PayToVendorTxt: Label 'Pay-to Vendor';
        ContactRelatedToDifferentCompanyErr: Label 'Contact %1 %2 is related to a different company than vendor %3.';
        DontShowAgainActionLbl: Label 'Don''t show again';
        ModifyBuyFromVendorAddressNotificationNameTxt: Label 'Update Buy-from Vendor Address';
        ModifyBuyFromVendorAddressNotificationDescriptionTxt: Label 'Warn if the Buy-from address on vendor contract is different from the Vendor''s existing address.';
        ModifyPayToVendorAddressNotificationNameTxt: Label 'Update Pay-to Vendor Address';
        ModifyPayToVendorAddressNotificationDescriptionTxt: Label 'Warn if the Pay-to address on vendor contract is different from the Vendor''s existing address.';
        ModifyVendorAddressNotificationLbl: Label 'Update the address';
        ModifyVendorAddressNotificationMsg: Label 'The address you entered for %1 is different from the Vendor''s existing address.', Comment = '%1=Vendor name';
        UpdateDimensionsOnLinesQst: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        AssignServicePricesMustBeRecalculatedMsg: Label 'You add services to a contract in which a different currency is stored than in the services. The prices for the services must therefore be recalculated.';
        CurrCodeChangePricesMustBeRecalculatedMsg: Label 'If you change the currency code, the prices for existing services must be recalculated.';
        UpdatedDeferralsMsg: Label 'The dimensions in %1 deferrals have been updated.';

    protected var
        HideValidationDialog: Boolean;

    local procedure InitInsert()
    var
        VendorContract2: Record "Vendor Contract";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitInsert(Rec, xRec, IsHandled);
        if not IsHandled then
            if "No." = '' then begin
                TestNoSeries();
                "No. Series" := ServiceContractSetup."Vendor Contract Nos.";
                if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                    "No. Series" := xRec."No. Series";
                "No." := NoSeries.GetNextNo("No. Series");
                VendorContract2.ReadIsolation(IsolationLevel::ReadUncommitted);
                VendorContract2.SetLoadFields("No.");
                while VendorContract2.Get("No.") do
                    "No." := NoSeries.GetNextNo("No. Series");
            end;
        "Assigned User ID" := CopyStr(UserId(), 1, MaxStrLen("Assigned User ID"));
    end;

    internal procedure AssistEdit(OldVendContract: Record "Vendor Contract"): Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssistEdit(Rec, OldVendContract, IsHandled);
        if IsHandled then
            exit;

        TestNoSeries();

        if NoSeries.LookupRelatedNoSeries(ServiceContractSetup."Vendor Contract Nos.", OldVendContract."No. Series", "No. Series") then begin
            "No." := NoSeries.GetNextNo("No. Series");
            exit(true);
        end;
    end;

    local procedure TestNoSeries()
    begin
        GetServiceContractSetup();
        ServiceContractSetup.TestField("Vendor Contract Nos.");
    end;

    local procedure GetServiceContractSetup()
    begin
        ServiceContractSetup.Get();
        OnAfterGetServiceContractSetup(Rec, ServiceContractSetup, CurrFieldNo);
    end;

    local procedure GetVend(VendNo: Code[20])
    begin
        if VendNo <> Vend."No." then
            Vend.Get(VendNo);
    end;

    local procedure GetHideValidationDialog(): Boolean
    begin
        exit(HideValidationDialog);
    end;

    local procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        IsHandled: Boolean;
        OldDimSetID: Integer;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        IsHandled := false;
        OnBeforeCreateDim(Rec, IsHandled);
        if IsHandled then
            exit;

        SourceCodeSetup.Get();

        DimMgt.AddDimSource(DefaultDimSource, Type1, No1);
        DimMgt.AddDimSource(DefaultDimSource, Type2, No2);

        OnAfterCreateDimDimSource(Rec, CurrFieldNo, DefaultDimSource);

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(Rec, CurrFieldNo, DefaultDimSource, SourceCodeSetup.Sales, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);

        OnCreateDimOnBeforeModify(Rec, xRec, CurrFieldNo);
        if (OldDimSetID <> "Dimension Set ID") and VendorContractLinesExists() then begin
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
            if VendorContractLinesExists() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
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
            if VendorContractLinesExists() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
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
                    ServiceCommitment.Modify(true);
                end;
            until ServiceCommitment.Next() = 0;
    end;

    local procedure VendorContractLinesExists(): Boolean
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        exit(VendorContractLinesExists(VendorContractLine));

    end;

    local procedure VendorContractLinesExists(var VendorContractLine: Record "Vendor Contract Line"): Boolean
    begin
        VendorContractLine.Reset();
        VendorContractLine.SetRange("Contract No.", Rec."No.");
        exit(not VendorContractLine.IsEmpty());
    end;

    internal procedure NotReleasedVendorContractDeferralsExists(): Boolean
    begin
        VendorContractDeferral.Reset();
        VendorContractDeferral.SetRange("Contract No.", Rec."No.");
        VendorContractDeferral.SetRange(Released, false);
        exit(not VendorContractDeferral.IsEmpty());
    end;

    local procedure CopyBuyFromVendorAddressFieldsFromVendor(var BuyFromVendor: Record Vendor; ForceCopy: Boolean)
    begin
        if BuyFromVendorIsReplaced() or ShouldCopyAddressFromBuyFromVendor(BuyFromVendor) or ForceCopy then begin
            "Buy-from Address" := BuyFromVendor.Address;
            "Buy-from Address 2" := BuyFromVendor."Address 2";
            "Buy-from City" := BuyFromVendor.City;
            "Buy-from Post Code" := BuyFromVendor."Post Code";
            "Buy-from County" := BuyFromVendor.County;
            "Buy-from Country/Region Code" := BuyFromVendor."Country/Region Code";
            OnAfterCopyBuyFromVendorAddressFieldsFromVendor(Rec, BuyFromVendor);
        end;
    end;

    internal procedure LookupBuyfromVendorName(): Boolean
    var
        Vendor: Record Vendor;
    begin
        if "Buy-from Vendor No." <> '' then
            Vendor.Get("Buy-from Vendor No.");

        if Vendor.SelectVendor(Vendor) then begin
            "Buy-from Vendor Name" := Vendor.Name;
            Validate("Buy-from Vendor No.", Vendor."No.");
            exit(true);
        end;
    end;

    local procedure ShouldCopyAddressFromPayToVendor(PayToVendor: Record Vendor): Boolean
    begin
        exit((not HasPayToAddress()) and PayToVendor.HasAddress());
    end;

    local procedure ShouldCopyAddressFromBuyFromVendor(BuyFromVendor: Record Vendor): Boolean
    begin
        exit((not HasBuyFromAddress()) and BuyFromVendor.HasAddress());
    end;

    local procedure PayToVendorIsReplaced(): Boolean
    begin
        exit((xRec."Pay-to Vendor No." <> '') and (xRec."Pay-to Vendor No." <> "Pay-to Vendor No."));
    end;

    local procedure ShouldSearchForVendorByName(VendorNo: Code[20]): Boolean
    var
        Vendor: Record Vendor;
    begin
        if VendorNo = '' then
            exit(true);

        if not Vendor.Get(VendorNo) then
            exit(true);

        exit(not Vendor."Disable Search by Name");
    end;

    local procedure BuyFromVendorIsReplaced(): Boolean
    begin
        exit((xRec."Buy-from Vendor No." <> '') and (xRec."Buy-from Vendor No." <> "Buy-from Vendor No."));
    end;

    local procedure InitFromContact(ContactNo: Code[20]; VendorNo: Code[20]): Boolean
    begin
        if (ContactNo = '') and (VendorNo = '') then begin
            Init();
            GetServiceContractSetup();
            "No. Series" := xRec."No. Series";
            OnInitFromContactOnBeforeInitRecord(Rec, xRec);
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

    internal procedure OnAfterValidateBuyFromVendorNo(var VendorContract: Record "Vendor Contract"; var xVendorContract: Record "Vendor Contract")
    begin
        if VendorContract.GetFilter("Buy-from Vendor No.") = xVendorContract."Buy-from Vendor No." then
            if VendorContract."Buy-from Vendor No." <> xVendorContract."Buy-from Vendor No." then
                VendorContract.SetRange("Buy-from Vendor No.");
    end;

    local procedure ModifyPayToVendorAddress()
    var
        Vendor: Record Vendor;
    begin
        if ("Pay-to Vendor No." <> "Buy-from Vendor No.") and Vendor.Get("Pay-to Vendor No.") then
            if HasPayToAddress() and HasDifferentPayToAddress(Vendor) then
                ShowModifyAddressNotification(GetModifyPayToVendorAddressNotificationId(),
                  ModifyVendorAddressNotificationLbl, ModifyVendorAddressNotificationMsg,
                  'CopyPayToVendorAddressFieldsFromVendorContract', "Pay-to Vendor No.",
                  "Pay-to Name", FieldName("Pay-to Vendor No."));
    end;

    local procedure ModifyVendorAddress()
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get("Buy-from Vendor No.") and HasBuyFromAddress() and HasDifferentBuyFromAddress(Vendor) then
            ShowModifyAddressNotification(GetModifyVendorAddressNotificationId(),
              ModifyVendorAddressNotificationLbl, ModifyVendorAddressNotificationMsg,
              'CopyBuyFromVendorAddressFieldsFromVendorContract', "Buy-from Vendor No.",
              "Buy-from Vendor Name", FieldName("Buy-from Vendor No."));
    end;

    local procedure ShowModifyAddressNotification(NotificationID: Guid; NotificationLbl: Text; NotificationMsg: Text; NotificationFunctionTok: Text; VendorNumber: Code[20]; VendorName: Text[100]; VendorNumberFieldName: Text)
    var
        MyNotifications: Record "My Notifications";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        ModifyVendorAddressNotification: Notification;
    begin
        if not MyNotifications.IsEnabled(NotificationID) then
            exit;

        ModifyVendorAddressNotification.Id := NotificationID;
        ModifyVendorAddressNotification.Message := StrSubstNo(NotificationMsg, VendorName);
        ModifyVendorAddressNotification.AddAction(NotificationLbl, Codeunit::"Contract Notifications", NotificationFunctionTok);
        ModifyVendorAddressNotification.AddAction(
          DontShowAgainActionLbl, Codeunit::"Contract Notifications", 'VendorContractHideNotificationForCurrentUser');
        ModifyVendorAddressNotification.Scope := NotificationScope::LocalScope;
        ModifyVendorAddressNotification.SetData(FieldName("No."), "No.");
        ModifyVendorAddressNotification.SetData(VendorNumberFieldName, VendorNumber);
        NotificationLifecycleMgt.SendNotification(ModifyVendorAddressNotification, RecordId);
    end;

    internal procedure SetBuyFromVendorFromFilter()
    var
        BuyFromVendorNo: Code[20];
    begin
        BuyFromVendorNo := GetFilterVendNo();
        if BuyFromVendorNo = '' then begin
            FilterGroup(2);
            BuyFromVendorNo := GetFilterVendNo();
            FilterGroup(0);
        end;
        if BuyFromVendorNo <> '' then
            Validate("Buy-from Vendor No.", BuyFromVendorNo);
    end;

    internal procedure CopyBuyFromVendorFilter()
    var
        BuyFromVendorFilter: Text;
    begin
        BuyFromVendorFilter := GetFilter("Buy-from Vendor No.");
        if BuyFromVendorFilter <> '' then begin
            FilterGroup(2);
            SetFilter("Buy-from Vendor No.", BuyFromVendorFilter);
            FilterGroup(0)
        end;
    end;

    local procedure GetFilterVendNo(): Code[20]
    begin
        if GetFilter("Buy-from Vendor No.") <> '' then
            if GetRangeMin("Buy-from Vendor No.") = GetRangeMax("Buy-from Vendor No.") then
                exit(GetRangeMax("Buy-from Vendor No."));
    end;

    local procedure HasBuyFromAddress() Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeHasBuyFromAddress(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        case true of
            "Buy-from Address" <> '':
                exit(true);
            "Buy-from Address 2" <> '':
                exit(true);
            "Buy-from City" <> '':
                exit(true);
            "Buy-from Country/Region Code" <> '':
                exit(true);
            "Buy-from County" <> '':
                exit(true);
            "Buy-from Post Code" <> '':
                exit(true);
            "Buy-from Contact" <> '':
                exit(true);
        end;

        exit(false);
    end;

    local procedure HasPayToAddress() Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeHasPayToAddress(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

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

    local procedure HasDifferentBuyFromAddress(Vendor: Record Vendor): Boolean
    begin
        exit(("Buy-from Address" <> Vendor.Address) or
          ("Buy-from Address 2" <> Vendor."Address 2") or
          ("Buy-from City" <> Vendor.City) or
          ("Buy-from Country/Region Code" <> Vendor."Country/Region Code") or
          ("Buy-from County" <> Vendor.County) or
          ("Buy-from Post Code" <> Vendor."Post Code") or
          ("Buy-from Contact" <> Vendor.Contact));
    end;

    local procedure HasDifferentPayToAddress(Vendor: Record Vendor): Boolean
    begin
        exit(("Pay-to Address" <> Vendor.Address) or
          ("Pay-to Address 2" <> Vendor."Address 2") or
          ("Pay-to City" <> Vendor.City) or
          ("Pay-to Country/Region Code" <> Vendor."Country/Region Code") or
          ("Pay-to County" <> Vendor.County) or
          ("Pay-to Post Code" <> Vendor."Post Code") or
          ("Pay-to Contact" <> Vendor.Contact));
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

    local procedure UpdateBuyFromCont(VendorNo: Code[20])
    var
        ContBusRel: Record "Contact Business Relation";
        Vendor: Record "Vendor";
        OfficeContact: Record Contact;
        OfficeMgt: Codeunit "Office Management";
    begin
        if OfficeMgt.GetContact(OfficeContact, VendorNo) then begin
            SetHideValidationDialog(true);
            UpdateBuyFromVend(OfficeContact."No.");
            SetHideValidationDialog(false);
        end else
            if Vendor.Get(VendorNo) then begin
                if Vendor."Primary Contact No." <> '' then
                    "Buy-from Contact No." := Vendor."Primary Contact No."
                else
                    "Buy-from Contact No." := ContBusRel.GetContactNo(ContBusRel."Link to Table"::Vendor, "Buy-from Vendor No.");
                "Buy-from Contact" := Vendor.Contact;
            end;

        if "Buy-from Contact No." <> '' then
            if OfficeContact.Get("Buy-from Contact No.") then
                OfficeContact.CheckIfPrivacyBlockedGeneric();

        OnAfterUpdateBuyFromCont(Rec, Vendor, OfficeContact);
    end;

    local procedure UpdatePayToCont(VendorNo: Code[20])
    var
        ContBusRel: Record "Contact Business Relation";
        Vendor: Record Vendor;
        Contact: Record Contact;
    begin
        if Vendor.Get(VendorNo) then begin
            if Vendor."Primary Contact No." <> '' then
                "Pay-to Contact No." := Vendor."Primary Contact No."
            else
                "Pay-to Contact No." := ContBusRel.GetContactNo(ContBusRel."Link to Table"::Vendor, "Pay-to Vendor No.");
            "Pay-to Contact" := Vendor.Contact;
        end;

        if "Pay-to Contact No." <> '' then
            if Contact.Get("Pay-to Contact No.") then
                Contact.CheckIfPrivacyBlockedGeneric();

        OnAfterUpdatePayToCont(Rec, Vendor, Contact);
    end;

    local procedure UpdateBuyFromVend(ContactNo: Code[20])
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Vendor: Record Vendor;
        Cont: Record Contact;
    begin
        if Cont.Get(ContactNo) then begin
            "Buy-from Contact No." := Cont."No.";
            if Cont.Type = Cont.Type::Person then
                "Buy-from Contact" := Cont.Name
            else
                if Vendor.Get("Buy-from Vendor No.") then
                    "Buy-from Contact" := Vendor.Contact
                else
                    "Buy-from Contact" := ''
        end else begin
            "Buy-from Contact" := '';
            exit;
        end;

        if ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Vendor, Cont."Company No.") then begin
            if ("Buy-from Vendor No." <> '') and
               ("Buy-from Vendor No." <> ContBusinessRelation."No.")
            then
                Error(ContactNotRelatedToVendorErr, Cont."No.", Cont.Name, "Buy-from Vendor No.");
            if "Buy-from Vendor No." = '' then begin
                SkipBuyFromContact := true;
                Validate("Buy-from Vendor No.", ContBusinessRelation."No.");
                SkipBuyFromContact := false;
            end;
        end else
            ContactIsNotRelatedToVendorError(Cont, ContactNo);

        if ("Buy-from Vendor No." = "Pay-to Vendor No.") or
           ("Pay-to Vendor No." = '')
        then
            Validate("Pay-to Contact No.", "Buy-from Contact No.");

        OnAfterUpdateBuyFromVend(Rec, Cont);
    end;

    local procedure UpdatePayToVend(ContactNo: Code[20])
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Vendor: Record Vendor;
        Cont: Record Contact;
    begin
        if Cont.Get(ContactNo) then begin
            "Pay-to Contact No." := Cont."No.";
            if Cont.Type = Cont.Type::Person then
                "Pay-to Contact" := Cont.Name
            else
                if Vendor.Get("Pay-to Vendor No.") then
                    "Pay-to Contact" := Vendor.Contact
                else
                    "Pay-to Contact" := '';
        end else begin
            "Pay-to Contact" := '';
            exit;
        end;

        if ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Vendor, Cont."Company No.") then begin
            if "Pay-to Vendor No." = '' then begin
                SkipPayToContact := true;
                Validate("Pay-to Vendor No.", ContBusinessRelation."No.");
                SkipPayToContact := false;
            end else
                if "Pay-to Vendor No." <> ContBusinessRelation."No." then
                    Error(ContactNotRelatedToVendorErr, Cont."No.", Cont.Name, "Pay-to Vendor No.");
        end else
            ContactIsNotRelatedToVendorError(Cont, ContactNo);
        OnAfterUpdatePayToVend(Rec, Cont);
    end;

    local procedure ContactIsNotRelatedToVendorError(Cont: Record Contact; ContactNo: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeContactIsNotRelatedToVendorError(Cont, ContactNo, IsHandled);
        if IsHandled then
            exit;

        Error(ContactIsNotRelatedToAnyVendorErr, Cont."No.", Cont.Name);
    end;

    local procedure RecallModifyAddressNotification(NotificationID: Guid)
    var
        MyNotifications: Record "My Notifications";
        ModifyVendorAddressNotification: Notification;
    begin
        if (not MyNotifications.IsEnabled(NotificationID)) then
            exit;
        ModifyVendorAddressNotification.Id := NotificationID;
        ModifyVendorAddressNotification.Recall();
    end;

    local procedure GetModifyVendorAddressNotificationId(): Guid
    begin
        exit('70D33B2A-0A18-44FB-9D27-2429FC5167ED');
    end;

    local procedure GetModifyPayToVendorAddressNotificationId(): Guid
    begin
        exit('CCEDACB9-211A-4457-919B-5B841759EBB5');
    end;

    internal procedure DontNotifyCurrentUserAgain(NotificationID: Guid)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(NotificationID) then
            case NotificationID of
                GetModifyVendorAddressNotificationId():
                    MyNotifications.InsertDefault(NotificationID, ModifyBuyFromVendorAddressNotificationNameTxt,
                      ModifyBuyFromVendorAddressNotificationDescriptionTxt, false);
                GetModifyPayToVendorAddressNotificationId():
                    MyNotifications.InsertDefault(NotificationID, ModifyPayToVendorAddressNotificationNameTxt,
                      ModifyPayToVendorAddressNotificationDescriptionTxt, false);
            end;
    end;

    local procedure UpdatePayToAddressFromBuyFromAddress(FieldNumber: Integer)
    begin
        if PayToAddressEqualsOldBuyFromAddress() then
            case FieldNumber of
                FieldNo("Pay-to Address"):
                    if xRec."Buy-from Address" = "Pay-to Address" then
                        "Pay-to Address" := "Buy-from Address";
                FieldNo("Pay-to Address 2"):
                    if xRec."Buy-from Address 2" = "Pay-to Address 2" then
                        "Pay-to Address 2" := "Buy-from Address 2";
                FieldNo("Pay-to City"), FieldNo("Pay-to Post Code"):
                    begin
                        if xRec."Buy-from City" = "Pay-to City" then
                            "Pay-to City" := "Buy-from City";
                        if xRec."Buy-from Post Code" = "Pay-to Post Code" then
                            "Pay-to Post Code" := "Buy-from Post Code";
                        if xRec."Buy-from County" = "Pay-to County" then
                            "Pay-to County" := "Buy-from County";
                        if xRec."Buy-from Country/Region Code" = "Pay-to Country/Region Code" then
                            "Pay-to Country/Region Code" := "Buy-from Country/Region Code";
                    end;
                FieldNo("Pay-to County"):
                    if xRec."Buy-from County" = "Pay-to County" then
                        "Pay-to County" := "Buy-from County";
                FieldNo("Pay-to Country/Region Code"):
                    if xRec."Buy-from Country/Region Code" = "Pay-to Country/Region Code" then
                        "Pay-to Country/Region Code" := "Buy-from Country/Region Code";
            end;
    end;

    local procedure PayToAddressEqualsOldBuyFromAddress(): Boolean
    begin
        if (xRec."Buy-from Address" = "Pay-to Address") and
           (xRec."Buy-from Address 2" = "Pay-to Address 2") and
           (xRec."Buy-from City" = "Pay-to City") and
           (xRec."Buy-from County" = "Pay-to County") and
           (xRec."Buy-from Post Code" = "Pay-to Post Code") and
           (xRec."Buy-from Country/Region Code" = "Pay-to Country/Region Code")
        then
            exit(true);
    end;

    internal procedure BuyFromAddressEqualsPayToAddress(): Boolean
    begin
        exit(
          ("Pay-to Address" = "Buy-from Address") and
          ("Pay-to Address 2" = "Buy-from Address 2") and
          ("Pay-to City" = "Buy-from City") and
          ("Pay-to County" = "Buy-from County") and
          ("Pay-to Post Code" = "Buy-from Post Code") and
          ("Pay-to Country/Region Code" = "Buy-from Country/Region Code") and
          ("Pay-to Contact No." = "Buy-from Contact No.") and
          ("Pay-to Contact" = "Buy-from Contact"));
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

    local procedure ValidatePurchaserOnVendorContract(VendorContract2: Record "Vendor Contract")
    begin
        if VendorContract2."Purchaser Code" <> '' then
            if SalespersonPurchaser.Get(VendorContract2."Purchaser Code") then
                if SalespersonPurchaser.VerifySalesPersonPurchaserPrivacyBlocked(SalespersonPurchaser) then
                    Error(SalespersonPurchaser.GetPrivacyBlockedGenericText(SalespersonPurchaser, false));
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

    internal procedure CreateVendorContractLinesFromServiceCommitments(var ServiceCommitment: Record "Service Commitment" temporary)
    var
        ServiceObject: Record "Service Object";
    begin
        ServiceCommitment.TestServiceCommitmentsCurrencyCode(ServiceCommitment);
        if (("Currency Code" <> ServiceCommitment."Currency Code") and ("Currency Code" <> '')) then
            if not ServiceCommitment.OpenExchangeSelectionPage(CurrencyFactorDate, CurrencyFactor, Rec."Currency Code", AssignServicePricesMustBeRecalculatedMsg, false) then
                Error('');

        if ServiceCommitment.FindSet() then
            repeat
                ServiceObject.Get(ServiceCommitment."Service Object No.");
                ServiceCommitment.TestField("Contract No.");
                CreateVendorContractLineFromServiceCommitment(ServiceCommitment);
                ServiceCommitment.Delete(false);
            until ServiceCommitment.Next() = 0;
    end;

    internal procedure UpdateServicesDates()
    var
        VendorContractLines: Record "Vendor Contract Line";
        TempServiceObject: Record "Service Object" temporary;
        ServiceObject: Record "Service Object";
    begin
        VendorContractLines.SetRange("Contract No.", Rec."No.");
        VendorContractLines.SetRange("Contract Line Type", "Contract Line Type"::"Service Commitment");
        if VendorContractLines.FindSet() then
            repeat
                if not TempServiceObject.Get(VendorContractLines."Service Object No.") then begin
                    ServiceObject.Get(VendorContractLines."Service Object No.");
                    ServiceObject.UpdateServicesDates();
                    ServiceObject.Modify(false);
                    TempServiceObject := ServiceObject;
                    TempServiceObject.Insert(false);
                end;
            until VendorContractLines.Next() = 0;
    end;

    procedure CreateVendorContractLineFromServiceCommitment(ServiceCommitment: Record "Service Commitment")
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        CreateVendorContractLineFromServiceCommitment(ServiceCommitment, ServiceCommitment."Contract No.", VendorContractLine);
    end;

    internal procedure CreateVendorContractLineFromServiceCommitment(var ServiceCommitment: Record "Service Commitment"; ContractNo: Code[20]; var VendorContractLine: Record "Vendor Contract Line")
    var
        ServiceObject: Record "Service Object";
        VendorContract: Record "Vendor Contract";
    begin
        ServiceObject.Get(ServiceCommitment."Service Object No.");
        VendorContractLine.InitFromServiceCommitment(ServiceCommitment, ContractNo);
        VendorContractLine.Insert(false);

        ServiceCommitment."Contract No." := VendorContractLine."Contract No.";
        ServiceCommitment."Contract Line No." := VendorContractLine."Line No.";

        VendorContract.Get(ServiceCommitment."Contract No.");
        ServiceCommitment.GetCombinedDimensionSetID(ServiceCommitment."Dimension Set ID", VendorContract."Dimension Set ID");
        if "Currency Code" <> ServiceCommitment."Currency Code" then begin
            ServiceCommitment.SetCurrencyData(CurrencyFactor, CurrencyFactorDate, VendorContract."Currency Code");
            ServiceCommitment.RecalculateAmountsFromCurrencyData();
        end;
        ServiceCommitment."Exclude from Price Update" := VendorContract.DefaultExcludeFromPriceUpdate;
        ServiceCommitment.Modify(false);
    end;

    local procedure VendorContractLinesExist(): Boolean
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        VendorContractLine.Reset();
        VendorContractLine.SetRange("Contract No.", "No.");
        exit(not VendorContractLine.IsEmpty());
    end;

    internal procedure UpdateAndRecalculateServiceCommitmentCurrencyData()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        if not VendorContractLinesExist() then
            exit;
        if not ServiceCommitment.OpenExchangeSelectionPage(CurrencyFactorDate, CurrencyFactor, Rec."Currency Code", CurrCodeChangePricesMustBeRecalculatedMsg, false) then
            Error('');
        ServiceCommitment.UpdateAndRecalculateServCommCurrencyFromContract(Enum::"Service Partner"::Vendor, Rec."No.", CurrencyFactor, CurrencyFactorDate, Rec."Currency Code");
    end;

    internal procedure ResetVendorServiceCommitmentCurrencyFromLCY()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommitment.ResetServiceCommitmentCurrencyLCYFromContract(Enum::"Service Partner"::Vendor, Rec."No.");
    end;

    internal procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    internal procedure UpdateDimensionsInDeferrals()
    var
        ServiceCommitment: Record "Service Commitment";
        VendorContractLine: Record "Vendor Contract Line";
        DeferralCount: Integer;
    begin
        if NotReleasedVendorContractDeferralsExists() then
            if VendorContractLinesExists(VendorContractLine) then begin
                VendorContractLine.SetFilter("Service Commitment Entry No.", '<>0');
                if VendorContractLine.FindSet() then
                    repeat
                        if ServiceCommitment.Get(VendorContractLine."Service Commitment Entry No.") then begin
                            VendorContractDeferral.SetRange("Contract Line No.", VendorContractLine."Line No.");
                            VendorContractDeferral.SetRange(Released, false);
                            DeferralCount += VendorContractDeferral.Count;
                            VendorContractDeferral.ModifyAll("Dimension Set ID", ServiceCommitment."Dimension Set ID", false);
                        end;
                    until VendorContractLine.Next() = 0;
            end;
        Message(UpdatedDeferralsMsg, DeferralCount);
    end;

    local procedure SetDefaultWithoutContractDeferralsFromContractType()
    var
        ContractType: Record "Contract Type";
    begin
        if not ContractType.Get(Rec."Contract Type") then
            exit;
        Rec."Without Contract Deferrals" := ContractType."Def. Without Contr. Deferrals";
    end;

    internal procedure CreateBillingProposal()
    var
        BillingProposal: Codeunit "Billing Proposal";
    begin
        BillingProposal.CreateBillingProposalFromContract(Rec."No.", Rec.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
    end;

    [InternalEvent(false, false)]
    local procedure OnValidateBuyFromVendorNoAfterInit(var VendorContract: Record "Vendor Contract"; var xVendorContract: Record "Vendor Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterGetServiceContractSetup(VendorContract: Record "Vendor Contract"; var ServiceContractSetup: Record "Service Contract Setup"; CalledByFieldNo: Integer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnInitFromContactOnBeforeInitRecord(var VendorContract: Record "Vendor Contract"; var xVendorContract: Record "Vendor Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeHasBuyFromAddress(var VendorContract: Record "Vendor Contract"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyBuyFromVendorFieldsFromVendor(var VendorContract: Record "Vendor Contract"; Vendor: Record Vendor; xVendorContract: Record "Vendor Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyPayToVendorAddressFieldsFromVendor(var VendorContract: Record "Vendor Contract"; PayToVendor: Record Vendor)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateBuyFromCont(var VendorContract: Record "Vendor Contract"; Vendor: Record Vendor; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyBuyFromVendorAddressFieldsFromVendor(var VendorContract: Record "Vendor Contract"; BuyFromVendor: Record Vendor)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeHasPayToAddress(var VendorContract: Record "Vendor Contract"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdatePayToCont(var VendorContract: Record "Vendor Contract"; Vendor: Record Vendor; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdatePayToVend(var VendorContract: Record "Vendor Contract"; Contact: Record Contact)
    begin
    end;

    [InternalEvent(true, false)]
    local procedure OnBeforeContactIsNotRelatedToVendorError(Contact: Record Contact; ContactNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateBuyFromVend(var VendorContract: Record "Vendor Contract"; Contact: Record Contact)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeInitInsert(var VendorContract: Record "Vendor Contract"; var xVendorContract: Record "Vendor Contract"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeAssistEdit(var VendorContract: Record "Vendor Contract"; OldVendorContract: Record "Vendor Contract"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var VendorContract: Record "Vendor Contract"; xVendorContract: Record "Vendor Contract"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateDim(var VendorContract: Record "Vendor Contract"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateDimOnBeforeModify(var VendorContract: Record "Vendor Contract"; xVendorContract: Record "Vendor Contract"; CurrentFieldNo: Integer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var VendorContract: Record "Vendor Contract"; xVendorContract: Record "Vendor Contract"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateDimDimSource(Rec: Record "Vendor Contract"; CurrFieldNo: Integer; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;
}