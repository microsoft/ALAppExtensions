// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using System.Security.AccessControl;

table 18203 "GST Distribution Header"
{
    Caption = 'Distribution Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = false;
            DataClassification = CustomerContent;
        }
        field(2; "From GSTIN No."; Code[20])
        {
            Caption = 'From GSTIN No.';
            Editable = false;
            TableRelation = "GST Registration Nos." where("Input Service Distributor" = filter(true));
            DataClassification = CustomerContent;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(7; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(8; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(9; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
        }
        field(10; "Dist. Document Type"; Enum "BankCharges DocumentType")
        {
            Caption = 'Dist. Document Type';
            DataClassification = CustomerContent;
        }
        field(11; Reversal; Boolean)
        {
            Caption = 'Reversal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(12; "Reversal Invoice No."; Code[20])
        {
            Caption = 'Reversal Invoice No.';
            DataClassification = CustomerContent;
            TableRelation = "Posted GST Distribution Header"
                where(
                    Reversal = const(false),
                    "Completely Reversed" = const(false));
        }
        field(13; "ISD Document Type"; Enum "Adjustment Document Type")
        {
            Caption = 'ISD Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "From Location Code"; Code[10])
        {
            Caption = 'From Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("GST Input Service Distributor" = const(true));
        }
        field(16; "Dist. Credit Type"; Enum "GST Credit")
        {
            Caption = 'Dist. Credit Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Total Amout Applied for Dist.", 0);
            end;
        }
        field(17; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            DataClassification = CustomerContent;
        }
        field(18; "Total Amout Applied for Dist."; Decimal)
        {
            Caption = 'Total Amout Applied for Dist.';
            DataClassification = CustomerContent;
        }
        field(19; "Distribution Basis"; Text[50])
        {
            Caption = 'Distribution Basis';
            DataClassification = CustomerContent;
        }
        field(25; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(26; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = SystemMetadata;

            trigger OnLookup()
            begin
                ShowDocDim();
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var
        GLSetup: Record "General Ledger Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        UpdateDimQst: Label 'You may have changed a dimension.Do you want to update the lines?';
        DimensionSetMsg: Label '%1', Comment = '%1 =Dimension Set No.';

    procedure AssistEdit(GSTDistributionHeader: Record "GST Distribution Header"): Boolean
    begin
        Copy(Rec);
        GLSetup.Get();
        GLSetup.TestField("GST Distribution Nos.");
        if NoSeriesManagement.SelectSeries(GLSetup."GST Distribution Nos.", "No. Series", "No. Series") then begin
            NoSeriesManagement.SetSeries("No.");
            Rec := GSTDistributionHeader;
            exit(true);
        end;
    end;

    procedure ShowDocDim()
    var
        DimMgt: Codeunit DimensionManagement;
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" := DimMgt.EditDimensionSet(
            "Dimension Set ID",
            StrSubstNo(DimensionSetMsg, "No."),
            "Shortcut Dimension 1 Code",
            "Shortcut Dimension 2 Code");
        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            if GSTDistributionLinesExist() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    local procedure GSTDistributionLinesExist(): Boolean
    var
        GSTDistributionLine: Record "GST Distribution Line";
    begin
        GSTDistributionLine.SetRange("Distribution No.", "No.");
        exit(not GSTDistributionLine.IsEmpty());
    end;

    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    var
        GSTDistributionLine: Record "GST Distribution Line";
        DimMgt: Codeunit DimensionManagement;
        NewDimSetID: Integer;
    begin
        if NewParentDimSetID = OldParentDimSetID then
            exit;
        if not Confirm(UpdateDimQst) then
            exit;

        GSTDistributionLine.SetRange("Distribution No.", "No.");
        GSTDistributionLine.LockTable();
        if GSTDistributionLine.FindSet() then
            repeat
                NewDimSetID := DimMgt.GetDeltaDimSetID(
                    GSTDistributionLine."Dimension Set ID",
                    NewParentDimSetID,
                    OldParentDimSetID);
                if GSTDistributionLine."Dimension Set ID" <> NewDimSetID then begin
                    GSTDistributionLine."Dimension Set ID" := NewDimSetID;
                    DimMgt.UpdateGlobalDimFromDimSetID(
                        GSTDistributionLine."Dimension Set ID",
                        GSTDistributionLine."Shortcut Dimension 1 Code",
                        GSTDistributionLine."Shortcut Dimension 2 Code");
                    GSTDistributionLine.Modify();
                end;
            until GSTDistributionLine.Next() = 0;
    end;
}
