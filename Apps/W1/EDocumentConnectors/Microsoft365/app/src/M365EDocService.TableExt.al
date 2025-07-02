// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Processing.Import;

tableextension 6381 "M365 E-Doc. Service" extends "E-Document Service"
{
    fields
    {
        modify("Service Integration V2")
        {
            trigger OnAfterValidate()
            begin
                if not (Rec."Service Integration V2" in [
                    Enum::"Service Integration"::OneDrive,
                    Enum::"Service Integration"::Outlook,
                    Enum::"Service Integration"::SharePoint
                ]) then
                    exit;
                Rec."Import Process" := Enum::"E-Document Import Process"::"Version 2.0";
                Rec.Modify();
            end;
        }
    }
}