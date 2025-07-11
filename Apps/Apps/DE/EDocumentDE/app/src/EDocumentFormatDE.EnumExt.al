// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.IO.Peppol;

enumextension 13914 "E-Document Format DE" extends "E-Document Format"
{
#pragma warning disable AS0125
    value(13914; "XRechnung")
    {
        Caption = 'XRechnung';
        Implementation = "E-Document" = "XRechnung Format";
    }
#pragma warning restore AS0125
    value(13915; "PEPPOL BIS 3.0 DE")
    {
        Caption = 'PEPPOL BIS 3.0 DE';
        Implementation = "E-Document" = "EDoc PEPPOL BIS 3.0 DE";
    }
    value(13916; ZUGFeRD)
    {
        Implementation = "E-Document" = "ZUGFeRD Format";
        Caption = 'ZUGFeRD';
    }
}