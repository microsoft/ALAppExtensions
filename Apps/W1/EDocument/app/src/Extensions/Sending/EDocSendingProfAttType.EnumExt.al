// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;

enumextension 6103 "E-Doc. Sending Prof. Att. Type" extends "Document Sending Profile Attachment Type"
{
    value(6100; "E-Document")
    {
        Caption = 'E-Document';
    }
    value(6101; "PDF & E-Document")
    {
        Caption = 'PDF & E-Document';
    }
}