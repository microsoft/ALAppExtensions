// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.CRM.Contact;
using Microsoft.EServices.EDocument;
using Microsoft.Sales.Customer;

tableextension 13646 "OIOUBL-Sales Header" extends "Sales Header"
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

                if NOT OIOXMLDocumentEncode.IsValidGLN("OIOUBL-GLN") then
                    FIELDERROR("OIOUBL-GLN", InvalidGLNErr);
            end;
        }
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
            trigger OnValidate();
            var
                SalesLine: Record "Sales Line";
            begin
                SalesLine.RESET();
                SalesLine.SETRANGE("Document Type", "Document Type");
                SalesLine.SETRANGE("Document No.", "No.");
                SalesLine.SETFILTER(Type, '>%1', SalesLine.Type::" ");
                SalesLine.SETFILTER("OIOUBL-Account Code", '%1|%2', xRec."OIOUBL-Account Code", '');
                SalesLine.MODIFYALL("OIOUBL-Account Code", "OIOUBL-Account Code");
            end;
        }
        field(13632; "OIOUBL-Profile Code"; Code[10])
        {
            Caption = 'Profile Code';
            TableRelation = "OIOUBL-Profile";
        }
        field(13635; "OIOUBL-Sell-to Contact Phone No."; Text[30])
        {
            Caption = 'Sell-to Contact Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(13636; "OIOUBL-Sell-to Contact Fax No."; Text[30])
        {
            Caption = 'Sell-to Contact Fax No.';
        }
        field(13637; "OIOUBL-Sell-to Contact E-Mail"; Text[80])
        {
            Caption = 'Sell-to Contact E-Mail';
            ExtendedDatatype = EMail;
        }
        field(13638; "OIOUBL-Sell-to Contact Role"; Option)
        {
            Caption = 'Sell-to Contact Role';
            OptionMembers = " ",,,"Purchase Responsible",,,"Accountant",,,"Budget Responsible",,,"Requisitioner";
        }
        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                Customer: Record Customer;
                Contact: Record Contact;
            begin
                if "Sell-to Contact No." <> xRec."Sell-to Contact No." then
                    Validate("Sell-to Contact No.");

                if not Customer.Get("Sell-to Customer No.") then
                    exit;

                "Sell-to Contact" := Customer.Contact;
                "OIOUBL-Account Code" := Customer."OIOUBL-Account Code";
                "OIOUBL-Sell-to Contact Phone No." := Customer."Phone No.";
                "OIOUBL-Sell-to Contact Fax No." := Customer."Fax No.";
                "OIOUBL-Sell-to Contact E-Mail" := Customer."E-Mail";
                "OIOUBL-Sell-to Contact Role" := "OIOUBL-Sell-to Contact Role"::" ";

                if not Contact.Get("Sell-to Contact No.") then
                    exit;

                if Contact.Type <> Contact.Type::Person then
                    exit;

                "Sell-to Contact" := Contact.Name;
                "OIOUBL-Sell-to Contact Phone No." := Contact."Phone No.";
                "OIOUBL-Sell-to Contact Fax No." := Contact."Fax No.";
                "OIOUBL-Sell-to Contact E-Mail" := Contact."E-Mail";
            end;
        }
        modify("Bill-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                Customer: Record Customer;
            begin
                if not Customer.Get("Bill-to Customer No.") then
                    exit;

                "OIOUBL-GLN" := Customer.GLN;
                "OIOUBL-Profile Code" := Customer."OIOUBL-Profile Code";
            end;
        }
    }

    var
        OIOXMLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';

    procedure ClearSellToCust();
    begin
        "Sell-to Contact" := '';
        "OIOUBL-Sell-to Contact Phone No." := '';
        "OIOUBL-Sell-to Contact Fax No." := '';
        "OIOUBL-Sell-to Contact E-Mail" := '';
        "OIOUBL-Sell-to Contact Role" := "OIOUBL-Sell-to Contact Role"::" ";
    end;

    procedure GetselltoCust(Name: Text[50]; PhoneNo: Text[30]; FaxNo: Text[30]; Email: Text[80]);
    begin
        "Sell-to Contact" := Name;
        "OIOUBL-Sell-to Contact Phone No." := PhoneNo;
        "OIOUBL-Sell-to Contact Fax No." := FaxNo;
        "OIOUBL-Sell-to Contact E-Mail" := Email;
        "OIOUBL-Sell-to Contact Role" := "OIOUBL-Sell-to Contact Role"::" ";
    end;
}
