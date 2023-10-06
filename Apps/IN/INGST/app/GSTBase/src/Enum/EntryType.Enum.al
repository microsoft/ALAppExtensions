// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18017 "Entry Type"
{
    value(0; "Initial Entry")
    {
        Caption = 'Initial Entry';
    }
    value(1; Application)
    {
        Caption = 'Application';
    }
}
