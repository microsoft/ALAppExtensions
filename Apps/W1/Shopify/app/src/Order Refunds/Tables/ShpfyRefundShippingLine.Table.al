// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Refund Shipping Line (ID 30162).
/// </summary>
table 30162 "Shpfy Refund Shipping Line"
{
    Access = Internal;
    Caption = 'Refund Shipping Line';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Refund Shipping Line Id"; BigInteger)
        {
            Caption = 'Refund Shipping Line Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Refund Id"; BigInteger)
        {
            Caption = 'Refund Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Refund Header"."Refund Id";
            Editable = false;
        }
        field(3; Title; Text[1024])
        {
            Caption = 'Title';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Subtotal Amount"; Decimal)
        {
            Caption = 'Subtotal Amount';
            DataClassification = SystemMetadata;
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = OrderCurrencyCode();
        }
        field(5; "Presentment Subtotal Amount"; Decimal)
        {
            Caption = 'Presentment Subtotal Amount';
            DataClassification = SystemMetadata;
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = OrderPresentmentCurrencyCode();
        }
        field(6; "Tax Amount"; Decimal)
        {
            Caption = 'Total Tax Amount';
            DataClassification = SystemMetadata;
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = OrderCurrencyCode();
        }
        field(7; "Presentment Tax Amount"; Decimal)
        {
            Caption = 'Presentment Total Tax Amount';
            DataClassification = SystemMetadata;
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = OrderPresentmentCurrencyCode();
        }
    }
    keys
    {
        key(PK; "Refund Id", "Refund Shipping Line Id")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        DataCapture: Record "Shpfy Data Capture";
    begin
        DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
        DataCapture.SetRange("Linked To Table", Database::"Shpfy Refund Shipping Line");
        DataCapture.SetRange("Linked To Id", Rec.SystemId);
        if not DataCapture.IsEmpty then
            DataCapture.DeleteAll(false);
    end;

    local procedure OrderCurrencyCode(): Code[10]
    var
        RefundHeader: Record "Shpfy Refund Header";
        OrderHeader: Record "Shpfy Order Header";
    begin
        if RefundHeader.Get("Refund Id") then
            if OrderHeader.Get(RefundHeader."Order Id") then
                exit(OrderHeader."Currency Code");
    end;

    local procedure OrderPresentmentCurrencyCode(): Code[10]
    var
        RefundHeader: Record "Shpfy Refund Header";
        OrderHeader: Record "Shpfy Order Header";
    begin
        if RefundHeader.Get("Refund Id") then
            if OrderHeader.Get(RefundHeader."Order Id") then
                exit(OrderHeader."Presentment Currency Code");
    end;
}