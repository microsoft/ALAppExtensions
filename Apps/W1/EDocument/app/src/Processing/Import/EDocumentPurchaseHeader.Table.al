// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;

table 6100 "E-Document Purchase Header"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            TableRelation = "E-Document"."Entry No";
            DataClassification = SystemMetadata;
            ValidateTableRelation = true;
        }
        field(2; "Customer Company Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Customer Company Id"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Purchase Order No."; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Sales Invoice No."; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Invoice Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Due Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Vendor Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Vendor Address"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Vendor Address Recipient"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(12; "Customer Address"; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(13; "Customer Address Recipient"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(14; "Billing Address"; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(15; "Billing Address Recipient"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(16; "Shipping Address"; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(17; "Shipping Address Recipient"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(18; "Sub Total"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(19; "Total Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(20; "Total Tax"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(21; "Total"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(22; "Amount Due"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(23; "Previous Unpaid Balance"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(24; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(25; "Remittance Address"; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(26; "Remittance Address Recipient"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(27; "Service Address"; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(28; "Service Address Recipient"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(29; "Service Start Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(30; "Service End Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(31; "Vendor Tax Id"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(32; "Customer Tax Id"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(33; "Payment Terms"; Text[150])
        {
            DataClassification = CustomerContent;
        }
        field(34; "Customer GLN"; Text[13])
        {
            DataClassification = CustomerContent;
            Caption = 'Global Location Number';
        }
        field(35; "Vendor GLN"; Text[13])
        {
            DataClassification = CustomerContent;
            Caption = 'Global Location Number';
        }
        field(36; "Vendor External Id"; Text[200])
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "E-Document Entry No.")
        {
            Clustered = true;
        }
    }

    procedure GetFromEDocument(EDocument: Record "E-Document")
    begin
        Clear(Rec);
        if Rec.Get(EDocument."Entry No") then;
    end;

}