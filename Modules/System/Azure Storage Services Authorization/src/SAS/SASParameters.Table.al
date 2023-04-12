// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Optional parameters for Shared Access Signature authorization for Azure Storage Services.
/// see: https://go.microsoft.com/fwlink/?linkid=2210398
/// </summary>
table 9064 "SAS Parameters"
{
    Access = Public;
    Extensible = false;
    TableType = Temporary;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        /// <summary>
        /// Specifies the storage service version to use to execute the request made using the account SAS URI.
        /// </summary>
        field(1; ApiVersion; Enum "Storage Service API Version")
        {
            DataClassification = SystemMetadata;
            InitValue = "2020-10-02";
        }

        /// <summary>
        /// The time at which the SAS becomes valid, expressed in one of the accepted ISO 8601 UTC formats. If omitted, the start time is assumed to be the time when the storage service receives the request.
        /// </summary>
        field(2; SignedStart; DateTime)
        {
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Specifies an IP address or a range of IP addresses from which to accept requests. When specifying a range, note that the range is inclusive.
        /// </summary>
        field(3; SignedIp; Text[2048])
        {
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// Specifies the protocol permitted for a request made with the account SAS. Possible values are both HTTPS and HTTP (https,http) or HTTPS only (https)
        /// </summary>
        /// <remarks>Note that HTTP only is not a permitted value.</remarks>
        field(4; SignedProtocol; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = "https&http","https";
            OptionCaption = '"https and http",https', Locked = true;
        }

        /// <summary>
        /// Indicates the encryption scope to use to encrypt the request contents.
        /// This field is supported with version 2020-12-06 and later.
        /// See also: https://learn.microsoft.com/en-us/rest/api/storageservices/create-account-sas#specify-the-encryption-scope
        /// The name of the encryption scope within the specified storage account. Encryption scope names must be between 3 and 63 characters in length and use numbers, lower-case letters and dash (-) only
        /// Every dash (-) character must be immediately preceded and followed by a letter or number.
        /// See also: https://learn.microsoft.com/en-us/rest/api/storagerp/encryption-scopes/put?tabs=HTTP#uri-parameters
        /// </summary>
        field(5; SignedEncryptionScope; Text[63])
        {
            DataClassification = SystemMetadata;
        }
    }
}