// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;

table 18351 "Service Transfer Line"
{
    Caption = 'Service Transfer Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Transfer From G/L Account No."; Code[20])
        {
            Caption = 'Transfer From G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Direct Posting" = const(true));

            trigger OnValidate()
            var
                GSTBaseValidation: Codeunit "GST Base Validation";
            begin
                TestField(Shipped, false);
                TestStatusOpen();
                GetServiceTransferHeader();
                GetGLAccountGSTInfo();
                GeneralLedgerSetup.Get();
                "GST Rounding Type" := GSTBaseValidation.GenLedInvRoundingType2GSTInvRoundingTypeEnum(GeneralLedgerSetup."Inv. Rounding Type (LCY)");
                "GST Rounding Precision" := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
                "Dimension Set ID" := ServiceTransferHeader."Dimension Set ID";
                DimensionManagement.UpdateGlobalDimFromDimSetID(
                    "Dimension Set ID",
                    "Shortcut Dimension 1 Code",
                    "Shortcut Dimension 2 Code");
            end;
        }
        field(4; "Transfer To G/L Account No."; Code[20])
        {
            Caption = 'Transfer To G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Direct Posting" = const(true));

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                GLAccount.Get("Transfer To G/L Account No.");
                GLAccount.TestField(Blocked, false);
                TestField("Receive Control A/C No.");
                "To G/L Account Description" := GLAccount.Name;
            end;
        }
        field(5; "Transfer Price"; Decimal)
        {
            Caption = 'Transfer Price';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Shipped, false);
                TestStatusOpen();
                if "Transfer Price" < 0 then
                    Error(TransPriceErr);
            end;
        }
        field(6; "Ship Control A/C No."; Code[20])
        {
            Caption = 'Ship Control A/C No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "G/L Account" where("Direct Posting" = const(true));
        }
        field(7; "Receive Control A/C No."; Code[20])
        {
            Caption = 'Receive Control A/C No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "G/L Account" where("Direct Posting" = const(true));
        }
        field(8; Shipped; Boolean)
        {
            Caption = 'Shipped';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(10; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(11; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
            TableRelation = "GST Group" where("GST Group Type" = filter(Service));
            trigger OnValidate()
            begin
                Rec."SAC Code" := '';
            end;
        }
        field(12; "SAC Code"; Code[10])
        {
            Caption = 'SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(16; "GST Rounding Type"; enum "GST Inv Rounding Type")
        {
            Caption = 'GST Rounding Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "GST Rounding Precision"; Decimal)
        {
            Caption = 'GST Rounding Precision';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18; "From G/L Account Description"; Text[100])
        {
            Caption = 'From G/L Account Description';
            DataClassification = CustomerContent;
        }
        field(19; "To G/L Account Description"; Text[100])
        {
            Caption = 'To G/L Account Description';
            DataClassification = CustomerContent;
        }
        field(20; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Shipped, false);
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            TableRelation = "Dimension Set Entry";
            DataClassification = SystemMetadata;

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        TestStatusOpen();
        TestField(Shipped, false);
    end;

    trigger OnInsert()
    var
        ServiceTransferLine: Record "Service Transfer Line";
    begin
        TestStatusOpen();
        TestShipped();
        ServiceTransferLine.Reset();
        ServiceTransferLine.SetFilter("Document No.", ServiceTransferHeader."No.");
        if ServiceTransferLine.FindLast() then
            "Line No." := ServiceTransferLine."Line No." + 10000;
    end;

    trigger OnRename()
    begin
        Error(RenameErr, TableCaption());
    end;

    var
        ServiceTransferHeader: Record "Service Transfer Header";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionManagement: Codeunit DimensionManagement;
        DimChangeQst: Label 'You have changed one or more dimensions on the %1, which is already shipped.\\Do you want to keep the changed dimension?', Comment = '%1 = Document No';
        CancellErr: Label 'Cancelled.';
        CompanyGSTRegNoErr: Label 'Please specify GST Registration No. in Company Information.';
        LocGSTRegNoARNNoErr: Label 'Location must have either GST Registration No. or Location ARN No.';
        RenameErr: Label 'You cannot rename a %1.', Comment = '%1 = Table Name';
        TransPriceErr: Label 'Transfer Price can not be Negative.';
        GSTGroupReverseChargeErr: Label 'GST Group Code %1 with Reverse Charge cannot be selected for Service Transfers.',
        Comment = '%1 = GST Group Code';
        DimensionSetMsg: Label '%1,%2', Comment = '%1=Document No.,%2=Line No.';

    procedure IsShippedDimChanged(): Boolean
    begin
        exit(("Dimension Set ID" <> xRec."Dimension Set ID") and
          (Shipped <> false));
    end;

    procedure ConfirmShippedDimChange(): Boolean
    begin
        if not Confirm(DimChangeQst, false, TableCaption()) then
            Error(CancellErr);

        exit(true);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        VerifyItemLineDim();
    end;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimensionManagement.EditDimensionSet(
              "Dimension Set ID",
              StrSubstNo(DimensionSetMsg, "Document No.", "Line No."));
        VerifyItemLineDim();
        DimensionManagement.UpdateGlobalDimFromDimSetID(
            "Dimension Set ID",
            "Shortcut Dimension 1 Code",
            "Shortcut Dimension 2 Code");
    end;

    procedure GSTApplicableOnServiceTransfer(ServTransHeader: Record "Service Transfer Header"): Boolean
    var
        CompanyInformation: Record "Company Information";
        location: Record Location;
    begin
        CompanyInformation.Get();
        if (CompanyInformation."ARN No." <> '') and (CompanyInformation."GST Registration No." = '') then
            if Location.Get(ServTransHeader."Transfer-to Code") then
                if (Location."Location ARN No." = '') or
                   ((Location."Location ARN No." <> '') and (Location."GST Registration No." <> ''))
                then
                    Error(CompanyGSTRegNoErr);

        CheckLocation(ServTransHeader."Transfer-from Code");
        CheckLocation(ServTransHeader."Transfer-to Code");
        exit(CheckFromAndToGSTRegistrationNo(ServTransHeader."Transfer-from Code", ServTransHeader."Transfer-to Code"));
    end;

    local procedure TestStatusOpen()
    begin
        TestField("Document No.");
        ServiceTransferHeader.Get("Document No.");
        ServiceTransferHeader.TestField(Status, ServiceTransferHeader.Status::Open);
    end;

    local procedure TestShipped()
    var
        ServiceTransferLine: Record "Service Transfer Line";
    begin
        ServiceTransferLine.SetRange("Document No.", "Document No.");
        ServiceTransferLine.SetRange(Shipped, true);
        if ServiceTransferLine.FindFirst() then
            ServiceTransferLine.TestField(Shipped, false);
    end;

    local procedure GetServiceTransferHeader()
    begin
        TestField("Document No.");
        ServiceTransferHeader.Get("Document No.");

        ServiceTransferHeader.TestField("Shipment Date");
        ServiceTransferHeader.TestField("Receipt Date");
        ServiceTransferHeader.TestField("Transfer-from Code");
        ServiceTransferHeader.TestField("Transfer-to Code");
        ServiceTransferHeader.TestField("Ship Control Account");
        "Ship Control A/C No." := ServiceTransferHeader."Ship Control Account";
        "Receive Control A/C No." := ServiceTransferHeader."Receive Control Account";
    end;

    local procedure GetGLAccountGSTInfo()
    var
        GLAccount: Record "G/L Account";
        GSTGroup: Record "GST Group";
    begin
        TestField("Transfer From G/L Account No.");
        GLAccount.Get("Transfer From G/L Account No.");
        GLAccount.TestField(Blocked, false);
        "GST Group Code" := GLAccount."GST Group Code";
        if GSTGroup.Get("GST Group Code") and GSTGroup."Reverse Charge" then
            Error(GSTGroupReverseChargeErr, "GST Group Code");
        "SAC Code" := GLAccount."HSN/SAC Code";
        Exempted := GLAccount.Exempted;
        "From G/L Account Description" := GLAccount.Name;
    end;

    local procedure VerifyItemLineDim()
    begin
        if IsShippedDimChanged() then
            ConfirmShippedDimChange();
    end;

    local procedure CheckLocation(LocationCode: Code[10])
    var
        location: Record Location;
    begin
        if Location.Get(LocationCode) then begin
            Location.TestField("State Code");
            if (Location."GST Registration No." = '') and (Location."Location ARN No." = '') then
                Error(LocGSTRegNoARNNoErr);
        end;
    end;

    local procedure CheckFromAndToGSTRegistrationNo(FromLocation: Code[10]; ToLocation: Code[10]): Boolean
    var
        Location: Record Location;
        FromLocationRegNo: Code[20];
        ToLocationRegNo: Code[20];
        FromLocationARNNo: Code[20];
        ToLocationARNNo: Code[20];
    begin
        Location.Get(FromLocation);
        if Location."GST Registration No." <> '' then
            FromLocationRegNo := Location."GST Registration No."
        else
            FromLocationARNNo := Location."Location ARN No.";
        Location.Get(ToLocation);
        if Location."GST Registration No." <> '' then
            ToLocationRegNo := Location."GST Registration No."
        else
            ToLocationARNNo := Location."Location ARN No.";
        if (FromLocationRegNo <> '') or (ToLocationRegNo <> '') then
            exit(FromLocationRegNo <> ToLocationRegNo);

        exit(FromLocationARNNo <> ToLocationARNNo);
    end;
}
