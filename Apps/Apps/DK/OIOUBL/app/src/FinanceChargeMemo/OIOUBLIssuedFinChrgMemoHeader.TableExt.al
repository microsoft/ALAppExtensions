// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

tableextension 13643 "OIOUBL-IssuedFinChrgMemoHeader" extends "Issued Fin. Charge Memo Header"
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
        field(13634; "OIOUBL-Elec. Fin. Charge Memo Created"; Boolean)
        {
            Caption = 'Elec. Fin. Charge Memo Created';
            Editable = false;
        }
        field(13635; "OIOUBL-Contact Phone No."; Text[30])
        {
            Caption = 'Contact Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(13636; "OIOUBL-Contact Fax No."; Text[30])
        {
            Caption = 'Contact Fax No.';
        }
        field(13637; "OIOUBL-Contact E-Mail"; Text[80])
        {
            Caption = 'Coontact E-Mail';
            ExtendedDatatype = EMail;
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
        IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line";
    begin
        IssuedFinChargeMemoLine.RESET();
        IssuedFinChargeMemoLine.SETRANGE("Finance Charge Memo No.", "No.");
        IssuedFinChargeMemoLine.SETFILTER(Type, '>%1', IssuedFinChargeMemoLine.Type::" ");
        IssuedFinChargeMemoLine.SETFILTER("OIOUBL-Account Code", '<>%1&<>%2', '', "OIOUBL-Account Code");
        exit(NOT IssuedFinChargeMemoLine.ISEMPTY());
    end;

    procedure TaxLineSpecified(): Boolean;
    var
        IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line";
    begin
        IssuedFinChargeMemoLine.RESET();
        IssuedFinChargeMemoLine.SETRANGE("Finance Charge Memo No.", "No.");
        IssuedFinChargeMemoLine.SETFILTER(Type, '>%1', IssuedFinChargeMemoLine.Type::" ");
        IssuedFinChargeMemoLine.FIND('-');
        IssuedFinChargeMemoLine.SETFILTER("VAT %", '<>%1', IssuedFinChargeMemoLine."VAT %");
        exit(NOT IssuedFinChargeMemoLine.ISEMPTY());
    end;

    procedure GetDescription(): Text[1024];
    var
        DescriptionTxt: Label '%1 %2 %3%4', Locked = true;
    begin
        exit(CopyStr(STRSUBSTNO(DescriptionTxt, TABLECAPTION(), FIELDCAPTION("No."), "No.", CrLf()), 1, 1024));
    end;

    local procedure CrLf() CrLf: Text[2];
    begin
        CrLf[1] := 13;
        CrLf[2] := 10;
    end;
}
