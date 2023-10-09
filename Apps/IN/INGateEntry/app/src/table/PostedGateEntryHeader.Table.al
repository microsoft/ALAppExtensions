// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using System.Security.AccessControl;

table 18606 "Posted Gate Entry Header"
{
    Caption = 'Posted Gate Entry Header';
    LookupPageID = "Posted Inward Gate Entry List";

    fields
    {
        field(1; "Entry Type"; Enum "Gate Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Document Time"; Time)
        {
            Caption = 'Document Time';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; Description; Text[120])
        {
            Caption = 'Description';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Item Description"; Text[120])
        {
            Caption = 'Item Description';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "LR/RR No."; Code[20])
        {
            Caption = 'LR/RR No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "LR/RR Date"; Date)
        {
            Caption = 'LR/RR Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Station From/To"; Code[20])
        {
            Caption = 'Station From/To';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; Comment; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("Gate Entry Comment Line" where("Gate Entry Type" = field("Entry Type"), "No." = field("No.")));
            Caption = 'Comment';
        }
        field(17; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18; "Posting Time"; Time)
        {
            Caption = 'Posting Time';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(19; "Gate Entry No."; Code[20])
        {
            Caption = 'Gate Entry No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";


            trigger OnLookup()
            var
                GateEntryHandler: Codeunit "Gate Entry Handler";
            begin
                GateEntryHandler.LookupUserID("User ID");
            end;
        }
    }

    keys
    {
        key(Key1; "Entry Type", "No.")
        {
            Clustered = true;
        }
        key(Key2; "Location Code", "Posting Date", "No.")
        {
        }
    }
}
