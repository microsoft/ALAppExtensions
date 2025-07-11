// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.PostingHandler;

enum 20334 "Posting Field Symbol"
{
    Extensible = true;

    value(1; "Gen. Bus. Posting Group") { }
    value(2; "Gen. Prod. Posting Group") { }
    value(3; "Dimension Set ID") { }
    value(4; "G/L Entry No.") { }
    value(5; "Posted Document No.") { }
    value(6; "Posted Document Line No.") { }
    value(7; "G/L Entry Transaction No.") { }
}
