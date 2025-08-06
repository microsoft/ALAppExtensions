namespace Microsoft.SubscriptionBilling;

using System.Reflection;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
using Microsoft.Projects.Project.Job;

table 8070 "Subscription Billing Cue"
{
    Caption = 'Subscription Billing Activities Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; "Cust. Sub. Contr. Invoices"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = filter(Invoice), "Recurring Billing" = filter(true)));
            Caption = 'Customer Subscription Contract Invoices';
            Editable = false;
            FieldClass = FlowField;
        }
        field(3; "Cust. Sub. Contr. Credit Memos"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = filter("Credit Memo"), "Recurring Billing" = filter(true)));
            Caption = 'Customer Subscription Contract Credit Memos';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Vend. Sub. Contr. Invoices"; Integer)
        {
            CalcFormula = count("Purchase Header" where("Document Type" = filter(Invoice), "Recurring Billing" = filter(true)));
            Caption = 'Vendor Subscription Contract Invoices';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Vend. Contr. Credit Memos"; Integer)
        {
            CalcFormula = count("Purchase Header" where("Document Type" = filter("Credit Memo"), "Recurring Billing" = filter(true)));
            Caption = 'Vendor Subscription Contract Credit Memos';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Sub. L. wo Cust. Sub. Contract"; Integer)
        {
            CalcFormula = count("Subscription Line"
                                where("Invoicing via" = filter(Contract), "Subscription Contract No." = filter(''), Partner = filter(Customer)));
            Caption = 'Subscription Lines wo Customer Subscription Contract';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Sub. L. wo Vend. Sub. Contract"; Integer)
        {
            CalcFormula = count("Subscription Line"
                                where("Invoicing via" = filter(Contract), "Subscription Contract No." = filter(''), Partner = filter(Vendor)));
            Caption = 'Subscription Lines wo Vendor Subscription Contract';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Jobs Over Budget"; Integer)
        {
            CalcFormula = count(Job where("Over Budget" = filter(= true)));
            Caption = 'Projects Over Budget';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Revenue current Month"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            Caption = 'Revenue Current Month';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }

        field(10; "Cost current Month"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            Caption = 'Cost Current Month';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(11; "Revenue previous Month"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            Caption = 'Revenue Previous Month';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }

        field(12; "Cost previous Month"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            Caption = 'Cost Previous Month';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(13; "Last Updated On"; DateTime)
        {
            Caption = 'Last Updated On';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(20; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(21; "Job No. Filter"; Code[20])
        {
            Caption = 'Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(22; Overdue; Integer)
        {
            Caption = 'Overdue';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(23; "Not Invoiced"; Integer)
        {
            CalcFormula = count("Billing Line" where("Document No." = filter('')));
            Caption = 'Not invoiced';
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(SK1; "Primary Key")
        {
            Clustered = true;
        }
    }

    local procedure GetAmountFormat(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.GetAmountFormatLCYWithUserLocale());
    end;
}
