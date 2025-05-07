namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Pricing;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Currency;

table 8073 "Subscription Line Archive"
{
    Caption = 'Subscription Line Archive';
    DataClassification = CustomerContent;
    DrillDownPageId = "Service Commitment Archive";
    LookupPageId = "Service Commitment Archive";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = "Subscription Header";
        }
        field(4; "Original Entry No."; Integer)
        {
            Caption = 'Original Entry No.';
        }
        field(5; "Subscription Package Code"; Code[20])
        {
            Caption = 'Subscription Package Code';
            NotBlank = true;
            TableRelation = "Subscription Package";
            Editable = false;
        }
        field(6; Template; Code[20])
        {
            Caption = 'Template';
            NotBlank = true;
            TableRelation = "Sub. Package Line Template";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Subscription Line Start Date"; Date)
        {
            Caption = 'Subscription Line Start Date';
        }
        field(9; "Subscription Line End Date"; Date)
        {
            Caption = 'Subscription Line End Date';
        }
        field(10; "Next Billing Date"; Date)
        {
            Caption = 'Next Billing Date';
            Editable = false;
        }
        field(11; "Calculation Base Amount"; Decimal)
        {
            Caption = 'Calculation Base Amount';
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(12; "Calculation Base %"; Decimal)
        {
            Caption = 'Calculation Base %';
            MinValue = 0;
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(13; "Price"; Decimal)
        {
            Caption = 'Price';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(14; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            MinValue = 0;
            MaxValue = 100;
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(15; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(16; Amount; Decimal)
        {
            Caption = 'Amount';
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(17; "Billing Base Period"; DateFormula)
        {
            Caption = 'Billing Base Period';
        }
        field(18; "Invoicing via"; Enum "Invoicing Via")
        {
            Caption = 'Invoicing via';
        }
        field(19; "Invoicing Item No."; Code[20])
        {
            Caption = 'Invoicing Item No.';
            TableRelation = Item."No." where("Subscription Option" = filter("Invoicing Item" | "Service Commitment Item"));
        }
        field(20; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(21; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            TableRelation = if (Partner = const(Customer)) "Customer Subscription Contract" where("Sell-to Customer No." = field("Sub. Header Customer No.")) else
            if (Partner = const(Vendor)) "Vendor Subscription Contract";
        }
        field(22; "Notice Period"; DateFormula)
        {
            Caption = 'Notice Period';
        }
        field(23; "Initial Term"; DateFormula)
        {
            Caption = 'Initial Term';
        }
        field(24; "Extension Term"; DateFormula)
        {
            Caption = 'Subsequent Term';
        }
        field(25; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
        }
        field(26; "Cancellation Possible Until"; Date)
        {
            Caption = 'Cancellation Possible Until';
        }
        field(27; "Term Until"; Date)
        {
            Caption = 'Term Until';
        }
        field(28; "Sub. Header Customer No."; Code[20])
        {
            Caption = 'Subscription Header Customer No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header"."End-User Customer No." where("No." = field("Subscription Header No.")));
            Editable = false;
        }
        field(29; "Subscription Contract Line No."; Integer)
        {
            Caption = 'Subscription Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Cust. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No.")) else
            if (Partner = const(Vendor)) "Vend. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No."));
        }
        field(30; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(31; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));
        }
        field(32; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));
        }
        field(33; "Price (LCY)"; Decimal)
        {
            Caption = 'Price (LCY)';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(34; "Discount Amount (LCY)"; Decimal)
        {
            Caption = 'Discount Amount (LCY)';
            Editable = false;
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(35; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(36; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(37; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(38; "Currency Factor Date"; Date)
        {
            Caption = 'Currency Factor Date';
            Editable = false;
        }
        field(39; "Calculation Base Amount (LCY)"; Decimal)
        {
            Caption = 'Calculation Base Amount (LCY)';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(40; Discount; Boolean)
        {
            Caption = 'Discount';
            Editable = false;
        }
        field(41; "Serial No. (Sub. Header)"; Code[50])
        {
            Caption = 'Serial No. (Subscription)';
            Editable = false;
        }
        field(42; "Quantity (Sub. Header)"; Decimal)
        {
            Caption = 'Quantity (Subscription)';
        }
        field(50; "Next Price Update"; Date)
        {
            Caption = 'Next Price Update';
        }
        field(53; "Type Of Update"; Enum "Type Of Price Update")
        {
            Caption = 'Type Of Update';
        }
        field(54; "Perform Update On"; Date)
        {
            Caption = 'Perform Update On';
        }
        field(96; "Variant Code (Sub. Header)"; Code[10])
        {
            Caption = 'Variant Code (Subscription)';
        }
        field(100; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(101; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
        }
        field(107; "Closed"; Boolean)
        {
            Caption = 'Closed';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
        }
        key(SK1; "Subscription Header No.", "Original Entry No.")
        {
        }
    }

    internal procedure CopyFromServiceCommitment(ServiceCommitment: Record "Subscription Line")
    var
        ServiceObject: Record "Subscription Header";
    begin
        Rec."Subscription Header No." := ServiceCommitment."Subscription Header No.";
        ServiceObject.Get(ServiceCommitment."Subscription Header No.");
        Rec."Quantity (Sub. Header)" := ServiceObject.Quantity;
        Rec."Serial No. (Sub. Header)" := ServiceObject."Serial No.";
        Rec."Variant Code (Sub. Header)" := ServiceObject."Variant Code";
        Rec."Original Entry No." := ServiceCommitment."Entry No.";
        Rec."Subscription Package Code" := ServiceCommitment."Subscription Package Code";
        Rec."Template" := ServiceCommitment."Template";
        Rec."Description" := ServiceCommitment."Description";
        Rec."Subscription Line Start Date" := ServiceCommitment."Subscription Line Start Date";
        Rec."Subscription Line End Date" := ServiceCommitment."Subscription Line End Date";
        Rec."Next Billing Date" := ServiceCommitment."Next Billing Date";
        Rec."Calculation Base Amount" := ServiceCommitment."Calculation Base Amount";
        Rec."Calculation Base %" := ServiceCommitment."Calculation Base %";
        Rec."Price" := ServiceCommitment."Price";
        Rec."Discount %" := ServiceCommitment."Discount %";
        Rec."Discount Amount" := ServiceCommitment."Discount Amount";
        Rec.Amount := ServiceCommitment.Amount;
        Rec."Billing Base Period" := ServiceCommitment."Billing Base Period";
        Rec."Invoicing via" := ServiceCommitment."Invoicing via";
        Rec."Invoicing Item No." := ServiceCommitment."Invoicing Item No.";
        Rec."Partner" := ServiceCommitment."Partner";
        Rec."Subscription Contract No." := ServiceCommitment."Subscription Contract No.";
        Rec."Notice Period" := ServiceCommitment."Notice Period";
        Rec."Initial Term" := ServiceCommitment."Initial Term";
        Rec."Extension Term" := ServiceCommitment."Extension Term";
        Rec."Billing Rhythm" := ServiceCommitment."Billing Rhythm";
        Rec."Cancellation Possible Until" := ServiceCommitment."Cancellation Possible Until";
        Rec."Term Until" := ServiceCommitment."Term Until";
        Rec."Subscription Contract Line No." := ServiceCommitment."Subscription Contract Line No.";
        Rec."Customer Price Group" := ServiceCommitment."Customer Price Group";
        Rec."Shortcut Dimension 1 Code" := ServiceCommitment."Shortcut Dimension 1 Code";
        Rec."Shortcut Dimension 2 Code" := ServiceCommitment."Shortcut Dimension 2 Code";
        Rec."Price (LCY)" := ServiceCommitment."Price (LCY)";
        Rec."Discount Amount (LCY)" := ServiceCommitment."Discount Amount (LCY)";
        Rec."Amount (LCY)" := ServiceCommitment."Amount (LCY)";
        Rec."Currency Code" := ServiceCommitment."Currency Code";
        Rec."Currency Factor" := ServiceCommitment."Currency Factor";
        Rec."Currency Factor Date" := ServiceCommitment."Currency Factor Date";
        Rec."Calculation Base Amount (LCY)" := ServiceCommitment."Calculation Base Amount (LCY)";
        Rec."Dimension Set ID" := ServiceCommitment."Dimension Set ID";
        Rec."Next Price Update" := ServiceCommitment."Next Price Update";
        Rec."Unit Cost" := ServiceCommitment."Unit Cost";
        Rec."Unit Cost (LCY)" := ServiceCommitment."Unit Cost (LCY)";
        Rec.Closed := ServiceCommitment.Closed;
        OnAfterCopyFromSubscriptionLine(Rec, ServiceCommitment);
    end;

    internal procedure FilterOnServiceCommitment(OriginalEntryNo: Integer)
    begin
        Rec.SetRange("Original Entry No.", OriginalEntryNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromSubscriptionLine(var SubscriptionLineArchive: Record "Subscription Line Archive"; SubscriptionLine: Record "Subscription Line")
    begin
    end;

}