// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Formats;
using Microsoft.eServices.EDocument.Processing.Interfaces;

enumextension 13917 "XRechnung EDoc Read into Draft" extends "E-Doc. Read into Draft"
{
    value(13914; "XRechnung")
    {
        Caption = 'XRechnung';
        Implementation = IStructuredFormatReader = "E-Document XRechnung Handler";
    }
}
