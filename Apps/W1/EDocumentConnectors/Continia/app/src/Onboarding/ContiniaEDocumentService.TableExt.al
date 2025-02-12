// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument;

tableextension 6390 "Continia E-Document Service" extends "E-Document Service"
{
    fields
    {
        field(6390; "No. Of Network Profiles"; Integer)
        {
            CalcFormula = count("Continia Activated Net. Prof." where("E-Document Service Code" = field(Code)));
            Caption = 'No. Of Network Profiles';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}