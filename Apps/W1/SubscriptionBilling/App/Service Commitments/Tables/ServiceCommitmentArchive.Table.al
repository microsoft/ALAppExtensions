namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Pricing;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Currency;

table 8073 "Service Commitment Archive"
{
    Caption = 'Service Commitment Archive';
    DataClassification = CustomerContent;
    DrillDownPageId = "Service Commitment Archive";
    LookupPageId = "Service Commitment Archive";
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
        }
        field(4; "Original Entry No."; Integer)
        {
            Caption = 'Original Entry No.';
        }
        field(5; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            NotBlank = true;
            TableRelation = "Service Commitment Package";
            Editable = false;
        }
        field(6; Template; Code[20])
        {
            Caption = 'Template';
            NotBlank = true;
            TableRelation = "Service Commitment Template";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Service Start Date"; Date)
        {
            Caption = 'Service Start Date';
        }
        field(9; "Service End Date"; Date)
        {
            Caption = 'Service End Date';
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
        field(16; "Service Amount"; Decimal)
        {
            Caption = 'Service Amount';
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
            TableRelation = Item."No." where("Service Commitment Option" = filter("Invoicing Item" | "Service Commitment Item"));
        }
        field(20; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(21; "Contract No."; Code[20])
        {
            Caption = 'Contract';
            TableRelation = if (Partner = const(Customer)) "Customer Contract" where("Sell-to Customer No." = field("Service Object Customer No.")) else
            if (Partner = const(Vendor)) "Vendor Contract";
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
        field(28; "Service Object Customer No."; Code[20])
        {
            Caption = 'Service Object Customer No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Service Object"."End-User Customer No." where("No." = field("Service Object No.")));
            Editable = false;
        }
        field(29; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            TableRelation = if (Partner = const(Customer)) "Customer Contract Line"."Line No." where("Contract No." = field("Contract No.")) else
            if (Partner = const(Vendor)) "Vendor Contract Line"."Line No." where("Contract No." = field("Contract No."));
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
        field(35; "Service Amount (LCY)"; Decimal)
        {
            Caption = 'Service Amount (LCY)';
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
        field(41; "Serial No. (Service Object)"; Code[50])
        {
            Caption = 'Serial No. (Service Object)';
            Editable = false;
        }
        field(42; "Quantity Decimal (Service Ob.)"; Decimal)
        {
            Caption = 'Quantity (Service Object)';
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
        field(96; "Variant Code (Service Object)"; Code[10])
        {
            Caption = 'Variant Code (Service Object)';
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
        key(SK1; "Service Object No.", "Original Entry No.")
        {
        }
    }

    internal procedure CopyFromServiceCommitment(ServiceCommitment: Record "Service Commitment")
    var
        ServiceObject: Record "Service Object";
    begin
        Rec."Service Object No." := ServiceCommitment."Service Object No.";
        ServiceObject.Get(ServiceCommitment."Service Object No.");
        Rec."Quantity Decimal (Service Ob.)" := ServiceObject."Quantity Decimal";
        Rec."Serial No. (Service Object)" := ServiceObject."Serial No.";
        Rec."Variant Code (Service Object)" := ServiceObject."Variant Code";
        Rec."Original Entry No." := ServiceCommitment."Entry No.";
        Rec."Package Code" := ServiceCommitment."Package Code";
        Rec."Template" := ServiceCommitment."Template";
        Rec."Description" := ServiceCommitment."Description";
        Rec."Service Start Date" := ServiceCommitment."Service Start Date";
        Rec."Service End Date" := ServiceCommitment."Service End Date";
        Rec."Next Billing Date" := ServiceCommitment."Next Billing Date";
        Rec."Calculation Base Amount" := ServiceCommitment."Calculation Base Amount";
        Rec."Calculation Base %" := ServiceCommitment."Calculation Base %";
        Rec."Price" := ServiceCommitment."Price";
        Rec."Discount %" := ServiceCommitment."Discount %";
        Rec."Discount Amount" := ServiceCommitment."Discount Amount";
        Rec."Service Amount" := ServiceCommitment."Service Amount";
        Rec."Billing Base Period" := ServiceCommitment."Billing Base Period";
        Rec."Invoicing via" := ServiceCommitment."Invoicing via";
        Rec."Invoicing Item No." := ServiceCommitment."Invoicing Item No.";
        Rec."Partner" := ServiceCommitment."Partner";
        Rec."Contract No." := ServiceCommitment."Contract No.";
        Rec."Notice Period" := ServiceCommitment."Notice Period";
        Rec."Initial Term" := ServiceCommitment."Initial Term";
        Rec."Extension Term" := ServiceCommitment."Extension Term";
        Rec."Billing Rhythm" := ServiceCommitment."Billing Rhythm";
        Rec."Cancellation Possible Until" := ServiceCommitment."Cancellation Possible Until";
        Rec."Term Until" := ServiceCommitment."Term Until";
        Rec."Contract Line No." := ServiceCommitment."Contract Line No.";
        Rec."Customer Price Group" := ServiceCommitment."Customer Price Group";
        Rec."Shortcut Dimension 1 Code" := ServiceCommitment."Shortcut Dimension 1 Code";
        Rec."Shortcut Dimension 2 Code" := ServiceCommitment."Shortcut Dimension 2 Code";
        Rec."Price (LCY)" := ServiceCommitment."Price (LCY)";
        Rec."Discount Amount (LCY)" := ServiceCommitment."Discount Amount (LCY)";
        Rec."Service Amount (LCY)" := ServiceCommitment."Service Amount (LCY)";
        Rec."Currency Code" := ServiceCommitment."Currency Code";
        Rec."Currency Factor" := ServiceCommitment."Currency Factor";
        Rec."Currency Factor Date" := ServiceCommitment."Currency Factor Date";
        Rec."Calculation Base Amount (LCY)" := ServiceCommitment."Calculation Base Amount (LCY)";
        Rec."Dimension Set ID" := ServiceCommitment."Dimension Set ID";
        Rec."Next Price Update" := ServiceCommitment."Next Price Update";
        Rec.Closed := ServiceCommitment.Closed;
        OnAfterCopyFromServiceCommitment(Rec, ServiceCommitment);
    end;

    internal procedure FilterOnServiceCommitment(OriginalEntryNo: Integer)
    begin
        Rec.SetRange("Original Entry No.", OriginalEntryNo);
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCopyFromServiceCommitment(var Rec: Record "Service Commitment Archive"; ServiceCommitment: Record "Service Commitment")
    begin
    end;

}