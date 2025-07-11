// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GST.Base;

table 18319 "GST Liability Adjustment"
{
    Caption = 'GST Liability Adjustment';
    fields
    {
        field(1; "Journal Doc. No."; Code[20])
        {
            Caption = 'Journal Doc. No.';
            DataClassification = CustomerContent;
        }
        field(2; "GST Registration No."; Code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
        }
        field(4; "Document Type"; Enum "Adjustment Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Document Posting Date"; Date)
        {
            Caption = 'Document Posting Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "External Document No."; Code[40])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Adjustment Posting Date"; Date)
        {
            Caption = 'Adjustment Posting Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Adjustment Amount"; Decimal)
        {
            Caption = 'Adjustment Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Total GST Amount"; Decimal)
        {
            CalcFormula = sum("Detailed GST Ledger Entry"."GST Amount"
                where(
                    "Document No." = field("Document No."),
                    "Entry Type" = filter("Initial Entry")));
            Caption = 'Total GST Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Total GST Credit Amount"; Decimal)
        {
            CalcFormula = sum("Detailed GST Ledger Entry"."GST Amount"
                where(
                    "Document No." = field("Document No."),
                    "GST Credit" = filter(Availment),
                    "Entry Type" = filter("Initial Entry")));
            Caption = 'Total GST Credit Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Total GST Liability Amount"; Decimal)
        {
            CalcFormula = sum("Detailed GST Ledger Entry"."GST Amount"
                where(
                    "Document No." = field("Document No."),
                    "Entry Type" = filter("Initial Entry")));
            Caption = 'Total GST Liability Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Nature of Adjustment"; Enum "Cr Libty Adjustment Type")
        {
            Caption = 'Nature of Adjustment';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Nature of Adjustment" <> "Nature of Adjustment"::" ") and
                    ("Nature of Adjustment" <> "Select Nature of Adjustment")
                then
                    Error(NatureofAdjErr, "Select Nature of Adjustment");
            end;
        }
        field(16; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
        }
        field(17; "Select Nature of Adjustment"; Enum "Cr Libty Adjustment Type")
        {
            Caption = 'Select Nature of Adjustment';
            DataClassification = CustomerContent;
        }
        field(26; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
        }
        field(28; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code
                where(
                    "Global Dimension No." = const(1),
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
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1; "GST Registration No.", "Document Type", "Document No.")
        {
            Clustered = true;
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;
        NatureofAdjErr: Label 'Nature of Adjustment can be Blank or %1 only.', Comment = '%1 = Option';
        Text051Qst: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        DimensionSetDocMsg: Label '%1,%2', comment = '%1=Document Type,%2= No.';

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");

        if OldDimSetID <> "Dimension Set ID" then
            Modify();
    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
              "Dimension Set ID",
              StrSubstNo(DimensionSetDocMsg, "Document Type", "Document No."),
              "Shortcut Dimension 1 Code",
              "Shortcut Dimension 2 Code");

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    var
        NewDimSetID: Integer;
    begin
        if NewParentDimSetID = OldParentDimSetID then
            exit;
        if not Confirm(Text051Qst) then
            exit;
        if FindSet() then
            repeat
                NewDimSetID := DimMgt.GetDeltaDimSetID(
                    "Dimension Set ID",
                    NewParentDimSetID,
                    OldParentDimSetID);

                if "Dimension Set ID" <> NewDimSetID then begin
                    "Dimension Set ID" := NewDimSetID;
                    DimMgt.UpdateGlobalDimFromDimSetID(
                      "Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                    Modify();
                end;
            until Next() = 0;
    end;
}
