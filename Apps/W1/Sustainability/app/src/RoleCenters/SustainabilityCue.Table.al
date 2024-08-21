namespace Microsoft.Sustainability.RoleCenters;

using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;
using Microsoft.EServices.EDocument;
using Microsoft.Sustainability.Account;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Document;

table 6220 "Sustainability Cue"
{
    Caption = 'Sustainability Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CO2" where("Posting Date" = field("Date Filter"), "Emission Scope" = field("Scope Filter")));
        }
        field(3; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CH4" where("Posting Date" = field("Date Filter"), "Emission Scope" = field("Scope Filter")));
        }
        field(4; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission N2O" where("Posting Date" = field("Date Filter"), "Emission Scope" = field("Scope Filter")));
        }
        field(6; "Ongoing Purchase Orders"; Integer)
        {
            Caption = 'Ongoing Purchase Orders';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = const(Order), "Sustainability Lines Exist" = const(true)));
            Editable = false;
        }
        field(7; "Ongoing Purchase Invoices"; Integer)
        {
            Caption = 'Ongoing Purchase Invoices';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = const(Invoice), "Sustainability Lines Exist" = const(true)));
            Editable = false;
        }
        field(8; "Purch. Invoices Due Next Week"; Integer)
        {
            CalcFormula = count("Vendor Ledger Entry" where("Document Type" = filter(Invoice | "Credit Memo"),
                                                             "Due Date" = field("Due Next Week Filter"),
                                                             Open = const(true)));
            Caption = 'Purch. Invoices Due Next Week';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "My Incoming Documents"; Integer)
        {
            CalcFormula = count("Incoming Document" where(Processed = const(false)));
            Caption = 'My Incoming Documents';
            FieldClass = FlowField;
        }
        field(15; "Inc. Doc. Awaiting Verfication"; Integer)
        {
            CalcFormula = count("Incoming Document" where("OCR Status" = const("Awaiting Verification")));
            Caption = 'Inc. Doc. Awaiting Verfication';
            FieldClass = FlowField;
        }
        field(20; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Caption = 'Date Filter';
        }
        field(21; "Due Next Week Filter"; Date)
        {
            Caption = 'Due Next Week Filter';
            FieldClass = FlowFilter;
        }
        field(22; "Scope Filter"; Enum "Emission Scope")
        {
            Caption = 'Scope Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
    var
        SustainabilitySetup: Record "Sustainability Setup";
}