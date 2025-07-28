// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Order Shipping Charges (ID 30130).
/// </summary>
table 30130 "Shpfy Order Shipping Charges"
{
    Caption = 'Shopify Order Shipping Charges';
    DataClassification = CustomerContent;
    LookupPageID = "Shpfy Order Shipping Charges";

    fields
    {
        field(1; "Shopify Shipping Line Id"; BigInteger)
        {
            Caption = 'Shopify Shipping Line Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Shopify Order Id"; BigInteger)
        {
            Caption = 'Shopify Order Id';
            DataClassification = SystemMetadata;
        }
        field(3; Title; Text[50])
        {
            Caption = 'Title';
            DataClassification = SystemMetadata;
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
            AutoFormatType = 1;
            AutoFormatExpression = OrderCurrencyCode();
        }
        field(5; Source; Code[30])
        {
            Caption = 'Source';
            DataClassification = SystemMetadata;
        }
        field(6; "Code"; Code[50])
        {
            Caption = 'Code Preview';
            DataClassification = SystemMetadata;
        }
        field(7; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = SystemMetadata;
            AutoFormatType = 1;
            AutoFormatExpression = OrderCurrencyCode();
        }
        field(8; "Presentment Amount"; Decimal)
        {
            Caption = 'Presentment Amount';
            DataClassification = SystemMetadata;
            AutoFormatType = 1;
            AutoFormatExpression = OrderPresentmentCurrencyCode();
        }
        field(9; "Presentment Discount Amount"; Decimal)
        {
            Caption = 'Presentment Discount Amount';
            DataClassification = SystemMetadata;
            AutoFormatType = 1;
            AutoFormatExpression = OrderPresentmentCurrencyCode();
        }
        field(10; "Code Value"; Text[2048])
        {
            Caption = 'Code Value';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Shopify Shipping Line Id")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        DataCapture: Record "Shpfy Data Capture";
    begin
        DataCapture.SetRange("Linked To Table", Database::"Shpfy Order Shipping Charges");
        DataCapture.SetRange("Linked To Id", Rec.SystemId);
        if not DataCapture.IsEmpty then
            DataCapture.DeleteAll(false);
    end;

    local procedure OrderCurrencyCode(): Code[10]
    var
        OrderHeader: Record "Shpfy Order Header";
    begin
        if OrderHeader.Get("Shopify Order Id") then
            exit(OrderHeader."Currency Code");
    end;

    local procedure OrderPresentmentCurrencyCode(): Code[10]
    var
        OrderHeader: Record "Shpfy Order Header";
    begin
        if OrderHeader.Get("Shopify Order Id") then
            exit(OrderHeader."Presentment Currency Code");
    end;
}

