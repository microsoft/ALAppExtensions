// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

interface PaymentPracticeLinesAggregator
{
    /// <summary>
    /// Prepare the layout to be used for Payment Practice report that is suitable for the aggregation type of the header/lines.
    /// </summary>
    procedure PrepareLayout()

    /// <summary>
    /// Generate the lines for the Payment Practice report based on the Payment Practice Data raw data and Payment Practice Header fields.
    /// </summary>
    /// <param name="PaymentPracticeData">Raw data generated with DataGenerator, based on header type.</param>
    /// <param name="PaymentPracticeHeader">The document to link lines to and take configuration from.</param>
    procedure GenerateLines(var PaymentPracticeData: Record "Payment Practice Data"; PaymentPracticeHeader: Record "Payment Practice Header")

    /// <summary>
    /// Validate if the Payment Practice Header is suitable for the aggregation type of the header/lines.
    /// </summary>
    /// <param name="PaymentPracticeHeader">The document header that needs checking.</param>
    procedure ValidateHeader(var PaymentPracticeHeader: Record "Payment Practice Header")
}
