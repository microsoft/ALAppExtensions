// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;

table 18471 "Multiple Subcon. Order Details"
{
    Caption = 'Multiple Subcon. Order Details';
    LookupPageID = "Multiple Order Subcon Det List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    PurchasePayablesSetup.Get();
                    NoSeriesMgt.TestManual(PurchasePayablesSetup."Multiple Subcon. Order Det Nos");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Subcontractor No."; Code[20])
        {
            Caption = 'Subcontractor No.';
            TableRelation = Vendor;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Vendor Shipment No."; Code[20])
        {
            Caption = 'Vendor Shipment No.';
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

    trigger OnInsert()
    begin
        if "No." = '' then begin
            PurchasePayablesSetup.Get();
            PurchasePayablesSetup.TestField("Multiple Subcon. Order Det Nos");
            NoSeries.Get(PurchasePayablesSetup."Multiple Subcon. Order Det Nos");
            "No." := NoSeriesMgt.GetNextNo(NoSeries.Code, WorkDate(), true);
            "No. Series" := PurchasePayablesSetup."Multiple Subcon. Order Det Nos";
        end;
        "Posting Date" := WorkDate();
        "Document Date" := WorkDate();
    end;

    procedure AssistEdit(OldMultipleSubconOrdDet: Record "Multiple Subcon. Order Details"): Boolean
    var
        MultipleSubconOrdDet: Record "Multiple Subcon. Order Details";
    begin
        Copy(Rec);
        PurchasePayablesSetup.Get();
        PurchasePayablesSetup.TestField("Multiple Subcon. Order Det Nos");
        if NoSeriesMgt.SelectSeries
           (PurchasePayablesSetup."Multiple Subcon. Order Det Nos", "No. Series", "No. Series")
        then begin
            NoSeriesMgt.SetSeries("No.");
            Rec := MultipleSubconOrdDet;
            exit(true);
        end;
    end;

    var
        NoSeries: Record "No. Series";
        PurchasePayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}
