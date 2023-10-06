// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Email;

using System.Email;

pageextension 134487 "Email Editor Ext" extends "Email Editor"
{
    trigger OnOpenPage()
    var
        EmailEditorValues: Codeunit "Email Editor Values";
    begin
        DefaultExitOption := EmailEditorValues.GetDefaultExitOption();
    end;
}