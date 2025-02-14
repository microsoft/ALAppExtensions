// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import;

using Microsoft.Purchases.Document;
using Microsoft.Utilities;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.eServices.EDocument;
using Microsoft.Finance.AllocationAccount;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Foundation.UOM;

table 6105 "E-Document Line Mapping"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    fields
    {
        field(1; "E-Document Line Id"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "E-Document Entry No."; Integer)
        {
            TableRelation = "E-Document"."Entry No";
        }
        field(3; "Purchase Line Type"; Enum "Purchase Line Type")
        {
            Caption = 'Purchase Line Type';
            DataClassification = CustomerContent;
        }
        field(4; "Purchase Type No."; Code[20])
        {
            Caption = 'Purchase Type No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Purchase Line Type" = const(" ")) "Standard Text"
            else
            if ("Purchase Line Type" = const("G/L Account")) "G/L Account"
            else
            if ("Purchase Line Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Purchase Line Type" = const("Charge (Item)")) "Item Charge"
            else
            if ("Purchase Line Type" = const(Item)) Item
            else
            if ("Purchase Line Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Purchase Line Type" = const(Resource)) Resource;
        }
        field(5; "Unit of Measure"; Code[20])
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
    }
    keys
    {
        key(PK; "E-Document Line Id")
        {
            Clustered = true;
        }
    }

    procedure InsertForEDocumentLine(EDocument: Record "E-Document"; EDocumentLineId: Integer)
    begin
        if Rec.Get(EDocumentLineId) then begin
            Clear(Rec);
            Rec."E-Document Line Id" := EDocumentLineId;
            Rec."E-Document Entry No." := EDocument."Entry No";
            Rec.Modify();
        end;
        Rec."E-Document Entry No." := EDocument."Entry No";
        Rec."E-Document Line Id" := EDocumentLineId;
        Rec.Insert();
    end;

}