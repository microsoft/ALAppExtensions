#pragma warning disable AS0049
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import.Purchase;

using Microsoft.eServices.EDocument;

table 6100 "E-Document Purchase Header"
{
    Access = Internal;
    ReplicateData = false;
#pragma warning disable AS0034
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
#pragma warning restore AS0034

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            TableRelation = "E-Document"."Entry No";
            DataClassification = SystemMetadata;
            ValidateTableRelation = true;
        }
        field(2; "Customer Company Name"; Text[250])
        {
            Caption = 'Customer Company Name';
            DataClassification = CustomerContent;
        }
        field(3; "Customer Company Id"; Text[250])
        {
            Caption = 'Customer Company Id';
            DataClassification = CustomerContent;
        }
        field(4; "Purchase Order No."; Text[100])
        {
            Caption = 'Purchase Order No.';
            DataClassification = CustomerContent;
        }
        field(5; "Sales Invoice No."; Text[100])
        {
            Caption = 'Sales Invoice No.';
            DataClassification = CustomerContent;
        }
        field(6; "Invoice Date"; Date)
        {
            Caption = 'Invoice Date';
            DataClassification = CustomerContent;
        }
        field(7; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(8; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(9; "Vendor Company Name"; Text[250])
        {
            Caption = 'Vendor Company Name';
            DataClassification = CustomerContent;
        }
        field(10; "Vendor Address"; Text[250])
        {
            Caption = 'Vendor Address';
            DataClassification = CustomerContent;
        }
        field(11; "Vendor Address Recipient"; Text[250])
        {
            Caption = 'Vendor Address Recipient';
            DataClassification = CustomerContent;
        }
        field(12; "Customer Address"; Text[250])
        {
            Caption = 'Customer Address';
            DataClassification = CustomerContent;
        }
        field(13; "Customer Address Recipient"; Text[250])
        {
            Caption = 'Customer Address Recipient';
            DataClassification = CustomerContent;
        }
        field(14; "Billing Address"; Text[250])
        {
            Caption = 'Billing Address';
            DataClassification = CustomerContent;
        }
        field(15; "Billing Address Recipient"; Text[250])
        {
            Caption = 'Billing Address Recipient';
            DataClassification = CustomerContent;
        }
        field(16; "Shipping Address"; Text[250])
        {
            Caption = 'Shipping Address';
            DataClassification = CustomerContent;
        }
        field(17; "Shipping Address Recipient"; Text[250])
        {
            Caption = 'Shipping Address Recipient';
            DataClassification = CustomerContent;
        }
        field(18; "Sub Total"; Decimal)
        {
            Caption = 'Sub Total';
            DataClassification = CustomerContent;
        }
        field(19; "Total Discount"; Decimal)
        {
            Caption = 'Total Discount';
            DataClassification = CustomerContent;
        }
        field(20; "Total VAT"; Decimal)
        {
            Caption = 'Total VAT';
            DataClassification = CustomerContent;
        }
        field(21; Total; Decimal)
        {
            Caption = 'Total';
            DataClassification = CustomerContent;
        }
        field(22; "Amount Due"; Decimal)
        {
            Caption = 'Amount Due';
            DataClassification = CustomerContent;
        }
        field(23; "Previous Unpaid Balance"; Decimal)
        {
            Caption = 'Previous Unpaid Balance';
            DataClassification = CustomerContent;
        }
        field(24; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(25; "Remittance Address"; Text[250])
        {
            Caption = 'Remittance Address';
            DataClassification = CustomerContent;
        }
        field(26; "Remittance Address Recipient"; Text[250])
        {
            Caption = 'Remittance Address Recipient';
            DataClassification = CustomerContent;
        }
        field(27; "Service Address"; Text[250])
        {
            Caption = 'Service Address';
            DataClassification = CustomerContent;
        }
        field(28; "Service Address Recipient"; Text[250])
        {
            Caption = 'Service Address Recipient';
            DataClassification = CustomerContent;
        }
        field(29; "Service Start Date"; Date)
        {
            Caption = 'Service Start Date';
            DataClassification = CustomerContent;
        }
        field(30; "Service End Date"; Date)
        {
            Caption = 'Service End Date';
            DataClassification = CustomerContent;
        }
        field(31; "Vendor VAT Id"; Text[100])
        {
            Caption = 'Vendor VAT Id';
            DataClassification = CustomerContent;
        }
        field(32; "Customer VAT Id"; Text[100])
        {
            Caption = 'Customer VAT Id';
            DataClassification = CustomerContent;
        }
        field(33; "Payment Terms"; Text[250])
        {
            Caption = 'Payment Terms';
            DataClassification = CustomerContent;
        }
        field(34; "Customer GLN"; Text[13])
        {
            Caption = 'Customer Global Location Number';
            DataClassification = CustomerContent;
        }
        field(35; "Vendor GLN"; Text[13])
        {
            Caption = 'Vendor Global Location Number';
            DataClassification = CustomerContent;
        }
        field(36; "Vendor External Id"; Text[250])
        {
            Caption = 'Vendor External Id';
            DataClassification = CustomerContent;
        }
        field(37; "Vendor Contact Name"; Text[250])
        {
            Caption = 'Vendor Contact Name';
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

    procedure InsertForEDocument(EDocument: Record "E-Document")
    begin
        Rec."E-Document Entry No." := EDocument."Entry No";
        if not Rec.Insert() then begin
            Clear(Rec);
            Rec."E-Document Entry No." := EDocument."Entry No";
            Rec.Modify();
        end;
    end;

}
#pragma warning restore AS0049