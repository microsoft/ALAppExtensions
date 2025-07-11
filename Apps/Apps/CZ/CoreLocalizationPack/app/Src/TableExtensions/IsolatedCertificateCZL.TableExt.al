// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.Encryption;

tableextension 11783 "Isolated Certificate CZL" extends "Isolated Certificate"
{
    fields
    {
        field(31140; "Certificate Code CZL"; Code[20])
        {
            Caption = 'Certificate Code';
            Editable = false;
            TableRelation = "Certificate Code CZL";
            DataClassification = CustomerContent;
        }
    }
}
