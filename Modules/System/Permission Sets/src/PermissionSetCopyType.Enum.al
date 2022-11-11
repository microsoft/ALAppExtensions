// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 9863 "Permission Set Copy Type"
{
    Extensible = false;

    value(0; Reference)
    {
        Caption = 'Copy by reference';
    }

    value(1; Flat)
    {
        Caption = 'Flat permission copy';
    }

    value(2; Clone)
    {
        Caption = 'Clone';
    }
}