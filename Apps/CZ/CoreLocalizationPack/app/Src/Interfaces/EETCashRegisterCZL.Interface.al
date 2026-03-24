// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

interface "EET Cash Register CZL"
{
    /// <summary>
    /// Returns the cash register name.
    /// </summary>
    /// <param name="CashRegisterNo">Cash register number.</param>
    /// <returns>Cash register name.</returns>
    procedure GetCashRegisterName(CashRegisterNo: Code[20]): Text[100]

    /// <summary>
    /// Show the lookup page of cash registers for cash register no. field.
    /// </summary>
    /// <param name="CashRegisterNo">Cash register number</param>
    /// <returns>True if the lookup page confirmed choice.</returns>
    procedure LookupCashRegisterNo(var CashRegisterNo: Code[20]): Boolean

    /// <summary>
    /// Show the page of document of cash register.
    /// </summary>
    /// <param name="CashRegisterNo">Cash register number</param>
    /// <param name="DocumentNo">Document number</param>
    procedure ShowDocument(CashRegisterNo: Code[20]; DocumentNo: Code[20])
}
