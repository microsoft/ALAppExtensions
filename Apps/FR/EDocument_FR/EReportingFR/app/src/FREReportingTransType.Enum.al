// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

enum 10972 "FR E-Reporting Trans. Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "B2C")
    {
        Caption = 'Business-to-consumer';
    }
    value(2; "Cross-Border B2B")
    {
        Caption = 'Cross-border business-to-business';
    }
    value(3; "Export")
    {
        Caption = 'Exports outside of EU';
    }
    value(4; "Intra-Community")
    {
        Caption = 'Intra-community deliveries and acquisitions';
    }
    value(5; "Overseas Territory")
    {
        Caption = 'Transactions involving overseas territories';
    }
}
