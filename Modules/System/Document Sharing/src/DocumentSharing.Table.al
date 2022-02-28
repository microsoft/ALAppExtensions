// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Table containing the required state for document sharing.
/// </summary>
table 9560 "Document Sharing"
{
    TableType = Temporary;
    Access = Public;
    Extensible = false;

    fields
    {
        /// <summary>
        /// Specifies the unique id of this record.
        /// </summary>
        field(1; Id; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        /// <summary>
        /// Specifies the blob data to be shared (e.g. a report pdf).
        /// </summary>
        field(2; Data; Blob)
        {
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Specifies the filename of the document (with file extension).
        /// This will be used for uploading and also displayed in the share experience.
        /// </summary>
        field(3; Name; Text[2048])
        {
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Specifies the filename extension (e.g. '.pdf').
        /// This is required to display the share experience.
        /// </summary>
        field(4; Extension; Text[2048])
        {
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Specifies the Document Service token.
        /// This is required to display the share experience.
        /// </summary>
        field(5; Token; Blob)
        {
            DataClassification = EndUserIdentifiableInformation;
        }

        /// <summary>
        /// Specifies the root location of the document.
        /// This is typically the store used by the Document Service.
        /// </summary>
        field(6; DocumentRootUri; Text[2048])
        {
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Specifies the location of where the document has been uploaded.
        /// Navigating here will allow the user to download the file.
        /// </summary>
        field(7; DocumentUri; Text[2048])
        {
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Specifies the preview location.
        /// Navigating here will allow the user to preview the document in a browser.
        /// </summary>
        field(8; DocumentPreviewUri; Text[2048])
        {
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Specifies the sharing intent of the document.
        /// </summary>
        field(9; "Document Sharing Intent"; Enum "Document Sharing Intent")
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}