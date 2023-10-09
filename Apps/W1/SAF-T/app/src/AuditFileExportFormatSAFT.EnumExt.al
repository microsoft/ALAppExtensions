// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enumextension 5280 "Audit File Export Format SAF-T" extends "Audit File Export Format"
{
    value(5280; SAFT)
    {
        Caption = 'SAF-T';
        Implementation = "Audit File Export Data Handling" = "Audit Data Handling SAF-T",
                         "Audit File Export Data Check" = "Audit Data Check SAF-T";
    }
}
