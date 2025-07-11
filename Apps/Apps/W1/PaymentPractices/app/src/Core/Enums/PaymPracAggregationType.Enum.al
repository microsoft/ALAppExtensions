// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

enum 685 "Paym. Prac. Aggregation Type" implements PaymentPracticeLinesAggregator
{
    Extensible = true;

    value(1; Period)
    {
        Implementation = PaymentPracticeLinesAggregator = "Paym. Prac. Period Aggregator";
    }
    value(2; "Company Size")
    {
        Implementation = PaymentPracticeLinesAggregator = "Paym. Prac. Size Aggregator";
    }
}
