// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13657 "OIOUBL-Service Cr.Memo Header" extends "Service Cr.Memo Header"
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
        field(13634; "OIOUBL-Electronic Credit Memo Created"; Boolean)
        {
            Caption = 'Electronic Credit Memo Created';
            Editable = false;
        }
        field(13632; "OIOUBL-Profile Code"; Code[10])
        {
            Caption = 'Profile Code';
            TableRelation = "OIOUBL-Profile";
        }
        field(13638; "OIOUBL-Contact Role"; Option)
        {
            Caption = 'Contact Role';
            OptionMembers = " ",,,"Purchase Responsible",,,Accountant,,,"Budget Responsible",,,Requisitioner;
        }
    }
    keys
    {
    }

    procedure AccountCodeLineSpecified(): Boolean;
    var
        ServCrMemoLine: Record "Service Cr.Memo Line";
    begin
        ServCrMemoLine.RESET();
        ServCrMemoLine.SETRANGE("Document No.", "No.");
        ServCrMemoLine.SETFILTER(Type, '>%1', ServCrMemoLine.Type::" ");
        ServCrMemoLine.SETFILTER("OIOUBL-Account Code", '<>%1&<>%2', '', "OIOUBL-Account Code");
        exit(NOT ServCrMemoLine.ISEMPTY());
    end;

    procedure TaxLineSpecified(): Boolean;
    var
        ServCrMemoLine: Record "Service Cr.Memo Line";
    begin
        ServCrMemoLine.RESET();
        ServCrMemoLine.SETRANGE("Document No.", "No.");
        ServCrMemoLine.SETFILTER(Type, '>%1', ServCrMemoLine.Type::" ");
        ServCrMemoLine.FIND('-');
        ServCrMemoLine.SETFILTER("VAT %", '<>%1', ServCrMemoLine."VAT %");
        exit(NOT ServCrMemoLine.ISEMPTY());
    end;
}