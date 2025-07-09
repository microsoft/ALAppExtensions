// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Vendor;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Purchases.Document;

table 6102 "E-Document Header Mapping"
{
    Access = Internal;
    ReplicateData = false;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            TableRelation = "E-Document"."Entry No";
            DataClassification = SystemMetadata;
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor."No.";
        }
        field(3; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order));
        }
    }
    keys
    {
        key(PK; "E-Document Entry No.")
        {
            Clustered = true;
        }
    }

    procedure InsertForEDocument(EDocument: Record "E-Document")
    begin
        Rec."E-Document Entry No." := EDocument."Entry No";
        if not Rec.Insert() then begin
            Clear(Rec);
            Rec."E-Document Entry No." := EDocument."Entry No";
            Rec.Modify();
        end;
    end;

    internal procedure GetEDocumentPurchaseHeader() EDocumentPurchaseHeader: Record "E-Document Purchase Header"
    begin
        if EDocumentPurchaseHeader.Get(Rec."E-Document Entry No.") then;
    end;

}