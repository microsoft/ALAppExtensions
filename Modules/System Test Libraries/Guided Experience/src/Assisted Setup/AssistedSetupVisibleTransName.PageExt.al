// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Environment.Configuration;

using System.Environment.Configuration;

pageextension 132586 AssistedSetupVisibleTransName extends "Assisted Setup"
{
    layout
    {
        modify(TranslatedName)
        {
            Visible = true;
        }
    }
}
