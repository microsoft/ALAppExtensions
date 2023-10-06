// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

tableextension 27033 "DIOT Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(27030; "DIOT Type of Operation"; Option)
        {
            Caption = 'DIOT Type of Operation';
            OptionMembers = " ","Prof. Services","Lease and Rent",Others;
            OptionCaption = ' ,Prof. Services,Lease and Rent,Others';
        }
    }
}
