// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;

tableextension 71107792 "B2Brouter E-Document" extends Microsoft.EServices.EDocument."E-Document"
{
    fields
    {
        field(71107792; "B2Brouter File Id"; Integer)
        {
            Caption = 'File Id';
            DataClassification = CustomerContent;
        }
    }
}