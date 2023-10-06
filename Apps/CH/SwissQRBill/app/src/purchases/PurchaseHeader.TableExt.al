// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

tableextension 11513 "Swiss QR-Bill Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(11500; "Swiss QR-Bill"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11501; "Swiss QR-Bill IBAN"; Code[50])
        {
            Caption = 'IBAN/QR-IBAN';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11502; "Swiss QR-Bill Bill Info"; Text[140])
        {
            Caption = 'Billing Information';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11503; "Swiss QR-Bill Unstr. Message"; Text[140])
        {
            Caption = 'Unstructured Message';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11504; "Swiss QR-Bill Amount"; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(11505; "Swiss QR-Bill Currency"; Code[10])
        {
            Caption = 'Currency';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11506; "Swiss QR-Bill Has Zero Amount"; Boolean)
        {
            Caption = 'QR-Bill Has Zero Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
