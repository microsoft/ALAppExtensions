// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.EServices.EDocument;
using Microsoft.Sales.History;

tableextension 13630 "OIOUBL-Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(13630; "OIOUBL-GLN"; Code[13])
        {
            Caption = 'GLN';
        }
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
        }
        field(13632; "OIOUBL-Profile Code"; Code[10])
        {
            Caption = 'Profile Code';
            TableRelation = "OIOUBL-Profile";
        }
        field(13634; "OIOUBL-Electronic Invoice Created"; Boolean)
        {
            Caption = 'Electronic Invoice Created';
            Editable = false;
        }
        field(13635; "OIOUBL-Sell-to Contact Phone No."; Text[30])
        {
            Caption = 'Sell-to Contact Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(13636; "OIOUBL-Sell-to Contact Fax No."; Text[30]) { }
        field(13637; "OIOUBL-Sell-to Contact E-Mail"; Text[80]) { ExtendedDatatype = EMail; }
        field(13638; "OIOUBL-Sell-to Contact Role"; Option) { OptionMembers = " ",,,"Purchase Responsible",,,Accountant,,,"Budget Responsible",,,Requisitioner; }
    }
    keys
    {
    }

    procedure AccountCodeLineSpecified(): Boolean
    var
        SalesInvLine: Record "Sales invoice Line";
    begin
        SalesInvLine.RESET();
        SalesInvLine.SETRANGE("Document No.", "No.");
        SalesInvLine.SETFILTER(Type, '>%1', SalesInvLine.Type::" ");
        SalesInvLine.SETFILTER("OIOUBL-Account Code", '<>%1&<>%2', '', "OIOUBL-Account Code");
        exit(NOT SalesInvLine.ISEMPTY());
    end;

    procedure TaxLineSpecified(): Boolean;
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        SalesInvLine.RESET();
        SalesInvLine.SETRANGE("Document No.", "No.");
        SalesInvLine.SETFILTER(Type, '>%1', SalesInvLine.Type::" ");
        SalesInvLine.FIND('-');
        SalesInvLine.SETFILTER("VAT %", '<>%1', SalesInvLine."VAT %");
        exit(NOT SalesInvLine.ISEMPTY());
    end;
}
