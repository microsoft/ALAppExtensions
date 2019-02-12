// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13655 "OIOUBL-Service Invoice Header" extends "Service Invoice Header"
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
        ServInvLine: Record "Service Invoice Line";
    begin
        ServInvLine.RESET();
        ServInvLine.SETRANGE("Document No.", "No.");
        ServInvLine.SETFILTER(Type, '>%1', ServInvLine.Type::" ");
        ServInvLine.SETFILTER("OIOUBL-Account Code", '<>%1&<>%2', '', "OIOUBL-Account Code");
        exit(NOT ServInvLine.ISEMPTY());
    end;

    procedure TaxLineSpecified(): Boolean;
    var
        ServInvLine: Record "Service Invoice Line";
    begin
        ServInvLine.RESET();
        ServInvLine.SETRANGE("Document No.", "No.");
        ServInvLine.SETFILTER(Type, '>%1', ServInvLine.Type::" ");
        ServInvLine.FIND('-');
        ServInvLine.SETFILTER("VAT %", '<>%1', ServInvLine."VAT %");
        exit(NOT ServInvLine.ISEMPTY());
    end;

}