// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

/// <summary>
/// The interface to create xml file content to submit 1099 forms to IRS electronically using Information Returns Intake System (IRIS).
/// </summary>
interface "IRS 1099 IRIS Xml"
{
    /// <summary>
    /// Creates the content of the XML file that is sent to the IRS using IRIS.
    /// </summary>
    /// <param name="Transmission"> The transmission record from which the XML file content is created. </param>
    /// <param name="TransmissionType"> The type of the transmission which determines how the data should be processed and transmitted. The possible values are Original, Correction, and Replacement. </param>
    /// <param name="CorrectionToZeroMode"> Defines if all the amounts in the correction transmission should be set to zero. </param>
    /// <param name="UniqueTransmissionId"> Returns the unique transmission identifier that is defined when the transmission XML file is created. </param>
    /// <param name="TempIRS1099FormDocHeader"> A temporary record that contains the documents that were included in the transmission. </param>
    /// <param name="TempBlob"> The temporary blob in which the XML file content is returned. </param>
    procedure CreateTransmissionXmlContent(var Transmission: Record "Transmission IRIS"; TransmissionType: Enum "Transmission Type IRIS"; CorrectionToZeroMode: Boolean; var UniqueTransmissionId: Text[100]; var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; var TempBlob: Codeunit "Temp Blob")

    /// <summary>
    /// Creates an XML request to get the status of a previously submitted transmission. Response will contain status only and NOT error details.
    /// </summary>
    /// <param name="SearchParamType">Defines what ID is used to obtain the status. Options: RID (Receipt ID), UTID (Unique Transmission ID).</param>
    /// <param name="SearchId">The identifier value to search for (either a Receipt ID or a Unique Transmission ID).</param>
    /// <param name="TempBlob">The temporary blob in which the XML request content is returned.</param>
    procedure CreateGetStatusRequestXmlContent(SearchParamType: Enum "Search Param Type IRIS"; SearchId: Text; var TempBlob: Codeunit "Temp Blob")

    /// <summary>
    /// Creates an XML request to get the acknowledgment (status and error details) for a previously submitted transmission.
    /// </summary>
    /// <param name="SearchParamType">Defines what ID is used to obtain the transmission acknowledgment. Options: RID (Receipt ID), UTID (Unique Transmission ID).</param>
    /// <param name="SearchId">The identifier value to search for (either a Receipt ID or a Unique Transmission ID).</param>
    /// <param name="TempBlob">The temporary blob in which the XML request content is returned.</param>
    procedure CreateAcknowledgmentRequestXmlContent(SearchParamType: Enum "Search Param Type IRIS"; SearchId: Text; var TempBlob: Codeunit "Temp Blob")
}