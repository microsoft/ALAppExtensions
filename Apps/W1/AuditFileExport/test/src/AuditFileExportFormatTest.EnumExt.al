// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Test.Finance.AuditFileExport;

using Microsoft.Finance.AuditFileExport;

enumextension 148035 "Audit File Export Format Test" extends "Audit File Export Format"
{
    value(148035; TEST)
    {
        Caption = 'TEST';
        Implementation = "Audit File Export Data Handling" = "Data Handling Test",
                         "Audit File Export Data Check" = "Data Check Test";
    }
}