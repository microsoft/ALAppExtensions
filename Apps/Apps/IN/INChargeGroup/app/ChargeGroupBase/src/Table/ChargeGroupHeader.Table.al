// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeGroupBase;

using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;

table 18510 "Charge Group Header"
{
    Caption = 'Charge Group Header';
    LookupPageId = "Charge Group List";
    DrillDownPageId = "Charge Group List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(20; "Invoice Combination"; Enum "Charge Group Invoice Comb.")
        {
            Caption = 'Invoice Combination';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                VerifyInvoiceCombination();
            end;
        }
        field(30; "Post Third Party Inv."; Boolean)
        {
            Caption = 'Post Third Party Inv.';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        CheckChargeGroupTransactionExist();
        DeleteChargeGroupLine();
    end;

    local procedure DeleteChargeGroupLine()
    var
        ChargeGroupLine: Record "Charge Group Line";
    begin
        ChargeGroupLine.LoadFields("Charge Group Code");
        ChargeGroupLine.SetRange("Charge Group Code", Rec.Code);
        if not ChargeGroupLine.IsEmpty() then
            ChargeGroupLine.DeleteAll(true);
    end;

    local procedure VerifyInvoiceCombination()
    var
        ChargeGroupLine: Record "Charge Group Line";
    begin
        ChargeGroupLine.LoadFields("Charge Group Code", "Third Party Invoice");
        ChargeGroupLine.SetRange("Charge Group Code", Rec.Code);
        ChargeGroupLine.SetRange("Third Party Invoice", true);
        if not ChargeGroupLine.IsEmpty then
            TestField("Invoice Combination");
    end;

    local procedure CheckChargeGroupTransactionExist()
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.SetRange("Charge Group Code", Code);
        if not PurchaseHeader.IsEmpty() then
            Error(RecordExistOnDeletErr, Rec.Code);

        SalesHeader.SetRange("Charge Group Code", Code);
        if not SalesHeader.IsEmpty() then
            Error(RecordExistOnDeletErr, Rec.Code);
    end;

    var
        RecordExistOnDeletErr: Label 'Record already exist for charge group %1.', Comment = '%1 = Charge Group Code';
}
