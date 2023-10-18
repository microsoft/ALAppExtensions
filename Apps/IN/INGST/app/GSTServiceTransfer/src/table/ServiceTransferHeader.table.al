// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Setup;
using System.Security.User;

table 18350 "Service Transfer Header"
{
    Caption = 'Service Transfer Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NoSeriesManagement: Codeunit NoSeriesManagement;
            begin
                if "No." <> xRec."No." then begin
                    GetInventorySetup();
                    NoSeriesManagement.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Transfer-from Code"; Code[10])
        {
            Caption = 'Transfer-from Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("Use As In-Transit" = const(false));

            trigger OnValidate()
            var
                Location: Record Location;
                Location2: Record Location;
                GLSetup: Record "General Ledger Setup";
                GSTBaseValidation: Codeunit "Gst Base Validation";
            begin
                TestStatusOpen();
                if ("Transfer-from Code" = "Transfer-to Code") and
                   ("Transfer-from Code" <> '')
                then
                    Error(
                      SameLocErr,
                      FieldCaption("Transfer-from Code"),
                      FieldCaption("Transfer-to Code"),
                      TableCaption(),
                      "No.");

                if Location.Get("Transfer-from Code") and Location2.Get("Transfer-to Code") then begin
                    if (Location2."GST Registration No." <> '') and
                        (Location."GST Registration No." <> '')
                    then
                        if Location."GST Registration No." = Location2."GST Registration No." then
                            Error(
                                SameLocRegErr,
                                FieldCaption("Transfer-from Code"),
                                FieldCaption("Transfer-to Code"),
                                TableCaption(),
                                "No.");

                    if (Location2."Location ARN No." <> '') and (Location."Location ARN No." <> '') then
                        if Location."Location ARN No." = Location2."Location ARN No." then
                            Error(
                                SameLocARNoErr,
                                FieldCaption("Transfer-from Code"),
                                FieldCaption("Transfer-to Code"),
                                TableCaption(),
                                "No.")
                end;

                Location.TestField("GST Input Service Distributor", false);
                if xRec."Transfer-from Code" <> "Transfer-from Code" then begin
                    if xRec."Transfer-from Code" = '' then
                        Confirmed := true
                    else
                        Confirmed := Confirm(LocChangeQst, false, FieldCaption("Transfer-from Code"));

                    if Confirmed then begin
                        "Transfer-from Name" := Location.Name;
                        "Transfer-from Name 2" := Location."Name 2";
                        "Transfer-from Address" := Location.Address;
                        "Transfer-from Address 2" := Location."Address 2";
                        "Transfer-from Post Code" := Location."Post Code";
                        "Transfer-from City" := Location.City;
                        "Transfer-from State" := Location."State Code";
                    end else
                        "Transfer-from Code" := xRec."Transfer-from Code";
                end;

                GLSetup.Get();
                "GST Inv. Rounding Precision" := GLSetup."Inv. Rounding Precision (LCY)";
                "GST Inv. Rounding Type" := GSTBaseValidation.GenLedInvRoundingType2GSTInvRoundingTypeEnum(GLSetup."Inv. Rounding Type (LCY)");
            end;
        }
        field(3; "Transfer-from Name"; Text[100])
        {
            Caption = 'Transfer-from Name';
            DataClassification = CustomerContent;
        }
        field(4; "Transfer-from Name 2"; Text[100])
        {
            Caption = 'Transfer-from Name 2';
            DataClassification = CustomerContent;
        }
        field(5; "Transfer-from Address"; Text[100])
        {
            Caption = 'Transfer-from Address';
            DataClassification = CustomerContent;
        }
        field(6; "Transfer-from Address 2"; Text[50])
        {
            Caption = 'Transfer-from Address 2';
            DataClassification = CustomerContent;
        }
        field(7; "Transfer-from Post Code"; Code[20])
        {
            Caption = 'Transfer-from Post Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidatePostCode(
                  "Transfer-from City", "Transfer-from Post Code",
                  County, Region, (CurrFieldNo <> 0) and GuiAllowed());
            end;
        }
        field(8; "Transfer-from City"; Text[30])
        {
            Caption = 'Transfer-from City';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidateCity(
                  "Transfer-from City", "Transfer-from Post Code",
                  County, Region, (CurrFieldNo <> 0) and GuiAllowed());
            end;
        }
        field(9; "Transfer-from State"; Code[10])
        {
            Caption = 'Transfer-from State';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(10; "Transfer-to Code"; Code[10])
        {
            Caption = 'Transfer-to Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("Use As In-Transit" = const(false));

            trigger OnValidate()
            var
                Location: Record Location;
                Location2: Record Location;
            begin
                TestStatusOpen();
                if ("Transfer-from Code" = "Transfer-to Code") and
                   ("Transfer-to Code" <> '')
                then
                    Error(
                      SameLocErr,
                      FieldCaption("Transfer-from Code"),
                      FieldCaption("Transfer-to Code"),
                      TableCaption(),
                      "No.");

                Location.Get("Transfer-to Code");
                Location.TestField("GST Input Service Distributor", false);
                if (Location."GST Registration No." = '') and (Location."Location ARN No." = '') then
                    Error(LocationCodeErr);

                if Location2.Get("Transfer-from Code") then begin
                    if (Location2."GST Registration No." <> '') and
                        (Location."GST Registration No." <> '')
                    then
                        if Location."GST Registration No." = Location2."GST Registration No." then
                            Error(
                                SameLocRegErr,
                                FieldCaption("Transfer-from Code"),
                                FieldCaption("Transfer-to Code"),
                                TableCaption(),
                                "No.");

                    if (Location2."Location ARN No." <> '') and (Location."Location ARN No." <> '') then
                        if Location."Location ARN No." = Location2."Location ARN No." then
                            Error(
                                SameLocARNoErr,
                                FieldCaption("Transfer-from Code"),
                                FieldCaption("Transfer-to Code"),
                                TableCaption(),
                                "No.");
                end;

                if xRec."Transfer-to Code" <> "Transfer-to Code" then begin
                    if xRec."Transfer-to Code" = '' then
                        Confirmed := true
                    else
                        Confirmed := Confirm(LocChangeQst, false, FieldCaption("Transfer-to Code"));

                    if Confirmed then begin
                        "Transfer-to Name" := Location.Name;
                        "Transfer-to Name 2" := Location."Name 2";
                        "Transfer-to Address" := Location.Address;
                        "Transfer-to Address 2" := Location."Address 2";
                        "Transfer-to Post Code" := Location."Post Code";
                        "Transfer-to City" := Location.City;
                        "Transfer-to State" := Location."State Code";
                    end else
                        "Transfer-to Code" := xRec."Transfer-to Code";
                end;
            end;
        }
        field(11; "Transfer-to Name"; Text[100])
        {
            Caption = 'Transfer-to Name';
            DataClassification = CustomerContent;
        }
        field(12; "Transfer-to Name 2"; Text[100])
        {
            Caption = 'Transfer-to Name 2';
            DataClassification = CustomerContent;
        }
        field(13; "Transfer-to Address"; Text[100])
        {
            Caption = 'Transfer-to Address';
            DataClassification = CustomerContent;
        }
        field(14; "Transfer-to Address 2"; Text[50])
        {
            Caption = 'Transfer-to Address 2';
            DataClassification = CustomerContent;
        }
        field(15; "Transfer-to Post Code"; Code[20])
        {
            Caption = 'Transfer-to Post Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidatePostCode(
                  "Transfer-to City", "Transfer-to Post Code", County,
                  Region, (CurrFieldNo <> 0) and GuiAllowed());
            end;
        }
        field(16; "Transfer-to City"; Text[30])
        {
            Caption = 'Transfer-to City';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidateCity(
                  "Transfer-to City", "Transfer-to Post Code", County,
                  Region, (CurrFieldNo <> 0) and GuiAllowed());
            end;
        }
        field(17; "Transfer-to State"; Code[10])
        {
            Caption = 'Transfer-to State';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = State;
        }
        field(19; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                Validate("Receipt Date", "Shipment Date");
            end;
        }
        field(20; "Receipt Date"; Date)
        {
            Caption = 'Receipt Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckReceiptDate();
            end;
        }
        field(21; Status; Enum Status)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(23; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(24; "Ship Control Account"; Code[20])
        {
            Caption = 'Ship Control Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Direct Posting" = const(true));

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                TestStatusOpen();
                GLAccount.Get("Ship Control Account");
                GLAccount.TestField(Blocked, false);
                UpdateServiceTransLines(FieldNo("Ship Control Account"));
            end;
        }
        field(25; "Receive Control Account"; Code[20])
        {
            Caption = 'Receive Control Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Direct Posting" = const(true));

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                GLAccount.Get("Receive Control Account");
                GLAccount.TestField(Blocked, false);
                UpdateServiceTransLines(FieldNo("Receive Control Account"));
            end;
        }
        field(27; "External Doc No."; Code[20])
        {
            Caption = 'External Doc No.';
            DataClassification = CustomerContent;
        }
        field(28; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(29; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(30; "GST Inv. Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            TableRelation = "Dimension Set Entry";
            DataClassification = SystemMetadata;

            trigger OnLookup()
            begin
                ShowDocDim();
            end;
        }
        field(9000; "Assigned User ID"; Code[50])
        {
            Caption = 'Assigned User ID';
            DataClassification = CustomerContent;
            TableRelation = "User Setup";
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        TestStatusOpen();
        ServiceTransferLine.Reset();
        ServiceTransferLine.SetRange("Document No.", "No.");
        if ServiceTransferLine.FindSet() then
            ServiceTransferLine.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        GetInventorySetup();
        if "No." = '' then begin
            InventorySetup.TestField("Service Transfer Order Nos.");
            NoSeriesManagement.InitSeries(
                GetNoSeriesCode(),
                xRec."No. Series",
                "Shipment Date",
                "No.",
                "No. Series");
        end;
        InitRecord();
    end;

    trigger OnRename()
    begin
        Error(RenameErr, TableCaption());
    end;

    var
        InventorySetup: Record "Inventory Setup";
        ServiceTransferLine: Record "Service Transfer Line";
        ServiceTransferHeader: Record "Service Transfer Header";
        DimensionManagement: Codeunit DimensionManagement;
        Confirmed: Boolean;
        HasInventorySetup: Boolean;
        County: Text[30];
        Region: Code[10];
        LocChangeQst: Label 'Do you want to change %1?',
            Comment = '%1 = Location Code.';
        DimChangeQst: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        SameLocRegErr: Label 'Registration No.s in %1 and %2 cannot be the same in %3 %4.',
            Comment = '%1 = From Location, %2 = To Location, %3 = Table Name, %4 = Document No';
        ReceiptDateErr: Label '%1 can not be less than %2.',
            Comment = '%1 = Receipt Date, %2 = Shipment Date';
        LocationCodeErr: Label 'Please specify the Location Code or Location GST Registration No for the selected document.';
        SameLocARNoErr: Label 'Location ARNNo in %1 and %2 cannot be the same in %3 %4.',
            Comment = '%1 = From Location, %2 = To Location, %3 = Table Name, %4 = Document No';
        RenameErr: Label 'You cannot rename a %1.',
            Comment = '%1 = Table Name';
        SameLocErr: Label '%1 and %2 cannot be the same in %3 %4.',
            Comment = '%1 = From Location, %2 = To Location, %3 = Table Name, %4 = Document No';

    procedure InitRecord()
    begin
        Validate("Shipment Date", WorkDate());
    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimensionManagement.EditDimensionSet(
              "Dimension Set ID",
              StrSubstNo('%1', "No."),
              "Shortcut Dimension 1 Code",
              "Shortcut Dimension 2 Code");

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            if ServiceTransferLinesExist() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure AssistEdit(OldServiceTransferHeader: Record "Service Transfer Header"): Boolean
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        ServiceTransferHeader := Rec;
        GetInventorySetup();
        InventorySetup.TestField("Service Transfer Order Nos.");
        if NoSeriesManagement.SelectSeries(GetNoSeriesCode(), OldServiceTransferHeader."No. Series", "No. Series") then begin
            NoSeriesManagement.SetSeries("No.");
            Rec := ServiceTransferHeader;
            exit(true);
        end;
    end;

    procedure GSTInvoiceRoundingDirection(): Text[1]
    begin
        case "GST Inv. Rounding Type" of
            "GST Inv. Rounding Type"::Nearest:
                exit('=');
            "GST Inv. Rounding Type"::Up:
                exit('>');
            "GST Inv. Rounding Type"::Down:
                exit('<');
        end;
    end;

    local procedure GetInventorySetup()
    begin
        if not HasInventorySetup then begin
            InventorySetup.Get();
            HasInventorySetup := true;
        end;
    end;

    local procedure GetNoSeriesCode(): Code[20]
    begin
        exit(InventorySetup."Service Transfer Order Nos.");
    end;

    local procedure TestStatusOpen()
    begin
        TestField(Status, Status::Open);
        ServiceTransferLine.SetRange("Document No.", "No.");
        ServiceTransferLine.SetRange(Shipped, true);
        if ServiceTransferLine.FindFirst() then
            ServiceTransferLine.TestField(Shipped, false);
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            if ServiceTransferLinesExist() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    local procedure ServiceTransferLinesExist(): Boolean
    begin
        ServiceTransferLine.Reset();
        ServiceTransferLine.SetRange("Document No.", "No.");
        exit(ServiceTransferLine.FindFirst());
    end;

    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    var
        NewDimSetID: Integer;
        ShippedLineDimChangeConfirmed: Boolean;
    begin
        // Update all lines with changed dimensions.
        if NewParentDimSetID = OldParentDimSetID then
            exit;

        if not Confirm(DimChangeQst) then
            exit;

        ServiceTransferLine.Reset();
        ServiceTransferLine.SetRange("Document No.", "No.");
        ServiceTransferLine.LockTable();
        if ServiceTransferLine.FindSet() then
            repeat
                NewDimSetID :=
                  DimensionManagement.GetDeltaDimSetID(
                      ServiceTransferLine."Dimension Set ID",
                      NewParentDimSetID,
                      OldParentDimSetID);

                if ServiceTransferLine."Dimension Set ID" <> NewDimSetID then begin
                    ServiceTransferLine."Dimension Set ID" := NewDimSetID;

                    VerifyShippedLineDimChange(ShippedLineDimChangeConfirmed);

                    DimensionManagement.UpdateGlobalDimFromDimSetID(
                      ServiceTransferLine."Dimension Set ID",
                      ServiceTransferLine."Shortcut Dimension 1 Code",
                      ServiceTransferLine."Shortcut Dimension 2 Code");
                    ServiceTransferLine.Modify();
                end;
            until ServiceTransferLine.Next() = 0;
    end;

    local procedure VerifyShippedLineDimChange(var ShippedLineDimChangeConfirmed: Boolean)
    begin
        if ServiceTransferLine.IsShippedDimChanged() then
            if not ShippedLineDimChangeConfirmed then
                ShippedLineDimChangeConfirmed := ServiceTransferLine.ConfirmShippedDimChange();
    end;

    local procedure UpdateServiceTransLines(FieldRef: Integer)
    var
        ServiceTransLine: Record "Service Transfer Line";
    begin
        ServiceTransLine.SetRange("Document No.", "No.");
        ServiceTransLine.SetFilter("Transfer From G/L Account No.", '<>%1', '');
        if ServiceTransLine.FindSet() then begin
            ServiceTransLine.LockTable();
            repeat
                case FieldRef of
                    FieldNo("Ship Control Account"):
                        ServiceTransLine.Validate("Ship Control A/C No.", "Ship Control Account");
                    FieldNo("Receive Control Account"):
                        ServiceTransLine.Validate("Receive Control A/C No.", "Receive Control Account");
                end;
                ServiceTransLine.Modify(true);
            until ServiceTransLine.Next() = 0;
        end;
    end;

    local procedure CheckReceiptDate()
    begin
        if ("Shipment Date" <> 0D) and ("Receipt Date" <> 0D) then
            if "Shipment Date" > "Receipt Date" then
                Error(ReceiptDateErr, FieldCaption("Receipt Date"), FieldCaption("Shipment Date"));
    end;
}
