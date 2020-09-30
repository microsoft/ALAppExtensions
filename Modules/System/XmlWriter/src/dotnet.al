// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("mscorlib")
    {
        type("System.Text.StringBuilder"; "StringBuilder") { }
        type("System.IO.StringWriter"; "StringWriter") { }
        type("System.Xml.XmlTextWriter"; "XmlTextWriter") { }
    }
}
