// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using System.Reflection;

table 30147 "Shpfy Return Header"
{
    Caption = 'Return Header';
    DataClassification = SystemMetadata;
    LookupPageId = "Shpfy Returns";
    DrillDownPageId = "Shpfy Returns";

    fields
    {
        field(1; "Return Id"; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Order Header"."Shopify Order Id";
            Editable = false;
        }
        field(3; "Return No."; Text[30])
        {
            Caption = 'Return No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; Status; Enum "Shpfy Return Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; "Total Quantity"; Integer)
        {
            Caption = 'Total Quantity';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Decline Reason"; Enum "Shpfy Return Decline Reason")
        {
            Caption = 'Decline Reason';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "Decline Note"; Blob)
        {
            Caption = 'Decline Note';
            DataClassification = SystemMetadata;
        }
        field(8; "Shop Code"; code[20])
        {
            Caption = 'Shop code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
#pragma warning disable AA0232
        field(12; "Discounted Total Amount"; Decimal)
        {
            Caption = 'Discounted Total Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Shpfy Return Line"."Discounted Total Amount" where("Return Id" = field("Return Id")));
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = OrderCurrencyCode();
        }
#pragma warning restore AA0232
        field(13; "Presentment Disc. Total Amt."; Decimal)
        {
            Caption = 'Presentment Discounted Total Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Shpfy Return Line"."Presentment Disc. Total Amt." where("Return Id" = field("Return Id")));
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = OrderPresentmentCurrencyCode();
        }
        field(101; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Sell-to Customer No." where("Shopify Order Id" = field("Order Id")));
        }
        field(102; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Bill-to Customer No." where("Shopify Order Id" = field("Order Id")));
        }
        field(103; "Sell-to Customer Name"; Text[50])
        {
            Caption = 'Sell-to Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Sell-to Customer Name" where("Shopify Order Id" = field("Order Id")));
        }
        field(104; "Bill-to Customer Name"; Text[50])
        {
            Caption = 'Bill-to Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Bill-to Name" where("Shopify Order Id" = field("Order Id")));
        }
        field(105; "Shopify Order No."; Text[50])
        {
            Caption = 'Shopify Order No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Shopify Order No." where("Shopify Order Id" = field("Order Id")));
        }
    }
    keys
    {
        key(PK; "Return Id")
        {
            Clustered = true;
        }
        key(Idx01; "Order Id") { }
        key(Idx02; "Return No.") { }
    }

    trigger OnDelete()
    var
        ReturnLine: Record "Shpfy Return Line";
        DataCapture: Record "Shpfy Data Capture";
    begin
        ReturnLine.SetRange("Return Id");
        if not ReturnLine.IsEmpty() then
            ReturnLine.DeleteAll(true);

        DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
        DataCapture.SetRange("Linked To Table", Database::"Shpfy Return Header");
        DataCapture.SetRange("Linked To Id", Rec.SystemId);
        if not DataCapture.IsEmpty then
            DataCapture.DeleteAll(false);
    end;

    internal procedure GetDeclineNote(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Decline Note");
        "Decline Note".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    internal procedure SetDeclineNote(NewDeclineNote: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Decline Note");
        "Decline Note".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewDeclineNote);
        Modify();
    end;

    local procedure OrderCurrencyCode(): Code[10]
    var
        OrderHeader: Record "Shpfy Order Header";
    begin
        if OrderHeader.Get("Order Id") then
            exit(OrderHeader."Currency Code");
    end;

    local procedure OrderPresentmentCurrencyCode(): Code[10]
    var
        OrderHeader: Record "Shpfy Order Header";
    begin
        if OrderHeader.Get("Order Id") then
            exit(OrderHeader."Presentment Currency Code");
    end;
}