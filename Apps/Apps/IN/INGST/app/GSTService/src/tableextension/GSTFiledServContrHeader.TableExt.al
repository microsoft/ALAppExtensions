// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Contract;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;

tableextension 18450 "GST Filed Serv. Contr. Header" extends "Filed Service Contract Header"
{
    fields
    {
        field(18440; "GST Customer Type"; enum "GST Customer Type")
        {
            Caption = 'GST Customer Type';
            DataClassification = CustomerContent;
        }
        field(18441; "Invoice Type"; enum "Sales Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
        }
        field(18442; "GST Bill-to State Code"; Code[10])
        {
            Caption = 'GST Bill-to State Code';
            DataClassification = CustomerContent;
            TableRelation = State;
        }
    }
}