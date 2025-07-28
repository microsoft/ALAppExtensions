// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Foundation.PaymentTerms;

/// <summary>
/// Table Shpfy Payment Terms (ID 30157).
/// </summary>
table 30158 "Shpfy Payment Terms"
{
    Caption = 'Payment Terms';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            TableRelation = "Shpfy Shop";
            Editable = false;
        }
        field(2; "Id"; BigInteger)
        {
            Caption = 'ID';
            Editable = false;
        }
        field(20; Name; Text[50])
        {
            Caption = 'Name';
            Editable = false;
        }
        field(30; "Due In Days"; Integer)
        {
            Caption = 'Due In Days';
            Editable = false;
        }
        field(40; "Description"; Text[50])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(50; "Type"; Code[20])
        {
            Caption = 'Type';
            Editable = false;
        }
        field(60; "Is Primary"; Boolean)
        {
            Caption = 'Is Primary';

            trigger OnValidate()
            var
                ShopifyPaymentTerms: Record "Shpfy Payment Terms";
            begin
                if Rec."Is Primary" then begin
                    ShopifyPaymentTerms.SetRange("Is Primary", true);
                    if not ShopifyPaymentTerms.IsEmpty() then
                        Error(MultiplePrimaryPaymentTermsErr);
                end;
            end;
        }
        field(70; "Payment Terms Code"; Code[10])
        {
            TableRelation = "Payment Terms";
            Caption = 'Payment Terms Code';
        }
    }

    keys
    {
        key(PK; "Shop Code", "Id")
        {
            Clustered = true;
        }
    }

    var
        MultiplePrimaryPaymentTermsErr: Label 'Only one primary payment term is allowed.';
}