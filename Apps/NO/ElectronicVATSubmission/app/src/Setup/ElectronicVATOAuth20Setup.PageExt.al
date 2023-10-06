// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.Authentication;

pageextension 10698 "Electronic VAT OAuth 2.0 Setup" extends "OAuth 2.0 Setup"
{
    layout
    {
        modify(General)
        {
            Editable = true;
        }
        modify("Service URL")
        {
            Editable = true;
        }
        modify("Redirect URL")
        {
            Editable = true;
        }
        modify(Scope)
        {
            Editable = true;
        }
        modify("Authorization URL Path")
        {
            Editable = true;
        }
        modify("Access Token URL Path")
        {
            Editable = true;
        }
    }
}
