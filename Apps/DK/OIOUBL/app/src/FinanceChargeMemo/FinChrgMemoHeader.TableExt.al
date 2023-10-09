// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.EServices.EDocument;
using Microsoft.Sales.Customer;

tableextension 13641 "OIOUBL-FinChrgMemoHeader" extends "Finance Charge Memo Header"
{
    fields
    {
        field(13630; "OIOUBL-GLN"; Code[13])
        {
            Caption = 'GLN';

            trigger OnValidate();
            begin
                if "OIOUBL-GLN" = '' then
                    EXIT;

                if NOT OIOUBLDocumentEncode.IsValidGLN("OIOUBL-GLN") then
                    FIELDERROR("OIOUBL-GLN", InvalidGLNErr);
            end;
        }
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';

            trigger OnValidate();
            var
                FinChrgMemoLine: Record "Finance Charge Memo Line";
            begin
                FinChrgMemoLine.RESET();
                FinChrgMemoLine.SETRANGE("Finance Charge Memo No.", "No.");
                FinChrgMemoLine.SETFILTER(Type, '>%1', FinChrgMemoLine.Type::" ");
                FinChrgMemoLine.SETFILTER("OIOUBL-Account Code", '%1|%2', xRec."OIOUBL-Account Code", '');
                FinChrgMemoLine.MODIFYALL("OIOUBL-Account Code", "OIOUBL-Account Code");
            end;
        }
        field(13635; "OIOUBL-Contact Phone No."; Text[30])
        {
            Caption = 'Contact Phone No.';

            ExtendedDataType = PhoneNo;
        }
        field(13636; "OIOUBL-Contact Fax No."; Text[30])
        {
            Caption = 'Contact Fax No.';
        }
        field(13637; "OIOUBL-Contact E-Mail"; Text[80])
        {
            Caption = 'Contact E-Mail';
            ExtendedDataType = EMail;
        }
        field(13638; "OIOUBL-Contact Role"; Option)
        {
            Caption = 'Contact Role';
            OptionMembers = " ",,,"Purchase Responsible",,,Accountant,,,"Budget Responsible",,,"Requisitioner";
        }

        modify("Customer No.")
        {
            trigger OnAfterValidate()
            var
                Customer: Record Customer;
            begin
                if not Customer.Get("Customer No.") then
                    exit;

                "OIOUBL-Contact Phone No." := Customer."Phone No.";
                "OIOUBL-Contact Fax No." := Customer."Fax No.";
                "OIOUBL-Contact E-Mail" := Customer."E-Mail";
                "OIOUBL-Contact Role" := "OIOUBL-Contact Role"::" ";

                "OIOUBL-Account Code" := Customer."OIOUBL-Account Code";
                "OIOUBL-GLN" := Customer.GLN;
            end;
        }
    }

    var
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';
}
