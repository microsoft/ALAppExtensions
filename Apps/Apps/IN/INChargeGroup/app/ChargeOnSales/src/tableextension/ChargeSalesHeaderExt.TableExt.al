// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;

tableextension 18803 "Charge Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(18698; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Charge Group Header";

            trigger OnValidate()
            begin
                if (Rec."Charge Group Code" <> xRec."Charge Group Code") and (xRec."Charge Group Code" <> '') then begin
                    RemoveOldChargeGroupEntriesOnSalesLine(xRec);
                    Message(DeleteMsg);
                end;
            end;
        }
    }

    procedure RemoveOldChargeGroupEntriesOnSalesLine(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Charge Group Code", SalesHeader."Charge Group Code");
        SalesLine.DeleteAll(true);
    end;

    var
        DeleteMsg: Label 'You have changed the Charge Group Code on the sales header after exploding the charge group lines, hence old charge group lines are deleted.\\You need to do the Explode Charge Group again.';
}
