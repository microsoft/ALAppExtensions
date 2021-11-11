// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enumextension 132586 "Assisted Setup Test Group" extends "Assisted Setup Group"
{
#pragma warning disable AS0013 - The IDs should have been within the ranges [132585..132588], [132594..132594], [132607..132609], [134934..134934]
    value(100; WithLinks)
    {
        Caption = 'WithLinks';
    }

    value(200; WithoutLinks)
    {
        Caption = 'WithoutLinks';
    }

    value(300; ZZ)
    {
        Caption = 'Last group alphabetically';
    }
#pragma warning restore AS0013 - The IDs should have been within the ranges [132585..132588], [132594..132594], [132607..132609], [134934..134934]
}