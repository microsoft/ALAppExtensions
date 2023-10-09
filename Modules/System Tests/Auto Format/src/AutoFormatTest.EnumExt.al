// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Text;

using System.Text;
#pragma warning disable AS0099
enumextension 132584 AutoFormatTest extends "Auto Format"
{
    value(100; Whatever)
    {
        caption = 'Whatever';
    }
    value(1000; "1 decimal")
    {
        Caption = '1 decimal';
    }
}
#pragma warning restore AS0099
