// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.IO;

using System.Security.AccessControl;

tableextension 13661 "OIOUBL-Record Export Buffer" extends "Record Export Buffer"
{
    fields
    {
        field(13630; "OIOUBL-User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User ID';
            TableRelation = User."User Name";
            Editable = false;
        }
    }
}
