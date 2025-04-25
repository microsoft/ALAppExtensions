// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Foundation.Address;

xmlport 31220 "Contoso Post Code CZ"
{
    Caption = 'Contoso Post Code';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = ';';
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Post Code"; "Post Code")
            {
                XmlName = 'PostCodes';
                fieldelement(code; "Post Code".Code)
                {
                }
                fieldelement(city; "Post Code".City)
                {
                    MinOccurs = Zero;
                }
                fieldelement(country; "Post Code"."Country/Region Code")
                {
                }
                fieldelement(county; "Post Code".County)
                {
                    MinOccurs = Zero;
                }
            }
        }
    }
}

