// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Common setting used when encoding 2D barcodes.
/// </summary>
table 9204 "Barcode Encode Settings 2D"
{
    Access = Public;
    Extensible = true;
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        /// <summary>
        /// Error Correction Level option used by QR code symbology.
        /// </summary>
        field(1; "Error Correction Level"; Option)
        {
            OptionMembers = "High","Medium","Low","Quartile";
            InitValue = "Medium";
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Module Size option used by QR code symbology.
        /// </summary>
        field(2; "Module Size"; Integer)
        {
            InitValue = 5;
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Quite Zone Width option used by QR code symbology.
        /// </summary>
        field(3; "Quite Zone Width"; Integer)
        {
            Caption = 'Quiet Zone Width';
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Code Page option used by QR code symbology.
        /// </summary>
        field(4; "Code Page"; Integer)
        {
            InitValue = 932;
            DataClassification = SystemMetadata;
        }
    }
}
