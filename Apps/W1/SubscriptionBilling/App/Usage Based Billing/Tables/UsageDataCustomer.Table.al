namespace Microsoft.SubscriptionBilling;

using System.Reflection;
using System.Globalization;
using Microsoft.Sales.Customer;

table 8012 "Usage Data Customer"
{
    Caption = 'Usage Data Customer';
    DataClassification = CustomerContent;
    LookupPageId = "Usage Data Customers";
    DrillDownPageId = "Usage Data Customers";
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Supplier No."; Code[20])
        {
            Caption = 'Supplier No.';
            TableRelation = "Usage Data Supplier";
        }
        field(3; "Supplier Description"; Text[80])
        {
            Caption = 'Supplier Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Usage Data Supplier".Description where("No." = field("Supplier No.")));
        }
        field(4; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(5; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(6; "E-mail"; Text[80])
        {
            Caption = 'E-mail';
        }
        field(7; Domain; Text[80])
        {
            Caption = 'Domain';
        }
        field(8; Culture; Text[20])
        {
            Caption = 'Culture';

            trigger OnLookup()
            var
                Language: Record Language;
                TypeHelper: Codeunit "Type Helper";
                DotNet_CultureInfo: Codeunit DotNet_CultureInfo;
            begin
                if Culture <> '' then begin
                    DotNet_CultureInfo.GetCultureInfoByName(Culture);
                    Language.Get(DotNet_CultureInfo.ThreeLetterWindowsLanguageName());
                end;

                if Page.RunModal(0, Language) = Action::LookupOK then
                    Rec.Validate(Culture, TypeHelper.LanguageIDToCultureName(Language."Windows Language ID"));
            end;
        }
        field(9; "Supplier Reference Entry No."; Integer)
        {
            Caption = 'Supplier Reference Entry No.';
            TableRelation = "Usage Data Supplier Reference";

            trigger OnValidate()
            var
                UsageDataSupplierReference: Record "Usage Data Supplier Reference";
            begin
                if "Supplier Reference Entry No." = 0 then
                    exit;
                UsageDataSupplierReference.Get("Supplier Reference Entry No.");
                "Supplier Reference" := UsageDataSupplierReference."Supplier Reference";
            end;
        }
        field(10; "Supplier Reference"; Text[80])
        {
            Caption = 'Supplier Reference';

            trigger OnValidate()
            var
                UsageDataSupplierReference: Record "Usage Data Supplier Reference";
            begin
                if "Supplier Reference" = '' then
                    exit;
                UsageDataSupplierReference.FindSupplierReference("Supplier No.", "Supplier Reference", UsageDataSupplierReference.Type::Customer);
                "Supplier Reference Entry No." := UsageDataSupplierReference."Entry No.";
            end;
        }
        field(11; "Tenant ID"; Text[36])
        {
            Caption = 'Tenant ID';
        }
        field(12; "Customer ID"; Text[80])
        {
            Caption = 'Customer ID';
        }
        field(13; "Customer Description"; Text[100])
        {
            Caption = 'Customer Description';
        }
        field(14; "Processing Status"; Enum "Processing Status")
        {
            Caption = 'Processing Status';
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
