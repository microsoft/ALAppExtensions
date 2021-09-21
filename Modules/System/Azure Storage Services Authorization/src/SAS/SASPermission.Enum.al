// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Defines the possible permissions for account SAS.
/// See: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas#account-sas-permissions-by-operation
/// </summary>
enum 9064 "SAS Permission"
{
    Access = Public;
    Extensible = false;

    value(0; Read)
    {
        Caption = 'r', Locked = true;
    }

    value(1; Add)
    {
        Caption = 'a', Locked = true;
    }

    value(2; Create)
    {
        Caption = 'c', Locked = true;
    }

    value(3; Write)
    {
        Caption = 'w', Locked = true;
    }

    value(4; Delete)
    {
        Caption = 'd', Locked = true;
    }

    value(5; List)
    {
        Caption = 'l', Locked = true;
    }

    value(6; "Permanent Delete")
    {
        Caption = 'y', Locked = true;
    }

    value(7; Update)
    {
        Caption = 'u', Locked = true;
    }

    value(8; Process)
    {
        Caption = 'p', Locked = true;
    }
}