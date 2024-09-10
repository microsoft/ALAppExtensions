// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.Sales.Customer;

tableextension 96361 "E-Doc TE Customer Ext" extends Customer
{
    fields
    {
        field(96360; "Service Participant Id"; Text[50])
        {
            Caption = 'Service Participant Id';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                TietoevryProcessing: Codeunit "Tietoevry Processing";
            begin
                if Rec."Service Participant Id" <> '' then
                    if not TietoevryProcessing.IsValidSchemeId(Rec."Service Participant Id") then
                        FieldError(Rec."Service Participant Id");
            end;
        }

    }
}
