// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Defines the possible service types for account SAS
/// More Information: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas#specifying-account-sas-parameters
/// </summary>
enum 9062 "SAS Service Type"
{
    Access = Public;
    Extensible = false;

    value(0; Blob)
    {
        Caption = 'b', Locked = true;
    }
    value(1; Queue)
    {
        Caption = 'q', Locked = true;
    }
    value(2; Table)
    {
        Caption = 't', Locked = true;
    }
    value(3; File)
    {
        Caption = 'f', Locked = true;
    }
}