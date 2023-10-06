// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Describes possible values for file attributes.
/// For the list of possible values see: https://learn.microsoft.com/en-us/rest/api/storageservices/create-file#file-system-attributes
/// </summary>
enum 8955 "AFS File Attribute"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// Indicates that the file is read-only.
    /// </summary>
    value(0; "Read Only")
    {
        Caption = 'ReadOnly', Locked = true;
    }
    /// <summary>
    /// Indicates that the file is hidden, and thus is not included in an ordinary directory listing.
    /// </summary>
    value(1; Hidden)
    {
        Caption = 'Hidden', Locked = true;
    }
    /// <summary>
    /// Indicates that the file is used by the operating system.
    /// </summary>
    value(2; System)
    {
        Caption = 'System', Locked = true;
    }
    /// <summary>
    /// Indicates that the there are no attributes.
    /// </summary>
    value(3; "None")
    {
        Caption = 'None', Locked = true;
    }
    /// <summary>
    /// Indicates that the file is an archive file. Applications use this attribute to mark files for backup or removal.
    /// </summary>
    value(4; Archive)
    {
        Caption = 'Archive', Locked = true;
    }
    /// <summary>
    /// Indicates that the file is temporary. File systems attempt to keep all of the data in memory for quicker access rather than flushing the data back to mass storage. A temporary file should be deleted by the application as soon as it is no longer needed.
    /// </summary>
    value(5; "Temporary")
    {
        Caption = 'Temporary', Locked = true;
    }
    /// <summary>
    /// Indicates that the file is offline. The data of the file is not immediately available.
    /// </summary>
    value(6; Offline)
    {
        Caption = 'Offline', Locked = true;
    }
    /// <summary>
    /// Indicates that the file will not be indexed by the content indexing service.
    /// </summary>
    value(7; "Not Content Indexed")
    {
        Caption = 'NotContentIndexed', Locked = true;
    }
    /// <summary>
    /// Indicates that the file should not be read by background data integrity scanner.
    /// </summary>
    value(8; "No Scrub Data")
    {
        Caption = 'NoScrubData', Locked = true;
    }
}