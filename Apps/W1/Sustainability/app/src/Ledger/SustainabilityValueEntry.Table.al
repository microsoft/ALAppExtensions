namespace Microsoft.Sustainability.Ledger;

using Microsoft.Finance.Dimension;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sustainability.Setup;
using Microsoft.Utilities;
using System.Security.AccessControl;

table 6227 "Sustainability Value Entry"
{
    Caption = 'Sustainability Value Entry';
    DrillDownPageID = "Sustainability Value Entries";
    LookupPageID = "Sustainability Value Entries";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(4; "Item Ledger Entry Type"; Enum "Item Ledger Entry Type")
        {
            Caption = 'Item Ledger Entry Type';
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(6; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            TableRelation = "Item Ledger Entry";
        }
        field(7; "Valued Quantity"; Decimal)
        {
            Caption = 'Valued Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(8; "Item Ledger Entry Quantity"; Decimal)
        {
            Caption = 'Item Ledger Entry Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(9; "Invoiced Quantity"; Decimal)
        {
            Caption = 'Invoiced Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(10; "CO2e per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'CO2e per Unit';
        }
        field(11; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(12; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(13; "Applies-to Entry"; Integer)
        {
            Caption = 'Applies-to Entry';
        }
        field(14; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(15; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(16; "Expected Emission"; Boolean)
        {
            Caption = 'Expected Emission';
        }
        field(17; "CO2e Amount (Actual)"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'CO2e Amount (Actual)';
        }
        field(18; "CO2e Amount (Expected)"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'CO2e Amount (Expected)';
        }
        field(19; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(20; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(21; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(22; "Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
        }
        field(23; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
        field(105; "Entry Type"; Enum "Cost Entry Type")
        {
            Caption = 'Entry Type';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(5831; "Capacity Ledger Entry No."; Integer)
        {
            Caption = 'Capacity Ledger Entry No.';
            TableRelation = "Capacity Ledger Entry";
        }
        field(5832; Type; Enum "Capacity Type Journal")
        {
            Caption = 'Type';
        }
        field(5834; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const("Machine Center")) "Machine Center"
            else
            if (Type = const("Work Center")) "Work Center"
            else
            if (Type = const(Resource)) Resource;
        }
        field(5818; Adjustment; Boolean)
        {
            Caption = 'Adjustment';
        }
        field(5156; "Shortcut Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Shortcut Dimension 3 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(3)));
        }
        field(5157; "Shortcut Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Shortcut Dimension 4 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(4)));
        }
        field(5158; "Shortcut Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Shortcut Dimension 5 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(5)));
        }
        field(5159; "Shortcut Dimension 6 Code"; Code[20])
        {
            CaptionClass = '1,2,6';
            Caption = 'Shortcut Dimension 6 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(6)));
        }
        field(5160; "Shortcut Dimension 7 Code"; Code[20])
        {
            CaptionClass = '1,2,7';
            Caption = 'Shortcut Dimension 7 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(7)));
        }
        field(5161; "Shortcut Dimension 8 Code"; Code[20])
        {
            CaptionClass = '1,2,8';
            Caption = 'Shortcut Dimension 8 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(8)));
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
        EntryRecIDLbl: Label '%1 %2', Locked = true;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet(Rec."Dimension Set ID", StrSubstNo(EntryRecIDLbl, Rec.TableCaption(), Rec."Entry No."));
    end;

    procedure CopyFromValueEntry(ValueEntry: Record "Value Entry")
    begin
        "Item No." := ValueEntry."Item No.";
        "Posting Date" := ValueEntry."Posting Date";
        "Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type";
        "Document No." := ValueEntry."Document No.";
        "Item Ledger Entry No." := ValueEntry."Item Ledger Entry No.";
        "Valued Quantity" := ValueEntry."Valued Quantity";
        "Item Ledger Entry Quantity" := ValueEntry."Item Ledger Entry Quantity";
        "Invoiced Quantity" := ValueEntry."Invoiced Quantity";
        "User ID" := ValueEntry."User ID";
        "Source Code" := ValueEntry."Source Code";
        "Applies-to Entry" := ValueEntry."Applies-to Entry";
        "Global Dimension 1 Code" := ValueEntry."Global Dimension 1 Code";
        "Global Dimension 2 Code" := ValueEntry."Global Dimension 2 Code";
        "Expected Emission" := ValueEntry."Expected Cost";
        "Journal Batch Name" := ValueEntry."Journal Batch Name";
        "Document Date" := ValueEntry."Document Date";
        "External Document No." := ValueEntry."External Document No.";
        "Document Type" := ValueEntry."Document Type";
        "Document Line No." := ValueEntry."Document Line No.";
        "Entry Type" := ValueEntry."Entry Type";
        "Dimension Set ID" := ValueEntry."Dimension Set ID";
        "Capacity Ledger Entry No." := ValueEntry."Capacity Ledger Entry No.";
        Type := ValueEntry.Type;
        "No." := ValueEntry."No.";
        Adjustment := ValueEntry.Adjustment;
    end;

    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;
}