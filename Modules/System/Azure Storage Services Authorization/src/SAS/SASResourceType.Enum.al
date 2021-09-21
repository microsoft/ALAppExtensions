// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Defines the possible resource types for account SAS.
/// See: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas#specifying-account-sas-parameters
/// </summary>
enum 9063 "SAS Resource Type"
{
    Access = Public;
    Extensible = false;

    value(0; Service)
    {
        Caption = 's', Locked = true;
    }
    value(1; Container)
    {
        Caption = 'c', Locked = true;
    }
    value(2; Object)
    {
        Caption = 'o', Locked = true;
    }
}