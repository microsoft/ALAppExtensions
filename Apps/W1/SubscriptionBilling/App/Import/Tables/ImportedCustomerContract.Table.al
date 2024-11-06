namespace Microsoft.SubscriptionBilling;

using Microsoft.CRM.Contact;
using Microsoft.CRM.BusinessRelation;
using Microsoft.Sales.Customer;
using Microsoft.CRM.Team;
using System.Security.User;
using Microsoft.Projects.Project.Job;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Currency;
using System.Security.AccessControl;

table 8010 "Imported Customer Contract"
{
    DataClassification = CustomerContent;
    Caption = 'Imported Customer Contract';
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            NotBlank = true;
        }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
        }
        field(3; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;
        }
        field(4; "Sell-to Contact No."; Code[20])
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
                CustomerContract: Record "Customer Contract";
            begin
                if "Sell-to Contact No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric();

                if ("Sell-to Customer No." <> '') and ("Sell-to Contact No." <> '') then
                    CustomerContract.CheckContactRelatedToCustomerCompany("Sell-to Contact No.", "Sell-to Customer No.", CurrFieldNo);
            end;
        }
        field(5; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Customer;
        }
        field(6; "Bill-to Contact No."; Code[20])
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
                CustomerContract: Record "Customer Contract";
            begin
                if "Bill-to Contact No." <> '' then
                    if Cont.Get("Bill-to Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric();

                if ("Bill-to Customer No." <> '') and ("Bill-to Contact No." <> '') then
                    CustomerContract.CheckContactRelatedToCustomerCompany("Bill-to Contact No.", "Bill-to Customer No.", CurrFieldNo);
            end;
        }
        field(7; "Contract Type"; Code[10])
        {
            TableRelation = "Contract Type";
            Caption = 'Contract Type';
        }
        field(8; "Description"; Text[200])
        {
            Caption = 'Description';
        }
        field(11; "Your Reference"; Text[35])
        {
            Caption = 'Your Reference';
        }
        field(12; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            var
                Salesperson: Record "Salesperson/Purchaser";
            begin
                if Rec."Salesperson Code" <> '' then
                    if Salesperson.Get(Rec."Salesperson Code") then
                        if Salesperson.VerifySalesPersonPurchaserPrivacyBlocked(Salesperson) then
                            Error(Salesperson.GetPrivacyBlockedGenericText(Salesperson, true));
            end;
        }
        field(13; "Assigned User ID"; Code[50])
        {
            Caption = 'Assigned User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "User Setup";
        }
        field(14; "Without Contract Deferrals"; Boolean)
        {
            Caption = 'Without Contract Deferrals';
        }
        field(15; "Detail Overview"; Enum "Contract Detail Overview")
        {
            Caption = 'Detail Overview';
        }
        field(16; "Dimension from Job No."; Code[20])
        {
            Caption = 'Dimension from Project No.';
            TableRelation = Job."No." where("Bill-to Customer No." = field("Bill-to Customer No."));
        }
        field(17; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Sell-to Customer No."));
        }
        field(18; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(19; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(20; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));
        }
        field(21; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));
        }
        field(22; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(100; "Contract created"; Boolean)
        {
            Caption = 'Contract created';
            Editable = false;
        }
        field(101; "Error Text"; Text[250])
        {
            Caption = 'Error Text';
            Editable = false;
        }
        field(102; "Processed by"; Code[50])
        {
            Caption = 'Processed by';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            Editable = false;
            ValidateTableRelation = false;
        }
        field(103; "Processed at"; DateTime)
        {
            Caption = 'Processed at';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}