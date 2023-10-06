// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enumextension 13687 "SAF-T Modification DK" extends "SAF-T Modification"
{
    value(13687; DK)
    {
        Caption = 'SAF-T Denmark';
        Implementation = XmlDataHandlingSAFT = "Xml Data Handling SAF-T DK",
                         CreateStandardDataSAFT = "Create Standard Data SAF-T DK",
                         DataCheckSAFT = "Data Check SAF-T DK";
    }
}
