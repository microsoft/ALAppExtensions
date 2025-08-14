// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;

enumextension 13911 "OIOUBL EDoc Read into Draft" extends "E-Doc. Read into Draft"
{
    value(13910; "OIOUBL")
    {
        Caption = 'OIOUBL';
        Implementation = IStructuredFormatReader = "E-Document OIOUBL Handler";
    }
}
