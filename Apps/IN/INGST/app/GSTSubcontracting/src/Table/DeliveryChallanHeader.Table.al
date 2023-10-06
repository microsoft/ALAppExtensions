// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;

table 18468 "Delivery Challan Header"
{
    Caption = 'Delivery Challan Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Process Description"; Text[100])
        {
            Caption = 'Process Description';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Challan Date"; Date)
        {
            Caption = 'Challan Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Sub. order No."; Code[20])
        {
            Caption = 'Sub. order No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Sub. Order Line No."; Integer)
        {
            Caption = 'Sub. Order Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; Rework; Boolean)
        {
            Caption = 'Rework';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            Editable = false;
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
        field(14; "Last Date"; Date)
        {
            Caption = 'Last Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Debit Note No."; Code[10])
        {
            Caption = 'Debit Note No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16; "Commissioner's Permission No."; Text[50])
        {
            Caption = 'Commissioner''s Permission No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(17; "Quantity for rework"; Decimal)
        {
            Caption = 'Quantity for rework';
            DecimalPlaces = 0 : 3;
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(26; "Remaining Quantity"; Boolean)
        {
            Caption = 'Remaining Quantity';
            FieldClass = FlowField;
            CalcFormula = Exist("Delivery Challan Line" where("Delivery Challan No." = field("No."), "Remaining Quantity" = filter(> 0)));
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Sub. order No.", "Sub. Order Line No.")
        {
        }
    }

    trigger OnInsert()
    begin
        InitRecord();
        PurchSetup.Get();
        if "No." = '' then begin
            PurchSetup.TestField("Posted Delivery Challan Nos.");
            NoSeriesMgt.InitSeries(PurchSetup."Posted Delivery Challan Nos.", xRec."No. Series", TODAY, "No.", "No. Series");
        end;
    end;

    procedure InitRecord()
    begin
        NoSeriesMgt.SetDefaultSeries("No. Series", PurchSetup."Posted Delivery Challan Nos.");
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
}
