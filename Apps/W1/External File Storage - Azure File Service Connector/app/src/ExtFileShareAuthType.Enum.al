// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

enum 4570 "Ext. File Share Auth. Type"
{
    Access = Internal;

    value(0; SasToken)
    {
        Caption = 'Shared Access Signature';
    }
    value(1; SharedKey)
    {
        Caption = 'Shared Key';
    }
}
