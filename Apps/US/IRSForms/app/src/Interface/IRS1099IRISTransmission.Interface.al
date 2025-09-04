// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

/// <summary>
/// The interface to prepare submission 1099 forms to IRS electronically using Information Returns Intake System (IRIS).
/// </summary>
interface "IRS 1099 IRIS Transmission"
{
    /// <summary>
    /// Creates a new transmission record for the given period. This record will be used later to create the XML file that is sent to the IRS using IRIS.
    /// </summary>
    /// <param name="Transmission"> The transmission record to be created. </param>
    /// <param name="PeriodNo"> The period number for which the transmission is created. </param>
    procedure CreateTransmission(var Transmission: Record "Transmission IRIS"; PeriodNo: Text[4])

    /// <summary>
    /// Checks if the original transmission is ready to be submitted to the IRS.
    /// </summary>
    /// <param name="Transmission"> The transmission record to be checked. </param>
    procedure CheckOriginalTransmission(var Transmission: Record "Transmission IRIS")

    /// <summary>
    /// Checks if the replacement transmission is ready to be submitted to the IRS.
    /// </summary>
    /// <param name="Transmission"> The transmission record to be checked. </param>
    procedure CheckReplacementTransmission(var Transmission: Record "Transmission IRIS")

    /// <summary>
    /// Checks if the correction transmission is ready to be submitted to the IRS.
    /// </summary>
    /// <param name="Transmission"> The transmission record to be checked. </param>
    procedure CheckCorrectionTransmission(var Transmission: Record "Transmission IRIS")

    /// <summary>
    /// Checks if the data that is submitted to the IRS is correct and complete according to IRIS documentation.
    /// </summary>
    /// <param name="Transmission"> The transmission record to be checked. </param>
    procedure CheckDataToReport(var Transmission: Record "Transmission IRIS")
}