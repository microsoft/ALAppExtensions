// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

enum 11744 "Reg. Log Detail Field CZL"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; Name)
    {
        Caption = 'Name';
    }
    value(1; Address)
    {
        Caption = 'Address';
    }
    value(2; City)
    {
        Caption = 'City';
    }
    value(3; "Post Code")
    {
        Caption = 'Post Code';
    }
    value(4; "VAT Registration No.")
    {
        Caption = 'VAT Registration No.';
    }
    value(5; "Country/Region Code")
    {
        Caption = 'Country/Region Code';
    }
}
