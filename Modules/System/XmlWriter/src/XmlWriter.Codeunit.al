// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for System.Xml.XmlWriter
/// </summary>
codeunit 1483 "XmlWriter"
{
    Access = Public;

    /// <summary>
    /// Creates the XmlWriter Document
    /// </summary>
    procedure WriteStartDocument()
    begin
        XmlWriterImpl.WriteStartDocument();
    end;

    /// <summary>
    /// When overridden in a derived class, closes any open elements or attributes and puts the writer back in the Start state.
    /// </summary>
    procedure WriteEndDocument()
    begin
        XmlWriterImpl.WriteEndDocument();
    end;

    /// <summary>
    /// Writes the text within XmlWriter to the BigText variable. 
    /// </summary>
    /// <param name="XmlBigText">The BigText the XmlWriter has to be write to.</param>
    procedure ToBigText(var XmlBigText: BigText)
    begin
        Clear(XmlBigText);
        XmlWriterImpl.ToBigText(XmlBigText)
    end;

    var
        XmlWriterImpl: Codeunit "XmlWriter Impl";
}