// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;

table 18477 "Subcontractor Delivery Challan"
{
    Caption = 'Subcontractor Delivery Challan';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Subcontractor No."; Code[20])
        {
            Caption = 'Subcontractor No.';
            TableRelation = Vendor."No." where(Subcontractor = const(true));
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                if "Subcontractor No." <> '' then
                    Vendor.Get("Subcontractor No.");

                UpdateLines();
                "Vendor Location" := Vendor."Vendor Location";
                "Gen. Bus. Posting Group" := Vendor."Gen. Bus. Posting Group";
            end;
        }
        field(4; "Vendor Location"; Code[10])
        {
            Caption = 'Vendor Location';
            Editable = false;
            TableRelation = Location.Code
                where("Subcontracting Location" = const(true),
                "Subcontractor No." = field("Subcontractor No."));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "From Location"; Code[10])
        {
            Caption = 'From Location';
            TableRelation = Location.Code where("Subcontracting Location" = const(false));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description)
        {
        }
    }

    procedure AssistEdit(OldDeliveryChallan: Record "Subcontractor Delivery Challan"): Boolean
    begin
        PurchSetup.Get();
        PurchSetup.TestField("Delivery Challan Nos.");
        if NoSeriesMgt.SelectSeries(PurchSetup."Delivery Challan Nos.", OldDeliveryChallan."No. Series", "No. Series") then BEGIN
            PurchSetup.Get();
            PurchSetup.TestField("Delivery Challan Nos.");
            NoSeriesMgt.SetSeries("No.");
            exit(true);
        end;
    end;

    procedure UpdateLines()
    begin
        SubconDeliveryChallanLine.SetRange("Document No.", "No.");
        if SubconDeliveryChallanLine.FindSet() then
            REPEAT
                SubconDeliveryChallanLine."Vendor Location" := Vendor."Vendor Location";
                SubconDeliveryChallanLine."Gen. Bus. Posting Group" := Vendor."Gen. Bus. Posting Group";
                SubconDeliveryChallanLine.Modify();
            until SubconDeliveryChallanLine.Next() = 0;
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        Vendor: Record "Vendor";
        SubconDeliveryChallanLine: Record "Subcon. Delivery Challan Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}
