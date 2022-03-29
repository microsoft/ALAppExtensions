// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The types of allowed lease operations
/// See: https://docs.microsoft.com/en-us/rest/api/storageservices/blob-service-rest-api
/// </summary>
enum 9049 "ABS Lease Action"
{
    Access = Internal;
    Extensible = false;

    /// <summary>
    /// Requests a new lease.
    /// </summary>
    value(0; Acquire)
    {
        Caption = 'acquire', Locked = true;
    }

    /// <summary>
    /// Renews the lease.
    /// </summary>
    value(1; Renew)
    {
        Caption = 'renew', Locked = true;
    }

    /// <summary>
    /// Changes the lease ID of an active lease.
    /// </summary>
    value(2; Change)
    {
        Caption = 'change', Locked = true;
    }

    /// <summary>
    /// Releases the lease
    /// </summary>
    value(3; Release)
    {
        Caption = 'release', Locked = true;
    }

    /// <summary>
    /// Breaks the lease, if the blob has an active lease
    /// </summary>
    value(4; Break)
    {
        Caption = 'break', Locked = true;
    }
}