// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enum 5280 "SAF-T Modification" implements XmlDataHandlingSAFT, CreateStandardDataSAFT, DataUpgradeSAFT, DataCheckSAFT
{
    Extensible = true;

    DefaultImplementation = DataUpgradeSAFT = "Data Upgrade SAF-T",
                            DataCheckSAFT = "Data Check SAF-T";

    value(0; None)
    {
        Implementation = XmlDataHandlingSAFT = "Xml Data Handling SAF-T",
                         CreateStandardDataSAFT = "Create Standard Data SAF-T";
    }
}
