// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

using Microsoft.Finance.GST.Base;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Vendor;

tableextension 18009 "GST Location Ext" extends Location
{
    fields
    {
        field(18000; "GST Registration No."; code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
            TableRelation = "GST Registration Nos." where("State Code" = field("State Code"));

            trigger onvalidate()
            var
                GSTRegistrationNos: Record "GST Registration Nos.";
            begin
                "GST Input Service Distributor" := false;
                if GSTRegistrationNos.Get("GST Registration No.") then
                    "GST Input Service Distributor" := GSTRegistrationNos."Input Service Distributor";
            end;
        }
        field(18001; "GST Input Service Distributor"; Boolean)
        {
            Caption = 'GST Input Service Distributor';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18002; "Location ARN No."; code[20])
        {
            Caption = 'Location ARN No.';
            DataClassification = CustomerContent;
        }
        field(18003; "Bonded warehouse"; Boolean)
        {
            Caption = 'Bonded warehouse';
            DataClassification = CustomerContent;
        }
        field(18004; "Subcontracting Location"; Boolean)
        {
            Caption = 'Subcontracting Location';
            DataClassification = CustomerContent;
        }
        field(18005; "Subcontractor No."; code[20])
        {
            Caption = 'Subcontractor No.';
            DataClassification = CustomerContent;
            TableRelation = vendor;
        }
        field(18006; "Export or Deemed Export"; Boolean)
        {
            Caption = 'Export or Deemed Export';
            DataClassification = CustomerContent;
        }
        field(18007; "Input Service Distributor"; Boolean)
        {
            Caption = 'Input Service Distributor';
            DataClassification = CustomerContent;
        }
        field(18008; "Trading Location"; Boolean)
        {
            Caption = 'Trading Location';
            DataClassification = CustomerContent;
        }
        field(18009; "Posted Dist. Invoice Nos."; code[20])
        {
            Caption = 'Posted Dist. Invoice Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18010; "Posted Dist. Cr. Memo Nos."; code[20])
        {
            Caption = 'Posted Dist. Cr. Memo Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18011; "Composition"; Boolean)
        {
            Caption = 'Composition';
            DataClassification = CustomerContent;
        }
        field(18012; "Composition Type"; Enum "Composition Type")
        {
            Caption = 'Composition Type';
            DataClassification = CustomerContent;
        }
        field(18013; "GST Liability Invoice"; Code[20])
        {
            Caption = 'GST Liability Invoice';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    procedure IsBondedWarehouse(LocationCode: Code[10]): Boolean
    begin
        if LocationCode <> '' then
            exit(Rec."Bonded warehouse");
    end;
}
