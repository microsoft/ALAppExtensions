// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;

tableextension 18531 "Charge Purchase Header Ext" extends "Purchase Header"
{
    fields
    {
        field(18675; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Charge Group Header";

            trigger OnValidate()
            begin
                if (Rec."Charge Group Code" <> xRec."Charge Group Code") and (xRec."Charge Group Code" <> '') then begin
                    RemoveOldChargeGroupEntriesOnPurchaseLine(xRec);
                    Message(DeleteMsg);
                end;
            end;
        }
        field(18676; "Third Party"; Boolean)
        {
            Caption = 'Third Party';
            DataClassification = CustomerContent;
        }
        field(18677; "Charge Refernce Invoice No."; Code[20])
        {
            Caption = 'Charge Refernce Invoice No.';
            DataClassification = CustomerContent;
        }
    }

    procedure RemoveOldChargeGroupEntriesOnPurchaseLine(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Charge Group Code", PurchaseHeader."Charge Group Code");
        if not PurchaseLine.IsEmpty then
            PurchaseLine.DeleteAll(true);
    end;

    var
        DeleteMsg: Label 'You have changed the Charge Group Code on the purchase header after exploding the charge group lines, hence old charge group lines are deleted.\\You need to do the Explode Charge Group again.';
}
