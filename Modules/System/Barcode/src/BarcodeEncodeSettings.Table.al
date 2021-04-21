// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Common setting used when encoding barcodes.
/// </summary>
table 9203 "Barcode Encode Settings"
{
    Access = Public;
    Extensible = true;
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        /// <summary>
        /// Code set option used by Code128 symbology
        /// </summary>
        field(1; "Code Set"; Option)
        {
            OptionMembers = "None","A","B","C";
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Setting used in Code39 and Code93 symbologies.
        /// </summary>
        field(2; "Allow Extended Charset"; Boolean)
        {
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Flag to indicate whether to enable checksum when encoding the barcode.
        /// Used by barcode symbology Code39.
        /// </summary>
        field(3; "Enable Checksum"; Boolean)
        {
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Barcode symbology Interleaved 2 of 5 setting.
        /// </summary>
        field(4; "Use mod 10"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }
}

