// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Purchases.ExcelReports;

using Microsoft.Purchases.Vendor;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;

table 4404 "EXR Top Vendor Report Buffer"
{
    Access = Internal;
    Caption = 'Top Vendor Data';
    DataClassification = CustomerContent;
    TableType = Temporary;
    ReplicateData = false;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = "Vendor";
        }
        field(2; "Vendor Name"; Text[200])
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
            OptionCaption = 'Purchases (LCY), Balance (LCY)';
            OptionMembers = "Purchases (LCY)","Balance (LCY)";
        }
        field(44; "Vendor Posting Group"; Code[20])
        {
            Caption = 'Vendor Posting Group';
            TableRelation = "Vendor Posting Group";
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
        key(PK; "Vendor No.", "Period Start Date", "Amount (LCY)")
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
