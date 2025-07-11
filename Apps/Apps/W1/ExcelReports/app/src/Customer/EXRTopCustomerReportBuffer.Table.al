// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sales.ExcelReports;

using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;

table 4405 "EXR Top Customer Report Buffer"
{
    Access = Internal;
    Caption = 'Top Customer Data';
    DataClassification = CustomerContent;
    TableType = Temporary;
    ReplicateData = false;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = "Customer";
        }
        field(2; "Customer Name"; Text[200])
        {
            Caption = 'Name';
        }
        field(10; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            CaptionClass = '3,' + GetAmount1Caption();
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(12; "Amount 2 (LCY)"; Decimal)
        {
            Caption = 'Amount 2 (LCY)';
            CaptionClass = '3,' + GetAmount2Caption();
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(13; "Ranking Based On"; Option)
        {
            Caption = 'Ranking Based On';
            OptionCaption = 'Sales (LCY), Balance (LCY)';
            OptionMembers = "Sales (LCY)","Balance (LCY)";
        }
        field(44; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            TableRelation = "Customer Posting Group";
            FieldClass = FlowFilter;
        }
        field(45; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            FieldClass = FlowFilter;
        }
        field(46; "Period Start Date"; Date)
        {
            Caption = 'Period Start Date';
        }
        field(100; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(101; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(102; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
    }
    keys
    {
        key(PK; "Customer No.", "Period Start Date", "Amount (LCY)")
        {
            Clustered = true;
        }
    }

    local procedure GetAmount1Caption(): Text
    var
        NewCaption: Text;
        Handled: Boolean;
    begin
        OnGetAmount1Caption(Handled, NewCaption);
        if not Handled then
            exit(AmountLCYTok);

        exit(NewCaption);
    end;

    local procedure GetAmount2Caption(): Text
    var
        NewCaption: Text;
        Handled: Boolean;
    begin
        OnGetAmount2Caption(Handled, NewCaption);
        if not Handled then
            exit(Amount2LCYTok);

        exit(NewCaption);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetAmount1Caption(var Handled: Boolean; var NewCaption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetAmount2Caption(var Handled: Boolean; var NewCaption: Text)
    begin
    end;

    var
        AmountLCYTok: Label 'Amount (LCY)';
        Amount2LCYTok: Label 'Amount 2 (LCY)';
}
