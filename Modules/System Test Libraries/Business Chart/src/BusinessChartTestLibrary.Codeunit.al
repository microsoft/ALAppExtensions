// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Test library for the Business Chart module.
/// </summary>
codeunit 135103 "Business Chart Test Library"
{
    /// <summary>
    /// Exposes the ability to export the underlying data table from Business Chart.
    /// </summary>
    /// <param name="BusinessChart">An instance Business Chart with the data table to export.</param>
    /// <param name="DotNetXMLDocument">The resulting XML document.</param>
    procedure WriteToXMLDocument(BusinessChart: Codeunit "Business Chart"; DotNetXMLDocument: DotNet XmlDocument)
    begin
        BusinessChart.WriteToXMLDocument(DotNetXMLDocument);
    end;
}