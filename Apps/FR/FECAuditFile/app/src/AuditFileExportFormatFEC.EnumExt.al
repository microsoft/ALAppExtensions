// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enumextension 10826 "Audit File Export Format FEC" extends "Audit File Export Format"
{
    value(10826; FEC)
    {
        Caption = 'FEC';
        Implementation = "Audit File Export Data Handling" = "Data Handling FEC",
                         "Audit File Export Data Check" = "Data Check FEC";
    }
}
